class_name CharacterSelect
extends Control

# Character Select Screen - Mortal Kombat Arcade Style

const CHARACTERS = [
	{
		"id": "aron",
		"name": "ARON",
		"title": "Speed Brawler",
		"portrait": "res://assets/ui/portraits/portrait_aron.png",
		"preview": "res://assets/characters/aron/idle/idle_01.png",
		"color": Color(0.2, 0.85, 1.0)
	},
	{
		"id": "om_hami",
		"name": "OM HAMI",
		"title": "Cane Martial Zoner",
		"portrait": "res://assets/ui/portraits/portrait_om_hami.png",
		"preview": "res://assets/characters/om_hami/idle/idle_01.png",
		"color": Color(1.0, 0.75, 0.2)
	}
]

var p1_index: int = 0
var p2_index: int = 1
var p1_ready: bool = false
var p2_ready: bool = false
var transition_started: bool = false

# UI References
@onready var p1_preview: TextureRect = $LeftPreview/CharSprite
@onready var p1_name_lbl: Label = $LeftPreview/NameLabel
@onready var p1_status_lbl: Label = $LeftPreview/StatusLabel
@onready var p1_cursor: Panel = $GridCenter/P1Cursor

@onready var p2_preview: TextureRect = $RightPreview/CharSprite
@onready var p2_name_lbl: Label = $RightPreview/NameLabel
@onready var p2_status_lbl: Label = $RightPreview/StatusLabel
@onready var p2_cursor: Panel = $GridCenter/P2Cursor

@onready var match_status_lbl: Label = $MatchStatusLabel
@onready var slot_aron: TextureRect = $GridCenter/GridContainer/SlotAron
@onready var slot_hami: TextureRect = $GridCenter/GridContainer/SlotHami
@onready var stage_btn: Button = $StageSelectBtn

func _ready() -> void:
	_update_p1_display()
	_update_p2_display()
	if stage_btn:
		stage_btn.visible = false
	slot_aron.mouse_filter = Control.MOUSE_FILTER_STOP
	slot_hami.mouse_filter = Control.MOUSE_FILTER_STOP
	slot_aron.gui_input.connect(_on_slot_aron_gui_input)
	slot_hami.gui_input.connect(_on_slot_hami_gui_input)
	# Wait for GridContainer layout calculation
	await get_tree().process_frame
	_update_cursors()

func _toggle_stage() -> void:
	if GameManager.selected_stage == "temple_ruin":
		GameManager.selected_stage = "ruined_school"
	else:
		GameManager.selected_stage = "temple_ruin"
	_update_stage_button()

func _update_stage_button() -> void:
	if stage_btn:
		var s_name = "TEMPLE RUIN" if GameManager.selected_stage == "temple_ruin" else "RUINED ACADEMY"
		stage_btn.text = "MAP: " + s_name + "  [CLICK TO SWITCH]"

func _on_slot_aron_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not transition_started:
		if event.button_index == MOUSE_BUTTON_LEFT:
			p1_index = 0
			p1_ready = true
			_update_p1_display()
			_update_cursors()
			_check_all_ready()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			p2_index = 0
			p2_ready = true
			_update_p2_display()
			_update_cursors()
			_check_all_ready()

func _on_slot_hami_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not transition_started:
		if event.button_index == MOUSE_BUTTON_LEFT:
			p1_index = 1
			p1_ready = true
			_update_p1_display()
			_update_cursors()
			_check_all_ready()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			p2_index = 1
			p2_ready = true
			_update_p2_display()
			_update_cursors()
			_check_all_ready()

func _process(_delta: float) -> void:
	if transition_started:
		return

	# Return to Main Menu with Escape
	if Input.is_action_just_pressed("pause"):
		GameManager.go_to_main_menu()
		return

	# Player 1 Inputs
	if not p1_ready:
		if Input.is_action_just_pressed("p1_move_left") or Input.is_action_just_pressed("p1_move_right"):
			p1_index = 1 if p1_index == 0 else 0
			_update_p1_display()
			_update_cursors()
		elif Input.is_action_just_pressed("p1_attack") or Input.is_action_just_pressed("p1_jump"):
			p1_ready = true
			_update_p1_display()
			_check_all_ready()
	else:
		if Input.is_action_just_pressed("p1_down") or Input.is_action_just_pressed("p1_dodge"):
			p1_ready = false
			_update_p1_display()

	# Player 2 Inputs
	if not p2_ready:
		if Input.is_action_just_pressed("p2_move_left") or Input.is_action_just_pressed("p2_move_right"):
			p2_index = 1 if p2_index == 0 else 0
			_update_p2_display()
			_update_cursors()
		elif Input.is_action_just_pressed("p2_attack") or Input.is_action_just_pressed("p2_jump"):
			p2_ready = true
			_update_p2_display()
			_check_all_ready()
	else:
		if Input.is_action_just_pressed("p2_down"):
			p2_ready = false
			_update_p2_display()

func _update_p1_display() -> void:
	var char_data = CHARACTERS[p1_index]
	p1_preview.texture = load(char_data["preview"])
	p1_name_lbl.text = char_data["name"]
	p1_name_lbl.modulate = char_data["color"]
	
	if p1_ready:
		p1_status_lbl.text = "READY!"
		p1_status_lbl.modulate = Color(0.2, 1.0, 0.4)
	else:
		p1_status_lbl.text = "[A]/[D] Move | [F] Choose"
		p1_status_lbl.modulate = Color(0.6, 0.8, 1.0)

func _update_p2_display() -> void:
	var char_data = CHARACTERS[p2_index]
	p2_preview.texture = load(char_data["preview"])
	p2_name_lbl.text = char_data["name"]
	p2_name_lbl.modulate = char_data["color"]
	
	if p2_ready:
		p2_status_lbl.text = "READY!"
		p2_status_lbl.modulate = Color(0.2, 1.0, 0.4)
	else:
		p2_status_lbl.text = "[Arrows] Move | [Enter]/[K] Choose"
		p2_status_lbl.modulate = Color(1.0, 0.9, 0.5)

func _update_cursors() -> void:
	if not is_inside_tree() or not slot_aron or not slot_hami:
		return

	var target_slot_p1 = slot_aron if p1_index == 0 else slot_hami
	var target_slot_p2 = slot_aron if p2_index == 0 else slot_hami
	
	# Global positioning so layout hierarchy never offsets cursors wrongly
	p1_cursor.global_position = target_slot_p1.global_position - Vector2(4, 4)
	p1_cursor.size = target_slot_p1.size + Vector2(8, 8)
	
	# If both on same slot, make P2 cursor slightly larger around P1
	if p1_index == p2_index:
		p2_cursor.global_position = target_slot_p2.global_position - Vector2(8, 8)
		p2_cursor.size = target_slot_p2.size + Vector2(16, 16)
	else:
		p2_cursor.global_position = target_slot_p2.global_position - Vector2(4, 4)
		p2_cursor.size = target_slot_p2.size + Vector2(8, 8)

func _check_all_ready() -> void:
	if p1_ready and p2_ready:
		transition_started = true
		match_status_lbl.text = "PREPARE FOR BATTLE!"
		match_status_lbl.modulate = Color(1.0, 0.2, 0.2)
		
		# Flash animation
		var tween = create_tween()
		tween.tween_property(match_status_lbl, "scale", Vector2(1.2, 1.2), 0.2)
		tween.tween_property(match_status_lbl, "scale", Vector2(1.0, 1.0), 0.2)
		
		await get_tree().create_timer(1.0).timeout
		var p1_id = CHARACTERS[p1_index]["id"]
		var p2_id = CHARACTERS[p2_index]["id"]
		GameManager.p1_character = p1_id
		GameManager.p2_character = p2_id
		GameManager.go_to_stage_select()
