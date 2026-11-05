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
	if slides.is_empty() or is_transitioning:
		return

	var current_slide = slides[current_slide_index]
	var mode = current_slide.get("mode", "dialogue")

	if mode == "dialogue" and is_typing:
		# Fast finish text
		dialogue_label.visible_characters = -1
		is_typing = false
		_update_advance_indicator(true)
	else:
		# Advance to next slide with smooth fade transition
		advance_slide()

func advance_slide() -> void:
	if is_transitioning:
		return
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

	var prologue_data = [
		{
			"paths": [
				"res://assets/Scene/cerita_fallen/cutscene 1.jpg",
				"res://assets/Scene/cerita_fallen/prologue_01.jpg",
				"res://assets/Scene/cerita_fallen/prologue_01.png"
			],
			"title": "1. A WORLD IN CHAOS",
			"text": "\"A world in chaos... This realm has long been without a ruler.\""
		},
		{
			"paths": [
				"res://assets/Scene/cerita_fallen/cutscene 2.jpg",
				"res://assets/Scene/cerita_fallen/prologue_02.jpg",
				"res://assets/Scene/cerita_fallen/prologue_02.png"
			],
			"title": "2. A PERSISTING LEGEND",
			"text": "\"Yet, a legend persists.\""
		},
		{
			"paths": [
				"res://assets/Scene/cerita_fallen/cutscene 3.jpg",
				"res://assets/Scene/cerita_fallen/prologue_03.jpg",
				"res://assets/Scene/cerita_fallen/prologue_03.png"
			],
			"title": "3. THE FALLEN",
			"text": "\"A legendary seat of power... known only as The Fallen.\""
		},
		{
			"paths": [
				"res://assets/Scene/cerita_fallen/cutscene 4.jpg",
				"res://assets/Scene/cerita_fallen/prologue_04.jpg",
				"res://assets/Scene/cerita_fallen/prologue_04.png"
			],
			"title": "4. AN ANCIENT MYTH",
			"text": "\"It is whispered that whoever sits upon it shall be granted absolute power... and the unconditional fulfillment of their deepest ambitions.\""
		},
		{
			"paths": [
				"res://assets/Scene/cerita_fallen/cutscene 5.jpg",
				"res://assets/Scene/cerita_fallen/prologue_05.jpg",
				"res://assets/Scene/cerita_fallen/prologue_05.png"
			],
			"title": "5. AND SO THEY CAME",
			"text": "\"Challengers from every corner of a shattered world. They are known as... The Claimants.\""
		},
		{
			"paths": [
				"res://assets/Scene/cerita_fallen/cutscene 6.jpg",
				"res://assets/Scene/cerita_fallen/prologue_06.jpg",
				"res://assets/Scene/cerita_fallen/prologue_06.png"
			],
			"title": "6. THE FLOATING ARENA",
			"text": "\"They gather upon a brutal, floating arena.\""
		},
		{
			"paths": [
				"res://assets/Scene/cerita_fallen/cutscene 7.jpg",
				"res://assets/Scene/cerita_fallen/prologue_07.jpg",
				"res://assets/Scene/cerita_fallen/prologue_07.png"
			],
			"title": "7. WHERE STRENGTH RULES",
			"text": "\"A ruler is not chosen by bloodlines or morality, but by close-combat skill, precision, and the will to survive on the platform.\""
		},
		{
			"paths": [
				"res://assets/Scene/cerita_fallen/cutscene 8.jpg",
				"res://assets/Scene/cerita_fallen/prologue_08.jpg",
				"res://assets/Scene/cerita_fallen/prologue_08.png"
			],
			"title": "8. TO FALL IS THE END",
			"text": "\"One mistake, one misstep, can cast a fighter into the endless void... the Death Zone.\""
		},
		{
			"paths": [
				"res://assets/Scene/cerita_fallen/cutscene 9.png",
				"res://assets/Scene/cerita_fallen/prologue_09.jpg",
				"res://assets/Scene/cerita_fallen/prologue_09.png"
			],
			"title": "9. MANY AMBITIONS",
			"text": "\"They fight for no single cause. Each Claimant carries their past, their purpose... and their own dark ambitions.\""
		},
		{
			"paths": [
				"res://assets/Scene/cerita_fallen/cutscene 10.jpg",
				"res://assets/Scene/cerita_fallen/prologue_10.jpg",
				"res://assets/Scene/cerita_fallen/prologue_10.png"
			],
			"title": "10. ONE THRONE",
			"text": "\"One throne... So many ambitions.\""
		},
		{
			"paths": [
				"res://assets/Scene/cerita_fallen/cutscene 11.jpg",
				"res://assets/Scene/cerita_fallen/prologue_11.jpg",
				"res://assets/Scene/cerita_fallen/prologue_11.png"
			],
			"title": "11. THE THRONE HAS FALLEN",
			"text": "\"In this world, power is never inherited. It is seized.\""
		}
	]

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
# ARON STORY
# ==============================================================================

func play_aron_prologue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var p1_tex = _load_texture_with_fallback(["res://assets/Scene/aron_story/aron_prologue_01.jpg", "res://assets/characters/aron/raw/aron idle.jpg"])
	var p2_tex = _load_texture_with_fallback(["res://assets/Scene/aron_story/aron_prologue_02.jpg", "res://assets/characters/aron/raw/aron hit 1.jpg"])
	var p3_tex = _load_texture_with_fallback(["res://assets/Scene/aron_story/aron_prologue_03.jpg", "res://assets/characters/aron/raw/aron hit 3.jpg"])

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

	var epi1_tex = _load_texture_with_fallback(["res://assets/Scene/aron_story/aron_epilogue_01.jpg", "res://assets/Scene/cerita_fallen/cutscene 10.jpg"])
	var epi2_tex = _load_texture_with_fallback(["res://assets/Scene/aron_story/aron_epilogue_02.jpg", "res://assets/Scene/cerita_fallen/cutscene 11.jpg"])

	slides.append({
		"background": epi1_tex,
		"mode": "dialogue",
		"speaker": "NARRATOR",
		"speaker_color": COLOR_NARRATOR,
		"text": "\"Dengan satu dentuman tinju terakhir yang memecah hening koloseum, sang penguasa purba terhempas ke jurang ketiadaan.\""
	})

	slides.append({
		"background": epi2_tex,
		"mode": "dialogue",
		"speaker": "ARON",
		"speaker_color": COLOR_ARON,
		"text": "\"Lihat ini, dunia. Figuran yang dulu kalian remehkan... sekarang memegang takdir kalian semua.\""
	})

	current_slide_index = 0
	_show_current_slide(false)

# ==============================================================================
# MIKE STORY
# ==============================================================================

func play_mike_prologue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var p1_tex = _load_texture_with_fallback(["res://assets/Scene/mike_story/mike_prologue_01.jpg", "res://assets/Scene/mike_story/mike_prologue_01.png", "res://assets/characters/mike/raw/mike idle.jpg"])
	var p2_tex = _load_texture_with_fallback(["res://assets/Scene/mike_story/mike_prologue_02.jpg", "res://assets/Scene/mike_story/mike_prologue_02.png", "res://assets/characters/mike/raw/mike hit 1.jpg"])
	var p3_tex = _load_texture_with_fallback(["res://assets/Scene/mike_story/mike_prologue_03.jpg", "res://assets/Scene/mike_story/mike_prologue_03.png", "res://assets/characters/mike/raw/mike hit 3.jpg"])

	slides.append({
		"background": p1_tex,
		"mode": "dialogue",
		"speaker": "MIKE",
		"speaker_color": COLOR_MIKE,
		"text": "\"Empat tahun... ratusan cangkir kopi sachet, revisi bab empat sebanyak tiga belas kali, dan ribuan jam tidur yang kukorbankan. Hari ini, draf skripsi bersampul tebal ini akhirnya selesai dijilid rapi. Tinggal selangkah lagi menuju toga dan kebebasan.\""
	})

	slides.append({
		"background": p2_tex,
		"mode": "dialogue",
		"speaker": "PETUGAS KAMPUS",
		"speaker_color": COLOR_WARGA,
		"text": "\"Mohon maaf, Saudara Mike. Karena ruang sidang lantai tiga hancur tertimpa petarung liar turnamen Fallen, jadwal ujian Anda dibatalkan. Sesuai regulasi sistem, Anda wajib membayar UKT semester sembilan besok pagi, atau status Anda resmi Drop Out.\""
	})

	slides.append({
		"background": p3_tex,
		"mode": "dialogue",
		"speaker": "MIKE",
		"speaker_color": COLOR_MIKE,
		"text": "\"(Mencengkeram kerangka besi kursi lipat kuliah dan menyandarkannya di pundak) 'Empat tahun begadang, dan sekarang kalian mau DO-kan aku begitu saja?! Persetan dengan birokrasi kampus! Kalau Takhta Fallen bisa mengabulkan apa saja... maka kursi lipat ini yang akan meratakan siapa pun di atas sana demi ijazah kelulusanku!'\""
	})

	current_slide_index = 0
	_show_current_slide(false)

func play_mike_epilogue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var epi_tex = _load_texture_with_fallback(["res://assets/Scene/mike_story/mike_epilogue_01.jpg", "res://assets/Scene/cerita_fallen/cutscene 10.jpg"])

	slides.append({
		"background": epi_tex,
		"mode": "dialogue",
		"speaker": "NARRATOR",
		"speaker_color": COLOR_NARRATOR,
		"text": "\"Dengan satu hantaman kursi lipat besi yang menggema ke seluruh semesta, wujud purba The First Fallen hancur lebur dan terhempas ke jurang ketiadaan.\""
	})

	slides.append({
		"background": epi_tex,
		"mode": "dialogue",
		"speaker": "MIKE",
		"speaker_color": COLOR_MIKE,
		"text": "\"(Duduk di takhta Fallen sambil menyandarkan kursi besi berlumur debu) 'Dengar ini, semesta! Dengan kuasa mutlak takhta ini... skripsiku resmi LULUS predikat Dengan Pujian tanpa revisi, dan birokrasi kampus resmi kububarkan!'\""
	})

	current_slide_index = 0
	_show_current_slide(false)

# ==============================================================================
# RIN STORY
# ==============================================================================

func play_rin_prologue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var p1_tex = _load_texture_with_fallback(["res://assets/Scene/rin_story/rin_prologue_01.jpg", "res://assets/Scene/rin_story/rin_prologue_01.png", "res://assets/characters/rin/raw/Rin idle.jpg"])
	var p2_tex = _load_texture_with_fallback(["res://assets/Scene/rin_story/rin_prologue_02.jpg", "res://assets/Scene/rin_story/rin_prologue_02.png", "res://assets/characters/rin/raw/Rin hit 1.jpg"])
	var p3_tex = _load_texture_with_fallback(["res://assets/Scene/rin_story/rin_prologue_03.jpg", "res://assets/Scene/rin_story/rin_prologue_03.png", "res://assets/characters/rin/raw/Rin hit 2.jpg"])
	var p4_tex = _load_texture_with_fallback(["res://assets/Scene/rin_story/rin_prologue_04.jpg", "res://assets/Scene/rin_story/rin_prologue_04.png", "res://assets/characters/rin/raw/Rin hit 3.jpg"])

	slides.append({
		"background": p1_tex,
		"mode": "dialogue",
		"speaker": "RIN",
		"speaker_color": COLOR_RIN,
		"text": "\"Dari fajar hingga senja, jemariku diajarkan hanya untuk memintal benang dan menatap lantai kayu yang sama. Mereka bilang batas tertinggi seorang perempuan adalah dinding rumah ini... Tapi dari balik jendela, aku selalu mendengar panggilan langit yang tak bertepi.\""
	})

	slides.append({
		"background": p2_tex,
		"mode": "dialogue",
		"speaker": "TETUA ADAT",
		"speaker_color": COLOR_WARGA,
		"text": "\"Berhenti di situ, Rin! Kau berani membawa langkahmu ke gelanggang luar?! Tempatmu adalah merajut kain, bukan menumpahkan darah di arena pertarungan kotor! Tradisi keluarga ini pantang dinodai oleh pembangkang sepertimu!\""
	})

	slides.append({
		"background": p3_tex,
		"mode": "dialogue",
		"speaker": "RIN",
		"speaker_color": COLOR_RIN,
		"text": "\"(Membuka peti rahasia pusaka neneknya yang memancarkan pendar nebula kosmik) 'Kalian menenun benang hanya untuk membelenggu sayap kami... tapi nenek mewariskan kain ini untuk membebaskanku. Jika tradisi kalian hanya melahirkan sangkar, maka dengan selendang bintang ini, aku sendiri yang akan menenun takdirku!'\""
	})

	slides.append({
		"background": p4_tex,
		"mode": "dialogue",
		"speaker": "RIN",
		"speaker_color": COLOR_RIN,
		"text": "\"(Selendang leluhur melilit lembut di tangannya memancarkan pendar energi kosmik yang membara) 'Ikatan tradisi ini resmi berakhir. Dengan selendang pusaka ini, tak ada lagi yang bisa mendikte batas langkahku. Takhta The Fallen... aku datang untuk merebutmu!'\""
	})

	current_slide_index = 0
	_show_current_slide(false)

func play_rin_epilogue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var epi_tex = _load_texture_with_fallback(["res://assets/Scene/rin_story/rin_epilogue_01.jpg", "res://assets/Scene/cerita_fallen/cutscene 10.jpg"])

	slides.append({
		"background": epi_tex,
		"mode": "dialogue",
		"speaker": "NARRATOR",
		"speaker_color": COLOR_NARRATOR,
		"text": "\"Pusaran cahaya nebula selendang kosmik Rin membelah angkasa dengan keanggunan mutlak. Sang penguasa purba terhempas dari takhtanya, hancur terkubur ke dalam kehampaan jurang ketiadaan.\""
	})

	slides.append({
		"background": epi_tex,
		"mode": "dialogue",
		"speaker": "RIN",
		"speaker_color": COLOR_RIN,
		"text": "\"(Duduk anggun dan bermartabat di Takhta The Fallen, membiarkan selendang sutra kosmiknya menyelimuti singgasana) 'Untuk kalian yang pernah membelenggu dan meremehkan langkah kami, saksikanlah. Era baru peradaban kini bermula di bawah naungan takhta ini.'\""
	})

	current_slide_index = 0
	_show_current_slide(false)

# ==============================================================================
# MUSLAN STORY
# ==============================================================================

func play_muslan_prologue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var p1_tex = _load_texture_with_fallback(["res://assets/Scene/muslan_story/muslan_prologue_01.jpg", "res://assets/characters/muslan/raw/muslan idle.jpg"])
	var p2_tex = _load_texture_with_fallback(["res://assets/Scene/muslan_story/muslan_prologue_02.jpg", "res://assets/characters/muslan/raw/muslan hit 1.jpg"])
	var p3_tex = _load_texture_with_fallback(["res://assets/Scene/muslan_story/muslan_prologue_03.jpg", "res://assets/characters/muslan/raw/muslan hit 3.jpg"])

	slides.append({
		"background": p1_tex,
		"mode": "dialogue",
		"speaker": "MUSLAN",
		"speaker_color": COLOR_MUSLAN,
		"text": "\"Bagiku, musik bukan sekadar susunan nada... tapi napas dan kejujuran hidup. Di panggung kayu beraroma asin laut ini, di hadapan orang-orang sederhana yang mendengarkan dengan hati, aku merasa laguku benar-benar memiliki jiwa.\""
	})

	slides.append({
		"background": p2_tex,
		"mode": "dialogue",
		"speaker": "PRODUSER REKAMAN",
		"speaker_color": COLOR_WARGA,
		"text": "\"Bawa pulang sampah ini, Anak Pantai! Lirikmu terlalu idealis dan aransemenmu kampungan, tidak ada nilai jualnya di industri! Pasar hanya butuh lagu pop instan, bukan rintihan sok puitis dari pengamen!\""
	})

	slides.append({
		"background": p3_tex,
		"mode": "dialogue",
		"speaker": "MUSLAN",
		"speaker_color": COLOR_MUSLAN,
		"text": "\"(Mengencangkan tali hardcase gitarnya di pundak) 'Jika telinga industri kalian terlalu tuli untuk mendengar kejujuran... maka aku akan menduduki Takhta The Fallen. Kan kujadikan seluruh semesta ini panggung pribadiku, dan kalian semua dipaksa untuk mendengarkan!'\""
	})

	current_slide_index = 0
	_show_current_slide(false)

func play_muslan_epilogue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var epi_tex = _load_texture_with_fallback(["res://assets/Scene/muslan_story/muslan_epilogue_01.jpg", "res://assets/Scene/cerita_fallen/cutscene 10.jpg"])

	slides.append({
		"background": epi_tex,
		"mode": "dialogue",
		"speaker": "NARRATOR",
		"speaker_color": COLOR_NARRATOR,
		"text": "\"Dengan satu hantaman hardcase dan dentuman akord nada distorsi terakhir yang membelah semesta, sang penguasa purba terhempas ke jurang ketiadaan. Panggung para dewa kini sunyi... menyisakan petikan senar sang musisi jalanan.\""
	})

	slides.append({
		"background": epi_tex,
		"mode": "dialogue",
		"speaker": "MUSLAN",
		"speaker_color": COLOR_MUSLAN,
		"text": "\"(Duduk santai di Takhta The Fallen sambil menyandarkan tas gitarnya di singgasana batu) 'Akhirnya... sebuah panggung megah tanpa ada produser serakah yang bisa mematikan mikrofonku. Tarik napas, pasang telinga kalian baik-baik... Dengarkan laguku, seluruh semesta!'\""
	})

	current_slide_index = 0
	_show_current_slide(false)

# ==============================================================================
# KEMET STORY
# ==============================================================================

func play_kemet_prologue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var p1_tex = _load_texture_with_fallback(["res://assets/Scene/kemet_story/kemet_prologue_01.jpg", "res://assets/Scene/kemet_story/cutscene Kemet 1.jpg"])
	var p2_tex = _load_texture_with_fallback(["res://assets/Scene/kemet_story/kemet_prologue_02.jpg", "res://assets/Scene/kemet_story/cutscene Kemet 2.jpg"])
	var p3_tex = _load_texture_with_fallback(["res://assets/Scene/kemet_story/kemet_prologue_03.png", "res://assets/Scene/kemet_story/cutscene Kemet 3.png", "res://assets/Scene/kemet_story/kemet_prologue_03.jpg"])

	slides.append({
		"background": p1_tex,
		"mode": "dialogue",
		"speaker": "KEMET",
		"speaker_color": COLOR_KEMET,
		"text": "\"Di dalam keheningan cairan hijau ini, aku tidak punya nama... hanya nomor subjek K-07. Mesin-mesin dingin ini terus menyuntikkan serum ke urat nadiku, memaksaku bermutasi menjadi senjata hidup pesanan mereka.\""
	})

	slides.append({
		"background": p2_tex,
		"mode": "dialogue",
		"speaker": "SISTEM ALARM LAB",
		"speaker_color": COLOR_WARGA,
		"text": "\"PERINGATAN! Mutasi genetik K-07 tidak stabil! Cakar bio-metalik menolak kode kendali! Subjek dicap 'PRODUK GAGAL', aktifkan protokol pemusnahan sekarang juga!\""
	})

	slides.append({
		"background": p2_tex,
		"mode": "dialogue",
		"speaker": "KEMET",
		"speaker_color": COLOR_KEMET,
		"text": "\"(Kaca tabung meledak hancur! Kemet menyeringai buas memperlihatkan taringnya) 'Produk gagal?! Kalian yang menanamkan taring dan cakar ini ke tubuhku, dan sekarang kalian takut melihat ciptaan kalian sendiri?! Mulai detik ini, aku bukan kelinci percobaan... akulah pemangsa puncak!'\""
	})

	slides.append({
		"background": p3_tex,
		"mode": "dialogue",
		"speaker": "KEMET",
		"speaker_color": COLOR_KEMET,
		"text": "\"(Menatap ke arah pusaran koloseum langit The Fallen sambil mencengkeram cakar berurat merahnya) 'Kudengar di atas sana ada singgasana yang menjanjikan kuasa mutlak bagi siapa pun yang bertahan hidup. Takhta itu akan kujadikan puncak rantai makananku!'\""
	})

	current_slide_index = 0
	_show_current_slide(false)

func play_kemet_epilogue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var epi_tex = _load_texture_with_fallback([
		"res://assets/Scene/kemet_story/kemet_epilogue_01.jpg",
		"res://assets/Scene/kemet_story/cutscene Kemet 4.jpg",
		"res://assets/Scene/kemet_story/kemet_epilogue_01.png",
		"res://assets/Scene/cerita_fallen/cutscene 10.jpg"
	])

	slides.append({
		"background": epi_tex,
		"mode": "dialogue",
		"speaker": "NARRATOR",
		"speaker_color": COLOR_NARRATOR,
		"text": "\"Dengan satu terobosan cakar mematikan, The First Fallen terhempas ke jurang ketiadaan. Di atas singgasana purba, sang pemangsa puncak kini memegang takdir semesta.\""
	})

	slides.append({
		"background": epi_tex,
		"mode": "dialogue",
		"speaker": "KEMET",
		"speaker_color": COLOR_KEMET,
		"text": "\"(Duduk congkak di atas Takhta The Fallen sambil menancapkan cakar logamnya ke singgasana batu hitam) 'Siapa sekarang yang kalian sebut produk gagal?! Biarkan para ilmuwan itu gemetar di balik sangkar mereka... Karena dari takhta ini, seluruh semesta resmi menjadi wilayah perburuanku!'\""
	})

	current_slide_index = 0
	_show_current_slide(false)

# ==============================================================================
# BUTLER STORY
# ==============================================================================

func play_butler_prologue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var p1_tex = _load_texture_with_fallback(["res://assets/Scene/butler_story/butler_prologue_01.jpg", "res://assets/Scene/butler_story/Cutscene Butler 1.jpg"])
	var p2_tex = _load_texture_with_fallback(["res://assets/Scene/butler_story/butler_prologue_02.jpg", "res://assets/Scene/butler_story/Cutscene butler 2.jpg"])
	var p3_tex = _load_texture_with_fallback(["res://assets/Scene/butler_story/butler_prologue_03.png", "res://assets/Scene/butler_story/Cutscene butler 3.png", "res://assets/Scene/butler_story/butler_prologue_03.jpg"])

	slides.append({
		"background": p1_tex,
		"mode": "dialogue",
		"speaker": "BUTLER",
		"speaker_color": COLOR_BUTLER,
		"text": "\"Keramahan, ketepatan rasa, dan dedikasi tanpa cela. Selama bertahun-tahun, aku menuangkan jiwa ke dalam setiap tetes koktail di balik meja bar marmer ini. Semua tamu memuji keanggunanku... dan aku mengira kerja keras ini dihargai.\""
	})

	slides.append({
		"background": p2_tex,
		"mode": "dialogue",
		"speaker": "PEMILIK BAR",
		"speaker_color": COLOR_WARGA,
		"text": "\"Kau dipecat, Butler! Mulai besok ada keponakanku yang menggantikan posisimu. Pesangon? Jangan bermimpi! Kau itu cuma pelayan rendahan yang gampang diganti. Ambil serbet bekasmu dan enyah dari tempatku!\""
	})

	slides.append({
		"background": p3_tex,
		"mode": "dialogue",
		"speaker": "BUTLER",
		"speaker_color": COLOR_BUTLER,
		"text": "\"(Menatap serbet kain di lengannya yang tiba-tiba meluap dalam pusaran api magis) 'Keanggunan tanpa kekuasaan hanyalah kesia-siaan seorang budak. Jika melayani manusia tamak hanya berujung penghinaan, maka aku akan menduduki Takhta The Fallen. Mulai hari ini, seluruh semesta yang akan melayaniku!'\""
	})

	current_slide_index = 0
	_show_current_slide(false)

func play_butler_epilogue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var epi_tex = _load_texture_with_fallback([
		"res://assets/Scene/butler_story/butler_epilogue_01.jpg",
		"res://assets/Scene/butler_story/cutscene butler 4.jpg",
		"res://assets/Scene/butler_story/butler_epilogue_01.png",
		"res://assets/Scene/cerita_fallen/cutscene 10.jpg"
	])

	slides.append({
		"background": epi_tex,
		"mode": "dialogue",
		"speaker": "NARRATOR",
		"speaker_color": COLOR_NARRATOR,
		"text": "\"Dengan satu kibasan cambukan api mutlak, The First Fallen terhempas ke jurang ketiadaan. Pelayanan kasar sang penguasa purba telah usai... berganti keanggunan sang tuan baru.\""
	})

	slides.append({
		"background": epi_tex,
		"mode": "dialogue",
		"speaker": "BUTLER",
		"speaker_color": COLOR_BUTLER,
		"text": "\"(Duduk bersilang kaki anggun di singgasana Takhta The Fallen sambil memegang piala anggur emas) 'Mulai detik ini, tak ada lagi tuan yang bisa membuangku. Seluruh kemewahan dan takdir semesta kini resmi tunduk di bawah telunjukku.'\""
	})

	current_slide_index = 0
	_show_current_slide(false)

# ==============================================================================
# OM HAMI STORY
# ==============================================================================

func play_om_hami_prologue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var p1_tex = _load_texture_with_fallback(["res://assets/Scene/om_hami_story/om_hami_prologue_01.jpg", "res://assets/Scene/om_hami_story/Gemini_Generated_Image_f8jpl7f8jpl7f8jp.jpg"])
	var p2_tex = _load_texture_with_fallback(["res://assets/Scene/om_hami_story/om_hami_prologue_02.jpg", "res://assets/Scene/om_hami_story/Gemini_Generated_Image_eja2oyeja2oyeja2.jpg"])
	var p3_tex = _load_texture_with_fallback(["res://assets/Scene/om_hami_story/om_hami_prologue_03.png", "res://assets/Scene/om_hami_story/Pixel Warrior Beneath the Crimson Arena.png", "res://assets/Scene/om_hami_story/om_hami_prologue_03.jpg"])

	slides.append({
		"background": p1_tex,
		"mode": "dialogue",
		"speaker": "OM HAMI",
		"speaker_color": COLOR_OM_HAMI,
		"text": "\"Segelas kopi hitam panas, sebatang rokok, dan angin malam yang tenang. Bagi orang seusiaku, tugas paling berharga adalah memastikan anak-anak kampung bisa tidur nyenyak tanpa rasa takut.\""
	})

	slides.append({
		"background": p2_tex,
		"mode": "dialogue",
		"speaker": "WARGA KAMPUNG",
		"speaker_color": COLOR_WARGA,
		"text": "\"Gawat, Om Hami! Ada dua makhluk misterius saling hantam di gang depan! Gerobak dagangan warga hancur lebur, pagar rumah roboh semua! Mereka tidak mau berhenti!\""
	})

	slides.append({
		"background": p3_tex,
		"mode": "dialogue",
		"speaker": "OM HAMI",
		"speaker_color": COLOR_OM_HAMI,
		"text": "\"(Mengisap rokoknya dalam-dalam sambil menyandarkan tongkat kayu ronda di pundaknya) 'Sudah lewat jam sepuluh malam masih bikin onar sampai merusak lapak warga. Di kampung ini aturan tetap aturan. Waktunya takhta itu kutertibkan sendiri!'\""
	})

	current_slide_index = 0
	_show_current_slide(false)

func play_om_hami_epilogue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var epi_tex = _load_texture_with_fallback([
		"res://assets/Scene/om_hami_story/om_hami_epilogue_01.jpg",
		"res://assets/Scene/om_hami_story/Gemini_Generated_Image_somelssomelssome.jpg",
		"res://assets/Scene/om_hami_story/om_hami_epilogue_01.png",
		"res://assets/Scene/cerita_fallen/cutscene 10.jpg"
	])

	slides.append({
		"background": epi_tex,
		"mode": "dialogue",
		"speaker": "NARRATOR",
		"speaker_color": COLOR_NARRATOR,
		"text": "\"Dengan satu ketukan tegas tongkat kayu rondanya, The First Fallen terhempas ke jurang ketiadaan. Jam malam semesta kini resmi ditegakkan.\""
	})

	slides.append({
		"background": epi_tex,
		"mode": "dialogue",
		"speaker": "OM HAMI",
		"speaker_color": COLOR_OM_HAMI,
		"text": "\"(Duduk selonjoran santai di Takhta The Fallen sambil mengisap rokok dan menyandarkan tongkat kayunya) 'Kursinya lumayan empuk juga buat ronda malam. Nah... sekarang seluruh wilayah aman, tertib, dan tidak ada lagi bocah nakal yang bikin keributan. Waktunya istirahat.'\""
	})

	current_slide_index = 0
	_show_current_slide(false)

# ==============================================================================
# SUNKIBO STORY
# ==============================================================================

func play_sunkibo_prologue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var p1_tex = _load_texture_with_fallback(["res://assets/Scene/sunkibo_story/sunkibo_prologue_01.jpg", "res://assets/Scene/sunkibo_story/Gemini_Generated_Image_w9l5d9w9l5d9w9l5.jpg"])
	var p2_tex = _load_texture_with_fallback(["res://assets/Scene/sunkibo_story/sunkibo_prologue_02.jpg", "res://assets/Scene/sunkibo_story/Gemini_Generated_Image_6fzxya6fzxya6fzx.jpg"])
	var p3_tex = _load_texture_with_fallback(["res://assets/Scene/sunkibo_story/sunkibo_prologue_03.png", "res://assets/Scene/sunkibo_story/Sunkibo_ Golden Cloud Warrior.png", "res://assets/Scene/sunkibo_story/sunkibo_prologue_03.jpg"])

	slides.append({
		"background": p1_tex,
		"mode": "dialogue",
		"speaker": "SUNKIBO",
		"speaker_color": COLOR_SUNKIBO,
		"text": "\"Menghabiskan hari dengan tidur siang di atas awan, makan buah persik manis, dan menikmati semilir angin surgawi. Bagiku, hidup di kahyangan ini sudah cukup damai... sebelum para dewa tua itu mulai membuka mulut.\""
	})

	slides.append({
		"background": p2_tex,
		"mode": "dialogue",
		"speaker": "DEWA KAHYANGAN",
		"speaker_color": COLOR_WARGA,
		"text": "\"Hahaha! Lihatlah kera kecil keturunan Sun Wukong itu. Memakai kacamata culun dan hanya bisa bermalas-malasan! Dia hanyalah aib keluarga yang tidak punya bakat sedikit pun!\""
	})

	slides.append({
		"background": p3_tex,
		"mode": "dialogue",
		"speaker": "SUNKIBO",
		"speaker_color": COLOR_SUNKIBO,
		"text": "\"(Menyandarkan tongkat saktinya di pundak, menyeringai nakal penuh percaya diri) 'Terus saja kalian memuji kakek buyutku! Jika langit ini terlalu sombong untuk melihatku... maka aku akan rebut Takhta The Fallen dan memaksa kalian semua menunduk padaku!'\""
	})

	current_slide_index = 0
	_show_current_slide(false)

func play_sunkibo_epilogue(callback: Callable = Callable()) -> void:
	on_complete_callable = callback
	slides.clear()

	var epi_tex = _load_texture_with_fallback([
		"res://assets/Scene/sunkibo_story/sunkibo_epilogue_01.jpg",
		"res://assets/Scene/sunkibo_story/Gemini_Generated_Image_dxb1b4dxb1b4dxb1.jpg",
		"res://assets/Scene/sunkibo_story/sunkibo_epilogue_01.png",
		"res://assets/Scene/cerita_fallen/cutscene 10.jpg"
	])

	slides.append({
		"background": epi_tex,
		"mode": "dialogue",
		"speaker": "NARRATOR",
		"speaker_color": COLOR_NARRATOR,
		"text": "\"Dengan satu ayunan tongkat emas yang memanjang membelah angkasa, The First Fallen terhempas ke jurang ketiadaan. Takhta para dewa kini dikuasai oleh sang pewaris kera sakti.\""
	})

	slides.append({
		"background": epi_tex,
		"mode": "dialogue",
		"speaker": "SUNKIBO",
		"speaker_color": COLOR_SUNKIBO,
		"text": "\"(Duduk bersila santai di Takhta The Fallen sambil mengunyah buah persik manis, tertawa puas menantang langit) 'Woy, para dewa di kahyangan! Buka mata kalian lebar-lebar! Lihat siapa sekarang penguasa baru semesta... Masih berani mengabaikan Sunkibo?! Hahaha!'\""
	})

	current_slide_index = 0
	_show_current_slide(false)

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

	# Slide 1: Narration POV approaching throne
	slides.append({
		"background": intro_tex,
		"mode": "dialogue",
		"speaker": "NARRATOR",
		"speaker_color": COLOR_NARRATOR,
		"text": "\"Setelah melewati pertarungan berdarah di atas koloseum terapung, sang penantang akhirnya melangkah ke puncak takhta kuno. Namun sebelum jemarinya menyentuh singgasana... sebuah bayangan hitam raksasa bangkit menghunus pedang purba.\""
	})

	var char_key = character_id.to_lower().strip_edges()
	var boss_line = ""
	var char_speaker = ""
	var char_color = COLOR_ARON
	var char_line = ""

	match char_key:
		"aron":
			boss_line = "\"Bocah dengan sarung tinju dan delusi kepahlawanan... Kau kira takhta penciptaan ini panggung dongengmu? Tunjukkan padaku apakah jiwamu layak, atau kau hanya sampah fana yang akan terlempar ke jurang!\""
			char_speaker = "ARON"
			char_color = COLOR_ARON
			char_line = "\"Protagonis tidak pernah lari di babak klimaks! Pasang kudakudamu, Raja Tua!\""
		"muslan":
			boss_line = "\"Pengamen jalanan berpenampilan lusuh... Tempat ini dibangun di atas tumpukan tulang, bukan nyanyian cengeng penyesalan!\""
			char_speaker = "MUSLAN"
			char_color = COLOR_MUSLAN
			char_line = "\"Darah atau musik, sama saja, Bos. Dua-duanya butuh rasa sakit biar orang mau dengar. Ayo selesaikan lagu ini.\""
		"mike":
			boss_line = "\"Membawa kursi lipat besi ke hadapan takhta penciptaan... Betapa hinanya manusia fana selemah dirimu.\""
			char_speaker = "MIKE"
			char_color = COLOR_MIKE
			char_line = "\"Tanda tangan kelulusan dan ganti rugi biaya UKT-ku! Minggir dari kursi itu sebelum kepalamu kupukul rata!\""
		"om_hami", "om hami", "hami":
			boss_line = "\"Pria beraroma tembakau dengan sebatang kayu lapuk... Kau datang ke altar suci para penguasa tanpa rasa hormat sedikit pun.\""
			char_speaker = "OM HAMI"
			char_color = COLOR_OM_HAMI
			char_line = "\"Suci apaan? Berisiknya kedengaran sampai ke RT sebelah, tongkrongan warga jadi kacau. Cepat turun, jangan bikin masalah lagi.\""
		"butler":
			boss_line = "\"Pelayan yang terbiasa menuangkan anggur untuk orang lain... Takhta ini bukan panggung bagi budak yang tak berdaya.\""
			char_speaker = "BUTLER"
			char_color = COLOR_BUTLER
			char_line = "\"Justru karena aku telah melihat betapa rakusnya para majikan, aku tahu nilai mutlak dari kekuasaan. Mari kita selesaikan pesanan Anda.\""
		"kemet":
			boss_line = "\"Ciptaan rusak yang merangkak keluar dari tabung buangan... Logam karatan di tanganmu itu adalah simbol aib kegagalan!\""
			char_speaker = "KEMET"
			char_color = COLOR_KEMET
			char_line = "\"Logam ini... yang akan merobek lehermu dan merebut singgasanamu! RRRGH!\""
		"rin":
			boss_line = "\"Gadis penenun dengan sehelai kain sutra rapuh... Kau berani menantang takdir yang dijaga ribuan bilah kehancuran?\""
			char_speaker = "RIN"
			char_color = COLOR_RIN
			char_line = "\"Kain ini bukan sekadar rajutan benang, melainkan titian martabat dan keadilan. Waktunya keangkuhanmu berakhir di sini.\""
		"sunkibo":
			boss_line = "\"Darah kera mitologi yang kekanakan... Takhta ini bukan arena sirkus untuk memuaskan rasa haus pengakuan dari kaum langitmu.\""
			char_speaker = "SUNKIBO"
			char_color = COLOR_SUNKIBO
			char_line = "\"Haha! Sirkus atau bukan, penontonnya megah banget, kan? Ayo buktikan apakah gelarmu sebagai raja tua bukan sekadar omong kosong!\""
		_:
			boss_line = "\"Siapapun dirimu fana yang lancang melangkah ke takhta ini... jiwamu akan lebur menjadi tumbal kehampaan!\""
			char_speaker = char_key.to_upper()
			char_color = COLOR_ARON
			char_line = "\"Aku datang untuk merebut takhta ini! Bersiaplah!\""

	# Slide 2: The First Fallen speaks
	slides.append({
		"background": intro_tex,
		"mode": "dialogue",
		"speaker": "THE FIRST FALLEN",
		"speaker_color": COLOR_BOSS,
		"text": boss_line
	})

	# Slide 3: Claimant responds
	slides.append({
		"background": intro_tex,
		"mode": "dialogue",
		"speaker": char_speaker,
		"speaker_color": char_color,
		"text": char_line
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

	# Slide 1: Fallen down defeated
	slides.append({
		"background": down_tex,
		"mode": "dialogue",
		"speaker": "NARRATOR",
		"speaker_color": COLOR_NARRATOR,
		"text": "\"Hantaman telak meretakkan zirah kuno sang penguasa purba. The First Fallen berlutut tersungkur di atas lantai arena yang remuk, Greatsword raksasanya terpental lepas dari genggaman.\""
	})

	var char_key = character_id.to_lower().strip_edges()
	var boss_roar = ""
	var char_speaker = ""
	var char_color = COLOR_ARON
	var char_react = ""

	match char_key:
		"aron":
			boss_roar = "\"ROOOAAARRR! KAU PIKIR BISA MENUMBANGKANKU DENGAN PUKULAN MAINAN ITU?! SAKSIKAN KEKUATAN SEJATI THE FALLEN!\""
			char_speaker = "ARON"
			char_color = COLOR_ARON
			char_react = "\"Mau kau berubah jadi monster sebesar apa pun... di babak akhir, pahlawanlah yang berdiri tegak!\""
		"muslan":
			boss_roar = "\"AKU AKAN MEREMUKKAN SETIAP SENAR DAN TULANG DI TUBUHMU! KEMATIAN ADALAH SATU-SATUNYA NADA YANG TERSISA!\""
			char_speaker = "MUSLAN"
			char_color = COLOR_MUSLAN
			char_react = "\"Distorsi suaramu jelek banget. Biar kubereskan aransemennya!\""
		"mike":
			boss_roar = "\"KEMARAHAN SEPELE DARI HEWAN TERNAK BIROKRASI! AKU AKAN MEMBAKAR SEGALA HARAPANMU MENJADI ABU!\""
			char_speaker = "MIKE"
			char_color = COLOR_MIKE
			char_react = "\"Kau tidak tahu rasanya begadang bertahun-tahun cuma untuk dihancurkan begitu saja... MAJU SINI KAU MONSTER SKRIPSI!\""
		"om_hami", "om hami", "hami":
			boss_roar = "\"LANCANG! AKU AKAN MENCABIK DAGINGMU HINGGA TAK ADA LAGI YANG MENGENALIMU!\""
			char_speaker = "OM HAMI"
			char_color = COLOR_OM_HAMI
			char_react = "\"Nah kan, dibilangin baik-baik malah ngamuk kayak orang kesurupan. Waktunya jam malam, Tong!\""
		"butler":
			boss_roar = "\"KAU HANYA SERANGGA BERPAKAIAN RAPI! RASAKAN KEPUTUSASAAN DARI KEHAMPANAN MUTLAK!\""
			char_speaker = "BUTLER"
			char_color = COLOR_BUTLER
			char_react = "\"Pelayanan sekasar ini tidak ada dalam daftar menu saya. Waktunya melunasi seluruh tagihan Anda!\""
		"kemet":
			boss_roar = "\"KAU INGIN MELIHAT MONSTER SEJATI?! BENTUK CACATMU ITU BUKAN TANDINGAN BAGI KUTUKAN KEHAMPANANKU!\""
			char_speaker = "KEMET"
			char_color = COLOR_KEMET
			char_react = "\"Bagus... monster lawan monster. Kita buktikan cakar siapa yang lebih dalam menembus daging!\""
		"rin":
			boss_roar = "\"KEADILAN ADALAH ILUSI PARA PENGECUT! KEPALAMU AKAN MEREMUK DI BAWAH CAKARKU!\""
			char_speaker = "RIN"
			char_color = COLOR_RIN
			char_react = "\"Bahkan bintang paling terang pun terbit dari kegelapan yang pekat. Rehatlah, monster nestapa... selendang ini yang akan menyucikanmu!\""
		"sunkibo":
			boss_roar = "\"KERA KURANG AJAR! AKU AKAN MEREMUKKAN MAHKOTA ITU BERSAMA TENGKORAK KEPALAMU!\""
			char_speaker = "SUNKIBO"
			char_color = COLOR_SUNKIBO
			char_react = "\"Wah, akhirnya wujud monstermu keluar juga! Kakekku dulu menghajar ratusan monster sepertimu. Sekarang giliranku!\""
		_:
			boss_roar = "\"LANCANG! KEKUATAN KEHAMPANAN INI AKAN MENELAN SELURUH SEMESTA!\""
			char_speaker = char_key.to_upper()
			char_color = COLOR_ARON
			char_react = "\"Aku tidak akan mundur sejengkal pun!\""

	# Slide 2: Evolve / Rage / Void explosion
	slides.append({
		"background": evolve_tex,
		"mode": "dialogue",
		"speaker": "THE FIRST FALLEN",
		"speaker_color": COLOR_BOSS,
		"text": boss_roar
	})

	# Slide 3: Beast stance ready for battle
	slides.append({
		"background": beast_tex,
		"mode": "dialogue",
		"speaker": char_speaker,
		"speaker_color": char_color,
		"text": char_react
	})

	current_slide_index = 0
	_show_current_slide(false)

func play_character_epilogue(character_id: String = "aron", callback: Callable = Callable()) -> void:
	match character_id.to_lower().strip_edges():
		"aron":
			play_aron_epilogue(callback)
		"rin":
			play_rin_epilogue(callback)
		"mike":
			play_mike_epilogue(callback)
		"muslan":
			play_muslan_epilogue(callback)
		"butler":
			play_butler_epilogue(callback)
		"kemet":
			play_kemet_epilogue(callback)
		"om_hami", "om hami", "hami":
			play_om_hami_epilogue(callback)
		"sunkibo":
			play_sunkibo_epilogue(callback)
		_:
			play_aron_epilogue(callback)
