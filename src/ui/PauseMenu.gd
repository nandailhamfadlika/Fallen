class_name PauseMenu
extends CanvasLayer

signal match_restarted()

@onready var panel: Control = $Control
@onready var menu_panel: Control = $Control/CenterContainer/PanelContainer
@onready var title_label: Label = $Control/CenterContainer/PanelContainer/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $Control/CenterContainer/PanelContainer/VBoxContainer/SubtitleLabel
@onready var resume_button: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/RestartButton
@onready var char_select_button: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/CharSelectButton
@onready var quit_button: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/QuitButton
@onready var help_label: Label = $Control/CenterContainer/PanelContainer/VBoxContainer/HelpLabel

# Confirmation Modal
@onready var confirm_modal: Control = $Control/ConfirmCenterContainer
@onready var confirm_title: Label = $Control/ConfirmCenterContainer/ConfirmPanel/MarginContainer/VBoxContainer/ConfirmTitle
@onready var confirm_msg: Label = $Control/ConfirmCenterContainer/ConfirmPanel/MarginContainer/VBoxContainer/ConfirmMessage
@onready var confirm_yes_btn: Button = $Control/ConfirmCenterContainer/ConfirmPanel/MarginContainer/VBoxContainer/ButtonBox/ConfirmYesBtn
@onready var confirm_no_btn: Button = $Control/ConfirmCenterContainer/ConfirmPanel/MarginContainer/VBoxContainer/ButtonBox/ConfirmNoBtn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	if confirm_modal:
		confirm_modal.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or (event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_ESCAPE):
		if panel.visible:
			if confirm_modal and confirm_modal.visible:
				_close_confirm_modal()
			else:
				resume_game()
		else:
			toggle_pause()
	elif event.is_action_pressed("ui_cancel"):
		if panel.visible and confirm_modal and confirm_modal.visible:
			_close_confirm_modal()
	elif event.is_action_pressed("restart") or (event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R):
		# Rematch / restart via key [R] is explicitly disabled in campaign mode
		if GameManager.game_mode != "campaign":
			restart_match()

func toggle_pause() -> void:
	var new_paused = !get_tree().paused
	get_tree().paused = new_paused
	panel.visible = new_paused
	if new_paused:
		_setup_pause_ui()

func _setup_pause_ui() -> void:
	if confirm_modal:
		confirm_modal.visible = false
	menu_panel.visible = true

	var gm = GameManager
	var mode = gm.game_mode if gm else "pvp"

	if mode == "campaign":
		title_label.text = "CAMPAIGN PAUSED"
		title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25)) # Campaign Gold
		var cur_stage = gm.campaign_stage_index if gm else 1
		var opp = gm.p2_character.to_upper() if gm else "OPPONENT"
		subtitle_label.visible = true
		subtitle_label.text = "STAGE %d/6 — SOUL TRIAL vs %s" % [cur_stage, opp]
		subtitle_label.add_theme_color_override("font_color", Color(0.9, 0.78, 0.4))
		
		# Rematch button is hidden in campaign mode
		restart_button.visible = false
		char_select_button.text = "Change Character"
		help_label.text = "Campaign: %s | Souls: %d" % [gm.campaign_difficulty.to_upper(), gm.round_stocks]
	elif mode == "training":
		title_label.text = "TRAINING PAUSED"
		title_label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4)) # Green
		subtitle_label.visible = true
		subtitle_label.text = "PRACTICE DOJO"
		subtitle_label.add_theme_color_override("font_color", Color(0.7, 0.9, 0.7))
		
		restart_button.visible = true
		restart_button.text = "Reset Positions [R]"
		char_select_button.text = "Change Character"
		help_label.text = "Press [R] anytime to reset training positions"
	else:
		# PVP / VS Mode
		title_label.text = "VS BATTLE PAUSED"
		title_label.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0)) # Cyan
		var num_players = gm.active_players.size() if gm else 2
		subtitle_label.visible = true
		subtitle_label.text = "%d PLAYERS LOCAL BRAWL" % num_players
		subtitle_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.9))
		
		restart_button.visible = true
		restart_button.text = "Restart Match [R]"
		char_select_button.text = "Change Character"
		help_label.text = "P1: WASD+[F] | P2: Arrows+[Enter]/[K]"

	resume_button.grab_focus()

func resume_game() -> void:
	get_tree().paused = false
	panel.visible = false
	if confirm_modal:
		confirm_modal.visible = false

func restart_match() -> void:
	# Disabled in campaign mode
	if GameManager.game_mode == "campaign":
		return
	get_tree().paused = false
	panel.visible = false
	match_restarted.emit()
	get_tree().reload_current_scene()

func _on_resume_button_pressed() -> void:
	resume_game()

func _on_restart_button_pressed() -> void:
	restart_match()

func _on_char_select_button_pressed() -> void:
	_open_confirm_modal()

func _open_confirm_modal() -> void:
	menu_panel.visible = false
	confirm_modal.visible = true

	var is_campaign = (GameManager.game_mode == "campaign")
	confirm_title.text = "CHANGE CHARACTER?"
	if is_campaign:
		confirm_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
		confirm_msg.text = "Are you sure you want to change character?\n\nCurrent Campaign run will be forfeit and you will return to Campaign Character Select."
	else:
		confirm_title.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
		confirm_msg.text = "Are you sure you want to change character?\n\nCurrent battle will end and you will return to Fighter Selection."

	# Default focus on Cancel button for safety
	confirm_no_btn.grab_focus()

func _close_confirm_modal() -> void:
	confirm_modal.visible = false
	menu_panel.visible = true
	char_select_button.grab_focus()

func _on_confirm_no_button_pressed() -> void:
	_close_confirm_modal()

func _on_confirm_yes_button_pressed() -> void:
	get_tree().paused = false
	panel.visible = false
	confirm_modal.visible = false

	if GameManager.game_mode == "campaign":
		GameManager.go_to_campaign_character_select()
	else:
		GameManager.go_to_character_select()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	panel.visible = false
	GameManager.go_to_main_menu()
