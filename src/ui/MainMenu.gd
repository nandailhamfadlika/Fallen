class_name MainMenu
extends Control

@onready var menu_container: Control = $MenuContainer

@onready var btn_campaign: Button = $MenuContainer/BtnCampaign
@onready var btn_vs: Button = $MenuContainer/BtnVS
@onready var btn_training: Button = $MenuContainer/BtnTraining
@onready var btn_settings: Button = $MenuContainer/BtnSettings
@onready var btn_exit: Button = $MenuContainer/BtnExit

@onready var settings_modal: Panel = $SettingsModal
@onready var btn_close_settings: Button = $SettingsModal/BtnCloseSettings
@onready var fullscreen_check: CheckBox = $SettingsModal/VBox/FullscreenCheck

@onready var difficulty_modal: Panel = $DifficultyModal
@onready var btn_easy: Button = $DifficultyModal/VBox/BtnEasy
@onready var btn_medium: Button = $DifficultyModal/VBox/BtnMedium
@onready var btn_hard: Button = $DifficultyModal/VBox/BtnHard
@onready var btn_close_difficulty: Button = $DifficultyModal/BtnCloseDifficulty


const NORMAL_SCALE := Vector2.ONE
const HOVER_SCALE := Vector2(1.05, 1.05)
const ANIMATION_DURATION := 0.3


func _ready() -> void:
	if btn_campaign:
		btn_campaign.pressed.connect(_on_campaign_pressed)
		setup_button_effect(btn_campaign)
	btn_vs.pressed.connect(_on_vs_pressed)
	btn_training.pressed.connect(_on_training_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)

	setup_button_effect(btn_vs)
	setup_button_effect(btn_training)
	setup_button_effect(btn_settings)
	setup_button_effect(btn_exit)

	if btn_close_settings:
		btn_close_settings.pressed.connect(_on_close_settings)

	if fullscreen_check:
		fullscreen_check.toggled.connect(_on_fullscreen_toggled)
		fullscreen_check.button_pressed = (
			DisplayServer.window_get_mode()
			== DisplayServer.WINDOW_MODE_FULLSCREEN
		)

	settings_modal.visible = false
	if difficulty_modal:
		difficulty_modal.visible = false
		btn_easy.pressed.connect(func(): _on_select_difficulty("easy"))
		btn_medium.pressed.connect(func(): _on_select_difficulty("medium"))
		btn_hard.pressed.connect(func(): _on_select_difficulty("hard"))
		btn_close_difficulty.pressed.connect(_on_close_difficulty)

		btn_easy.focus_neighbor_bottom = btn_medium.get_path()
		btn_medium.focus_neighbor_top = btn_easy.get_path()
		btn_medium.focus_neighbor_bottom = btn_hard.get_path()
		btn_hard.focus_neighbor_top = btn_medium.get_path()
		btn_hard.focus_neighbor_bottom = btn_close_difficulty.get_path()
		btn_close_difficulty.focus_neighbor_top = btn_hard.get_path()

	if btn_campaign:
		btn_campaign.grab_focus()
	else:
		btn_vs.grab_focus()


# ====================================
# SETUP EFEK TOMBOL
# ====================================

func setup_button_effect(button: Button) -> void:
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.resized.connect(func(): button.pivot_offset = button.size / 2.0)
	button.pivot_offset = button.size / 2.0

	var empty_style := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", empty_style)
	button.add_theme_stylebox_override("hover", empty_style)
	button.add_theme_stylebox_override("pressed", empty_style)
	button.add_theme_stylebox_override("focus", empty_style)

	button.focus_entered.connect(
		func():
			_on_button_focus_entered(button)
	)

	button.focus_exited.connect(
		func():
			_on_button_focus_exited(button)
	)

	button.mouse_entered.connect(
		func():
			if not button.has_focus():
				animate_button(button, true)
	)

	button.mouse_exited.connect(
		func():
			if not button.has_focus():
				animate_button(button, false)
	)


# ====================================
# ANIMASI FOKUS KEYBOARD
# ====================================

func _on_button_focus_entered(button: Button) -> void:
	stop_button_tween(button)

	button.z_index = 1

	var tween := create_tween()
	button.set_meta("current_tween", tween)

	tween.set_loops()

	tween.tween_property(
		button,
		"scale",
		HOVER_SCALE,
		ANIMATION_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		button,
		"scale",
		NORMAL_SCALE,
		ANIMATION_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_button_focus_exited(button: Button) -> void:
	stop_button_tween(button)

	button.scale = NORMAL_SCALE
	button.z_index = 0

	if button.get_global_rect().has_point(
		get_global_mouse_position()
	):
		animate_button(button, true)


# ====================================
# ANIMASI HOVER MOUSE
# ====================================

func animate_button(button: Button, is_active: bool) -> void:
	stop_button_tween(button)

	var target_scale := HOVER_SCALE if is_active else NORMAL_SCALE

	var tween := create_tween()
	button.set_meta("current_tween", tween)

	tween.tween_property(
		button,
		"scale",
		target_scale,
		0.15
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	button.z_index = 1 if is_active else 0


# ====================================
# HENTIKAN ANIMASI
# ====================================

func stop_button_tween(button: Button) -> void:
	if button.has_meta("current_tween"):
		var old_tween = button.get_meta("current_tween")

		if old_tween and old_tween.is_running():
			old_tween.kill()


# ====================================
# TOMBOL MENU
# ====================================

func _on_campaign_pressed() -> void:
	if difficulty_modal:
		menu_container.hide()
		difficulty_modal.show()
		btn_medium.grab_focus()
	else:
		GameManager.setup_campaign("medium")

func _on_select_difficulty(diff: String) -> void:
	GameManager.setup_campaign(diff)

func _on_close_difficulty() -> void:
	if difficulty_modal:
		difficulty_modal.hide()
	menu_container.show()
	if btn_campaign:
		btn_campaign.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if difficulty_modal and difficulty_modal.visible:
			_on_close_difficulty()
			get_viewport().set_input_as_handled()
		elif settings_modal and settings_modal.visible:
			_on_close_settings()
			get_viewport().set_input_as_handled()


func _on_vs_pressed() -> void:
	GameManager.game_mode = "pvp"
	GameManager.go_to_character_select()


func _on_training_pressed() -> void:
	GameManager.start_training()


func _on_settings_pressed() -> void:
	menu_container.hide()
	settings_modal.show()

	if btn_close_settings:
		btn_close_settings.grab_focus()


func _on_close_settings() -> void:
	settings_modal.hide()
	menu_container.show()
	btn_settings.grab_focus()


func _on_fullscreen_toggled(button_pressed: bool) -> void:
	if button_pressed:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
		)
	else:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED
		)


func _on_exit_pressed() -> void:
	get_tree().quit()
