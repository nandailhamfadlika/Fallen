class_name VisualNovelPlayer
extends Control

const StoryDatabase = preload("res://src/core/StoryDatabase.gd")

## VisualNovelPlayer - Cinematic Story & Subtitle Cutscene System
## Supports Fullscreen Illustrated Prologue & Subtitle Visual Novel Dialogue
## Keyboard, Gamepad, and Mouse interactive with Typewriter effect & Smooth Transitions

signal cutscene_completed
signal slide_changed(current_index: int, total_slides: int)

enum CutsceneType {
	UNIVERSAL_PROLOGUE,
	ARON_PROLOGUE,
	ARON_EPILOGUE,
	FACING_THE_FALLEN_INTRO,
	THE_FIRST_FALLEN_EVOLVE,
	CHARACTER_EPILOGUE,
	CUSTOM
}

@export var default_sequence: CutsceneType = CutsceneType.UNIVERSAL_PROLOGUE
@export var auto_start: bool = true

@onready var background_rect: TextureRect = $BackgroundRect
@onready var bottom_vignette: TextureRect = $BottomVignette
@onready var dialogue_container: MarginContainer = $DialogueContainer
@onready var speaker_badge: PanelContainer = $DialogueContainer/PanelContainer/MarginContainer/VBoxContainer/SpeakerRow/SpeakerBadge
@onready var speaker_label: Label = $DialogueContainer/PanelContainer/MarginContainer/VBoxContainer/SpeakerRow/SpeakerBadge/MarginContainer/SpeakerLabel
@onready var dialogue_label: RichTextLabel = $DialogueContainer/PanelContainer/MarginContainer/VBoxContainer/DialogueLabel
@onready var progress_label: Label = $DialogueContainer/PanelContainer/MarginContainer/VBoxContainer/FooterRow/ProgressLabel
@onready var advance_indicator: Label = $DialogueContainer/PanelContainer/MarginContainer/VBoxContainer/FooterRow/AdvanceIndicator
@onready var illustration_prompt: MarginContainer = $IllustrationPrompt
@onready var slide_counter: Label = $IllustrationPrompt/HBoxContainer/SlideCounter
@onready var top_bar: MarginContainer = $TopBar
@onready var btn_skip: Button = $TopBar/HBoxContainer/BtnSkip
@onready var fade_overlay: ColorRect = $FadeOverlay

# Data & Runtime Variables
var slides: Array[Dictionary] = []
var current_slide_index: int = 0
var is_typing: bool = false
var typing_speed: float = 45.0 # Chars per second
var current_text: String = ""
var visible_chars_float: float = 0.0
var on_complete_callable: Callable
var is_transitioning: bool = false
var current_tween: Tween
var _last_blip_char_idx: int = 0
var _chars_since_blip: int = 0
const BLIP_CHAR_INTERVAL: int = 3

# Speaker Color Palette
const COLOR_ARON := Color(0.2, 0.85, 1.0)       # Cyan Blue
const COLOR_WARGA := Color(1.0, 0.6, 0.2)      # Orange / Amber
const COLOR_NARRATOR := Color(1.0, 0.85, 0.3)   # Warm Gold
const COLOR_BOSS := Color(0.9, 0.2, 0.3)       # Void Crimson
const COLOR_MIKE := Color(1.0, 0.65, 0.2)      # Amber Gold
const COLOR_RIN := Color(0.85, 0.45, 1.0)      # Mystic Violet
const COLOR_MUSLAN := Color(0.9, 0.65, 0.25)   # Warm Troubadour
const COLOR_KEMET := Color(1.0, 0.25, 0.2)     # Crimson Blood
const COLOR_BUTLER := Color(0.95, 0.25, 0.25)  # Crimson Flame
const COLOR_OM_HAMI := Color(0.85, 0.58, 0.32) # Warm Tobacco
const COLOR_SUNKIBO := Color(1.0, 0.78, 0.17)  # Sunburst Gold

func _ready() -> void:
	_ensure_nodes()
	_apply_localization()
	var loc_mgr = get_node_or_null("/root/LocalizationManager")
	if loc_mgr and not loc_mgr.locale_changed.is_connected(_on_locale_changed):
		loc_mgr.locale_changed.connect(_on_locale_changed)

	if btn_skip and not btn_skip.pressed.is_connected(_on_skip_pressed):
		btn_skip.pressed.connect(_on_skip_pressed)

	if auto_start:
		match default_sequence:
			CutsceneType.UNIVERSAL_PROLOGUE:
				play_universal_prologue()
			CutsceneType.ARON_PROLOGUE:
				play_aron_prologue()
			CutsceneType.ARON_EPILOGUE:
				play_aron_epilogue()

func _apply_localization() -> void:
	if btn_skip:
		btn_skip.text = tr("VN_SKIP_BTN")

func _on_locale_changed(_new_locale: String) -> void:
	_apply_localization()

func _ensure_nodes() -> void:
	if not background_rect: background_rect = get_node_or_null("BackgroundRect")
	if not bottom_vignette: bottom_vignette = get_node_or_null("BottomVignette")
	if not dialogue_container: dialogue_container = get_node_or_null("DialogueContainer")
	if not speaker_badge: speaker_badge = get_node_or_null("DialogueContainer/PanelContainer/MarginContainer/VBoxContainer/SpeakerRow/SpeakerBadge")
	if not speaker_label: speaker_label = get_node_or_null("DialogueContainer/PanelContainer/MarginContainer/VBoxContainer/SpeakerRow/SpeakerBadge/MarginContainer/SpeakerLabel")
	if not dialogue_label: dialogue_label = get_node_or_null("DialogueContainer/PanelContainer/MarginContainer/VBoxContainer/DialogueLabel")
	if not progress_label: progress_label = get_node_or_null("DialogueContainer/PanelContainer/MarginContainer/VBoxContainer/FooterRow/ProgressLabel")
	if not advance_indicator: advance_indicator = get_node_or_null("DialogueContainer/PanelContainer/MarginContainer/VBoxContainer/FooterRow/AdvanceIndicator")
	if not illustration_prompt: illustration_prompt = get_node_or_null("IllustrationPrompt")
	if not slide_counter: slide_counter = get_node_or_null("IllustrationPrompt/HBoxContainer/SlideCounter")
	if not top_bar: top_bar = get_node_or_null("TopBar")
	if not btn_skip: btn_skip = get_node_or_null("TopBar/HBoxContainer/BtnSkip")
	if not fade_overlay: fade_overlay = get_node_or_null("FadeOverlay")

func _process(delta: float) -> void:
	if is_typing:
		visible_chars_float += typing_speed * delta
		var total_chars := dialogue_label.get_total_character_count()
		var target_count := int(visible_chars_float)
		if target_count >= total_chars:
			dialogue_label.visible_characters = -1
			is_typing = false
			_update_advance_indicator(true)
		else:
			dialogue_label.visible_characters = target_count
			_trigger_typing_sfx(target_count)

func _trigger_typing_sfx(current_visible: int) -> void:
	if current_visible <= _last_blip_char_idx:
		return

	var am := get_node_or_null("/root/AudioManager")
	var text_len := current_text.length()

	while _last_blip_char_idx < current_visible:
		if _last_blip_char_idx < text_len:
			var ch := current_text[_last_blip_char_idx]
			if ch != " " and ch != "\n" and ch != "\t":
				_chars_since_blip += 1
				if _chars_since_blip >= BLIP_CHAR_INTERVAL:
					_chars_since_blip = 0
					if am:
						am.play_sfx("text_blip", 0.12, -1.5)
		_last_blip_char_idx += 1

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode in [KEY_TAB, KEY_ESCAPE]):
		_on_skip_pressed()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("p1_attack") or event.is_action_pressed("p1_jump") \
	or (event is InputEventKey and event.pressed and event.keycode in [KEY_SPACE, KEY_ENTER]) \
	or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		_handle_advance_input()
		get_viewport().set_input_as_handled()

func _handle_advance_input() -> void:
	if slides.is_empty() or is_transitioning:
		return

	var current_slide = slides[current_slide_index]
	var mode = current_slide.get("mode", "dialogue")

	if mode == "dialogue" and is_typing:
		# Fast finish text
		dialogue_label.visible_characters = -1
		is_typing = false
		_last_blip_char_idx = current_text.length()
		_update_advance_indicator(true)
	else:
		# Advance to next slide with smooth fade transition
		advance_slide()

func advance_slide() -> void:
	if is_transitioning:
		return
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.play_sfx("confirm")
	if current_slide_index + 1 < slides.size():
		current_slide_index += 1
		_show_current_slide(true)
	else:
		_finish_cutscene()

func _finish_cutscene() -> void:
	is_transitioning = true
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	var tw = create_tween()
	tw.set_trans(Tween.TRANS_SINE)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(fade_overlay, "color:a", 1.0, 0.4)
	tw.tween_callback(func():
		is_transitioning = false
		cutscene_completed.emit()
		if on_complete_callable.is_valid():
			on_complete_callable.call()
	)

func _on_skip_pressed() -> void:
	if is_transitioning:
		return
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.play_sfx("back")
	_finish_cutscene()

func _show_current_slide(with_transition: bool = true) -> void:
	_ensure_nodes()
	if current_slide_index < 0 or current_slide_index >= slides.size():
		return

	var slide = slides[current_slide_index]
	var mode = slide.get("mode", "dialogue")
	var bg_tex: Texture2D = slide.get("background", null)

	slide_changed.emit(current_slide_index, slides.size())

	if current_tween and current_tween.is_valid():
		current_tween.kill()

	if with_transition and fade_overlay:
		is_transitioning = true
		current_tween = create_tween()
		current_tween.set_trans(Tween.TRANS_SINE)
		current_tween.set_ease(Tween.EASE_IN_OUT)

		# 1. Fade out to pure black (kesan menyimak cerita secara mendalam)
		current_tween.tween_property(fade_overlay, "color:a", 1.0, 0.32)

		# 2. Swap background texture & slide content saat layar benar-benar gelap
		current_tween.tween_callback(func():
			if bg_tex:
				background_rect.texture = bg_tex
			_apply_slide_content(slide, mode)
		)

		# Jeda hening tipis di kegelapan sebelum gambar baru terbuka
		current_tween.tween_interval(0.08)

		# 3. Fade in kembali dengan lembut
		current_tween.tween_property(fade_overlay, "color:a", 0.0, 0.38)
		current_tween.tween_callback(func():
			is_transitioning = false
		)
	else:
		if bg_tex:
			background_rect.texture = bg_tex
		_apply_slide_content(slide, mode)
		if fade_overlay:
			var tw = create_tween()
			tw.set_trans(Tween.TRANS_SINE)
			tw.set_ease(Tween.EASE_OUT)
			tw.tween_property(fade_overlay, "color:a", 0.0, 0.35)
		is_transitioning = false

func _apply_slide_content(slide: Dictionary, mode: String) -> void:
	if mode == "fullscreen_illustration":
		dialogue_container.visible = false
		bottom_vignette.visible = false
		illustration_prompt.visible = true
		slide_counter.text = "Slide %d / %d" % [current_slide_index + 1, slides.size()]
	else:
		dialogue_container.visible = true
		bottom_vignette.visible = true
		illustration_prompt.visible = false

		var speaker: String = slide.get("speaker", "")
		var text: String = slide.get("text", "")
		var color: Color = slide.get("speaker_color", COLOR_NARRATOR)

		speaker_label.text = speaker
		speaker_label.add_theme_color_override("font_color", color)

		# Speaker badge border accent color
		if speaker_badge:
			var sb = speaker_badge.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
			if sb:
				sb.border_color = Color(color.r, color.g, color.b, 0.9)
				speaker_badge.add_theme_stylebox_override("panel", sb)

		current_text = text
		dialogue_label.text = text
		dialogue_label.visible_characters = 0
		visible_chars_float = 0.0
		_last_blip_char_idx = 0
		_chars_since_blip = 0
		is_typing = true
		_update_advance_indicator(false)

		progress_label.text = "%d / %d" % [current_slide_index + 1, slides.size()]

func _update_advance_indicator(ready_to_advance: bool) -> void:
	if advance_indicator:
		if ready_to_advance:
			advance_indicator.text = tr("VN_ADVANCE_PROMPT")
			advance_indicator.modulate = Color.WHITE
		else:
			advance_indicator.text = "..."
			advance_indicator.modulate = Color(1, 1, 1, 0.5)

# ==============================================================================
# TEXTURE LOADER HELPER (ROBUST RESOURCE + DIRECT DISK FALLBACK)
# ==============================================================================

func _load_texture_with_fallback(primary_paths: Array) -> Texture2D:
	for path in primary_paths:
		var p_str = str(path)
		if ResourceLoader.exists(p_str):
			var res = load(p_str)
			if res is Texture2D:
				return res
		var global_p = ProjectSettings.globalize_path(p_str)
		if FileAccess.file_exists(p_str) or FileAccess.file_exists(global_p):
			var target_path = p_str if FileAccess.file_exists(p_str) else global_p
			var img = Image.load_from_file(target_path)
			if img and not img.is_empty():
				return ImageTexture.create_from_image(img)
	return null

# ==============================================================================
# SEQUENCE BUILDERS
# ==============================================================================

func play_universal_prologue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var locale := "en"
	var loc_mgr = get_node_or_null("/root/LocalizationManager")
	if loc_mgr:
		locale = loc_mgr.get_locale()

	var prologue_data: Array[Dictionary] = StoryDatabase.get_universal_prologue(locale)

	for data in prologue_data:
		var tex = _load_texture_with_fallback(data["paths"])
		slides.append({
			"background": tex,
			"mode": "dialogue",
			"speaker": data["title"],
			"speaker_color": COLOR_NARRATOR,
			"text": data["text"]
		})

	current_slide_index = 0
	_show_current_slide(false)

# ==============================================================================
# BILINGUAL STORY SEQUENCES (POWERED BY StoryDatabase)
# ==============================================================================

func _get_current_locale() -> String:
	var loc_mgr = get_node_or_null("/root/LocalizationManager")
	if loc_mgr:
		return loc_mgr.get_locale()
	return "en"

func _play_prologue_sequence(character_id: String, callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()
	var locale := _get_current_locale()
	var data_list: Array[Dictionary] = StoryDatabase.get_character_prologue(character_id, locale)
	for item in data_list:
		var tex = _load_texture_with_fallback(item["paths"])
		slides.append({
			"background": tex,
			"mode": "dialogue",
			"speaker": item["speaker"],
			"speaker_color": item["speaker_color"],
			"text": item["text"]
		})
	current_slide_index = 0
	_show_current_slide(false)

func _play_epilogue_sequence(character_id: String, callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()
	var locale := _get_current_locale()
	var data_list: Array[Dictionary] = StoryDatabase.get_character_epilogue(character_id, locale)
	for item in data_list:
		var tex = _load_texture_with_fallback(item["paths"])
		slides.append({
			"background": tex,
			"mode": "dialogue",
			"speaker": item["speaker"],
			"speaker_color": item["speaker_color"],
			"text": item["text"]
		})
	current_slide_index = 0
	_show_current_slide(false)

# Character Prologue Methods
func play_character_prologue(character_id: String, callback: Callable = Callable()) -> void:
	_play_prologue_sequence(character_id, callback)

func play_aron_prologue(callback: Callable = Callable()) -> void:
	_play_prologue_sequence("aron", callback)

func play_mike_prologue(callback: Callable = Callable()) -> void:
	_play_prologue_sequence("mike", callback)

func play_rin_prologue(callback: Callable = Callable()) -> void:
	_play_prologue_sequence("rin", callback)

func play_muslan_prologue(callback: Callable = Callable()) -> void:
	_play_prologue_sequence("muslan", callback)

func play_kemet_prologue(callback: Callable = Callable()) -> void:
	_play_prologue_sequence("kemet", callback)

func play_butler_prologue(callback: Callable = Callable()) -> void:
	_play_prologue_sequence("butler", callback)

func play_om_hami_prologue(callback: Callable = Callable()) -> void:
	_play_prologue_sequence("om_hami", callback)

func play_sunkibo_prologue(callback: Callable = Callable()) -> void:
	_play_prologue_sequence("sunkibo", callback)

# Character Epilogue Methods
func play_character_epilogue(character_id: String = "aron", callback: Callable = Callable()) -> void:
	_play_epilogue_sequence(character_id, callback)

func play_aron_epilogue(callback: Callable = Callable()) -> void:
	_play_epilogue_sequence("aron", callback)

func play_mike_epilogue(callback: Callable = Callable()) -> void:
	_play_epilogue_sequence("mike", callback)

func play_rin_epilogue(callback: Callable = Callable()) -> void:
	_play_epilogue_sequence("rin", callback)

func play_muslan_epilogue(callback: Callable = Callable()) -> void:
	_play_epilogue_sequence("muslan", callback)

func play_kemet_epilogue(callback: Callable = Callable()) -> void:
	_play_epilogue_sequence("kemet", callback)

func play_butler_epilogue(callback: Callable = Callable()) -> void:
	_play_epilogue_sequence("butler", callback)

func play_om_hami_epilogue(callback: Callable = Callable()) -> void:
	_play_epilogue_sequence("om_hami", callback)

func play_sunkibo_epilogue(callback: Callable = Callable()) -> void:
	_play_epilogue_sequence("sunkibo", callback)

# ==============================================================================
# THE FIRST FALLEN BOSS CUTSCENES
# ==============================================================================

func play_facing_the_fallen_intro(character_id: String = "aron", callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var intro_tex = _load_texture_with_fallback([
		"res://assets/Scene/facing_the_fallen/facing_the_fallen_intro.png",
		"res://assets/Scene/facing_the_fallen/Facing first fallen phase 1.png",
		"res://assets/characters/the_first_fallen/Chara select First fallen phase 1.jpg",
		"res://assets/Scene/cerita_fallen/cutscene 10.jpg"
	])

	var locale := _get_current_locale()
	var dial: Dictionary = StoryDatabase.get_boss_intro(character_id, locale)

	# Slide 1: Narration POV approaching throne
	slides.append({
		"background": intro_tex,
		"mode": "dialogue",
		"speaker": "NARRATOR" if locale == "en" else "NARATOR",
		"speaker_color": COLOR_NARRATOR,
		"text": dial["narrator_text"]
	})

	# Slide 2: The First Fallen speaks
	slides.append({
		"background": intro_tex,
		"mode": "dialogue",
		"speaker": dial["boss_speaker"],
		"speaker_color": dial["boss_color"],
		"text": dial["boss_text"]
	})

	# Slide 3: Claimant responds
	slides.append({
		"background": intro_tex,
		"mode": "dialogue",
		"speaker": dial["char_speaker"],
		"speaker_color": dial["char_color"],
		"text": dial["char_text"]
	})

	current_slide_index = 0
	_show_current_slide(false)

func play_first_fallen_evolve(character_id: String = "aron", callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var down_tex = _load_texture_with_fallback([
		"res://assets/Scene/facing_the_fallen/the_first_fallen_down.jpg",
		"res://assets/Scene/facing_the_fallen/the first fallen down.jpg",
		"res://assets/characters/the_first_fallen/Chara select First fallen phase 1.jpg"
	])
	var evolve_tex = _load_texture_with_fallback([
		"res://assets/Scene/facing_the_fallen/the_first_fallen_evolve.jpg",
		"res://assets/Scene/facing_the_fallen/first fallen evolve.jpg",
		"res://assets/characters/the_first_fallen/Chara select first fallen phase 2.jpg"
	])
	var beast_tex = _load_texture_with_fallback([
		"res://assets/Scene/facing_the_fallen/the_first_fallen_phase2_stand.png",
		"res://assets/Scene/facing_the_fallen/pre fight fallen phase 2.png",
		"res://assets/characters/the_first_fallen/Chara select first fallen phase 2.jpg"
	])

	var locale := _get_current_locale()
	var dial: Dictionary = StoryDatabase.get_boss_evolve(character_id, locale)

	# Slide 1: Fallen down defeated
	slides.append({
		"background": down_tex,
		"mode": "dialogue",
		"speaker": "NARRATOR" if locale == "en" else "NARATOR",
		"speaker_color": COLOR_NARRATOR,
		"text": dial["narrator_text"]
	})

	# Slide 2: Evolve / Rage / Void explosion
	slides.append({
		"background": evolve_tex,
		"mode": "dialogue",
		"speaker": dial["boss_speaker"],
		"speaker_color": dial["boss_color"],
		"text": dial["boss_roar"]
	})

	# Slide 3: Beast stance ready for battle
	slides.append({
		"background": beast_tex,
		"mode": "dialogue",
		"speaker": dial["char_speaker"],
		"speaker_color": dial["char_color"],
		"text": dial["char_react"]
	})

	current_slide_index = 0
	_show_current_slide(false)
