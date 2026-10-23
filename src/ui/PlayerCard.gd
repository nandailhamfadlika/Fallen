class_name PlayerCard
extends Panel

## Reusable Player Card for Character Select Lobby (Supports P1, P2, P3, P4)

@export var player_num: int = 1
@export var player_color: Color = Color(0.2, 0.85, 1.0)
@export var default_join_text: String = "PRESS [F] / [ENTER] / [O]"

var is_joined: bool = false
var is_ready: bool = false
var current_char_data: Dictionary = {}

@onready var unjoined_box: Control = $UnjoinedBox
@onready var unjoined_prompt: Label = $UnjoinedBox/PromptLabel
@onready var unjoined_title: Label = $UnjoinedBox/TitleLabel
@onready var unjoined_sub: Label = $UnjoinedBox/SubLabel

@onready var joined_box: Control = $JoinedBox
@onready var p_badge: Label = $JoinedBox/Header/BadgeLabel
@onready var device_lbl: Label = $JoinedBox/Header/DeviceLabel
@onready var char_sprite: TextureRect = $JoinedBox/CharSprite
@onready var name_lbl: Label = $JoinedBox/NameLabel
@onready var status_lbl: Label = $JoinedBox/StatusLabel

var pulse_tween: Tween

func _ready() -> void:
	_apply_card_theme()
	set_unjoined()

func _apply_card_theme() -> void:
	var style = get_theme_stylebox("panel")
	if style:
		var new_style = style.duplicate() as StyleBoxFlat
		new_style.border_color = Color(player_color.r, player_color.g, player_color.b, 0.45)
		new_style.shadow_color = Color(player_color.r, player_color.g, player_color.b, 0.25)
		add_theme_stylebox_override("panel", new_style)

func set_unjoined() -> void:
	is_joined = false
	is_ready = false
	unjoined_box.visible = true
	joined_box.visible = false
	unjoined_title.text = "PLAYER %d" % player_num
	unjoined_title.modulate = player_color
	unjoined_prompt.text = default_join_text
	if unjoined_sub != null:
		unjoined_sub.text = "TO JOIN BATTLE"

	_start_unjoined_pulse()

func set_unjoined_custom(title_text: String, prompt_text: String, sub_text: String = "") -> void:
	set_unjoined()
	if title_text != "":
		unjoined_title.text = title_text
	if prompt_text != "":
		unjoined_prompt.text = prompt_text
	if sub_text != "" and unjoined_sub != null:
		unjoined_sub.text = sub_text

func set_joined(dev_name: String, initial_char: Dictionary) -> void:
	is_joined = true
	is_ready = false
	unjoined_box.visible = false
	joined_box.visible = true

	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()

	p_badge.text = "P%d" % player_num
	p_badge.modulate = player_color
	device_lbl.text = dev_name

	# Glow up border
	var style = get_theme_stylebox("panel")
	if style:
		var new_style = style.duplicate() as StyleBoxFlat
		new_style.border_color = player_color
		new_style.shadow_color = Color(player_color.r, player_color.g, player_color.b, 0.6)
		new_style.shadow_size = 6
		add_theme_stylebox_override("panel", new_style)

	update_character(initial_char)

func update_character(char_data: Dictionary) -> void:
	current_char_data = char_data
	var is_locked = char_data.get("locked", false)

	if ResourceLoader.exists(char_data.get("portrait", "")):
		char_sprite.texture = load(char_data["portrait"])
	elif ResourceLoader.exists(char_data.get("preview", "")):
		char_sprite.texture = load(char_data["preview"])

	if is_locked:
		char_sprite.modulate = Color(0.4, 0.4, 0.45, 0.8)
		name_lbl.text = char_data.get("name", "") + " (LOCKED)"
		name_lbl.modulate = Color(0.65, 0.65, 0.7)
		status_lbl.text = "[LOCKED]"
		status_lbl.modulate = Color(1.0, 0.35, 0.35)
	else:
		char_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		name_lbl.text = char_data.get("name", "")
		name_lbl.modulate = char_data.get("color", Color.WHITE)

		if is_ready:
			status_lbl.text = "READY!"
			status_lbl.modulate = Color(0.2, 1.0, 0.4)
		else:
			status_lbl.text = "CHOOSING..."
			status_lbl.modulate = Color(1.0, 0.85, 0.3)

func set_ready_state(ready: bool) -> void:
	is_ready = ready
	update_character(current_char_data)
	if is_ready:
		var tw = create_tween()
		tw.tween_property(status_lbl, "scale", Vector2(1.2, 1.2), 0.1)
		tw.tween_property(status_lbl, "scale", Vector2(1.0, 1.0), 0.1)

func _start_unjoined_pulse() -> void:
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(unjoined_prompt, "modulate:a", 0.4, 0.7)
	pulse_tween.tween_property(unjoined_prompt, "modulate:a", 1.0, 0.7)
