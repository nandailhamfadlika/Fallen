class_name ThronePlatformStage
extends Node2D

const FIGHTER_SCENES = {
	"aron": "res://src/characters/Aron.tscn",
	"om_hami": "res://src/characters/OmHami.tscn",
	"kemet": "res://src/characters/Kemet.tscn",
	"butler": "res://src/characters/Butler.tscn",
	"mike": "res://src/characters/Mike.tscn",
	"muslan": "res://src/characters/Muslan.tscn",
	"rin": "res://src/characters/Rin.tscn",
	"sunkibo": "res://src/characters/Sunkibo.tscn",
	"the_first_fallen": "res://src/characters/TheFirstFallen.tscn",
	"dummy": "res://src/characters/DummyTarget.tscn"
}

# Stage spawn position overrides (optional per stage scene)
@export var p1_spawn_pos: Vector2 = Vector2.ZERO
@export var p2_spawn_pos: Vector2 = Vector2.ZERO
@export var p3_spawn_pos: Vector2 = Vector2.ZERO
@export var p4_spawn_pos: Vector2 = Vector2.ZERO
@export var randomize_spawns: bool = true

const DEFAULT_SPAWN_POSITIONS = [
	Vector2(400, 420),
	Vector2(880, 420),
	Vector2(540, 420),
	Vector2(740, 420)
]

var valid_platforms: Array[Dictionary] = []

@onready var hud: HUD = $HUD
@onready var death_zone: DeathZone = $DeathZone
@onready var pause_menu: PauseMenu = $PauseMenu

# Backwards compatibility reference
var p1: FighterBase
var p2: FighterBase

var fighters: Array[FighterBase] = []
var match_over: bool = false
var match_started: bool = false
var match_timer: float = 99.0
var timer_enabled: bool = false

var max_stocks: int = 3
var fighter_stocks: Dictionary = {}
var is_sudden_death: bool = false
var p1_won_campaign: bool = false
var campaign_advancing: bool = false

func _ready() -> void:
	fighters.clear()
	_collect_valid_platforms()

	var players_data = GameManager.active_players
	if players_data.is_empty():
		players_data = [
			{"player_id": 1, "device_type": "keyboard_wasd", "device_id": -1, "character": "aron"},
			{"player_id": 2, "device_type": "keyboard_arrows", "device_id": -1, "character": "om_hami"}
		]

	var assigned_positions: Array[Vector2] = []
	var preset_spawns = [p1_spawn_pos, p2_spawn_pos, p3_spawn_pos, p4_spawn_pos]

	for i in range(players_data.size()):
		var p_info = players_data[i]
		var char_key = p_info.get("character", "aron")
		if GameManager.game_mode == "training" and i == 1:
			char_key = "dummy"

		var scene_path = FIGHTER_SCENES.get(char_key, FIGHTER_SCENES["aron"])
		var scene: PackedScene = load(scene_path) if scene_path is String else scene_path
		if not scene:
			printerr("Failed to load fighter scene: ", scene_path)
			continue
		var fighter: FighterBase = scene.instantiate()
		fighter.player_id = p_info.get("player_id", i + 1)
		
		var spawn_pos: Vector2 = Vector2.ZERO
		if GameManager.game_mode == "training":
			var main_plat = _get_main_platform()
			if not main_plat.is_empty():
				if i == 0:
					spawn_pos = Vector2(main_plat.left_x + main_plat.width * 0.35, main_plat.top_y - 50.0)
				else:
					spawn_pos = Vector2(main_plat.left_x + main_plat.width * 0.65, main_plat.top_y - 50.0)
			else:
				spawn_pos = get_random_platform_spawn_pos(assigned_positions, 50.0)
		elif randomize_spawns:
			spawn_pos = get_random_platform_spawn_pos(assigned_positions, 50.0)
		else:
			if i < preset_spawns.size() and preset_spawns[i] != Vector2.ZERO:
				spawn_pos = preset_spawns[i]
			else:
				spawn_pos = get_random_platform_spawn_pos(assigned_positions, 50.0)
		
		assigned_positions.append(spawn_pos)
		fighter.position = spawn_pos
		fighter.set_device(p_info.get("device_type", "keyboard_wasd"), p_info.get("device_id", -1))
		fighter.input_enabled = false
		fighter.velocity = Vector2.ZERO
		add_child(fighter)
		fighters.append(fighter)

		# Menghadap ke arah tengah arena
		if spawn_pos.x < 640.0:
			fighter.set_facing(1)
		else:
			fighter.set_facing(-1)

		var f_id = fighter.player_id
		fighter.hp_changed.connect(func(cur, max_hp): _on_fighter_hp_changed(f_id, cur, max_hp))
		fighter.died.connect(func(cause): _on_fighter_died(fighter, cause))
		if "attack_hitbox" in fighter and fighter.attack_hitbox:
			fighter.attack_hitbox.hit_landed.connect(_on_hit_landed)

	if fighters.size() > 0: p1 = fighters[0]
	if fighters.size() > 1: p2 = fighters[1]

	# Inisialisasi stok nyawa per fighter
	max_stocks = GameManager.round_stocks
	for f in fighters:
		fighter_stocks[f.player_id] = max_stocks

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

	# Match intro banner & 2-second freeze
	var mode_text = ""
	if GameManager.game_mode == "campaign":
		var cur_stage = GameManager.campaign_stage_index
		if cur_stage <= 5:
			mode_text = "SOUL TRIAL - STAGE %d/6 (%s)" % [cur_stage, GameManager.p2_character.to_upper()]
		else:
			mode_text = "FINAL TRIAL - THE FIRST FALLEN!"
	elif GameManager.game_mode == "pvp":
		mode_text = "%d PLAYERS BATTLE!" % fighters.size()
	else:
		mode_text = "Training Mode"

	_start_match_intro_sequence(mode_text)

func _start_match_intro_sequence(mode_text: String) -> void:
	match_started = false

	# Ensure all fighters are frozen
	for f in fighters:
		if is_instance_valid(f):
			f.input_enabled = false
			f.velocity.x = 0.0

	# Show MATCH START banner
	hud.show_banner("MATCH START", mode_text)

	# 2-second delay before characters can move and battle commences
	await get_tree().create_timer(2.0, false).timeout
	if match_over or not is_inside_tree():
		return

	# Allow all fighters to move and start AI / player inputs
	for f in fighters:
		if is_instance_valid(f):
			f.input_enabled = true

	match_started = true

	# Flash FIGHT! banner briefly
	hud.show_banner("FIGHT!", "")
	await get_tree().create_timer(0.6, false).timeout
	if not match_over and is_inside_tree():
		hud.hide_banner()

func _process(delta: float) -> void:
	if match_over or not timer_enabled or not match_started:
		return

	match_timer -= delta
	var display_sec: int = max(0, int(ceil(match_timer)))
	hud.update_timer(display_sec)

	if match_timer <= 0.0:
		_on_time_over()

func _on_time_over() -> void:
	if match_over or is_sudden_death:
		return

	# Cek sisa stock pemain yang masih bertahan
	var alive_fighters: Array[FighterBase] = []
	for f in fighters:
		if is_instance_valid(f) and fighter_stocks.get(f.player_id, 0) > 0:
			alive_fighters.append(f)

	if alive_fighters.size() == 0:
		_end_match("DRAW GAME!", "TIME OVER! Press [R] to Rematch")
		return

	# Cari petarung dengan sisa stock tertinggi
	var best_stock: int = -1
	var top_fighters: Array[FighterBase] = []
	for f in alive_fighters:
		var st = fighter_stocks.get(f.player_id, 0)
		if st > best_stock:
			best_stock = st
			top_fighters = [f]
		elif st == best_stock:
			top_fighters.append(f)

	if top_fighters.size() == 1:
		# Pemenang mutlak dengan stock terbanyak
		var winner = top_fighters[0]
		if GameManager.game_mode == "campaign":
			if winner.player_id == 1:
				p1_won_campaign = true
				var cur_st = GameManager.campaign_stage_index
				if cur_st < GameManager.CAMPAIGN_TOTAL_STAGES:
					_end_match("[ STAGE %d CLEARED! ]" % cur_st, "TIME OVER - SOULS ADVANTAGE! ADVANCING TO TRIAL %d/6... [SPACE/ATTACK]" % (cur_st + 1))
				else:
					_end_match("THE FIRST FALLEN HAS FALLEN!", "CONGRATULATIONS! THE ANCIENT THRONE IS YOURS!")
			else:
				p1_won_campaign = false
				_end_match("TRIAL FAILED!", "TIME OVER - DEFEATED IN STAGE %d. Press [R] to Retry or [Esc] for Menu" % GameManager.campaign_stage_index)
		else:
			_end_match("PLAYER %d (%s) WINS!" % [winner.player_id, winner.fighter_name.to_upper()], "TIME OVER - HIGHEST SOUL STOCKS! Press [R] to Rematch")
	else:
		# Stock sama -> Masuk ke SUDDEN DEATH!
		_trigger_sudden_death()

func _trigger_sudden_death() -> void:
	is_sudden_death = true
	timer_enabled = false
	hud.update_timer(-1) # Displays ∞
	
	hud.show_banner("SUDDEN DEATH!", "LAST STAND - NEXT FATAL HIT LOSES!")
	
	# Reset stock petarung yang bertahan menjadi 1 dan HP menjadi kritis (30.0 / 1-hit kill threshold)
	for f in fighters:
		if is_instance_valid(f) and fighter_stocks.get(f.player_id, 0) > 0:
			fighter_stocks[f.player_id] = 1
			f.current_hp = 30.0
			f.hp_changed.emit(f.current_hp, f.max_hp)
			hud.update_fighter_stocks(f.player_id, 1, 1)

	var cam = get_node_or_null("Camera2D")
	if cam and "shake_intensity" in cam:
		cam.shake_intensity = 16.0

func _input(event: InputEvent) -> void:
	if match_over and GameManager.game_mode == "campaign":
		if p1_won_campaign:
			# Skip / advance cepat dengan tombol serang / Space / Enter
			if event.is_action_pressed("ui_accept") or event.is_action_pressed("p1_attack") or (event is InputEventKey and event.pressed and not event.echo and event.physical_keycode in [KEY_SPACE, KEY_ENTER, KEY_F]):
				if not campaign_advancing:
					campaign_advancing = true
					GameManager.advance_campaign_stage()
					return
		else:
			# Jika kalah di campaign
			if event.is_action_pressed("restart") or (event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R):
				GameManager.retry_campaign_stage()
				return
			elif event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_ESCAPE):
				GameManager.go_to_main_menu()
				return

	if event.is_action_pressed("restart") or (event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R):
		if GameManager.game_mode != "campaign":
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

func _on_fighter_died(victim: FighterBase, _cause: String) -> void:
	if match_over:
		return

	var p_id = victim.player_id
	var current_st = fighter_stocks.get(p_id, 1)

	if current_st > 1:
		current_st -= 1
		fighter_stocks[p_id] = current_st
		hud.update_fighter_stocks(p_id, current_st, max_stocks)
		
		# Respawn petarung setelah jeda singkat
		await get_tree().create_timer(0.6).timeout
		if not match_over and is_instance_valid(victim):
			_respawn_fighter(victim)
	else:
		fighter_stocks[p_id] = 0
		hud.update_fighter_stocks(p_id, 0, max_stocks)
		
		# Cek petarung yang masih memiliki stock tersisa
		var survivors: Array[FighterBase] = []
		for f in fighters:
			if is_instance_valid(f) and fighter_stocks.get(f.player_id, 0) > 0:
				survivors.append(f)

		if survivors.size() <= 1:
			match_over = true
			if survivors.size() == 1:
				var winner = survivors[0]
				if GameManager.game_mode == "campaign":
					if winner.player_id == 1:
						p1_won_campaign = true
						var cur_st = GameManager.campaign_stage_index
						if cur_st < GameManager.CAMPAIGN_TOTAL_STAGES:
							_end_match("[ STAGE %d CLEARED! ]" % cur_st, "CLAIMANT DEFEATED! ADVANCING TO TRIAL %d/6... [PRESS ATTACK / SPACE]" % (cur_st + 1))
						else:
							_end_match("THE FIRST FALLEN HAS FALLEN!", "CONGRATULATIONS! THE ANCIENT THRONE IS YOURS!")
					else:
						p1_won_campaign = false
						_end_match("TRIAL FAILED!", "DEFEATED IN STAGE %d. Press [R] to Retry or [Esc] for Menu" % GameManager.campaign_stage_index)
				else:
					var win_sub = "SUDDEN DEATH VICTORY! Press [R] to Rematch" if is_sudden_death else "SOUL SURVIVAL CHAMPION! Press [R] to Rematch"
					_end_match("PLAYER %d (%s) WINS!" % [winner.player_id, winner.fighter_name.to_upper()], win_sub)
			else:
				if GameManager.game_mode == "campaign":
					p1_won_campaign = false
					_end_match("TRIAL FAILED!", "DRAW - SOULS EXTINGUISHED! Press [R] to Retry or [Esc] for Menu")
				else:
					_end_match("DRAW GAME!", "ALL SOULS EXTINGUISHED! Press [R] to Rematch")

func _respawn_fighter(victim: FighterBase) -> void:
	if not is_instance_valid(victim) or match_over:
		return
	
	# Kumpulkan posisi petarung lain yang masih hidup agar tidak respawn tepat di atas lawan
	var avoid_positions: Array[Vector2] = []
	for f in fighters:
		if is_instance_valid(f) and f != victim and f.current_state != FighterBase.State.DEAD:
			avoid_positions.append(f.global_position)
	
	var spawn_pos: Vector2 = get_random_platform_spawn_pos(avoid_positions, 80.0)
	victim.respawn_to(spawn_pos)
	
	if spawn_pos.x < 640.0:
		victim.set_facing(1)
	else:
		victim.set_facing(-1)
		
	victim.grant_spawn_invulnerability(1.5)

# --- Dynamic Platform Detection & Randomized Safe Spawning ---

func _collect_valid_platforms() -> void:
	valid_platforms.clear()
	for child in get_children():
		_scan_node_for_platforms(child)
	
	# Fallback aman jika stage tidak memiliki StaticBody2D
	if valid_platforms.is_empty():
		valid_platforms.append({
			"name": "FallbackPlatform",
			"left_x": 300.0,
			"right_x": 980.0,
			"safe_left": 360.0,
			"safe_right": 920.0,
			"top_y": 480.0,
			"width": 680.0,
			"is_main": true
		})

func _scan_node_for_platforms(node: Node) -> void:
	# Abaikan DeathZone dan Area2D
	if node is DeathZone or "Death" in node.name or node is Area2D:
		return
	
	if node is StaticBody2D:
		for c in node.get_children():
			if c is CollisionShape2D and not c.disabled and c.shape is RectangleShape2D:
				var rect_shape: RectangleShape2D = c.shape as RectangleShape2D
				var scale_factor: Vector2 = c.global_scale.abs() if c.is_inside_tree() else Vector2.ONE
				var half_size: Vector2 = rect_shape.size * 0.5 * scale_factor
				var center: Vector2 = c.global_position if c.is_inside_tree() else (node.position + c.position)
				var left_x: float = center.x - half_size.x
				var right_x: float = center.x + half_size.x
				var top_y: float = center.y - half_size.y
				var width: float = right_x - left_x
				
				# Hanya platform yang berada di atas abyss/deathzone (top_y < 700) dan cukup lebar (>= 70px)
				if width >= 70.0 and top_y < 700.0:
					var margin: float = clamp(width * 0.18, 30.0, 60.0)
					var safe_left: float = left_x + margin
					var safe_right: float = right_x - margin
					if safe_right > safe_left:
						var is_main: bool = ("Main" in node.name or "Floor" in node.name or "Island" in node.name or "Pedestal" in node.name or "Altar" in node.name or width >= 400.0)
						valid_platforms.append({
							"name": node.name,
							"left_x": left_x,
							"right_x": right_x,
							"safe_left": safe_left,
							"safe_right": safe_right,
							"top_y": top_y,
							"width": width,
							"is_main": is_main
						})
	
	# Scan recursively jika ada nested grouping
	for sub in node.get_children():
		if not (sub is StaticBody2D):
			_scan_node_for_platforms(sub)

func _get_main_platform() -> Dictionary:
	if valid_platforms.is_empty():
		_collect_valid_platforms()
	for p in valid_platforms:
		if p.get("is_main", false):
			return p
	if not valid_platforms.is_empty():
		return valid_platforms[0]
	return {}

func get_random_platform_spawn_pos(avoid_positions: Array = [], airborne_height: float = 70.0) -> Vector2:
	if valid_platforms.is_empty():
		_collect_valid_platforms()
	
	if valid_platforms.is_empty():
		return Vector2(640, 360)
	
	# Hitung total bobot berdasarkan lebar platform
	var total_weight: float = 0.0
	for p in valid_platforms:
		var w: float = p.width * (1.8 if p.is_main else 1.0)
		total_weight += w
	
	var best_pos: Vector2 = Vector2.ZERO
	var best_dist: float = -1.0
	
	# Cari kandidat posisi terbaik dengan jarak yang cukup dari avoid_positions
	for attempt in range(16):
		var r_weight: float = randf_range(0.0, total_weight)
		var chosen_plat: Dictionary = valid_platforms[0]
		var cum: float = 0.0
		for p in valid_platforms:
			var w: float = p.width * (1.8 if p.is_main else 1.0)
			cum += w
			if r_weight <= cum:
				chosen_plat = p
				break
		
		var spawn_x: float = randf_range(chosen_plat.safe_left, chosen_plat.safe_right)
		var spawn_y: float = chosen_plat.top_y - airborne_height
		var candidate: Vector2 = Vector2(spawn_x, spawn_y)
		
		if avoid_positions.is_empty():
			return candidate
		
		var min_dist: float = 99999.0
		for other in avoid_positions:
			var d: float = candidate.distance_to(other)
			if d < min_dist:
				min_dist = d
		
		if min_dist > best_dist:
			best_dist = min_dist
			best_pos = candidate
		
		if min_dist >= 140.0:
			return candidate
	
	if best_pos != Vector2.ZERO:
		return best_pos
	
	var p0 = valid_platforms[0]
	return Vector2(randf_range(p0.safe_left, p0.safe_right), p0.top_y - airborne_height)

func _end_match(title: String, subtitle: String) -> void:
	match_over = true
	timer_enabled = false
	hud.show_banner(title, subtitle)
	# Disable fighter movement after win so characters can't move unless pressing R or pausing
	for f in fighters:
		if is_instance_valid(f):
			f.input_enabled = false
			if f.current_state != FighterBase.State.DEAD:
				f.velocity.x = 0
				if f.is_on_floor():
					f.change_state(FighterBase.State.IDLE)

	if GameManager.game_mode == "campaign" and p1_won_campaign:
		_trigger_campaign_advance_timer(2.6)

func _trigger_campaign_advance_timer(delay_sec: float) -> void:
	if campaign_advancing:
		return
	await get_tree().create_timer(delay_sec).timeout
	if GameManager.game_mode == "campaign" and p1_won_campaign and not campaign_advancing:
		campaign_advancing = true
		GameManager.advance_campaign_stage()
