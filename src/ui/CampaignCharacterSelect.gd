class_name CampaignCharacterSelect
extends Control

## Dedicated Single Player Character Select for Campaign Mode
## Supports full Keyboard (WASD / Arrows), Gamepad, and Mouse control with responsive layout.

const CHARACTERS = [
	{
		"id": "aron",
		"name": "ARON",
		"title": "Speed Brawler",
		"archetype": "✦ SPEED BRAWLER / COMBO RUSHDOWN ✦",
		"lore": "A relentless street brawler who channels electric agility into lightning-quick boxing combos. He sets out into the shattered world to uncover the origin of the Cataclysm.",
		"portrait": "res://assets/ui/portraits/portrait_aron.png",
		"preview": "res://assets/characters/aron/idle/idle_01.png",
		"color": Color(0.2, 0.85, 1.0),
		"speed": "★★★★★",
		"power": "★★★☆☆",
		"range": "★★☆☆☆",
		"tech": "★★★☆☆",
		"locked": false
	},
	{
		"id": "om_hami",
		"name": "OM HAMI",
		"title": "Cane Martial Zoner",
		"archetype": "✦ SPACING ZONER / STAFF MASTER ✦",
		"lore": "A disciplined martial elder wielding an ancestral walking cane. Using calculated reach, sweeps, and deflective strikes, he controls space and punishes reckless foes.",
		"portrait": "res://assets/ui/portraits/portrait_om_hami.png",
		"preview": "res://assets/characters/om_hami/idle/idle_01.png",
		"color": Color(1.0, 0.78, 0.25),
		"speed": "★★☆☆☆",
		"power": "★★★☆☆",
		"range": "★★★★★",
		"tech": "★★★★☆",
		"locked": false
	},
	{
		"id": "kemet",
		"name": "KEMET",
		"title": "Claw Assassin",
		"archetype": "✦ AERIAL HUNTER / CLAW ASSASSIN ✦",
		"lore": "A lethal shadow assassin fighting with twin jagged claw gauntlets. Excels at high-speed lunges, vertical repositioning, and ferocious air-to-ground pursuit.",
		"portrait": "res://assets/ui/portraits/portrait_kemet.png",
		"preview": "res://assets/characters/kemet/idle/idle_01.png",
		"color": Color(0.95, 0.35, 0.25),
		"speed": "★★★★☆",
		"power": "★★★★☆",
		"range": "★★★☆☆",
		"tech": "★★★★☆",
		"locked": false
	},
	{
		"id": "butler",
		"name": "BUTLER",
		"title": "Cloth Flame Vanguard",
		"archetype": "✦ PHANTOM PYRO / TACTICAL VANGUARD ✦",
		"lore": "An impeccably dressed servant commanding phantom blue flames. Combines elegant movement with mid-range fire blasts and refined defensive parries.",
		"portrait": "res://assets/ui/portraits/portrait_butler.png",
		"preview": "res://assets/characters/butler/idle/idle_01.png",
		"color": Color(1.0, 0.82, 0.35),
		"speed": "★★★☆☆",
		"power": "★★★★☆",
		"range": "★★★★☆",
		"tech": "★★★☆☆",
		"locked": false
	},
	{
		"id": "mike",
		"name": "MIKE",
		"title": "College Chair Vanguard",
		"archetype": "✦ ARMORED BRAWLER / HEAVY GRAPPLER ✦",
		"lore": "An eccentric collegiate powerhouse wielding an indestructible steel folding chair. Delivers overwhelming armor, devastating overhead smashes, and massive knockback.",
		"portrait": "res://assets/ui/portraits/portrait_mike.png",
		"preview": "res://assets/characters/mike/idle/idle_01.png",
		"color": Color(0.95, 0.65, 0.25),
		"speed": "★★☆☆☆",
		"power": "★★★★★",
		"range": "★★★☆☆",
		"tech": "★★☆☆☆",
		"locked": false
	},
	{
		"id": "muslan",
		"name": "MUSLAN",
		"title": "The Southern Troubadour",
		"archetype": "✦ SONIC WEAPONEER (LOCKED) ✦",
		"lore": "A wandering minstrel whose melodies conceal devastating sonic shockwaves. Complete Campaign acts to unlock.",
		"portrait": "res://assets/ui/portraits/portrait_muslan.png",
		"preview": "res://assets/ui/portraits/portrait_muslan.png",
		"color": Color(0.5, 0.75, 0.9),
		"speed": "★★★☆☆",
		"power": "★★★☆☆",
		"range": "★★★★☆",
		"tech": "★★★★☆",
		"locked": true
	},
	{
		"id": "rin",
		"name": "RIN",
		"title": "The Mystic Weaver",
		"archetype": "✦ CELESTIAL WEAVER (LOCKED) ✦",
		"lore": "A guardian who weaves astral threads into defensive barriers and binding traps. Complete Campaign acts to unlock.",
		"portrait": "res://assets/ui/portraits/portrait_rin.png",
		"preview": "res://assets/ui/portraits/portrait_rin.png",
		"color": Color(0.9, 0.45, 0.7),
		"speed": "★★★★☆",
		"power": "★★★☆☆",
		"range": "★★★★☆",
		"tech": "★★★★★",
		"locked": true
	},
	{
		"id": "sunkibo",
		"name": "SUNKIBO",
		"title": "The Ignored Scion",
		"archetype": "✦ HIDDEN MONARCH (LOCKED) ✦",
		"lore": "An exile noble who carries ancient sovereign powers sealed within his golden sash. Complete Campaign acts to unlock.",
		"portrait": "res://assets/ui/portraits/portrait_sunkibo.png",
		"preview": "res://assets/ui/portraits/portrait_sunkibo.png",
		"color": Color(0.9, 0.6, 0.2),
		"speed": "★★★★☆",
		"power": "★★★★☆",
		"range": "★★★☆☆",
		"tech": "★★★★☆",
		"locked": true
	}
]

var selected_index: int = 0
var transition_started: bool = false
var button_nodes: Array[Button] = []
var current_device_type: String = "keyboard_wasd"
var current_device_id: int = -1

# Node References
@onready var showcase_panel: PanelContainer = $MainHBox/LeftShowcase
@onready var portrait_frame: PanelContainer = $MainHBox/LeftShowcase/MarginContainer/VBoxContainer/PortraitFrame
@onready var portrait_texture: TextureRect = $MainHBox/LeftShowcase/MarginContainer/VBoxContainer/PortraitFrame/PortraitTexture
@onready var archetype_label: Label = $MainHBox/LeftShowcase/MarginContainer/VBoxContainer/ArchetypeBadge
@onready var hero_name_label: Label = $MainHBox/LeftShowcase/MarginContainer/VBoxContainer/HeroName
@onready var hero_title_label: Label = $MainHBox/LeftShowcase/MarginContainer/VBoxContainer/HeroTitle
@onready var lore_label: Label = $MainHBox/LeftShowcase/MarginContainer/VBoxContainer/LoreLabel
@onready var stat_speed: Label = $MainHBox/LeftShowcase/MarginContainer/VBoxContainer/StatsGrid/ValSpeed
@onready var stat_power: Label = $MainHBox/LeftShowcase/MarginContainer/VBoxContainer/StatsGrid/ValPower
@onready var stat_range: Label = $MainHBox/LeftShowcase/MarginContainer/VBoxContainer/StatsGrid/ValRange
@onready var stat_tech: Label = $MainHBox/LeftShowcase/MarginContainer/VBoxContainer/StatsGrid/ValTech
@onready var lock_badge: Label = $MainHBox/LeftShowcase/MarginContainer/VBoxContainer/LockBadge

@onready var grid_container: GridContainer = $MainHBox/RightRoster/GridCenter/GridContainer
@onready var btn_back: Button = $BottomBar/BtnBack
@onready var btn_start: Button = $BottomBar/BtnStart
@onready var status_hint: Label = $BottomBar/StatusHint

var warning_tween: Tween

func _ready() -> void:
	GameManager.game_mode = "campaign"

	# Hubungkan tombol footer
	btn_back.pressed.connect(_on_back_pressed)
	btn_start.pressed.connect(_on_start_pressed)

	_setup_roster_buttons()
	_select_character(0)

	# Berikan fokus pada tombol karakter pertama agar gamepad & keyboard langsung aktif
	if button_nodes.size() > 0:
		button_nodes[0].grab_focus()

func _setup_roster_buttons() -> void:
	button_nodes.clear()
	var children = grid_container.get_children()

	for i in range(children.size()):
		var btn = children[i] as Button
		if btn:
			var char_idx = i
			button_nodes.append(btn)

			# Atur pivot di tengah untuk animasi hover/focus
			btn.resized.connect(func(): btn.pivot_offset = btn.size / 2.0)
			btn.pivot_offset = btn.size / 2.0

			btn.pressed.connect(func(): _on_button_clicked(char_idx))
			btn.focus_entered.connect(func(): _on_button_focused(char_idx))
			btn.mouse_entered.connect(func(): _on_button_focused(char_idx))

func _on_button_focused(idx: int) -> void:
	if idx != selected_index:
		_select_character(idx)
	_animate_button(button_nodes[idx], true)

func _on_button_clicked(idx: int) -> void:
	_select_character(idx)
	var data = CHARACTERS[idx]
	if data.get("locked", false):
		_show_warning("Karakter %s masih terkunci!" % data["name"])
	else:
		_confirm_and_start()

func _select_character(idx: int) -> void:
	selected_index = idx
	var data = CHARACTERS[idx]

	# Update UI Showcase kiri
	hero_name_label.text = data["name"]
	hero_name_label.modulate = data["color"]
	hero_title_label.text = data["title"]
	archetype_label.text = data["archetype"]
	archetype_label.modulate = data["color"]
	lore_label.text = data["lore"]

	stat_speed.text = data.get("speed", "★★★☆☆")
	stat_power.text = data.get("power", "★★★☆☆")
	stat_range.text = data.get("range", "★★★☆☆")
	stat_tech.text = data.get("tech", "★★★☆☆")

	if ResourceLoader.exists(data["portrait"]):
		portrait_texture.texture = load(data["portrait"])
	elif ResourceLoader.exists(data["preview"]):
		portrait_texture.texture = load(data["preview"])

	var is_locked = data.get("locked", false)
	if is_locked:
		portrait_texture.modulate = Color(0.4, 0.4, 0.45, 0.8)
		lock_badge.visible = true
		btn_start.disabled = true
		btn_start.text = "LOCKED"
		btn_start.modulate = Color(0.6, 0.6, 0.6)
	else:
		portrait_texture.modulate = Color(1.0, 1.0, 1.0, 1.0)
		lock_badge.visible = false
		btn_start.disabled = false
		btn_start.text = "START CAMPAIGN ▶ [ENTER/F]"
		btn_start.modulate = Color(1.0, 0.85, 0.35)

	# Update frame border color
	_update_portrait_border(data["color"], is_locked)

	# Highlight tombol aktif
	for i in range(button_nodes.size()):
		var b = button_nodes[i]
		if i == idx:
			b.modulate = Color(1.15, 1.15, 1.15)
		else:
			b.modulate = Color(0.85, 0.85, 0.85)

func _update_portrait_border(accent_color: Color, is_locked: bool) -> void:
	var sb = portrait_frame.get_theme_stylebox("panel")
	if sb and sb is StyleBoxFlat:
		var new_sb = sb.duplicate() as StyleBoxFlat
		if is_locked:
			new_sb.border_color = Color(0.5, 0.3, 0.3, 0.6)
			new_sb.shadow_color = Color(0.3, 0.1, 0.1, 0.4)
		else:
			new_sb.border_color = accent_color
			new_sb.shadow_color = Color(accent_color.r, accent_color.g, accent_color.b, 0.5)
			new_sb.shadow_size = 8
		portrait_frame.add_theme_stylebox_override("panel", new_sb)

func _animate_button(btn: Button, is_active: bool) -> void:
	var tween = create_tween()
	var target_scale = Vector2(1.06, 1.06) if is_active else Vector2.ONE
	tween.tween_property(btn, "scale", target_scale, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _unhandled_input(event: InputEvent) -> void:
	if transition_started:
		return

	# ESC: Kembali ke Menu Utama
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE):
		_on_back_pressed()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed:
		if event.physical_keycode in [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_ENTER, KEY_KP_ENTER, KEY_K, KEY_L]:
			current_device_type = "keyboard_arrows"
		else:
			current_device_type = "keyboard_wasd"

	# Konfirmasi (Enter / Space / F / Gamepad A / Start)
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (
		event.physical_keycode == KEY_ENTER or 
		event.physical_keycode == KEY_KP_ENTER or 
		event.physical_keycode == KEY_SPACE or 
		event.physical_keycode == KEY_F)):
		_on_start_pressed()
		get_viewport().set_input_as_handled()
		return

	# Gamepad buttons
	if event is InputEventJoypadButton and event.pressed:
		current_device_type = "joypad"
		current_device_id = event.device
		if event.button_index == JOY_BUTTON_A or event.button_index == JOY_BUTTON_START or event.button_index == JOY_BUTTON_X:
			_on_start_pressed()
			get_viewport().set_input_as_handled()
		elif event.button_index == JOY_BUTTON_B:
			_on_back_pressed()
			get_viewport().set_input_as_handled()

func _on_back_pressed() -> void:
	if transition_started:
		return
	GameManager.go_to_main_menu()

func _on_start_pressed() -> void:
	var data = CHARACTERS[selected_index]
	if data.get("locked", false):
		_show_warning("Karakter %s masih terkunci!" % data["name"])
		return

	_confirm_and_start()

func _confirm_and_start() -> void:
	if transition_started:
		return
	transition_started = true

	var data = CHARACTERS[selected_index]
	status_hint.text = "ENTERING THE FALLEN AS %s..." % data["name"]
	status_hint.modulate = Color(0.2, 1.0, 0.4)

	# Pulse Hero Showcase
	var tween = create_tween().set_parallel(true)
	tween.tween_property(portrait_frame, "scale", Vector2(1.08, 1.08), 0.18).set_trans(Tween.TRANS_BACK)
	tween.tween_property(btn_start, "scale", Vector2(1.1, 1.1), 0.18)

	await get_tree().create_timer(0.7).timeout
	GameManager.start_campaign(data["id"], current_device_type, current_device_id)

func _show_warning(msg: String) -> void:
	if warning_tween and warning_tween.is_valid():
		warning_tween.kill()

	status_hint.text = msg
	status_hint.modulate = Color(1.0, 0.3, 0.3)

	warning_tween = create_tween()
	warning_tween.tween_property(status_hint, "scale", Vector2(1.1, 1.1), 0.1)
	warning_tween.tween_property(status_hint, "scale", Vector2.ONE, 0.1)
	warning_tween.tween_interval(1.5)
	warning_tween.tween_callback(func():
		status_hint.text = "[WASD / ARROWS] Select Hero  •  [F / ENTER / SPACE] Start Campaign  •  [ESC] Back"
		status_hint.modulate = Color(0.7, 0.75, 0.85)
	)
