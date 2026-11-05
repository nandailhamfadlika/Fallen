class_name TitleScreen
extends Control

@onready var background: TextureRect = $Background
@onready var logo_texture: TextureRect = $CenterBox/VBoxContainer/LogoBox/LogoTexture
@onready var prompt_box: VBoxContainer = $CenterBox/VBoxContainer/PromptBox
@onready var prompt_label: Label = $CenterBox/VBoxContainer/PromptBox/PromptLabel
@onready var fade_overlay: ColorRect = $FadeOverlay

var is_transitioning: bool = false
var can_accept_input: bool = false
var pulse_tween: Tween = null
var logo_tween: Tween = null

func _ready() -> void:
	fade_overlay.color = Color.BLACK
	fade_overlay.modulate.a = 1.0
	prompt_box.modulate.a = 0.0

	# Fade in from black cleanly
	var enter_tween = create_tween()
	enter_tween.tween_property(fade_overlay, "modulate:a", 0.0, 0.6)
	await enter_tween.finished
	can_accept_input = true

	# Start looping pulse animation for "PRESS ANYTHING TO START"
	_start_prompt_pulse()

	# Start subtle floating bob animation for the Fallen logo
	_start_logo_float()

func _start_prompt_pulse() -> void:
	prompt_box.modulate.a = 0.3
	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(prompt_box, "modulate:a", 1.0, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(prompt_box, "modulate:a", 0.3, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _start_logo_float() -> void:
	if not logo_texture:
		return
	logo_tween = create_tween().set_loops()
	logo_tween.tween_property(logo_texture, "position:y", -10.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	logo_tween.tween_property(logo_texture, "position:y", 0.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _input(event: InputEvent) -> void:
	if not can_accept_input or is_transitioning:
		return

	if event is InputEventKey or event is InputEventJoypadButton or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		if event.is_pressed() and not event.is_echo():
			_on_start_pressed()

func _on_start_pressed() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	can_accept_input = false

	# Stop background pulse and flash prompt enthusiastically (arcade style!)
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()

	prompt_box.modulate.a = 1.0
	prompt_label.pivot_offset = prompt_label.size * 0.5

	var flash_tween = create_tween()
	prompt_label.add_theme_color_override("font_color", Color(2.5, 2.5, 1.8, 1.0)) # Bright flash
	flash_tween.tween_property(prompt_label, "scale", Vector2(1.15, 1.15), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	flash_tween.tween_property(prompt_label, "scale", Vector2.ONE, 0.12)
	flash_tween.tween_callback(func():
		prompt_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.35, 1.0))
	)

	await flash_tween.finished
	await get_tree().create_timer(0.25).timeout

	# Smooth fade out to black
	var exit_tween = create_tween()
	exit_tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.5)
	await exit_tween.finished

	get_tree().change_scene_to_file("res://src/ui/MainMenu.tscn")
