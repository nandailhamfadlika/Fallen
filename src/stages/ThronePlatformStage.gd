class_name ThronePlatformStage
extends Node2D

const FIGHTER_SCENES = {
	"aron": preload("res://src/characters/Aron.tscn"),
	"om_hami": preload("res://src/characters/OmHami.tscn"),
	"kemet": preload("res://src/characters/Kemet.tscn"),
	"dummy": preload("res://src/characters/DummyTarget.tscn")
}

@onready var hud: HUD = $HUD
@onready var death_zone: DeathZone = $DeathZone
@onready var pause_menu: PauseMenu = $PauseMenu

@export var p1_spawn_pos: Vector2 = Vector2(480, 408)
@export var p2_spawn_pos: Vector2 = Vector2(720, 408)

var p1: FighterBase
var p2: FighterBase
var match_over: bool = false

func _ready() -> void:
	# Spawn Player 1
	var p1_key = GameManager.p1_character if GameManager.p1_character in FIGHTER_SCENES else "aron"
	p1 = FIGHTER_SCENES[p1_key].instantiate()
	p1.player_id = 1
	p1.position = p1_spawn_pos
	add_child(p1)

	# Spawn Player 2
	var p2_key = "dummy"
	if GameManager.game_mode == "pvp":
		p2_key = GameManager.p2_character if GameManager.p2_character in FIGHTER_SCENES else "om_hami"
	
	p2 = FIGHTER_SCENES[p2_key].instantiate()
	p2.player_id = 2 if p2_key != "dummy" else 0
	p2.position = p2_spawn_pos
	add_child(p2)
	p2.set_facing(-1)

	# Connect P1 signals
	p1.hp_changed.connect(_on_p1_hp_changed)
	p1.died.connect(_on_p1_died)
	if "attack_hitbox" in p1 and p1.attack_hitbox:
		p1.attack_hitbox.hit_landed.connect(_on_hit_landed)

	# Connect P2 signals
	p2.hp_changed.connect(_on_p2_hp_changed)
	p2.died.connect(_on_p2_died)
	if "attack_hitbox" in p2 and p2.attack_hitbox:
		p2.attack_hitbox.hit_landed.connect(_on_hit_landed)

	# Connect Death Zone
	death_zone.entity_fallen.connect(_on_entity_fallen)

	# Update HUD
	hud.set_player_names(p1.fighter_name.to_upper(), p2.fighter_name.to_upper())
	hud.update_p1_hp(p1.current_hp, p1.max_hp)
	hud.update_p2_hp(p2.current_hp, p2.max_hp)

	# Match intro banner
	var mode_text = "P1: WASD+[F]  vs  P2: Arrows+[Enter]" if GameManager.game_mode == "pvp" else "Training Mode"
	hud.show_banner("FIGHT!", mode_text)
	await get_tree().create_timer(1.8).timeout
	if !match_over:
		hud.hide_banner()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _on_p1_hp_changed(cur: float, max_hp: float) -> void:
	hud.update_p1_hp(cur, max_hp)

func _on_p2_hp_changed(cur: float, max_hp: float) -> void:
	hud.update_p2_hp(cur, max_hp)

func _on_hit_landed(_target, _data) -> void:
	hud.register_hit()

func _on_entity_fallen(entity: Node2D) -> void:
	if match_over:
		return

	if entity == p1:
		_end_match(p2.fighter_name.to_upper() + " WINS!", "PLAYER 1 RING OUT! Press [R] to Rematch")
	elif entity == p2:
		_end_match(p1.fighter_name.to_upper() + " WINS!", "PLAYER 2 RING OUT! Press [R] to Rematch")

func _on_p1_died(_cause: String) -> void:
	if match_over:
		return
	_end_match(p2.fighter_name.to_upper() + " WINS!", "K.O.! Press [R] to Rematch")

func _on_p2_died(_cause: String) -> void:
	if match_over:
		return
	_end_match(p1.fighter_name.to_upper() + " WINS!", "K.O.! Press [R] to Rematch")

func _end_match(title: String, subtitle: String) -> void:
	match_over = true
	hud.show_banner(title, subtitle)
