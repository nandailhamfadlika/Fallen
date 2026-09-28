extends Node

# Global game state manager across scenes
var p1_character: String = "aron"
var p2_character: String = "om_hami"
var game_mode: String = "pvp" # "pvp" or "training"
var selected_stage: String = "temple_ruin" # "temple_ruin" or "ruined_school"

const STAGES = {
	"temple_ruin": "res://src/stages/TempleRuinStage.tscn",
	"ruined_school": "res://src/stages/ThronePlatformStage.tscn"
}

func start_pvp(char_p1: String, char_p2: String) -> void:
	p1_character = char_p1
	p2_character = char_p2
	game_mode = "pvp"
	var target = STAGES.get(selected_stage, STAGES["temple_ruin"])
	get_tree().change_scene_to_file(target)

func start_training() -> void:
	p1_character = "aron"
	p2_character = "dummy"
	game_mode = "training"
	var target = STAGES.get(selected_stage, STAGES["temple_ruin"])
	get_tree().change_scene_to_file(target)

func go_to_character_select() -> void:
	get_tree().change_scene_to_file("res://src/ui/CharacterSelect.tscn")

func go_to_stage_select() -> void:
	get_tree().change_scene_to_file("res://src/ui/StageSelect.tscn")

func launch_match() -> void:
	var target = STAGES.get(selected_stage, STAGES["temple_ruin"])
	get_tree().change_scene_to_file(target)

func go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://src/ui/MainMenu.tscn")
