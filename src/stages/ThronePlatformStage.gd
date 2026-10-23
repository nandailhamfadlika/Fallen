class_name ThronePlatformStage
extends Node2D

const FIGHTER_SCENES = {
	"aron": preload("res://src/characters/Aron.tscn"),
	"om_hami": preload("res://src/characters/OmHami.tscn"),
	"kemet": preload("res://src/characters/Kemet.tscn"),
	"butler": preload("res://src/characters/Butler.tscn"),
	"mike": preload("res://src/characters/Mike.tscn"),
	"the_first_fallen": preload("res://src/characters/TheFirstFallen.tscn"),
	"dummy": preload("res://src/characters/DummyTarget.tscn")
}

const DEFAULT_SPAWN_POSITIONS = [
	Vector2(400, 420),
	Vector2(880, 420),
	Vector2(540, 420),
	Vector2(740, 420)
]

@onready var hud: HUD = $HUD
@onready var death_zone: DeathZone = $DeathZone
@onready var pause_menu: PauseMenu = $PauseMenu

# Backwards compatibility reference
var p1: FighterBase
var p2: FighterBase

var fighters: Array[FighterBase] = []
var match_over: bool = false
var match_timer: float = 99.0
var timer_enabled: bool = false

func _ready() -> void:
	fighters.clear()
	var players_data = GameManager.active_players
	if players_data.is_empty():
		players_data = [
			{"player_id": 1, "device_type": "keyboard_wasd", "device_id": -1, "character": "aron"},
			{"player_id": 2, "device_type": "keyboard_arrows", "device_id": -1, "character": "om_hami"}
		]

	for i in range(players_data.size()):
		var p_info = players_data[i]
		var char_key = p_info.get("character", "aron")
		if GameManager.game_mode == "training" and i == 1:
			char_key = "dummy"

		var scene = FIGHTER_SCENES.get(char_key, FIGHTER_SCENES["aron"])
		var fighter: FighterBase = scene.instantiate()
		fighter.player_id = p_info.get("player_id", i + 1)
		
		var spawn_pos = DEFAULT_SPAWN_POSITIONS[i % DEFAULT_SPAWN_POSITIONS.size()]
		fighter.position = spawn_pos
		
		# P1 & P3 hadap kanan (1), P2 & P4 hadap kiri (-1)
		if i % 2 == 0:
			fighter.set_facing(1)
		else:
			fighter.set_facing(-1)

		fighter.set_device(p_info.get("device_type", "keyboard_wasd"), p_info.get("device_id", -1))
		add_child(fighter)
		fighters.append(fighter)

		var f_id = fighter.player_id
		fighter.hp_changed.connect(func(cur, max_hp): _on_fighter_hp_changed(f_id, cur, max_hp))
		fighter.died.connect(func(cause): _on_fighter_died(fighter, cause))
		if "attack_hitbox" in fighter and fighter.attack_hitbox:
			fighter.attack_hitbox.hit_landed.connect(_on_hit_landed)

	if fighters.size() > 0: p1 = fighters[0]
	if fighters.size() > 1: p2 = fighters[1]

	# Setup Camera
	var cam = get_node_or_null("Camera2D")
	if cam:
		cam.stage_center = Vector2(640, 360)
		cam.targets.clear()
		for f in fighters:
			cam.add_target(f)

	# Connect Death Zone
	if death_zone:
		death_zone.entity_fallen.connect(_on_entity_fallen)

	# Setup HUD
	hud.setup_multiplayer(fighters, players_data)

	# Setup Round Timer
	if GameManager.game_mode == "training" or GameManager.round_time_limit <= 0:
		timer_enabled = false
		hud.update_timer(-1)
	else:
		match_timer = float(GameManager.round_time_limit)
		timer_enabled = true
		hud.update_timer(int(match_timer))

	# Match intro banner
	var mode_text = "%d PLAYERS BATTLE!" % fighters.size() if GameManager.game_mode == "pvp" else "Training Mode"
	hud.show_banner("FIGHT!", mode_text)
	await get_tree().create_timer(1.8).timeout
	if !match_over:
		hud.hide_banner()

func _process(delta: float) -> void:
	if match_over or not timer_enabled:
		return

	match_timer -= delta
	var display_sec: int = max(0, int(ceil(match_timer)))
	hud.update_timer(display_sec)

	if match_timer <= 0.0:
		_on_time_over()

func _on_time_over() -> void:
	if match_over:
		return
	timer_enabled = false

	# Cari pemain dengan rasio HP tertinggi
	var best_fighter: FighterBase = null
	var best_ratio: float = -1.0
	var is_draw: bool = false

	for f in fighters:
		if is_instance_valid(f):
			var ratio = f.current_hp / f.max_hp
			if ratio > best_ratio:
				best_ratio = ratio
				best_fighter = f
				is_draw = false
			elif is_equal_approx(ratio, best_ratio):
				is_draw = true

	if is_draw or best_fighter == null:
		_end_match("DRAW GAME!", "TIME OVER - EQUAL HP! Press [R] to Rematch")
	else:
		_end_match("PLAYER %d (%s) WINS!" % [best_fighter.player_id, best_fighter.fighter_name.to_upper()], "TIME OVER - HIGHER HP! Press [R] to Rematch")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _on_fighter_hp_changed(p_id: int, cur: float, max_hp: float) -> void:
	hud.update_fighter_hp(p_id, cur, max_hp)

func _on_p1_hp_changed(cur: float, max_hp: float) -> void:
	hud.update_fighter_hp(1, cur, max_hp)

func _on_p2_hp_changed(cur: float, max_hp: float) -> void:
	hud.update_fighter_hp(2, cur, max_hp)

func _on_hit_landed(_target, _data) -> void:
	hud.register_hit()

func _on_entity_fallen(entity: Node2D) -> void:
	if match_over:
		return
	if entity is FighterBase and entity.current_state != FighterBase.State.DEAD:
		entity.trigger_ring_out()

func _on_fighter_died(_victim: FighterBase, _cause: String) -> void:
	if match_over:
		return

	# Hitung pemain yang masih bertahan hidup
	var alive_fighters: Array[FighterBase] = []
	for f in fighters:
		if is_instance_valid(f) and f.current_state != FighterBase.State.DEAD:
			alive_fighters.append(f)

	if alive_fighters.size() <= 1:
		match_over = true
		if alive_fighters.size() == 1:
			var winner = alive_fighters[0]
			_end_match("PLAYER %d (%s) WINS!" % [winner.player_id, winner.fighter_name.to_upper()], "VICTORY! Press [R] to Rematch")
		else:
			_end_match("DRAW GAME!", "ALL FIGHTERS DOWN! Press [R] to Rematch")

func _end_match(title: String, subtitle: String) -> void:
	match_over = true
	timer_enabled = false
	hud.show_banner(title, subtitle)
