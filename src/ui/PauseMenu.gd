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
@onready var options_button: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/OptionsButton
@onready var quit_button: Button = $Control/CenterContainer/PanelContainer/VBoxContainer/QuitButton
@onready var help_label: Label = $Control/CenterContainer/PanelContainer/VBoxContainer/HelpLabel

# Confirmation Modal
@onready var confirm_modal: Control = $Control/ConfirmCenterContainer
@onready var confirm_title: Label = $Control/ConfirmCenterContainer/ConfirmPanel/MarginContainer/VBoxContainer/ConfirmTitle
@onready var confirm_msg: Label = $Control/ConfirmCenterContainer/ConfirmPanel/MarginContainer/VBoxContainer/ConfirmMessage
@onready var confirm_yes_btn: Button = $Control/ConfirmCenterContainer/ConfirmPanel/MarginContainer/VBoxContainer/ButtonBox/ConfirmYesBtn
@onready var confirm_no_btn: Button = $Control/ConfirmCenterContainer/ConfirmPanel/MarginContainer/VBoxContainer/ButtonBox/ConfirmNoBtn

# Audio Options Modal
@onready var options_modal: Control = $Control/OptionsCenterContainer
@onready var options_title: Label = $Control/OptionsCenterContainer/OptionsPanel/MarginContainer/VBoxContainer/OptionsTitle
@onready var audio_settings_group: VBoxContainer = $Control/OptionsCenterContainer/OptionsPanel/MarginContainer/VBoxContainer/AudioSettingsGroup
@onready var options_close_btn: Button = $Control/OptionsCenterContainer/OptionsPanel/MarginContainer/VBoxContainer/OptionsCloseBtn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	if confirm_modal:
		confirm_modal.visible = false
	if options_modal:
		options_modal.visible = false

	var am := get_node_or_null("/root/AudioManager")
	if am:
		for btn in [resume_button, restart_button, char_select_button, options_button, quit_button, confirm_yes_btn, confirm_no_btn, options_close_btn]:
			am.wire_button_sfx(btn, "", true)

	if audio_settings_group and options_close_btn:
		var last_slider: Control = audio_settings_group.get_last_focusable()
		if last_slider:
			last_slider.focus_neighbor_bottom = options_close_btn.get_path()
			options_close_btn.focus_neighbor_top = last_slider.get_path()

	var lm := get_node_or_null("/root/LocalizationManager")
	if lm and lm.has_signal("locale_changed"):
		lm.locale_changed.connect(func(_l: String): _update_localized_texts())
	_update_localized_texts()

func _update_localized_texts() -> void:
	if resume_button: resume_button.text = tr("UI_RESUME")
	if restart_button:
		if GameManager.game_mode == "training":
			restart_button.text = tr("PAUSE_RESET_POS")
		else:
			restart_button.text = tr("UI_REMATCH")
	if char_select_button:
		if GameManager.game_mode in ["campaign", "training"]:
			char_select_button.text = tr("PAUSE_CHANGE_CHAR_BTN")
		else:
			char_select_button.text = tr("UI_CHARACTER_SELECT")
	if options_button: options_button.text = tr("UI_OPTIONS")
	if quit_button: quit_button.text = tr("UI_MAIN_MENU")
	if confirm_yes_btn: confirm_yes_btn.text = tr("UI_YES")
	if confirm_no_btn: confirm_no_btn.text = tr("UI_NO")
	if options_title: options_title.text = tr("OPT_HEADER")
	if options_close_btn: options_close_btn.text = tr("UI_BACK")
	if confirm_modal and confirm_modal.visible:
		_open_confirm_modal()
	elif panel and panel.visible:
		_setup_pause_ui()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or (event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_ESCAPE):
		if panel.visible:
			if options_modal and options_modal.visible:
				_close_options_modal()
			elif confirm_modal and confirm_modal.visible:
				_close_confirm_modal()
			else:
				resume_game("back")
		else:
			toggle_pause()
	elif event.is_action_pressed("ui_cancel"):
		if panel.visible:
			if options_modal and options_modal.visible:
				_close_options_modal()
			elif confirm_modal and confirm_modal.visible:
				_close_confirm_modal()
	elif event.is_action_pressed("restart") or (event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R):
		# Rematch / restart via key [R] is explicitly disabled in campaign mode
		if GameManager.game_mode != "campaign":
			restart_match()

func _exit_tree() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.set_bgm_ducked(false, 0.15)

func toggle_pause() -> void:
	var new_paused = !get_tree().paused
	get_tree().paused = new_paused
	panel.visible = new_paused
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.play_sfx("back")
		am.set_bgm_ducked(new_paused, 0.2)
		if new_paused:
			am.suppress_select_for(80)
	if new_paused:
		_setup_pause_ui()

func _unpause_and_hide() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.set_bgm_ducked(false, 0.2)
	get_tree().paused = false
	panel.visible = false
	if confirm_modal:
		confirm_modal.visible = false
	if options_modal:
		options_modal.visible = false

func _setup_pause_ui() -> void:
	if confirm_modal:
		confirm_modal.visible = false
	if options_modal:
		options_modal.visible = false
	menu_panel.visible = true

	var gm = GameManager
	var mode = gm.game_mode if gm else "pvp"

	if mode == "campaign":
		title_label.text = tr("PAUSE_CAMPAIGN_TITLE")
		title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25)) # Campaign Gold
		var cur_stage = gm.campaign_stage_index if gm else 1
		var opp = gm.p2_character.to_upper() if gm else "OPPONENT"
		subtitle_label.visible = true
		subtitle_label.text = tr("PAUSE_STAGE_SUBTITLE") % [cur_stage, opp]
		subtitle_label.add_theme_color_override("font_color", Color(0.9, 0.78, 0.4))
		
		# Rematch button is hidden in campaign mode
		restart_button.visible = false
		char_select_button.text = tr("PAUSE_CHANGE_CHAR_BTN")
		help_label.text = "Campaign: %s | Souls: %d" % [gm.campaign_difficulty.to_upper(), gm.round_stocks]
	elif mode == "training":
		title_label.text = tr("PAUSE_TRAINING_TITLE")
		title_label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4)) # Green
		subtitle_label.visible = true
		subtitle_label.text = tr("PAUSE_TRAINING_SUBTITLE")
		subtitle_label.add_theme_color_override("font_color", Color(0.7, 0.9, 0.7))
		
		restart_button.visible = true
		restart_button.text = tr("PAUSE_RESET_POS")
		char_select_button.text = tr("PAUSE_CHANGE_CHAR_BTN")
		help_label.text = "Press [R] anytime to reset training positions"
	else:
		# PVP / VS Mode
		title_label.text = tr("PAUSE_VS_TITLE")
		title_label.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0)) # Cyan
		var num_players = gm.active_players.size() if gm else 2
		subtitle_label.visible = true
		subtitle_label.text = tr("PAUSE_VS_SUBTITLE") % num_players
		subtitle_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.9))
		
		restart_button.visible = true
		restart_button.text = tr("UI_REMATCH")
		char_select_button.text = tr("UI_CHARACTER_SELECT")
		var time_text = "Infinite Time" if gm and gm.round_time_limit <= 0 else ("%ds" % gm.round_time_limit if gm else "99s")
		help_label.text = "Local VS: %d Stocks | %s" % [gm.round_stocks, time_text]

	resume_button.grab_focus()

func resume_game(sfx_key: String = "confirm") -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am and not sfx_key.is_empty():
		am.play_sfx(sfx_key)
	_unpause_and_hide()

func restart_match() -> void:
	# Disabled in campaign mode
	if GameManager.game_mode == "campaign":
		return
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.play_sfx("confirm")
	_unpause_and_hide()
	match_restarted.emit()
	get_tree().reload_current_scene()

func _on_resume_button_pressed() -> void:
	resume_game("confirm")

func _on_restart_button_pressed() -> void:
	restart_match()

func _on_char_select_button_pressed() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.play_sfx("confirm")
	_open_confirm_modal()

func _open_confirm_modal() -> void:
	menu_panel.visible = false
	confirm_modal.visible = true

	var is_campaign = (GameManager.game_mode == "campaign")
	confirm_title.text = tr("PAUSE_CHANGE_CHAR_TITLE")
	if is_campaign:
		confirm_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
		confirm_msg.text = tr("PAUSE_CHANGE_CHAR_CAMPAIGN_MSG")
	else:
		confirm_title.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
		confirm_msg.text = tr("PAUSE_CHANGE_CHAR_VS_MSG")

	if confirm_yes_btn: confirm_yes_btn.text = tr("UI_YES")
	if confirm_no_btn: confirm_no_btn.text = tr("UI_NO")

	# Default focus on Cancel button for safety
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.suppress_select_for(80)
	confirm_no_btn.grab_focus()

func _close_confirm_modal() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.play_sfx("back")
		am.suppress_select_for(80)
	confirm_modal.visible = false
	menu_panel.visible = true
	char_select_button.grab_focus()

func _on_confirm_no_button_pressed() -> void:
	_close_confirm_modal()

func _on_confirm_yes_button_pressed() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.play_sfx("confirm")
	_unpause_and_hide()

	if GameManager.game_mode == "campaign":
		GameManager.go_to_campaign_character_select()
	else:
		GameManager.go_to_character_select()

func _on_quit_button_pressed() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.play_sfx("back")
	if GameManager.game_mode == "campaign":
		var sm := get_node_or_null("/root/SaveManager")
		if sm and GameManager.campaign_stage_index >= 1:
			sm.save_campaign_progress(
				GameManager.p1_character,
				GameManager.campaign_difficulty,
				GameManager.campaign_stage_index,
				GameManager.campaign_claimants,
				GameManager.campaign_stages,
				GameManager.campaign_player_device_type,
				GameManager.campaign_player_device_id
			)
	_unpause_and_hide()
	GameManager.go_to_main_menu()

func _on_options_button_pressed() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.play_sfx("confirm")
		am.suppress_select_for(80)
	_open_options_modal()

func _open_options_modal() -> void:
	menu_panel.visible = false
	options_modal.visible = true
	if GameManager.game_mode == "campaign":
		options_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	else:
		options_title.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
	if audio_settings_group:
		audio_settings_group.refresh()
		var first_slider: Control = audio_settings_group.get_first_focusable()
		if first_slider:
			first_slider.grab_focus()
			return
	options_close_btn.grab_focus()

func _close_options_modal() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.play_sfx("back")
		am.suppress_select_for(80)
	options_modal.visible = false
	menu_panel.visible = true
	options_button.grab_focus()

func _on_options_close_button_pressed() -> void:
	_close_options_modal()
