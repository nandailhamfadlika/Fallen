class_name TheFirstFallen
extends FighterBase

## The First Fallen - Final Boss Character for Fallen Campaign Mode
## Supports Phase 1 (Armored Sovereign with Greatsword) & Phase 2 (Monstrous Beast with Void Claws)
## Features massive HP, heavy poise (absorbs knockback), anti-ring-out immunity, and challenging AI.

signal phase_changed(new_phase: int)

enum BossPhase {
	PHASE_1_ARMORED,
	PHASE_2_BEAST
}

@export var current_phase: BossPhase = BossPhase.PHASE_1_ARMORED
@export var is_boss_ai: bool = true

@onready var attack_hitbox: Hitbox = $AttackHitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var void_particles: GPUParticles2D = get_node_or_null("VoidParticles")

# Boss State & AI Variables
var target_player: CharacterBody2D = null
var ai_decision_timer: float = 0.0
var ai_reaction_timer: float = 0.0
var phase_transformed: bool = false
var combo_step: int = 0
var can_chain_combo: bool = false
var has_buffered_attack: bool = false

# Poise and Weight resistance
var knockback_resistance: float = 0.08 # Only receives 8% knockback velocity

func _ready() -> void:
	fighter_name = "The First Fallen"
	if player_id <= 1:
		player_id = 2
	
	super._ready()
	
	if attack_hitbox:
		attack_hitbox.attacker_node = self
		attack_hitbox.monitoring = false
		
	apply_phase(current_phase)

func apply_phase(phase: BossPhase) -> void:
	current_phase = phase
	if not sprite:
		sprite = get_node_or_null("Sprite2D")
	if not anim_player:
		anim_player = get_node_or_null("AnimationPlayer")
	if not collision_shape:
		collision_shape = get_node_or_null("CollisionShape2D")
	if not hurtbox:
		hurtbox = get_node_or_null("Hurtbox")
	if not attack_hitbox:
		attack_hitbox = get_node_or_null("AttackHitbox")

	if phase == BossPhase.PHASE_1_ARMORED:
		max_hp = 500.0
		current_hp = max_hp
		speed = 240.0
		jump_velocity = -540.0
		knockback_resistance = 0.08
		if sprite:
			sprite.scale = Vector2(0.35, 0.35)
			sprite.position = Vector2(0, -96)
		if collision_shape:
			collision_shape.shape.height = 110.0
			collision_shape.shape.radius = 26.0
			collision_shape.position = Vector2(0, -55)
		if hurtbox and hurtbox.get_node_or_null("CollisionShape2D"):
			var hs = hurtbox.get_node("CollisionShape2D")
			hs.shape.height = 116.0
			hs.shape.radius = 30.0
			hs.position = Vector2(0, -55)
	elif phase == BossPhase.PHASE_2_BEAST:
		max_hp = 500.0
		current_hp = max_hp
		speed = 340.0
		jump_velocity = -600.0
		knockback_resistance = 0.06 # Even heavier
		if sprite:
			sprite.scale = Vector2(0.38, 0.38)
			sprite.position = Vector2(0, -104)
		if collision_shape:
			collision_shape.shape.height = 120.0
			collision_shape.shape.radius = 30.0
			collision_shape.position = Vector2(0, -60)
		if hurtbox and hurtbox.get_node_or_null("CollisionShape2D"):
			var hs = hurtbox.get_node("CollisionShape2D")
			hs.shape.height = 126.0
			hs.shape.radius = 34.0
			hs.position = Vector2(0, -60)
			
	hp_changed.emit(current_hp, max_hp)
	phase_changed.emit(current_phase)
	play_phase_anim("idle")

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		velocity.x = move_toward(velocity.x, 0, 800.0 * delta)
		move_and_slide()
		return

	# Handle hitstop
	if hitstop_timer > 0.0:
		hitstop_timer -= delta
		return

	# Handle hitstun
	if hitstun_timer > 0.0:
		hitstun_timer -= delta
		if hitstun_timer <= 0.0 and current_state == State.HURT:
			change_state(State.IDLE if is_on_floor() else State.FALL)

	# Anti-Ring-Out Floor clamp / recovery
	_enforce_arena_bounds()

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, 900.0)

	# AI Decision & Movement
	if is_boss_ai:
		_process_boss_ai(delta)

	move_and_slide()

	# State transitions based on velocity
	if current_state != State.ATTACK and current_state != State.HURT and current_state != State.DEAD:
		if is_on_floor():
			if abs(velocity.x) > 15.0:
				if current_state != State.RUN:
					change_state(State.RUN)
			else:
				if current_state != State.IDLE:
					change_state(State.IDLE)
		else:
			if velocity.y > 0 and current_state != State.FALL and current_state != State.WALL_SLIDE:
				change_state(State.FALL)

	# Phase 2 is triggered only after Phase 1 HP is completely depleted (0 HP) in take_damage()

func _enforce_arena_bounds() -> void:
	# Prevent the boss from ever falling out of the stage or getting rung out
	# If the boss falls below Y = 560 (stage pit level), immediately recover with void burst
	if global_position.y > 560.0:
		global_position.y = 350.0
		global_position.x = clamp(global_position.x, 300.0, 850.0)
		velocity = Vector2(0, -200.0)
		_trigger_hit_flash()

func _process_boss_ai(delta: float) -> void:
	# Acquire or validate target
	if not is_instance_valid(target_player) or target_player.current_state == State.DEAD:
		var fighters = get_tree().get_nodes_in_group("fighters")
		for f in fighters:
			if f != self and f is FighterBase and f.current_state != State.DEAD:
				target_player = f
				break

	if not is_instance_valid(target_player):
		velocity.x = move_toward(velocity.x, 0, 1000.0 * delta)
		return

	var to_target = target_player.global_position - global_position
	var dist_x = to_target.x
	var abs_dist_x = abs(dist_x)
	var dist_y = to_target.y
	var face_dir = 1 if dist_x >= 0 else -1

	# If currently attacking or in hitstun, don't override physics direction
	if current_state == State.ATTACK or current_state == State.HURT:
		return

	set_facing(face_dir)

	ai_decision_timer -= delta
	ai_reaction_timer -= delta

	# React to player jumping above
	if dist_y < -70.0 and abs_dist_x < 130.0 and is_on_floor() and ai_reaction_timer <= 0.0:
		ai_reaction_timer = 0.6
		velocity.y = jump_velocity
		change_state(State.JUMP)
		# Airborne punish strike
		get_tree().create_timer(0.18).timeout.connect(func():
			if current_state != State.DEAD and current_state != State.HURT:
				start_combo()
		)
		return

	# AI Decision intervals
	if ai_decision_timer <= 0.0:
		ai_decision_timer = randf_range(0.25, 0.5) if current_phase == BossPhase.PHASE_1_ARMORED else randf_range(0.12, 0.3)

		# Range 1: Far (> 240px) -> Close in with sprint / leap
		if abs_dist_x > 240.0:
			velocity.x = face_dir * speed
			if is_on_floor() and randf() < (0.25 if current_phase == BossPhase.PHASE_1_ARMORED else 0.45):
				velocity.y = jump_velocity * 0.9
				change_state(State.JUMP)

		# Range 2: Mid Range (110px to 240px) -> Lunge attack or gap close
		elif abs_dist_x > 115.0:
			var aggressive_chance = 0.75 if current_phase == BossPhase.PHASE_2_BEAST else 0.55
			if randf() < aggressive_chance:
				velocity.x = face_dir * speed * 1.2
				start_combo()
			else:
				velocity.x = face_dir * speed

		# Range 3: Close Range (<= 115px) -> Immediate combo or dodge mixup
		else:
			if randf() < 0.85:
				start_combo()
			else:
				# Quick backstep / spacing dodge
				velocity.x = -face_dir * speed * 0.85

func start_combo() -> void:
	if current_state == State.ATTACK or current_state == State.HURT or current_state == State.DEAD:
		return
		
	combo_step = 1
	has_buffered_attack = false
	can_chain_combo = false
	change_state(State.ATTACK)
	_play_combo_step(1)

func _advance_combo() -> void:
	can_chain_combo = false
	has_buffered_attack = false
	combo_step += 1
	if combo_step > 3:
		finish_combo_animation()
		return
	_play_combo_step(combo_step)

func _play_combo_step(step: int) -> void:
	var step_speed = 140.0 if current_phase == BossPhase.PHASE_1_ARMORED else 260.0
	if step == 3:
		step_speed *= 1.4
	velocity.x = facing_direction * step_speed

	match step:
		1:
			# Hit 1
			if current_phase == BossPhase.PHASE_1_ARMORED:
				attack_hitbox.damage = 18.0
				attack_hitbox.base_knockback = 280.0
				attack_hitbox.knockback_direction = Vector2(facing_direction, -0.2)
				attack_hitbox.hitstun_duration = 0.25
				_configure_hitbox(Vector2(65 * facing_direction, -55), Vector2(100, 60))
				play_phase_anim("combo_1")
			else:
				attack_hitbox.damage = 22.0
				attack_hitbox.base_knockback = 340.0
				attack_hitbox.knockback_direction = Vector2(facing_direction, -0.25)
				attack_hitbox.hitstun_duration = 0.28
				_configure_hitbox(Vector2(60 * facing_direction, -60), Vector2(110, 70))
				play_phase_anim("combo_1")
		2:
			# Hit 2
			if current_phase == BossPhase.PHASE_1_ARMORED:
				attack_hitbox.damage = 24.0
				attack_hitbox.base_knockback = 380.0
				attack_hitbox.knockback_direction = Vector2(facing_direction, -0.3)
				attack_hitbox.hitstun_duration = 0.30
				_configure_hitbox(Vector2(75 * facing_direction, -60), Vector2(120, 75))
				play_phase_anim("combo_2")
			else:
				attack_hitbox.damage = 28.0
				attack_hitbox.base_knockback = 450.0
				attack_hitbox.knockback_direction = Vector2(facing_direction, -0.35)
				attack_hitbox.hitstun_duration = 0.32
				_configure_hitbox(Vector2(70 * facing_direction, -65), Vector2(125, 80))
				play_phase_anim("combo_2")
		3:
			# Hit 3 - Finisher
			if current_phase == BossPhase.PHASE_1_ARMORED:
				attack_hitbox.damage = 38.0
				attack_hitbox.base_knockback = 620.0
				attack_hitbox.knockback_direction = Vector2(facing_direction * 0.7, -0.75)
				attack_hitbox.hitstun_duration = 0.42
				_configure_hitbox(Vector2(85 * facing_direction, -65), Vector2(140, 95))
				play_phase_anim("combo_3")
			else:
				attack_hitbox.damage = 45.0
				attack_hitbox.base_knockback = 720.0
				attack_hitbox.knockback_direction = Vector2(facing_direction * 0.65, -0.85)
				attack_hitbox.hitstun_duration = 0.46
				_configure_hitbox(Vector2(90 * facing_direction, -70), Vector2(150, 105))
				play_phase_anim("combo_3")

func _configure_hitbox(pos: Vector2, sz: Vector2) -> void:
	if attack_hitbox:
		attack_hitbox.position = pos
		var shape_node = attack_hitbox.get_node_or_null("CollisionShape2D")
		if shape_node and shape_node.shape is RectangleShape2D:
			shape_node.shape.size = sz

func enable_hitbox() -> void:
	if attack_hitbox:
		attack_hitbox.monitoring = true

func disable_hitbox() -> void:
	if attack_hitbox:
		attack_hitbox.monitoring = false

func open_combo_window() -> void:
	can_chain_combo = true
	# AI automatically chains combo if opponent is in range
	if is_boss_ai and combo_step < 3:
		if is_instance_valid(target_player) and abs(target_player.global_position.x - global_position.x) < 220.0:
			_advance_combo()

func finish_combo_animation() -> void:
	disable_hitbox()
	can_chain_combo = false
	has_buffered_attack = false
	combo_step = 0
	change_state(State.IDLE if is_on_floor() else State.FALL)

func trigger_phase_2_transformation() -> void:
	phase_transformed = true
	is_invulnerable = true
	change_state(State.HURT)
	velocity = Vector2.ZERO
	apply_phase(BossPhase.PHASE_2_BEAST)

	# Camera shake impact
	var cam = get_viewport().get_camera_2d() if get_viewport() else null
	if cam and "shake_intensity" in cam:
		cam.shake_intensity = 26.0

	# Show Phase 2 Banner on HUD if available
	var tree = get_tree()
	if tree:
		var hud = tree.get_first_node_in_group("hud")
		if not hud:
			var root_stage = tree.current_scene
			if root_stage and "hud" in root_stage and root_stage.hud:
				hud = root_stage.hud
		if hud and hud.has_method("show_banner"):
			hud.show_banner("PHASE 2 UNLEASHED!", "BEAST OF THE VOID AWAKENS!")
			hud.update_fighter_stocks(player_id, 1, 2)
			tree.create_timer(1.8).timeout.connect(func():
				if is_instance_valid(hud) and hud.has_method("hide_banner"):
					hud.hide_banner()
			)

	# Dramatic Transformation flash & shockwave
	var tw = create_tween()
	tw.tween_property(sprite, "modulate", Color(4.0, 0.3, 0.6, 1.0), 0.45)
	tw.tween_callback(func():
		apply_phase(BossPhase.PHASE_2_BEAST)
		# Powerful void shockwave repels all opponents
		var f_list = get_tree().get_nodes_in_group("fighters") if get_tree() else []
		for f in f_list:
			if f != self and f is FighterBase:
				var push_dir = sign(f.global_position.x - global_position.x)
				if push_dir == 0: push_dir = 1
				f.velocity = Vector2(push_dir * 620.0, -340.0)
	)
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.5)
	tw.tween_callback(func():
		is_invulnerable = false
		change_state(State.IDLE)
	)

func take_damage(data: CombatData) -> void:
	if current_state == State.DEAD or is_invulnerable:
		return

	current_hp = max(0.0, current_hp - data.damage)
	hp_changed.emit(current_hp, max_hp)
	_trigger_hit_flash()

	# Super-Armor Poise: Absorb knockback, but still show hurt reaction
	var knockback_force = data.base_knockback * knockback_resistance
	velocity = data.knockback_direction * knockback_force
	
	hitstun_timer = 0.16
	hitstop_timer = 0.08

	if current_hp <= 0.0:
		if current_phase == BossPhase.PHASE_1_ARMORED and not phase_transformed:
			current_hp = 0.0
			hp_changed.emit(0.0, max_hp)
			trigger_phase_2_transformation()
			return
		else:
			change_state(State.DEAD)
			died.emit("KO")
			return

	# Hurt state reaction (stagger) without flying away
	if current_state != State.ATTACK:
		change_state(State.HURT)

func set_facing(dir: int) -> void:
	if dir != 0:
		facing_direction = dir
		_update_facing_nodes(dir)

func _update_facing_nodes(dir: int) -> void:
	if sprite:
		sprite.flip_h = (dir < 0)
	if attack_hitbox:
		attack_hitbox.position.x = abs(attack_hitbox.position.x) * dir
	if void_particles:
		void_particles.position.x = abs(void_particles.position.x) * dir

func play_phase_anim(anim_name: String) -> void:
	if not anim_player:
		return
	var prefix = "p1_" if current_phase == BossPhase.PHASE_1_ARMORED else "p2_"
	var actual_name = anim_name
	if anim_name == "run" and current_phase == BossPhase.PHASE_2_BEAST:
		actual_name = "walk"
	var full_anim_key = prefix + actual_name
	if anim_player.has_animation(full_anim_key):
		anim_player.play(full_anim_key)

func _on_enter_state(new_state: State) -> void:
	match new_state:
		State.IDLE:
			play_phase_anim("idle")
		State.RUN:
			play_phase_anim("run")
		State.JUMP:
			play_phase_anim("jump")
		State.FALL:
			play_phase_anim("fall")
		State.WALL_SLIDE:
			play_phase_anim("wall_slide")
		State.HURT:
			play_phase_anim("hurt")
		State.DEAD:
			play_phase_anim("hurt")
			var tw = create_tween()
			tw.tween_property(sprite, "modulate", Color(0.1, 0.0, 0.05, 0.0), 1.2)
			tw.tween_callback(func():
				queue_free()
			)

# Anti-Ring-Out Override: Boss CANNOT be rung out or die from falling out of bounds
func trigger_ring_out() -> void:
	# Ignore ring-out death! Teleport back to stage center
	global_position.y = 350.0
	global_position.x = clamp(global_position.x, 400.0, 750.0)
	velocity = Vector2(0, -150.0)
	_trigger_hit_flash()
