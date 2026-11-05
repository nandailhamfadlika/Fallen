class_name OpeningVideoScene
extends Control

@onready var video_player: VideoStreamPlayer = $VideoPlayer
@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var skip_hint: Control = $SkipHintContainer

var is_transitioning: bool = false
var skip_allowed: bool = false

func _ready() -> void:
	fade_overlay.color = Color.BLACK
	fade_overlay.modulate.a = 1.0
	skip_hint.modulate.a = 0.0

	video_player.finished.connect(_on_video_finished)

	# Auto-start video
	video_player.play()

	# Fade in from black
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 0.0, 0.5)
	await tween.finished
	skip_allowed = true

	# Fade in skip hint gently after 1 second
	var hint_tween = create_tween()
	hint_tween.tween_property(skip_hint, "modulate:a", 0.75, 0.8).set_delay(0.8)

func _input(event: InputEvent) -> void:
	if not skip_allowed or is_transitioning:
		return

	if event is InputEventKey or event is InputEventJoypadButton or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		if event.is_pressed() and not event.is_echo():
			_transition_to_title()

func _on_video_finished() -> void:
	if not is_transitioning:
		_transition_to_title()

func _transition_to_title() -> void:
	if is_transitioning:
		return
	is_transitioning = true

	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.45)
	await tween.finished
	video_player.stop()
	get_tree().change_scene_to_file("res://src/ui/TitleScreen.tscn")
