class_name CampaignStoryScene
extends Control

## CampaignStoryScene - Orchestrates the Story Mode Narrative Flow
## Handles:
## 1. Prologue: Universal Prologue (11 slides) -> Character Prologue -> Campaign Stage 1
## 2. Facing The Fallen: Pre-Boss Intro Cutscene -> Final Boss Stage 6
## 3. Epilogue: Character Epilogue after defeating The First Fallen -> Main Menu

@onready var vn_player: VisualNovelPlayer = $VisualNovelPlayer

var current_character: String = "aron"
var story_mode: String = "prologue"

func _ready() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		current_character = gm.p1_character
		if "campaign_story_mode" in gm and not gm.campaign_story_mode.is_empty():
			story_mode = gm.campaign_story_mode
	if current_character.is_empty():
		current_character = "aron"
		
	vn_player.auto_start = false

	var am := get_node_or_null("/root/AudioManager")
	match story_mode:
		"facing_the_fallen":
			if am:
				am.stop_bgm(0.5)
			vn_player.play_facing_the_fallen_intro(current_character, func():
				_on_facing_the_fallen_done()
			)
		"epilogue":
			if am:
				am.stop_bgm(0.5)
			vn_player.play_character_epilogue(current_character, func():
				_on_epilogue_done()
			)
		_: # "prologue"
			if am:
				am.play_bgm("story_prologue", 0.8)
			vn_player.play_universal_prologue(func():
				_on_universal_prologue_done()
			)

func _on_universal_prologue_done() -> void:
	# Stop universal prologue BGM before character-specific prologue begins
	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.stop_bgm(0.6)

	# Phase 2: Play Character-Specific Prologue
	vn_player.play_character_prologue(current_character, func():
		_on_all_prologues_completed()
	)

func _on_all_prologues_completed() -> void:
	# Proceeds to Stage 1 of the Campaign Mode
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		if gm.has_method("start_campaign_stage_1"):
			gm.start_campaign_stage_1()
		else:
			gm.launch_match()

func _on_facing_the_fallen_done() -> void:
	# Proceeds to Final Boss Stage 6
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.start_campaign_stage(6)

func _on_epilogue_done() -> void:
	# Campaign fully completed, return to Main Menu
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.game_mode = "pvp"
		gm.campaign_story_mode = "prologue"
		gm.go_to_main_menu()
