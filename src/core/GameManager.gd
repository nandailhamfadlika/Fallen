extends Node

# Global game state manager across scenes

const PLAYER_COLORS = [
	Color(0.2, 0.85, 1.0),   # P1 Cyan
	Color(1.0, 0.35, 0.2),   # P2 Red / Orange
	Color(0.27, 0.88, 0.36), # P3 Lime Green
	Color(0.82, 0.38, 0.98)  # P4 Violet / Purple
]

# Daftar pemain aktif dalam match (2 sampai 4 pemain)
# Tiap entry: { "player_id": int, "device_type": String, "device_id": int, "character": String, "color": Color }
var active_players: Array[Dictionary] = [
	{"player_id": 1, "device_type": "keyboard_wasd", "device_id": -1, "character": "aron", "color": PLAYER_COLORS[0]},
	{"player_id": 2, "device_type": "keyboard_arrows", "device_id": -1, "character": "om_hami", "color": PLAYER_COLORS[1]}
]

# Backwards compatibility getter/setter
var p1_character: String:
	get:
		if active_players.size() > 0:
			return active_players[0].get("character", "aron")
		return "aron"
	set(val):
		if active_players.size() > 0:
			active_players[0]["character"] = val
		else:
			active_players.append({"player_id": 1, "device_type": "keyboard_wasd", "device_id": -1, "character": val, "color": PLAYER_COLORS[0]})

var p2_character: String:
	get:
		if active_players.size() > 1:
			return active_players[1].get("character", "om_hami")
		return "om_hami"
	set(val):
		if active_players.size() > 1:
			active_players[1]["character"] = val
		elif active_players.size() == 1:
			active_players.append({"player_id": 2, "device_type": "keyboard_arrows", "device_id": -1, "character": val, "color": PLAYER_COLORS[1]})

var game_mode: String = "pvp" # "pvp" or "training"
var selected_stage: String = "temple_ruin"

# Waktu ronde pertarungan: 99, 120, 150 detik (atau -1 untuk infinite / latihan)
const TIME_LIMIT_OPTIONS = [99, 120, 150, -1]
var round_time_limit: int = 99

# Opsi nyawa / soul stocks (1, 2, 3, 5) - Default: 3
const STOCK_OPTIONS = [1, 2, 3, 5]
var round_stocks: int = 3

func cycle_time_limit() -> int:
	var idx = TIME_LIMIT_OPTIONS.find(round_time_limit)
	if idx == -1:
		round_time_limit = 99
	else:
		round_time_limit = TIME_LIMIT_OPTIONS[(idx + 1) % TIME_LIMIT_OPTIONS.size()]
	return round_time_limit

func set_time_limit(seconds: int) -> void:
	if seconds in TIME_LIMIT_OPTIONS or seconds <= 0:
		round_time_limit = -1 if seconds <= 0 else seconds
	else:
		round_time_limit = 99

func get_time_limit_text() -> String:
	if round_time_limit <= 0:
		return "INFINITY"
	return "%d SECONDS" % round_time_limit

func set_stocks(stocks: int) -> void:
	if stocks in STOCK_OPTIONS:
		round_stocks = stocks
	else:
		round_stocks = 3

func cycle_stocks() -> int:
	var idx = STOCK_OPTIONS.find(round_stocks)
	if idx == -1:
		round_stocks = 3
	else:
		round_stocks = STOCK_OPTIONS[(idx + 1) % STOCK_OPTIONS.size()]
	return round_stocks

func get_stocks_text() -> String:
	if round_stocks == 1:
		return "1 SOUL (SUDDEN KO)"
	return "%d SOULS" % round_stocks

const STAGES = {
	"temple_ruin": "res://src/stages/TempleRuinStage.tscn",
	"ruined_school": "res://src/stages/ThronePlatformStage.tscn",
	"mad_lab": "res://src/stages/MadLabStage.tscn",
	"magic_waterfall": "res://src/stages/MagicWaterfallStage.tscn",
	"wild_west": "res://src/stages/WildWestStage.tscn",
	"heaven_secret": "res://src/stages/HeavenSecretStage.tscn",
	"rooftop": "res://src/stages/RooftopStage.tscn"
}

func _ready() -> void:
	_setup_app_icon()

func _setup_app_icon() -> void:
	var img: Image = null
	if ResourceLoader.exists("res://icon.png"):
		var res = load("res://icon.png")
		if res is Texture2D:
			img = res.get_image()
	if not img and FileAccess.file_exists("res://icon.png"):
		img = Image.load_from_file("res://icon.png")
	if img:
		DisplayServer.set_icon(img)

var target_stage_scene: String = ""

func load_stage_with_screen(stage_path: String) -> void:
	target_stage_scene = stage_path
	ResourceLoader.load_threaded_request(stage_path)
	get_tree().change_scene_to_file("res://src/ui/LoadingScreen.tscn")

func start_pvp_multi(players: Array[Dictionary]) -> void:
	active_players = players.duplicate(true)
	game_mode = "pvp"
	# When coming from CharacterSelect, StageSelect will be opened next.
	# If called directly without StageSelect, launches the match.

func start_pvp(char_p1: String, char_p2: String) -> void:
	active_players = [
		{"player_id": 1, "device_type": "keyboard_wasd", "device_id": -1, "character": char_p1, "color": PLAYER_COLORS[0]},
		{"player_id": 2, "device_type": "keyboard_arrows", "device_id": -1, "character": char_p2, "color": PLAYER_COLORS[1]}
	]
	game_mode = "pvp"
	var target = STAGES.get(selected_stage, STAGES["temple_ruin"])
	load_stage_with_screen(target)

func start_training() -> void:
	active_players = [
		{"player_id": 1, "device_type": "keyboard_wasd", "device_id": -1, "character": "aron", "color": PLAYER_COLORS[0]},
		{"player_id": 2, "device_type": "keyboard_arrows", "device_id": -1, "character": "dummy", "color": PLAYER_COLORS[1]}
	]
	game_mode = "training"
	var target = STAGES.get(selected_stage, STAGES["temple_ruin"])
	load_stage_with_screen(target)

func go_to_character_select() -> void:
	get_tree().change_scene_to_file("res://src/ui/CharacterSelect.tscn")

func go_to_campaign_character_select() -> void:
	get_tree().change_scene_to_file("res://src/ui/CampaignCharacterSelect.tscn")

func go_to_stage_select() -> void:
	get_tree().change_scene_to_file("res://src/ui/StageSelect.tscn")

func launch_match() -> void:
	var target = STAGES.get(selected_stage, STAGES["temple_ruin"])
	load_stage_with_screen(target)

func go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://src/ui/MainMenu.tscn")

# ==============================================================================
# CAMPAIGN / STORY MODE
# ==============================================================================

const CAMPAIGN_TIME_LIMIT: int = 120
const CAMPAIGN_STOCKS: int = 3
const CAMPAIGN_TOTAL_STAGES: int = 6 # 5 Claimants + 1 Final Boss

var campaign_difficulty: String = "medium" # "easy", "medium", "hard"
var campaign_stage_index: int = 0
var campaign_claimants: Array[String] = []
var campaign_stages: Array[String] = []
var campaign_player_device_type: String = "keyboard_wasd"
var campaign_player_device_id: int = -1

func setup_campaign(difficulty: String = "medium") -> void:
	campaign_difficulty = difficulty
	round_time_limit = CAMPAIGN_TIME_LIMIT
	round_stocks = CAMPAIGN_STOCKS
	game_mode = "campaign"
	go_to_campaign_character_select()

func start_campaign(chosen_char: String = "aron", dev_type: String = "keyboard_wasd", dev_id: int = -1) -> void:
	game_mode = "campaign"
	p1_character = chosen_char
	campaign_player_device_type = dev_type
	campaign_player_device_id = dev_id
	campaign_stage_index = 0
	round_time_limit = CAMPAIGN_TIME_LIMIT
	round_stocks = CAMPAIGN_STOCKS
	
	# Pilih 5 claimant unik dari 7 claimant lainnya
	var all_claimants: Array[String] = ["aron", "om_hami", "kemet", "butler", "mike", "muslan", "rin", "sunkibo"]
	all_claimants.erase(chosen_char)
	all_claimants.shuffle()
	campaign_claimants = all_claimants.slice(0, 5)
	
	# Rotasi stage acak untuk 5 pertarungan pertama
	var available_stages: Array[String] = ["temple_ruin", "magic_waterfall", "heaven_secret", "rooftop", "wild_west", "mad_lab"]
	available_stages.shuffle()
	campaign_stages = available_stages.slice(0, 5)
	
	active_players = [
		{"player_id": 1, "device_type": campaign_player_device_type, "device_id": campaign_player_device_id, "character": p1_character, "color": PLAYER_COLORS[0]}
	]
	get_tree().change_scene_to_file("res://src/ui/cutscenes/CampaignStoryScene.tscn")

func start_campaign_stage(stage_idx: int) -> void:
	campaign_stage_index = stage_idx
	round_time_limit = CAMPAIGN_TIME_LIMIT
	round_stocks = CAMPAIGN_STOCKS
	game_mode = "campaign"
	
	var opp_char: String = ""
	var stage_key: String = ""
	
	if stage_idx <= 5:
		var c_idx = stage_idx - 1
		opp_char = campaign_claimants[c_idx] if c_idx < campaign_claimants.size() else "om_hami"
		stage_key = campaign_stages[c_idx] if c_idx < campaign_stages.size() else "temple_ruin"
	else:
		# Final Boss: The First Fallen di Throne Platform (ruined_school)
		opp_char = "the_first_fallen"
		stage_key = "ruined_school"
	
	p2_character = opp_char
	selected_stage = stage_key
	
	active_players = [
		{
			"player_id": 1,
			"device_type": campaign_player_device_type,
			"device_id": campaign_player_device_id,
			"character": p1_character,
			"color": PLAYER_COLORS[0]
		},
		{
			"player_id": 2,
			"device_type": "ai_bot",
			"device_id": -1,
			"character": opp_char,
			"color": PLAYER_COLORS[1],
			"is_ai": true,
			"difficulty": campaign_difficulty
		}
	]
	
	launch_match()

# Backwards compatibility alias
func start_campaign_stage_1() -> void:
	start_campaign_stage(1)

func advance_campaign_stage() -> void:
	var next_idx = campaign_stage_index + 1
	if next_idx <= CAMPAIGN_TOTAL_STAGES:
		start_campaign_stage(next_idx)
	else:
		go_to_campaign_victory()

func retry_campaign_stage() -> void:
	start_campaign_stage(campaign_stage_index)

func go_to_campaign_victory() -> void:
	game_mode = "pvp"
	go_to_main_menu()
