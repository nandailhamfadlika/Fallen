class_name MainMenu
extends Control

@onready var btn_vs: Button = $MenuContainer/BtnVS
@onready var btn_training: Button = $MenuContainer/BtnTraining
@onready var btn_settings: Button = $MenuContainer/BtnSettings
@onready var btn_exit: Button = $MenuContainer/BtnExit

@onready var settings_modal: Panel = $SettingsModal
@onready var btn_close_settings: Button = $SettingsModal/BtnCloseSettings
@onready var fullscreen_check: CheckBox = $SettingsModal/VBox/FullscreenCheck

func _ready() -> void:
	btn_vs.pressed.connect(_on_vs_pressed)
	btn_training.pressed.connect(_on_training_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	
	if btn_close_settings:
		btn_close_settings.pressed.connect(_on_close_settings)
	if fullscreen_check:
		fullscreen_check.toggled.connect(_on_fullscreen_toggled)
		fullscreen_check.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)

	settings_modal.visible = false
	btn_vs.grab_focus()

func _on_vs_pressed() -> void:
	GameManager.game_mode = "pvp"
	GameManager.go_to_character_select()

func _on_training_pressed() -> void:
	GameManager.start_training()

func _on_settings_pressed() -> void:
	settings_modal.visible = true
	if btn_close_settings:
		btn_close_settings.grab_focus()

func _on_close_settings() -> void:
	settings_modal.visible = false
	btn_settings.grab_focus()

func _on_fullscreen_toggled(button_pressed: bool) -> void:
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_exit_pressed() -> void:
	get_tree().quit()
