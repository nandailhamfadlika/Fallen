class_name CharacterSelect
extends Control

## Character Select Screen - 4-Player Dynamic Drop-In Lobby (VS Mode)
## Supports Keyboard WASD, Keyboard Arrows, and Gamepads 0..3

const PlayerInputScript = preload("res://src/core/PlayerInput.gd")

const CHARACTERS = [
	{
		"id": "aron",
		"name": "ARON",
		"title": "Speed Brawler",
		"portrait": "res://assets/ui/portraits/portrait_aron.png",
		"preview": "res://assets/characters/aron/idle/idle_01.png",
		"color": Color(0.2, 0.85, 1.0),
		"locked": false
	},
	{
		"id": "om_hami",
		"name": "OM HAMI",
		"title": "Cane Martial Zoner",
		"portrait": "res://assets/ui/portraits/portrait_om_hami.png",
		"preview": "res://assets/characters/om_hami/idle/idle_01.png",
		"color": Color(1.0, 0.75, 0.2),
		"locked": false
	},
	{
		"id": "kemet",
		"name": "KEMET",
		"title": "Claw Assassin",
		"portrait": "res://assets/ui/portraits/portrait_kemet.png",
		"preview": "res://assets/characters/kemet/idle/idle_01.png",
		"color": Color(0.95, 0.35, 0.25),
		"locked": false
	},
	{
		"id": "butler",
		"name": "BUTLER",
		"title": "Cloth Flame Vanguard",
		"portrait": "res://assets/ui/portraits/portrait_butler.png",
		"preview": "res://assets/characters/butler/idle/idle_01.png",
		"color": Color(1.0, 0.82, 0.35),
		"locked": false
	},
	{
		"id": "mike",
		"name": "MIKE",
		"title": "College Chair Vanguard",
		"portrait": "res://assets/ui/portraits/portrait_mike.png",
		"preview": "res://assets/characters/mike/idle/idle_01.png",
		"color": Color(0.95, 0.65, 0.25),
		"locked": false
	},
	{
		"id": "muslan",
		"name": "MUSLAN",
		"title": "The Southern Troubadour",
		"portrait": "res://assets/ui/portraits/portrait_muslan.png",
		"preview": "res://assets/ui/portraits/portrait_muslan.png",
		"color": Color(0.5, 0.75, 0.9),
		"locked": true
	},
	{
		"id": "rin",
		"name": "RIN",
		"title": "The Mystic Weaver",
		"portrait": "res://assets/ui/portraits/portrait_rin.png",
		"preview": "res://assets/ui/portraits/portrait_rin.png",
		"color": Color(0.9, 0.45, 0.7),
		"locked": true
	},
	{
		"id": "sunkibo",
		"name": "SUNKIBO",
		"title": "The Ignored Scion",
		"portrait": "res://assets/ui/portraits/portrait_sunkibo.png",
		"preview": "res://assets/ui/portraits/portrait_sunkibo.png",
		"color": Color(0.9, 0.6, 0.2),
		"locked": true
	}
]

const PLAYER_COLORS = [
	Color(0.2, 0.85, 1.0),   # P1 Cyan
	Color(1.0, 0.35, 0.2),   # P2 Red / Orange
	Color(0.27, 0.88, 0.36), # P3 Green
	Color(0.82, 0.38, 0.98)  # P4 Purple
]

class PlayerSlotState:
	var player_num: int = 1
	var is_joined: bool = false
	var is_ready: bool = false
	var device_type: String = "" # "keyboard_wasd", "keyboard_arrows", "joypad"
	var device_id: int = -1
	var cursor_idx: int = 0
	var input_reader = null
	var card: Control = null
	var cursor: Panel = null
	var just_joined: bool = false

var slots: Array[PlayerSlotState] = []
var transition_started: bool = false

# UI References
@onready var header_title: Label = $HeaderTitle
@onready var grid_container: GridContainer = $GridCenter/GridContainer
@onready var match_status_lbl: Label = $MatchStatusLabel

@onready var player_cards: Array[Control] = [
	$PlayerCard1,
	$PlayerCard2,
	$PlayerCard3,
	$PlayerCard4
]

@onready var player_cursors: Array[Panel] = [
	$GridCenter/P1Cursor,
	$GridCenter/P2Cursor,
	$GridCenter/P3Cursor,
	$GridCenter/P4Cursor
]

var slot_nodes: Array[Control] = []
var warning_tween: Tween

func _ready() -> void:
	GameManager.game_mode = "pvp"

	if header_title:
		header_title.text = "SELECT YOUR FIGHTER"

	# Kumpulkan node slot karakter
	slot_nodes.clear()
	for child in grid_container.get_children():
		if child is Control and not child is Panel:
			var idx = slot_nodes.size()
			slot_nodes.append(child)
			child.mouse_filter = Control.MOUSE_FILTER_STOP
			child.gui_input.connect(func(event: InputEvent): _on_slot_gui_input(event, idx))

	# Inisialisasi 4 Player Slot (Semua dimulai unjoined)
	slots.clear()
	for i in range(4):
		var slot = PlayerSlotState.new()
		slot.player_num = i + 1
		slot.card = player_cards[i]
		slot.cursor = player_cursors[i]
		slot.cursor.visible = false
		slot.cursor_idx = i % CHARACTERS.size()
		slots.append(slot)

		player_cards[i].visible = true
		player_cards[i].set_unjoined()

	_update_status_banner()

func _join_player(slot_idx: int, dev_type: String, dev_id: int, initial_char_idx: int = -1) -> void:
	if slot_idx < 0 or slot_idx >= slots.size():
		return

	var slot = slots[slot_idx]
	if slot.is_joined:
		return

	slot.is_joined = true
	slot.is_ready = false
	slot.just_joined = true
	slot.device_type = dev_type
	slot.device_id = dev_id

	if initial_char_idx >= 0:
		slot.cursor_idx = initial_char_idx
	else:
		slot.cursor_idx = slot_idx % CHARACTERS.size()

	# Inisialisasi Input Reader
	slot.input_reader = PlayerInputScript.new()
	match dev_type:
		"keyboard_wasd":
			slot.input_reader.device_type = slot.input_reader.DeviceType.KEYBOARD_WASD
		"keyboard_arrows":
			slot.input_reader.device_type = slot.input_reader.DeviceType.KEYBOARD_ARROWS
		"joypad":
			slot.input_reader.device_type = slot.input_reader.DeviceType.JOYPAD
			slot.input_reader.joypad_id = dev_id

	# Sinkronkan state awal input agar tidak langsung membaca just_pressed di frame join
	slot.input_reader.update()
	slot.input_reader.attack_just_pressed = false
	slot.input_reader.jump_just_pressed = false
	slot.input_reader.dodge_just_pressed = false

	# Tentukan nama device untuk kartu
	var dev_name = "KEYBOARD WASD"
	if dev_type == "keyboard_arrows":
		dev_name = "KEYBOARD ARROWS"
	elif dev_type == "joypad":
		dev_name = "GAMEPAD %d" % (dev_id + 1)

	slot.card.set_joined(dev_name, CHARACTERS[slot.cursor_idx])
	slot.cursor.visible = true

	call_deferred("_update_cursor_position", slot_idx)
	_update_status_banner()

func _leave_player(slot_idx: int) -> void:
	if slot_idx < 0 or slot_idx >= slots.size():
		return

	var slot = slots[slot_idx]
	slot.is_joined = false
	slot.is_ready = false
	slot.just_joined = false
	slot.device_type = ""
	slot.device_id = -1
	slot.input_reader = null
	slot.cursor.visible = false

	slot.card.set_unjoined()
	_update_status_banner()

func _is_device_already_joined(dev_type: String, dev_id: int) -> bool:
	for slot in slots:
		if slot.is_joined:
			if slot.device_type == dev_type and slot.device_id == dev_id:
				return true
	return false

func _find_first_empty_slot() -> int:
	for i in range(slots.size()):
		if not slots[i].is_joined:
			return i
	return -1

func _process(delta: float) -> void:
	if transition_started:
		return

	# ESC untuk kembali ke Main Menu
	if Input.is_action_just_pressed("pause") or Input.is_physical_key_pressed(KEY_ESCAPE):
		GameManager.go_to_main_menu()
		return

	# 1. Cek Join Requests dari perangkat yang belum terdaftar
	_check_drop_in_requests()

	# 2. Proses input untuk tiap pemain yang sudah join
	for i in range(slots.size()):
		var slot = slots[i]
		if not slot.is_joined or slot.input_reader == null:
			continue

		slot.input_reader.update()

		# Jika baru join pada frame ini/sebelumnya, tunggu sampai tombol aksi dilepas
		if slot.just_joined:
			if not slot.input_reader.attack_held and not slot.input_reader.jump_held:
				slot.just_joined = false
			continue

		if not slot.is_ready:
			# Navigasi Grid 4x2
			var move_dir = Vector2i.ZERO
			if slot.input_reader.left_just_pressed:
				move_dir.x = -1
			elif slot.input_reader.right_just_pressed:
				move_dir.x = 1
			elif slot.input_reader.up_just_pressed:
				move_dir.y = -1
			elif slot.input_reader.down_just_pressed:
				move_dir.y = 1

			if move_dir != Vector2i.ZERO:
				slot.cursor_idx = _navigate_grid(slot.cursor_idx, move_dir)
				slot.card.update_character(CHARACTERS[slot.cursor_idx])
				_update_cursor_position(i)

			# Konfirmasi Pilihan (Attack Button / Enter / F)
			if slot.input_reader.attack_just_pressed:
				var char_data = CHARACTERS[slot.cursor_idx]
				if char_data.get("locked", false):
					_show_warning("P%d: Karakter masih dikunci!" % slot.player_num)
				else:
					slot.is_ready = true
					slot.card.set_ready_state(true)
					_check_all_ready()

			# Keluar dari Slot (Dodge Button / Shift / L)
			elif slot.input_reader.dodge_just_pressed:
				_leave_player(i)
		else:
			# Batalkan status READY (Dodge atau Down)
			if slot.input_reader.dodge_just_pressed or slot.input_reader.down_just_pressed:
				slot.is_ready = false
				slot.card.set_ready_state(false)
				_update_status_banner()

func _check_drop_in_requests() -> void:
	# Cek Keyboard WASD Join (Tombol F, Space, J, C)
	if (Input.is_physical_key_pressed(KEY_F) or
		Input.is_physical_key_pressed(KEY_SPACE) or
		Input.is_physical_key_pressed(KEY_J) or
		Input.is_physical_key_pressed(KEY_C)):
		if not _is_device_already_joined("keyboard_wasd", -1):
			var empty_idx = _find_first_empty_slot()
			if empty_idx != -1:
				_join_player(empty_idx, "keyboard_wasd", -1)

	# Cek Keyboard Arrows Join (Tombol Enter, KP_Enter, K, Z)
	if (Input.is_physical_key_pressed(KEY_ENTER) or
		Input.is_physical_key_pressed(KEY_KP_ENTER) or
		Input.is_physical_key_pressed(KEY_K) or
		Input.is_physical_key_pressed(KEY_Z)):
		if not _is_device_already_joined("keyboard_arrows", -1):
			var empty_idx = _find_first_empty_slot()
			if empty_idx != -1:
				_join_player(empty_idx, "keyboard_arrows", -1)

	# Cek Joypad / Gamepad Join (Start, A, B, X)
	for pad_id in Input.get_connected_joypads():
		if (Input.is_joy_button_pressed(pad_id, JOY_BUTTON_START) or
			Input.is_joy_button_pressed(pad_id, JOY_BUTTON_A) or
			Input.is_joy_button_pressed(pad_id, JOY_BUTTON_B) or
			Input.is_joy_button_pressed(pad_id, JOY_BUTTON_X)):
			if not _is_device_already_joined("joypad", pad_id):
				var empty_idx = _find_first_empty_slot()
				if empty_idx != -1:
					_join_player(empty_idx, "joypad", pad_id)

func _navigate_grid(curr: int, dir: Vector2i) -> int:
	# 4 columns x 2 rows
	# [0: Aron]   [1: Om Hami] [2: Kemet]   [3: Butler]
	# [4: Mike]   [5: Muslan]  [6: Rin]     [7: Sunkibo]
	if dir.y > 0: # DOWN
		return (curr + 4) if curr < 4 else (curr - 4)
	elif dir.y < 0: # UP
		return (curr - 4) if curr >= 4 else (curr + 4)
	elif dir.x > 0: # RIGHT
		return (curr - 3) if (curr % 4 == 3) else (curr + 1)
	elif dir.x < 0: # LEFT
		return (curr + 3) if (curr % 4 == 0) else (curr - 1)
	return curr

func _update_cursor_position(slot_idx: int) -> void:
	if slot_idx < 0 or slot_idx >= slots.size():
		return
	var slot = slots[slot_idx]
	if not slot.is_joined or slot.cursor == null or not slot.cursor.visible:
		return

	if slot.cursor_idx >= 0 and slot.cursor_idx < slot_nodes.size():
		var target_node = slot_nodes[slot.cursor_idx]
		var offset = slot_idx * 3
		slot.cursor.global_position = target_node.global_position - Vector2(4 + offset, 4 + offset)
		slot.cursor.size = target_node.size + Vector2(8 + offset * 2, 8 + offset * 2)

func _update_all_cursors() -> void:
	for i in range(slots.size()):
		_update_cursor_position(i)

func _update_status_banner() -> void:
	var joined_count = 0
	var ready_count = 0
	for s in slots:
		if s.is_joined:
			joined_count += 1
			if s.is_ready:
				ready_count += 1

	if joined_count == 0:
		match_status_lbl.text = "PRESS BUTTON TO JOIN (MIN 2 PLAYERS TO BATTLE)"
		match_status_lbl.modulate = Color(1.0, 0.85, 0.35)
	elif joined_count == 1:
		match_status_lbl.text = "1 PLAYER JOINED - WAITING FOR OPPONENTS TO JOIN..."
		match_status_lbl.modulate = Color(1.0, 0.75, 0.3)
	elif ready_count < joined_count:
		match_status_lbl.text = "%d / %d PLAYERS READY - PRESS ATTACK TO READY UP" % [ready_count, joined_count]
		match_status_lbl.modulate = Color(0.3, 0.9, 1.0)
	else:
		match_status_lbl.text = "ALL FIGHTERS READY! ENTERING ARENA..."
		match_status_lbl.modulate = Color(0.2, 1.0, 0.4)

func _check_all_ready() -> void:
	_update_status_banner()
	var joined_count = 0
	var ready_count = 0
	var ready_players: Array[Dictionary] = []

	for s in slots:
		if s.is_joined:
			joined_count += 1
			if s.is_ready:
				ready_count += 1
				ready_players.append({
					"player_id": s.player_num,
					"device_type": s.device_type,
					"device_id": s.device_id,
					"character": CHARACTERS[s.cursor_idx]["id"],
					"color": PLAYER_COLORS[s.player_num - 1]
				})

	if joined_count >= 2 and ready_count == joined_count:
		transition_started = true
		match_status_lbl.text = "ALL FIGHTERS READY! PREPARE FOR BATTLE!"
		match_status_lbl.modulate = Color(1.0, 0.2, 0.2)

		var tween = create_tween()
		tween.tween_property(match_status_lbl, "scale", Vector2(1.2, 1.2), 0.2)
		tween.tween_property(match_status_lbl, "scale", Vector2(1.0, 1.0), 0.2)

		await get_tree().create_timer(1.0).timeout
		GameManager.start_pvp_multi(ready_players)
		GameManager.go_to_stage_select()

func _show_warning(msg: String) -> void:
	if warning_tween and warning_tween.is_valid():
		warning_tween.kill()

	match_status_lbl.text = msg
	match_status_lbl.modulate = Color(1.0, 0.25, 0.25)

	warning_tween = create_tween()
	warning_tween.tween_property(match_status_lbl, "scale", Vector2(1.15, 1.15), 0.1)
	warning_tween.tween_property(match_status_lbl, "scale", Vector2(1.0, 1.0), 0.1)
	warning_tween.tween_interval(1.2)
	warning_tween.tween_callback(func():
		_update_status_banner()
	)

func _on_slot_gui_input(event: InputEvent, idx: int) -> void:
	if transition_started:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Klik kiri untuk Player 1 (Join jika belum join)
			if not slots[0].is_joined:
				_join_player(0, "keyboard_wasd", -1, idx)
			elif not slots[0].is_ready:
				slots[0].cursor_idx = idx
				slots[0].card.update_character(CHARACTERS[idx])
				_update_cursor_position(0)
				if not CHARACTERS[idx].get("locked", false):
					slots[0].is_ready = true
					slots[0].card.set_ready_state(true)
					_check_all_ready()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Klik kanan untuk Player 2 (Join jika belum join)
			if not slots[1].is_joined:
				_join_player(1, "keyboard_arrows", -1, idx)
			elif not slots[1].is_ready:
				slots[1].cursor_idx = idx
				slots[1].card.update_character(CHARACTERS[idx])
				_update_cursor_position(1)
				if not CHARACTERS[idx].get("locked", false):
					slots[1].is_ready = true
					slots[1].card.set_ready_state(true)
					_check_all_ready()
