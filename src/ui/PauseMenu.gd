class_name PauseMenu
extends CanvasLayer

signal match_restarted()

@onready var panel: Control = $Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
	elif event.is_action_pressed("restart"):
		restart_match()

func toggle_pause() -> void:
	var new_paused = !get_tree().paused
	get_tree().paused = new_paused
	panel.visible = new_paused

func resume_game() -> void:
	get_tree().paused = false
	panel.visible = false

func restart_match() -> void:
	get_tree().paused = false
	panel.visible = false
	match_restarted.emit()
	get_tree().reload_current_scene()

func _on_resume_button_pressed() -> void:
	resume_game()

func _on_restart_button_pressed() -> void:
	restart_match()

func _on_char_select_button_pressed() -> void:
	get_tree().paused = false
	GameManager.go_to_character_select()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	GameManager.go_to_main_menu()
