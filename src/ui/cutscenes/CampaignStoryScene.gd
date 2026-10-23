class_name CampaignStoryScene
extends Control

## CampaignStoryScene - Orchestrates the Story Mode Narrative Flow
## Plays Universal Prologue -> Character Prologue -> Proceeds to Campaign Fight 1

@onready var vn_player: VisualNovelPlayer = $VisualNovelPlayer

var current_character: String = "aron"

func _ready() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		current_character = gm.p1_character
	if current_character.is_empty():
		current_character = "aron"
		
	# Phase 1: Play Universal Prologue (11 illustrated slides)
	vn_player.auto_start = false
	vn_player.play_universal_prologue(func():
		_on_universal_prologue_done()
	)

func _on_universal_prologue_done() -> void:
	# Phase 2: Play Character-Specific Prologue
	match current_character:
		"aron":
			vn_player.play_aron_prologue(func():
				_on_all_prologues_completed()
			)
		_:
			# Default to Aron prologue for now if character is unmapped
			vn_player.play_aron_prologue(func():
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
