class_name StageSelect
extends Control

# Mortal Kombat Style Stage Selection Screen
const STAGE_OPTIONS = [
	{
		"id": "ruined_school",
		"name": "RUINED ACADEMY",
		"desc": "Collapsed stone cathedral with ancient throne & torchlit abyss",
		"preview": "res://assets/stages/ruined_school_stage.png",
		"thumb": "res://assets/ui/stages/ruined_academy_thumb.png",
		"locked": false
	},
	{
		"id": "temple_ruin",
		"name": "TEMPLE RUIN",
		"desc": "Sacred Dragon Shrine flanked by stone effigies & suspended ledges",
		"preview": "res://assets/stages/temple_ruin_stage.png",
		"thumb": "res://assets/ui/stages/temple_ruin_thumb.png",
		"locked": false
	},
	{
		"id": "random",
		"name": "RANDOM ARENA",
		"desc": "Fate decides the battlefield",
		"preview": "res://assets/stages/temple_ruin_stage.png",
		"thumb": "res://assets/ui/stages/random_stage_thumb.png",
		"locked": false
	}
]

var selected_index: int = 1 # Default to Temple Ruin
var is_locked_in: bool = false

@onready var stage_preview: TextureRect = $TopSection/StagePanorama
@onready var stage_title_lbl: Label = $BannerContainer/StageTitle
@onready var stage_desc_lbl: Label = $BannerContainer/StageDesc
@onready var grid_container: GridContainer = $BottomSection/StoneBezel/GridContainer
@onready var p1_token: Panel = $BottomSection/StoneBezel/P1Token
@onready var status_lbl: Label = $StatusLabel

var slot_nodes: Array[Control] = []

func _ready() -> void:
	# Set initial selection from GameManager
	if GameManager.selected_stage == "ruined_school":
		selected_index = 0
	else:
		selected_index = 1

	_setup_slots()
	await get_tree().process_frame
	_update_display()
	_update_token_position()

func _setup_slots() -> void:
	slot_nodes.clear()
	var children = grid_container.get_children()
	for i in range(children.size()):
		var slot = children[i] as Control
		slot_nodes.append(slot)
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		var idx = i
		slot.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed and not is_locked_in:
				if idx < STAGE_OPTIONS.size() and not STAGE_OPTIONS[idx]["locked"]:
					selected_index = idx
					_update_display()
					_update_token_position()
					if event.double_click:
						_confirm_selection()
		)

func _unhandled_input(event: InputEvent) -> void:
	if is_locked_in:
		return

	if event.is_action_pressed("p1_move_left") or event.is_action_pressed("p2_move_left") or event.is_action_pressed("ui_left"):
		_move_selection(-1)
	elif event.is_action_pressed("p1_move_right") or event.is_action_pressed("p2_move_right") or event.is_action_pressed("ui_right"):
		_move_selection(1)
	elif event.is_action_pressed("p1_attack") or event.is_action_pressed("p2_attack") or event.is_action_pressed("ui_accept"):
		_confirm_selection()
	elif event.is_action_pressed("pause"):
		GameManager.go_to_character_select()

func _move_selection(dir: int) -> void:
	var total_selectable = STAGE_OPTIONS.size()
	selected_index = (selected_index + dir + total_selectable) % total_selectable
	_update_display()
	_update_token_position()

func _update_display() -> void:
	var data = STAGE_OPTIONS[selected_index]
	stage_title_lbl.text = data["name"]
	stage_desc_lbl.text = data["desc"]
	
	if ResourceLoader.exists(data["preview"]):
		stage_preview.texture = load(data["preview"])
	
	# Title bump animation
	stage_title_lbl.pivot_offset = stage_title_lbl.size / 2.0
	var tween = create_tween()
	tween.tween_property(stage_title_lbl, "scale", Vector2(1.15, 1.15), 0.08)
	tween.tween_property(stage_title_lbl, "scale", Vector2(1.0, 1.0), 0.12)

func _update_token_position() -> void:
	if selected_index < slot_nodes.size():
		var target_slot = slot_nodes[selected_index]
		var target_pos = target_slot.global_position - Vector2(4, 4)
		var target_sz = target_slot.size + Vector2(8, 8)
		
		var tween = create_tween().set_parallel(true)
		tween.tween_property(p1_token, "global_position", target_pos, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(p1_token, "size", target_sz, 0.1)

func _confirm_selection() -> void:
	is_locked_in = true
	var chosen_id = STAGE_OPTIONS[selected_index]["id"]
	
	if chosen_id == "random":
		var roll = randi() % 2
		chosen_id = "temple_ruin" if roll == 0 else "ruined_school"
	
	GameManager.selected_stage = chosen_id
	
	# Dramatic confirmation flash
	status_lbl.text = "ARENA CONFIRMED - ENTERING BATTLE!"
	status_lbl.modulate = Color(1.0, 0.3, 0.2)
	p1_token.modulate = Color(2.0, 1.5, 0.5) # Bright gold flash
	
	var tween = create_tween()
	tween.tween_property(status_lbl, "scale", Vector2(1.2, 1.2), 0.15)
	tween.tween_property(status_lbl, "scale", Vector2(1.0, 1.0), 0.15)
	
	await get_tree().create_timer(0.9).timeout
	GameManager.launch_match()
