class_name VisualNovelPlayer
extends Control

## VisualNovelPlayer - Cinematic Story & Subtitle Cutscene System
## Supports Fullscreen Illustrated Prologue & Subtitle Visual Novel Dialogue
## Keyboard, Gamepad, and Mouse interactive with Typewriter effect & Smooth Transitions

signal cutscene_completed
signal slide_changed(current_index: int, total_slides: int)

enum CutsceneType {
	UNIVERSAL_PROLOGUE,
	ARON_PROLOGUE,
	ARON_EPILOGUE,
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

# Speaker Color Palette
const COLOR_ARON := Color(0.2, 0.85, 1.0)       # Cyan Blue
const COLOR_WARGA := Color(1.0, 0.6, 0.2)      # Orange / Amber
const COLOR_NARRATOR := Color(1.0, 0.85, 0.3)   # Warm Gold
const COLOR_BOSS := Color(0.9, 0.2, 0.3)       # Void Crimson

func _ready() -> void:
	_ensure_nodes()
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
		var target_count = int(visible_chars_float)
		if target_count >= dialogue_label.get_total_character_count():
			dialogue_label.visible_characters = -1
			is_typing = false
			_update_advance_indicator(true)
		else:
			dialogue_label.visible_characters = target_count

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
	if slides.is_empty():
		return

	var current_slide = slides[current_slide_index]
	var mode = current_slide.get("mode", "dialogue")

	if mode == "dialogue" and is_typing:
		# Fast finish text
		dialogue_label.visible_characters = -1
		is_typing = false
		_update_advance_indicator(true)
	else:
		# Advance to next slide
		advance_slide()

func advance_slide() -> void:
	if current_slide_index + 1 < slides.size():
		current_slide_index += 1
		_show_current_slide(true)
	else:
		_finish_cutscene()

func _finish_cutscene() -> void:
	var tw = create_tween()
	tw.tween_property(fade_overlay, "color:a", 1.0, 0.4)
	tw.tween_callback(func():
		cutscene_completed.emit()
		if on_complete_callable.is_valid():
			on_complete_callable.call()
	)

func _on_skip_pressed() -> void:
	_finish_cutscene()

func _show_current_slide(with_transition: bool = true) -> void:
	_ensure_nodes()
	if current_slide_index < 0 or current_slide_index >= slides.size():
		return

	var slide = slides[current_slide_index]
	var mode = slide.get("mode", "dialogue")
	var bg_tex: Texture2D = slide.get("background", null)

	slide_changed.emit(current_slide_index, slides.size())

	if with_transition and bg_tex:
		var tw = create_tween()
		tw.tween_property(fade_overlay, "color:a", 0.45, 0.15)
		tw.tween_callback(func():
			background_rect.texture = bg_tex
			_apply_slide_content(slide, mode)
		)
		tw.tween_property(fade_overlay, "color:a", 0.0, 0.18)
	else:
		if bg_tex:
			background_rect.texture = bg_tex
		_apply_slide_content(slide, mode)
		if fade_overlay:
			var tw = create_tween()
			tw.tween_property(fade_overlay, "color:a", 0.0, 0.2)

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
		var color: Color = slide.get("speaker_color", COLOR_ARON)

		speaker_label.text = speaker
		speaker_label.add_theme_color_override("font_color", color)

		# Speaker badge border accent color
		if speaker_badge:
			var sb = speaker_badge.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
			if sb:
				sb.border_color = Color(color.r, color.g, color.b, 0.9)
				speaker_badge.add_theme_stylebox_override("panel", sb)

		dialogue_label.text = text
		dialogue_label.visible_characters = 0
		visible_chars_float = 0.0
		is_typing = true
		_update_advance_indicator(false)

		progress_label.text = "%d / %d" % [current_slide_index + 1, slides.size()]

func _update_advance_indicator(ready_to_advance: bool) -> void:
	if advance_indicator:
		if ready_to_advance:
			advance_indicator.text = "[ SPACE / ENTER ] ▶"
			advance_indicator.modulate = Color.WHITE
		else:
			advance_indicator.text = "..."
			advance_indicator.modulate = Color(1, 1, 1, 0.5)

# ==============================================================================
# SEQUENCE BUILDERS
# ==============================================================================

func play_universal_prologue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	# 11 sequential slides from assets/Scene/cerita_fallen/prologue_01.png to 11
	for i in range(1, 12):
		var path = "res://assets/Scene/cerita_fallen/prologue_%02d.png" % i
		if ResourceLoader.exists(path):
			slides.append({
				"background": load(path),
				"mode": "fullscreen_illustration"
			})

	current_slide_index = 0
	_show_current_slide(false)

func play_aron_prologue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var p1_tex = load("res://assets/Scene/aron_story/aron_prologue_01.jpg")
	var p2_tex = load("res://assets/Scene/aron_story/aron_prologue_02.jpg")
	var p3_tex = load("res://assets/Scene/aron_story/aron_prologue_03.jpg")

	# Scene 1: Pra-Premis
	slides.append({
		"background": p1_tex,
		"mode": "dialogue",
		"speaker": "ARON",
		"speaker_color": COLOR_ARON,
		"text": "\"Setiap pagi aku bangun jam lima, memasang handwrap, dan memukul samsak sampai buku jariku kebas. Di dinding kamarku, tatapan para pahlawan anime laga ini selalu mengingatkanku... bahwa takdir besar sedang menungguku.\""
	})

	# Scene 2: Titik Balik (Part 1 - Ejekan)
	slides.append({
		"background": p2_tex,
		"mode": "dialogue",
		"speaker": "PEMUDA / WARGA",
		"speaker_color": COLOR_WARGA,
		"text": "\"Hahaha! Lihat si Aron, masih saja main tinju-tinjuan sendirian pakai kacamata tebal itu! Sadar diri woy, kau itu cuma anak culun yang kebanyakan nonton kartun!\""
	})

	# Scene 2: Titik Balik (Part 2 - Kegigihan Aron)
	slides.append({
		"background": p2_tex,
		"mode": "dialogue",
		"speaker": "ARON",
		"speaker_color": COLOR_ARON,
		"text": "(Mengepalkan tangan, menunduk getir) \"Mereka menertawakanku. Latihan keras bertahun-tahun dianggap lelucon, dan keringatku dicap delusi murahan. Tak seorang pun mau melihat siapa aku sebenarnya...\""
	})

	# Scene 3: Panggilan Fallen
	slides.append({
		"background": p3_tex,
		"mode": "dialogue",
		"speaker": "ARON",
		"speaker_color": COLOR_ARON,
		"text": "\"Baiklah. Kalau dunia menganggapku gila, maka aku akan rebut takhta itu dan membuktikan pada kalian semua... bahwa akulah sang karakter utama!\""
	})

	current_slide_index = 0
	_show_current_slide(false)

func play_aron_epilogue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var epi1_tex = load("res://assets/Scene/aron_story/aron_epilogue_01.jpg")
	var epi2_tex = load("res://assets/Scene/aron_story/aron_epilogue_02.jpg")

	# Epilogue 1: Takhta Fallen
	slides.append({
		"background": epi1_tex,
		"mode": "dialogue",
		"speaker": "NARRATOR",
		"speaker_color": COLOR_NARRATOR,
		"text": "\"Dengan satu dentuman tinju terakhir yang memecah hening koloseum, sang penguasa purba terhempas ke jurang ketiadaan.\""
	})

	# Epilogue 2: Aron Sang Karakter Utama
	slides.append({
		"background": epi2_tex,
		"mode": "dialogue",
		"speaker": "ARON",
		"speaker_color": COLOR_ARON,
		"text": "\"Lihat ini, dunia. Figuran yang dulu kalian remehkan... sekarang memegang takdir kalian semua.\""
	})

	current_slide_index = 0
	_show_current_slide(false)
