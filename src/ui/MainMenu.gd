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
@onready var audio_settings_group: VBoxContainer = $SettingsModal/VBox/AudioSettingsGroup

@onready var difficulty_modal: Panel = $DifficultyModal
@onready var btn_easy: Button = $DifficultyModal/VBox/BtnEasy
@onready var btn_medium: Button = $DifficultyModal/VBox/BtnMedium
@onready var btn_hard: Button = $DifficultyModal/VBox/BtnHard
@onready var btn_close_difficulty: Button = $DifficultyModal/BtnCloseDifficulty

# Campaign Choice Modal
@onready var campaign_choice_modal: Panel = $CampaignChoiceModal
@onready var btn_choice_continue: Button = $CampaignChoiceModal/VBox/BtnChoiceContinue
@onready var btn_choice_new_game: Button = $CampaignChoiceModal/VBox/BtnChoiceNewGame
@onready var btn_close_choice: Button = $CampaignChoiceModal/BtnCloseChoice

# New Game Confirmation Modal
@onready var new_game_confirm_modal: Panel = $NewGameConfirmModal
@onready var btn_new_game_confirm: Button = $NewGameConfirmModal/ButtonBox/BtnNewGameConfirm
@onready var btn_new_game_cancel: Button = $NewGameConfirmModal/ButtonBox/BtnNewGameCancel

# Campaign Continue Details Modal
@onready var campaign_continue_modal: Panel = $CampaignContinueModal
@onready var hero_portrait_rect: TextureRect = $CampaignContinueModal/MainHBox/PortraitFrame/Margin/HeroPortrait
@onready var hero_name_label: Label = $CampaignContinueModal/MainHBox/InfoVBox/HeroName
@onready var hero_archetype_label: Label = $CampaignContinueModal/MainHBox/InfoVBox/HeroArchetype
@onready var stage_progress_label: Label = $CampaignContinueModal/MainHBox/InfoVBox/StageProgress
@onready var opponent_label: Label = $CampaignContinueModal/MainHBox/InfoVBox/OpponentLabel
@onready var arena_label: Label = $CampaignContinueModal/MainHBox/InfoVBox/ArenaLabel
@onready var difficulty_label: Label = $CampaignContinueModal/MainHBox/InfoVBox/DifficultyLabel
@onready var saved_time_label: Label = $CampaignContinueModal/MainHBox/InfoVBox/SavedTimeLabel
@onready var btn_continue_confirm: Button = $CampaignContinueModal/ActionHBox/BtnContinueConfirm
@onready var btn_continue_back: Button = $CampaignContinueModal/ActionHBox/BtnContinueBack


const NORMAL_SCALE := Vector2.ONE
const HOVER_SCALE := Vector2(1.05, 1.05)
const ANIMATION_DURATION := 0.3


func _ready() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.play_bgm("main_menu", 0.5)

	# Smooth fade-in on menu entry
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.z_index = 50
	add_child(fade)
	var tw = create_tween()
	tw.tween_property(fade, "modulate:a", 0.0, 0.4)
	tw.tween_callback(fade.queue_free)

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

	if campaign_choice_modal:
		campaign_choice_modal.visible = false
		if btn_choice_continue:
			btn_choice_continue.pressed.connect(_on_choice_continue_pressed)
			setup_button_effect(btn_choice_continue)
		if btn_choice_new_game:
			btn_choice_new_game.pressed.connect(_on_choice_new_game_pressed)
			setup_button_effect(btn_choice_new_game)
		if btn_close_choice:
			btn_close_choice.pressed.connect(_on_close_campaign_choice)
			setup_button_effect(btn_close_choice)

		if btn_choice_continue and btn_choice_new_game and btn_close_choice:
			btn_choice_continue.focus_neighbor_bottom = btn_choice_new_game.get_path()
			btn_choice_new_game.focus_neighbor_top = btn_choice_continue.get_path()
			btn_choice_new_game.focus_neighbor_bottom = btn_close_choice.get_path()
			btn_close_choice.focus_neighbor_top = btn_choice_new_game.get_path()

	if new_game_confirm_modal:
		new_game_confirm_modal.visible = false
		if btn_new_game_confirm:
			btn_new_game_confirm.pressed.connect(_on_new_game_confirmed)
			setup_button_effect(btn_new_game_confirm)
		if btn_new_game_cancel:
			btn_new_game_cancel.pressed.connect(_on_new_game_cancelled)
			setup_button_effect(btn_new_game_cancel)

		if btn_new_game_confirm and btn_new_game_cancel:
			btn_new_game_cancel.focus_neighbor_left = btn_new_game_confirm.get_path()
			btn_new_game_confirm.focus_neighbor_right = btn_new_game_cancel.get_path()

	if campaign_continue_modal:
		campaign_continue_modal.visible = false
		if btn_continue_confirm:
			btn_continue_confirm.pressed.connect(_on_continue_confirm_pressed)
			setup_button_effect(btn_continue_confirm)
		if btn_continue_back:
			btn_continue_back.pressed.connect(_on_continue_back_pressed)
			setup_button_effect(btn_continue_back)

		if btn_continue_confirm and btn_continue_back:
			btn_continue_confirm.focus_neighbor_right = btn_continue_back.get_path()
			btn_continue_back.focus_neighbor_left = btn_continue_confirm.get_path()

	if btn_campaign:
		btn_campaign.grab_focus()
	else:
		btn_vs.grab_focus()

	if am:
		am.suppress_select_for(120)
		for btn in [btn_campaign, btn_vs, btn_training, btn_settings, btn_exit]:
			am.wire_button_sfx(btn, "confirm")
		for btn in [btn_easy, btn_medium, btn_hard, fullscreen_check]:
			am.wire_button_sfx(btn, "confirm")
		for btn in [btn_close_difficulty, btn_close_settings]:
			am.wire_button_sfx(btn, "back")
		if btn_choice_continue: am.wire_button_sfx(btn_choice_continue, "confirm")
		if btn_choice_new_game: am.wire_button_sfx(btn_choice_new_game, "confirm")
		if btn_close_choice: am.wire_button_sfx(btn_close_choice, "back")
		if btn_new_game_confirm: am.wire_button_sfx(btn_new_game_confirm, "confirm")
		if btn_new_game_cancel: am.wire_button_sfx(btn_new_game_cancel, "back")
		if btn_continue_confirm: am.wire_button_sfx(btn_continue_confirm, "confirm")
		if btn_continue_back: am.wire_button_sfx(btn_continue_back, "back")

	if audio_settings_group and fullscreen_check and btn_close_settings:
		var first_slider: Control = audio_settings_group.get_first_focusable()
		var last_slider: Control = audio_settings_group.get_last_focusable()
		if first_slider and last_slider:
			fullscreen_check.focus_neighbor_bottom = first_slider.get_path()
			first_slider.focus_neighbor_top = fullscreen_check.get_path()
			last_slider.focus_neighbor_bottom = btn_close_settings.get_path()
			btn_close_settings.focus_neighbor_top = last_slider.get_path()

	var lm := get_node_or_null("/root/LocalizationManager")
	if lm and lm.has_signal("locale_changed"):
		lm.locale_changed.connect(func(_l: String): _update_localized_texts())
	_update_localized_texts()

func _update_localized_texts() -> void:
	if settings_modal:
		var title := settings_modal.get_node_or_null("Title") as Label
		if title: title.text = tr("OPT_HEADER")
		var audio_hdr := settings_modal.get_node_or_null("VBox/AudioHeader") as Label
		if audio_hdr: audio_hdr.text = tr("OPT_SECTION_AUDIO") + " & " + tr("OPT_SECTION_LANGUAGE")
		if btn_close_settings: btn_close_settings.text = tr("UI_CLOSE")
	if fullscreen_check:
		fullscreen_check.text = " " + tr("OPT_FULLSCREEN")
	if difficulty_modal:
		var diff_title := difficulty_modal.get_node_or_null("Title") as Label
		if diff_title: diff_title.text = tr("DIFFICULTY_TITLE")
		var diff_sub := difficulty_modal.get_node_or_null("SubTitle") as Label
		if diff_sub: diff_sub.text = tr("DIFFICULTY_SUBTITLE")

		# Clear button text so Godot doesn't render overlapping default button text
		if btn_easy:
			btn_easy.text = ""
			var hdr := btn_easy.get_node_or_null("Margin/TextVBox/Header") as Label
			if hdr: hdr.text = tr("DIFFICULTY_EASY_HEADER")
			var dsc := btn_easy.get_node_or_null("Margin/TextVBox/Desc") as Label
			if dsc: dsc.text = tr("DIFFICULTY_EASY_DESC")
		if btn_medium:
			btn_medium.text = ""
			var hdr := btn_medium.get_node_or_null("Margin/TextVBox/Header") as Label
			if hdr: hdr.text = tr("DIFFICULTY_MEDIUM_HEADER")
			var dsc := btn_medium.get_node_or_null("Margin/TextVBox/Desc") as Label
			if dsc: dsc.text = tr("DIFFICULTY_MEDIUM_DESC")
		if btn_hard:
			btn_hard.text = ""
			var hdr := btn_hard.get_node_or_null("Margin/TextVBox/Header") as Label
			if hdr: hdr.text = tr("DIFFICULTY_HARD_HEADER")
			var dsc := btn_hard.get_node_or_null("Margin/TextVBox/Desc") as Label
			if dsc: dsc.text = tr("DIFFICULTY_HARD_DESC")

		if btn_close_difficulty:
			btn_close_difficulty.text = tr("UI_BACK")


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
	var sm = get_node_or_null("/root/SaveManager")
	var has_save: bool = (sm != null and sm.has_active_campaign())
	
	if has_save and campaign_choice_modal:
		_open_campaign_choice_modal()
	elif difficulty_modal:
		_open_difficulty_modal()
	else:
		GameManager.setup_campaign("medium")

func _open_campaign_choice_modal() -> void:
	menu_container.hide()
	if difficulty_modal: difficulty_modal.hide()
	if new_game_confirm_modal: new_game_confirm_modal.hide()
	if campaign_continue_modal: campaign_continue_modal.hide()
	if settings_modal: settings_modal.hide()
	
	campaign_choice_modal.show()
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.suppress_select_for(80)
	if btn_choice_continue:
		btn_choice_continue.grab_focus()

func _on_close_campaign_choice() -> void:
	if campaign_choice_modal:
		campaign_choice_modal.hide()
	menu_container.show()
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.suppress_select_for(80)
	if btn_campaign:
		btn_campaign.grab_focus()

func _on_choice_continue_pressed() -> void:
	_open_campaign_continue_modal()

func _on_choice_new_game_pressed() -> void:
	if new_game_confirm_modal:
		if campaign_choice_modal: campaign_choice_modal.hide()
		new_game_confirm_modal.show()
		var am := get_node_or_null("/root/AudioManager")
		if am:
			am.suppress_select_for(80)
		if btn_new_game_cancel:
			btn_new_game_cancel.grab_focus()
	else:
		_open_difficulty_modal()

func _on_new_game_confirmed() -> void:
	if new_game_confirm_modal:
		new_game_confirm_modal.hide()
	_open_difficulty_modal()

func _on_new_game_cancelled() -> void:
	if new_game_confirm_modal:
		new_game_confirm_modal.hide()
	_open_campaign_choice_modal()

func _open_campaign_continue_modal() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if not sm or not sm.has_active_campaign():
		_open_difficulty_modal()
		return
		
	var save: Dictionary = sm.get_active_campaign()
	var hero_id: String = save.get("hero_id", "aron")
	var stage_idx: int = int(save.get("stage_index", 1))
	var diff: String = str(save.get("difficulty", "medium")).to_upper()
	var saved_time: String = str(save.get("saved_at", ""))
	
	var meta: Dictionary = sm.get_hero_meta(hero_id)
	if hero_portrait_rect:
		var port_path = meta.get("portrait", "res://assets/ui/portraits/portrait_aron.png")
		if ResourceLoader.exists(port_path):
			hero_portrait_rect.texture = load(port_path)
			
	if hero_name_label:
		hero_name_label.text = meta.get("name", hero_id.to_upper())
		hero_name_label.add_theme_color_override("font_color", meta.get("color", Color(1, 0.85, 0.25)))
		
	if hero_archetype_label:
		hero_archetype_label.text = "✦ %s ✦" % meta.get("title", "Challenger").to_upper()
		
	if stage_progress_label:
		if stage_idx <= 5:
			stage_progress_label.text = "TRIAL PROGRESS: STAGE %d / 6" % stage_idx
		else:
			stage_progress_label.text = "FINAL TRIAL: THE FIRST FALLEN (STAGE 6/6)"
			
	# Opponent & stage
	var claimants = save.get("campaign_claimants", [])
	var stages = save.get("campaign_stages", [])
	var opp_name = "THE FIRST FALLEN"
	var stage_key = "ruined_school"
	
	if stage_idx <= 5 and (stage_idx - 1) < claimants.size():
		var opp_id = claimants[stage_idx - 1]
		var opp_meta = sm.get_hero_meta(opp_id)
		opp_name = opp_meta.get("name", str(opp_id).to_upper())
	if stage_idx <= 5 and (stage_idx - 1) < stages.size():
		stage_key = stages[stage_idx - 1]
		
	if opponent_label:
		opponent_label.text = "Target Lawan: VS %s" % opp_name
	if arena_label:
		arena_label.text = "Arena Panggung: %s" % sm.get_stage_display_name(stage_key)
	if difficulty_label:
		var diff_str = "WARRIOR (MEDIUM)"
		if diff == "EASY": diff_str = "APPRENTICE (EASY)"
		elif diff == "HARD": diff_str = "SOVEREIGN (HARD)"
		difficulty_label.text = "Tingkat Kesulitan: %s" % diff_str
	if saved_time_label:
		saved_time_label.text = "Terakhir Disimpan: %s" % (saved_time if saved_time != "" else "Baru saja")
		
	if campaign_choice_modal:
		campaign_choice_modal.hide()
	campaign_continue_modal.show()
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.suppress_select_for(80)
	if btn_continue_confirm:
		btn_continue_confirm.grab_focus()

func _on_continue_confirm_pressed() -> void:
	if campaign_continue_modal:
		campaign_continue_modal.hide()
	GameManager.resume_saved_campaign()

func _on_continue_back_pressed() -> void:
	if campaign_continue_modal:
		campaign_continue_modal.hide()
	_open_campaign_choice_modal()

func _open_difficulty_modal() -> void:
	menu_container.hide()
	if campaign_choice_modal: campaign_choice_modal.hide()
	if new_game_confirm_modal: new_game_confirm_modal.hide()
	if campaign_continue_modal: campaign_continue_modal.hide()
	if difficulty_modal:
		difficulty_modal.show()
		var am := get_node_or_null("/root/AudioManager")
		if am:
			am.suppress_select_for(80)
		if btn_medium:
			btn_medium.grab_focus()

func _on_select_difficulty(diff: String) -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm and sm.has_active_campaign():
		sm.clear_campaign_save()
	GameManager.setup_campaign(diff)

func _on_close_difficulty() -> void:
	if difficulty_modal:
		difficulty_modal.hide()
	menu_container.show()
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.suppress_select_for(80)
	if btn_campaign:
		btn_campaign.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var am := get_node_or_null("/root/AudioManager")
		if campaign_continue_modal and campaign_continue_modal.visible:
			if am: am.play_sfx("back")
			_on_continue_back_pressed()
			get_viewport().set_input_as_handled()
		elif new_game_confirm_modal and new_game_confirm_modal.visible:
			if am: am.play_sfx("back")
			_on_new_game_cancelled()
			get_viewport().set_input_as_handled()
		elif campaign_choice_modal and campaign_choice_modal.visible:
			if am: am.play_sfx("back")
			_on_close_campaign_choice()
			get_viewport().set_input_as_handled()
		elif difficulty_modal and difficulty_modal.visible:
			if am: am.play_sfx("back")
			_on_close_difficulty()
			get_viewport().set_input_as_handled()
		elif settings_modal and settings_modal.visible:
			if am: am.play_sfx("back")
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
	if audio_settings_group:
		audio_settings_group.refresh()
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.suppress_select_for(80)

	if btn_close_settings:
		btn_close_settings.grab_focus()


func _on_close_settings() -> void:
	settings_modal.hide()
	menu_container.show()
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.suppress_select_for(80)
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
