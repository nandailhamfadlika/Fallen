class_name LoadingScreen
extends Control

# Visual & Asynchronous Threaded Stage Loader for Fallen
# Adaptively supports 2, 3, and 4 players with cinematic matchup presentation

const TIPS = [
	"TIP: Press Attack right after respawning to instantly cancel invulnerability and surprise your opponent!",
	"TIP: In Stock Mode, each life lost extinguishes a Soul Gem. The last warrior standing wins.",
	"TIP: If time runs out with equal Souls, SUDDEN DEATH triggers: 1 Soul, 1-Hit Kill threshold!",
	"TIP: Press Jump again against walls to perform a Wall Slide and Wall Jump upward to safety.",
	"TIP: Press Down + Jump while standing on thin floating platforms to drop down quickly.",
	"TIP: Time your 3-hit attack strings to confirm knockdowns and push enemies off the stage.",
	"TIP: Sunkibo can extend his golden staff to poke and punish opponents from a safe distance.",
	"TIP: Butler charges forward with rapid-fire boxing combos and devastating uppercuts.",
	"TIP: Aron's powerful lunging punches deal massive stagger damage near stage walls.",
	"TIP: Om Hami controls space with his cane—use his thrusts to hold opponents at bay.",
	"TIP: In 3-Player & 4-Player battles, let aggressive rivals clash together and strike during their recovery!",
	"TIP: In multi-fighter chaos, preserve your Souls and hold the center platform rather than chasing off-stage.",
	"TIP: Keep an eye on Soul Gems in the HUD—target opponents with 1 Soul remaining for an elimination!",
	"TIP: When surrounded by multiple fighters, use Wall Slide and Air Recovery to escape the crossfire.",
	"TIP: Watch your fighter's shadow to accurately judge landing position above floating ledges."
]

const STAGE_TITLES = {
	"ruined_school": "RUINED ACADEMY",
	"temple_ruin": "TEMPLE RUIN",
	"mad_lab": "MAD LAB",
	"magic_waterfall": "MAGIC WATERFALL",
	"wild_west": "WILD WEST",
	"heaven_secret": "HEAVEN'S SECRET",
	"rooftop": "ROOFTOP BRAWL"
}

const STAGE_PREVIEWS = {
	"ruined_school": "res://assets/stages/ruined_school_stage.png",
	"temple_ruin": "res://assets/stages/temple_ruin_stage.png",
	"mad_lab": "res://assets/stages/Mad Lab.jpg",
	"magic_waterfall": "res://assets/stages/Magic Waterfall.jpg",
	"wild_west": "res://assets/stages/Wild West.jpg",
	"heaven_secret": "res://assets/stages/Heaven secret.jpg",
	"rooftop": "res://assets/stages/Rooftop.jpg"
}

const CHARACTER_INFO = {
	"aron": {
		"name": "ARON",
		"title": "Speed Brawler",
		"portrait": "res://assets/ui/portraits/portrait_aron.png",
		"color": Color(0.2, 0.85, 1.0)
	},
	"om_hami": {
		"name": "OM HAMI",
		"title": "Cane Martial Zoner",
		"portrait": "res://assets/ui/portraits/portrait_om_hami.png",
		"color": Color(1.0, 0.75, 0.2)
	},
	"kemet": {
		"name": "KEMET",
		"title": "Claw Assassin",
		"portrait": "res://assets/ui/portraits/portrait_kemet.png",
		"color": Color(0.95, 0.35, 0.25)
	},
	"butler": {
		"name": "BUTLER",
		"title": "Cloth Flame Vanguard",
		"portrait": "res://assets/ui/portraits/portrait_butler.png",
		"color": Color(1.0, 0.82, 0.35)
	},
	"mike": {
		"name": "MIKE",
		"title": "College Chair Vanguard",
		"portrait": "res://assets/ui/portraits/portrait_mike.png",
		"color": Color(0.95, 0.65, 0.25)
	},
	"muslan": {
		"name": "MUSLAN",
		"title": "The Southern Troubadour",
		"portrait": "res://assets/ui/portraits/portrait_muslan.png",
		"color": Color(0.35, 0.7, 0.95)
	},
	"rin": {
		"name": "RIN",
		"title": "The Mystic Weaver",
		"portrait": "res://assets/ui/portraits/portrait_rin.png",
		"color": Color(0.95, 0.4, 0.65)
	},
	"sunkibo": {
		"name": "SUNKIBO",
		"title": "The Ignored Scion",
		"portrait": "res://assets/ui/portraits/portrait_sunkibo.png",
		"color": Color(0.9, 0.6, 0.2)
	},
	"the_first_fallen": {
		"name": "THE FIRST FALLEN",
		"title": "Ancient Sovereign",
		"portrait": "res://assets/ui/portraits/portrait_first_fallen.png",
		"color": Color(0.8, 0.2, 0.9)
	},
	"dummy": {
		"name": "TRAINING DUMMY",
		"title": "Combat Target",
		"portrait": "res://assets/ui/portraits/portrait_locked.png",
		"color": Color(0.6, 0.6, 0.6)
	}
}

var target_scene_path: String = ""
var progress_array: Array = []
var displayed_progress: float = 0.0
var min_load_time: float = 1.0
var elapsed_time: float = 0.0
var is_transitioning: bool = false

var status_messages: Array[String] = [
	"COMMUNING WITH SOUL REALM...",
	"MANIFESTING ARENA REALITY...",
	"CHANNELING FIGHTER ENERGIES...",
	"CALIBRATING HITBOX RESONANCE...",
	"PREPARING BATTLEGROUND..."
]
var status_index: int = 0
var status_timer: float = 0.0

@onready var background: TextureRect = $Background
@onready var subtitle_lbl: Label = $ContentContainer/MainVBox/TopHeader/SubTitle
@onready var stage_title_lbl: Label = $ContentContainer/MainVBox/TopHeader/StageTitle
@onready var rules_badge_lbl: Label = $ContentContainer/MainVBox/TopHeader/RulesBadge
@onready var matchup_container: HBoxContainer = $ContentContainer/MainVBox/MatchupContainer
@onready var status_lbl: Label = $ContentContainer/MainVBox/BottomSection/StatusRow/StatusLabel
@onready var percent_lbl: Label = $ContentContainer/MainVBox/BottomSection/StatusRow/PercentLabel
@onready var progress_bar: ProgressBar = $ContentContainer/MainVBox/BottomSection/ProgressBar
@onready var tip_lbl: Label = $ContentContainer/MainVBox/BottomSection/TipLabel
@onready var fade_overlay: ColorRect = $FadeOverlay

func _ready() -> void:
	target_scene_path = GameManager.target_stage_scene
	if target_scene_path.is_empty():
		# Fallback if opened directly in editor
		target_scene_path = GameManager.STAGES.get("temple_ruin", "res://src/stages/TempleRuinStage.tscn")
		ResourceLoader.load_threaded_request(target_scene_path)
	
	_setup_stage_visuals()
	_setup_matchup()
	_setup_tip()
	
	# Smooth fade-in
	fade_overlay.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 0.0, 0.25)

func _setup_stage_visuals() -> void:
	var stage_id = GameManager.selected_stage
	var title = STAGE_TITLES.get(stage_id, "ANCIENT ARENA")
	stage_title_lbl.text = title
	
	var players_count = max(2, GameManager.active_players.size())
	if GameManager.game_mode == "training":
		subtitle_lbl.text = "TRAINING DOJO • PRACTICE SESSION"
	elif players_count == 2:
		subtitle_lbl.text = "DUEL OF SOULS • 1 ON 1 CLASH"
	elif players_count == 3:
		subtitle_lbl.text = "TRIPLE THREAT • 3-WAY BATTLE ROYALE"
	elif players_count >= 4:
		subtitle_lbl.text = "FATAL FOUR-WAY • 4-PLAYER MAYHEM"
	
	var stocks_str = GameManager.get_stocks_text()
	var time_str = GameManager.get_time_limit_text()
	if rules_badge_lbl:
		rules_badge_lbl.text = "⚔ %s • %s • %s ⚔" % [stocks_str.to_upper(), time_str.to_upper(), title]
	
	var bg_path = STAGE_PREVIEWS.get(stage_id, "res://assets/stages/temple_ruin_stage.png")
	if ResourceLoader.exists(bg_path):
		background.texture = load(bg_path)

func _setup_matchup() -> void:
	# Clear any placeholder children
	for child in matchup_container.get_children():
		child.queue_free()
	
	var players = GameManager.active_players
	if players.size() == 0:
		players = [
			{"player_id": 1, "character": "aron", "color": GameManager.PLAYER_COLORS[0]},
			{"player_id": 2, "character": "butler", "color": GameManager.PLAYER_COLORS[1]}
		]
	
	var total_p = players.size()
	
	# Adjust separation based on player count to keep layout perfectly centered & balanced
	if total_p == 2:
		matchup_container.add_theme_constant_override("separation", 36)
	elif total_p == 3:
		matchup_container.add_theme_constant_override("separation", 20)
	else:
		matchup_container.add_theme_constant_override("separation", 14)
	
	for i in range(total_p):
		var p_data = players[i]
		var card = _create_fighter_card(p_data, i, total_p)
		matchup_container.add_child(card)
		
		# Animate card entrance (slam-in with stagger delay)
		card.modulate.a = 0.0
		card.position.y += 24.0
		var card_tween = create_tween().set_parallel(true)
		card_tween.tween_property(card, "modulate:a", 1.0, 0.28).set_delay(i * 0.07)
		card_tween.tween_property(card, "position:y", card.position.y - 24.0, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(i * 0.07)
		
		# Add VS separator between players
		if i < total_p - 1:
			var vs_elem = _create_vs_separator(total_p)
			matchup_container.add_child(vs_elem)
			vs_elem.modulate.a = 0.0
			var vs_tween = create_tween()
			vs_tween.tween_property(vs_elem, "modulate:a", 1.0, 0.2).set_delay(i * 0.07 + 0.04)

func _create_fighter_card(p_data: Dictionary, idx: int, total_players: int) -> Control:
	var actual_p_id = p_data.get("player_id", idx + 1)
	var char_id = p_data.get("character", "aron")
	var info = CHARACTER_INFO.get(char_id, {
		"name": char_id.to_upper(),
		"title": "Fighter",
		"portrait": "res://assets/ui/portraits/portrait_aron.png",
		"color": Color.WHITE
	})
	
	var default_color = GameManager.PLAYER_COLORS[(actual_p_id - 1) % GameManager.PLAYER_COLORS.size()]
	var p_color = p_data.get("color", default_color)
	
	# Responsive dimensions based on player count
	var frame_w = 185
	var frame_h = 240
	var name_font_size = 18
	var title_font_size = 11
	
	if total_players == 3:
		frame_w = 175
		frame_h = 230
		name_font_size = 17
		title_font_size = 10
	elif total_players >= 4:
		frame_w = 152
		frame_h = 205
		name_font_size = 15
		title_font_size = 9
	
	var card_vbox = VBoxContainer.new()
	card_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card_vbox.add_theme_constant_override("separation", 6)
	
	# 1. Player Tag Pill (e.g. "PLAYER 1" or "P1")
	var tag_panel = PanelContainer.new()
	var tag_style = StyleBoxFlat.new()
	tag_style.bg_color = Color(0.05, 0.07, 0.11, 0.85)
	tag_style.border_width_left = 1
	tag_style.border_width_top = 1
	tag_style.border_width_right = 1
	tag_style.border_width_bottom = 1
	tag_style.border_color = p_color
	tag_style.corner_radius_top_left = 4
	tag_style.corner_radius_top_right = 4
	tag_style.corner_radius_bottom_right = 4
	tag_style.corner_radius_bottom_left = 4
	tag_panel.add_theme_stylebox_override("panel", tag_style)
	
	var tag_margin = MarginContainer.new()
	tag_margin.add_theme_constant_override("margin_left", 8)
	tag_margin.add_theme_constant_override("margin_top", 2)
	tag_margin.add_theme_constant_override("margin_right", 8)
	tag_margin.add_theme_constant_override("margin_bottom", 2)
	
	var tag_lbl = Label.new()
	tag_lbl.text = "PLAYER %d" % actual_p_id
	tag_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag_lbl.add_theme_font_size_override("font_size", 11)
	tag_lbl.add_theme_color_override("font_color", p_color)
	tag_margin.add_child(tag_lbl)
	tag_panel.add_child(tag_margin)
	card_vbox.add_child(tag_panel)
	
	# 2. Portrait Frame Container
	var frame_panel = PanelContainer.new()
	frame_panel.custom_minimum_size = Vector2(frame_w, frame_h)
	
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.07, 0.08, 0.12, 0.9)
	style_box.border_width_left = 3
	style_box.border_width_top = 3
	style_box.border_width_right = 3
	style_box.border_width_bottom = 3
	style_box.border_color = p_color
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.shadow_color = Color(p_color.r, p_color.g, p_color.b, 0.42)
	style_box.shadow_size = 14
	frame_panel.add_theme_stylebox_override("panel", style_box)
	
	var portrait_tex = TextureRect.new()
	portrait_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var port_path = info.get("portrait", "")
	if ResourceLoader.exists(port_path):
		portrait_tex.texture = load(port_path)
	frame_panel.add_child(portrait_tex)
	card_vbox.add_child(frame_panel)
	
	# 3. Character Name
	var name_lbl = Label.new()
	name_lbl.text = info.get("name", char_id.to_upper())
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", name_font_size)
	name_lbl.add_theme_color_override("font_color", Color.WHITE)
	name_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	name_lbl.add_theme_constant_override("shadow_offset_x", 1)
	name_lbl.add_theme_constant_override("shadow_offset_y", 2)
	card_vbox.add_child(name_lbl)
	
	# 4. Character Title / Role
	var title_lbl = Label.new()
	title_lbl.text = info.get("title", "")
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", title_font_size)
	title_lbl.add_theme_color_override("font_color", Color(0.85, 0.8, 0.65))
	card_vbox.add_child(title_lbl)
	
	# 5. Device Indicator Badge (if available)
	var dev_type = p_data.get("device_type", "")
	if not dev_type.is_empty():
		var dev_lbl = Label.new()
		var dev_str = "KEYBOARD"
		if dev_type == "keyboard_wasd":
			dev_str = "⌨ WASD"
		elif dev_type == "keyboard_arrows":
			dev_str = "⌨ ARROWS"
		elif dev_type == "joypad":
			dev_str = "🎮 PAD %d" % (p_data.get("device_id", 0) + 1)
		dev_lbl.text = dev_str
		dev_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dev_lbl.add_theme_font_size_override("font_size", 9)
		dev_lbl.add_theme_color_override("font_color", Color(0.65, 0.7, 0.8))
		card_vbox.add_child(dev_lbl)
	
	return card_vbox

func _create_vs_separator(total_players: int) -> Control:
	var vs_box = VBoxContainer.new()
	vs_box.alignment = BoxContainer.ALIGNMENT_CENTER
	
	if total_players == 2:
		vs_box.custom_minimum_size = Vector2(90, 200)
		vs_box.add_theme_constant_override("separation", 6)
		
		var vs_lbl = Label.new()
		vs_lbl.text = "VS"
		vs_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vs_lbl.add_theme_font_size_override("font_size", 44)
		vs_lbl.add_theme_color_override("font_color", Color(1.0, 0.28, 0.15))
		vs_lbl.add_theme_color_override("font_shadow_color", Color(0.55, 0.05, 0.05, 0.95))
		vs_lbl.add_theme_constant_override("shadow_offset_x", 2)
		vs_lbl.add_theme_constant_override("shadow_offset_y", 3)
		vs_box.add_child(vs_lbl)
		
		var mode_lbl = Label.new()
		mode_lbl.text = GameManager.get_stocks_text()
		mode_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mode_lbl.add_theme_font_size_override("font_size", 11)
		mode_lbl.add_theme_color_override("font_color", Color(0.95, 0.82, 0.45))
		vs_box.add_child(mode_lbl)
	elif total_players == 3:
		vs_box.custom_minimum_size = Vector2(48, 180)
		
		var badge_panel = PanelContainer.new()
		var badge_style = StyleBoxFlat.new()
		badge_style.bg_color = Color(0.1, 0.05, 0.05, 0.75)
		badge_style.border_width_left = 1
		badge_style.border_width_top = 1
		badge_style.border_width_right = 1
		badge_style.border_width_bottom = 1
		badge_style.border_color = Color(1.0, 0.45, 0.2, 0.8)
		badge_style.corner_radius_top_left = 6
		badge_style.corner_radius_top_right = 6
		badge_style.corner_radius_bottom_right = 6
		badge_style.corner_radius_bottom_left = 6
		badge_panel.add_theme_stylebox_override("panel", badge_style)
		
		var vs_lbl = Label.new()
		vs_lbl.text = "VS"
		vs_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vs_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		vs_lbl.add_theme_font_size_override("font_size", 24)
		vs_lbl.add_theme_color_override("font_color", Color(1.0, 0.45, 0.15))
		vs_lbl.add_theme_color_override("font_shadow_color", Color(0.4, 0.05, 0.0, 0.9))
		vs_lbl.add_theme_constant_override("shadow_offset_x", 1)
		vs_lbl.add_theme_constant_override("shadow_offset_y", 2)
		badge_panel.add_child(vs_lbl)
		vs_box.add_child(badge_panel)
	else:
		vs_box.custom_minimum_size = Vector2(36, 160)
		
		var badge_panel = PanelContainer.new()
		var badge_style = StyleBoxFlat.new()
		badge_style.bg_color = Color(0.12, 0.06, 0.04, 0.7)
		badge_style.border_width_left = 1
		badge_style.border_width_top = 1
		badge_style.border_width_right = 1
		badge_style.border_width_bottom = 1
		badge_style.border_color = Color(1.0, 0.6, 0.25, 0.7)
		badge_style.corner_radius_top_left = 4
		badge_style.corner_radius_top_right = 4
		badge_style.corner_radius_bottom_right = 4
		badge_style.corner_radius_bottom_left = 4
		badge_panel.add_theme_stylebox_override("panel", badge_style)
		
		var vs_lbl = Label.new()
		vs_lbl.text = "VS"
		vs_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vs_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		vs_lbl.add_theme_font_size_override("font_size", 18)
		vs_lbl.add_theme_color_override("font_color", Color(1.0, 0.55, 0.2))
		vs_lbl.add_theme_color_override("font_shadow_color", Color(0.3, 0.05, 0.0, 0.9))
		vs_lbl.add_theme_constant_override("shadow_offset_x", 1)
		vs_lbl.add_theme_constant_override("shadow_offset_y", 1)
		badge_panel.add_child(vs_lbl)
		vs_box.add_child(badge_panel)
	
	return vs_box

func _setup_tip() -> void:
	var tip_text = TIPS[randi() % TIPS.size()]
	tip_lbl.text = tip_text

func _process(delta: float) -> void:
	elapsed_time += delta
	status_timer += delta
	
	# Cycle status message periodically
	if status_timer >= 0.7:
		status_timer = 0.0
		status_index = (status_index + 1) % status_messages.size()
		if not is_transitioning:
			status_lbl.text = status_messages[status_index]
	
	# Query threaded loader
	var status = ResourceLoader.load_threaded_get_status(target_scene_path, progress_array)
	var raw_progress = progress_array[0] if progress_array.size() > 0 else 0.0
	
	# Smoothly interpolate progress bar
	displayed_progress = move_toward(displayed_progress, max(raw_progress, displayed_progress), delta * 2.0)
	
	# Progress bar visual update
	var pct = int(clamp(displayed_progress * 100.0, 0.0, 100.0))
	progress_bar.value = pct
	percent_lbl.text = "%d%%" % pct
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		if elapsed_time >= min_load_time and not is_transitioning:
			is_transitioning = true
			_finish_loading()
	elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		status_lbl.text = "ERROR LOADING STAGE! ENTERING DIRECTLY..."
		if not is_transitioning:
			is_transitioning = true
			get_tree().change_scene_to_file(target_scene_path)

func _finish_loading() -> void:
	progress_bar.value = 100
	percent_lbl.text = "100%"
	status_lbl.text = "BATTLE READY!"
	status_lbl.modulate = Color(1.0, 0.9, 0.4)
	
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.25)
	await tween.finished
	
	var loaded_scene = ResourceLoader.load_threaded_get(target_scene_path)
	if loaded_scene is PackedScene:
		get_tree().change_scene_to_packed(loaded_scene)
	else:
		get_tree().change_scene_to_file(target_scene_path)
