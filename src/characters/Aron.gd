class_name Aron
extends FighterBase

@onready var attack_hitbox: Hitbox = $AttackHitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Combo Management
var combo_step: int = 0
var is_air_combo: bool = false
var has_buffered_attack: bool = false
var can_chain_combo: bool = false

# Dash & Block Mechanics
const DASH_COOLDOWN: float = 2.0
const DASH_SPEED: float = 580.0
const DASH_DURATION: float = 0.22

var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: float = 1.0

# Block State Defense
var block_impact_timer: float = 0.0
var is_block_hit: bool = false

func _ready() -> void:
	fighter_name = "Aron"
	super._ready()
	if attack_hitbox:
		attack_hitbox.attacker_node = self
		attack_hitbox.monitoring = false

func _physics_process(delta: float) -> void:
	# Always tick dash cooldown
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer = max(0.0, dash_cooldown_timer - delta)

	if block_impact_timer > 0.0:
		block_impact_timer = max(0.0, block_impact_timer - delta)

	super._physics_process(delta)

func _handle_state_physics(delta: float) -> void:
	if current_state == State.DEAD:
		return

	var move_input := get_move_input()
	var jump_just_pressed := is_jump_just_pressed()
	var attack_just_pressed := is_attack_just_pressed()
	var dodge_just_pressed := is_dodge_just_pressed()
	var dodge_held := is_dodge_held()

	# -------------------------------------------------------------------------
	# 1. DASH STATE PHYSICS
	# -------------------------------------------------------------------------
	if current_state == State.DASH:
		dash_timer -= delta
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0.0 # Maintain flat trajectory during dash burst
		if dash_timer <= 0.0:
			if is_on_floor():
				change_state(State.RUN if move_input != 0 else State.IDLE)
			else:
				change_state(State.FALL)
		return

	# -------------------------------------------------------------------------
	# 2. BLOCK STATE PHYSICS
	# -------------------------------------------------------------------------
	if current_state == State.BLOCK:
		velocity.x = move_toward(velocity.x, 0.0, 1600.0 * delta)
		# If button is released, return to neutral
		if not dodge_held:
			is_block_hit = false
			block_impact_timer = 0.0
			change_state(State.IDLE if is_on_floor() else State.FALL)
			return

		# When block impact recovery ends, resume looping block guard stance
		if is_block_hit and block_impact_timer <= 0.0:
			is_block_hit = false
			if anim_player and anim_player.current_animation != "block":
				anim_player.play("block")

		# Can turn block direction if input pressed
		if move_input != 0:
			set_facing(sign(move_input))
		return

	# -------------------------------------------------------------------------
	# 3. ATTACK STATE PHYSICS (Ground & Air Combos)
	# -------------------------------------------------------------------------
	if current_state == State.ATTACK:
		if is_air_combo:
			# Gentle air-hang friction during mid-air combo
			velocity.x = move_toward(velocity.x, 0.0, 450.0 * delta)
			velocity.y = move_toward(velocity.y, 60.0, 300.0 * delta)
		else:
			# Ground combo deceleration (except when uppercut launches upward)
			if combo_step != 3 or velocity.y >= 0:
				velocity.x = move_toward(velocity.x, 0.0, 950.0 * delta)

		if attack_just_pressed:
			if can_chain_combo:
				_advance_combo()
			else:
				has_buffered_attack = true
		return

	# -------------------------------------------------------------------------
	# 4. HURT STATE
	# -------------------------------------------------------------------------
	if current_state == State.HURT:
		velocity.x = move_toward(velocity.x, 0.0, 550.0 * delta)
		return

	# -------------------------------------------------------------------------
	# 5. DASH & BLOCK TRIGGER (Same button: Dodge)
	# -------------------------------------------------------------------------
	# Dash trigger: Dodge button + movement direction + cooldown ready
	if dodge_just_pressed and move_input != 0.0 and dash_cooldown_timer <= 0.0:
		start_dash(sign(move_input))
		return
	# Block trigger: Dodge held without movement (or if dash on cooldown)
	elif dodge_held:
		start_block()
		return

	# -------------------------------------------------------------------------
	# 6. ATTACK TRIGGER (Ground or Mid-Air)
	# -------------------------------------------------------------------------
	if attack_just_pressed:
		if is_on_floor():
			start_ground_combo()
		else:
			start_air_combo()
		return

	# -------------------------------------------------------------------------
	# 7. WALL SLIDE & WALL JUMP
	# -------------------------------------------------------------------------
	if current_state == State.WALL_SLIDE:
		var wall_normal_x = get_wall_normal().x
		if sprite and wall_normal_x != 0:
			# Wall facing: flip toward wall
			sprite.flip_h = (wall_normal_x < 0)
			sprite.position.x = 6.0 if (wall_normal_x < 0) else -6.0

		if jump_just_pressed:
			var jump_dir = wall_normal_x if wall_normal_x != 0 else 1.0
			velocity.x = jump_dir * wall_jump_impulse.x
			velocity.y = wall_jump_impulse.y
			if sprite:
				sprite.position.x = 0
			set_facing(int(jump_dir))
			change_state(State.JUMP)
			return
		return

	# -------------------------------------------------------------------------
	# 8. JUMP & DOUBLE JUMP
	# -------------------------------------------------------------------------
	if jump_just_pressed:
		if is_on_floor():
			velocity.y = jump_velocity
			change_state(State.JUMP)
			return
		elif air_jumps_left > 0:
			velocity.y = jump_velocity * 0.95
			air_jumps_left -= 1
			change_state(State.JUMP)
			return

	# -------------------------------------------------------------------------
	# 9. RUN & IDLE MOVEMENT
	# -------------------------------------------------------------------------
	if move_input != 0:
		velocity.x = move_toward(velocity.x, move_input * speed, 1900.0 * delta)
		set_facing(sign(move_input))
		if is_on_floor() and velocity.y >= 0 and current_state != State.RUN:
			change_state(State.RUN)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 1500.0 * delta)
		if is_on_floor() and velocity.y >= 0 and current_state != State.IDLE:
			change_state(State.IDLE)

	# In-air transitions
	if not is_on_floor() and current_state != State.WALL_SLIDE:
		if velocity.y > 0 and current_state != State.FALL and current_state != State.JUMP:
			change_state(State.FALL)

# =============================================================================
# COMBAT & ATTACK COMBOS
# =============================================================================
func start_ground_combo() -> void:
	is_air_combo = false
	combo_step = 1
	has_buffered_attack = false
	can_chain_combo = false
	change_state(State.ATTACK)
	_play_combo_step(1)

func start_air_combo() -> void:
	is_air_combo = true
	combo_step = 1
	has_buffered_attack = false
	can_chain_combo = false
	change_state(State.ATTACK)
	_play_air_combo_step(1)

func _advance_combo() -> void:
	can_chain_combo = false
	has_buffered_attack = false
	combo_step += 1

	if is_air_combo:
		if combo_step > 3:
			combo_step = 1
		_play_air_combo_step(combo_step)
	else:
		if combo_step > 3:
			combo_step = 1
		_play_combo_step(combo_step)

func _play_combo_step(step: int) -> void:
	match step:
		1:
			# Hit 1: Left Jab
			velocity.x = facing_direction * 120.0
			attack_hitbox.damage = 7.0
			attack_hitbox.base_knockback = 190.0
			attack_hitbox.knockback_direction = Vector2(facing_direction, -0.15)
			attack_hitbox.hitstun_duration = 0.20
			anim_player.play("combo_jab")
		2:
			# Hit 2: Right Cross
			velocity.x = facing_direction * 160.0
			attack_hitbox.damage = 10.0
			attack_hitbox.base_knockback = 280.0
			attack_hitbox.knockback_direction = Vector2(facing_direction, -0.22)
			attack_hitbox.hitstun_duration = 0.25
			anim_player.play("combo_cross")
		3:
			# Hit 3: Rising Uppercut Finisher (Letter J Motion)
			# Initial crouch dip forward
			velocity.x = facing_direction * 140.0
			attack_hitbox.damage = 18.0
			attack_hitbox.base_knockback = 520.0
			attack_hitbox.knockback_direction = Vector2(facing_direction * 0.45, -0.92)
			attack_hitbox.hitstun_duration = 0.38
			anim_player.play("combo_uppercut")

func _play_air_combo_step(step: int) -> void:
	# Air combos halt vertical drop slightly for crisp fighting feel
	velocity.y = min(velocity.y * 0.25, 40.0)
	velocity.x = facing_direction * 110.0

	match step:
		1:
			# Air Hit 1: Mid-Air Left Jab
			attack_hitbox.damage = 6.0
			attack_hitbox.base_knockback = 170.0
			attack_hitbox.knockback_direction = Vector2(facing_direction, -0.1)
			attack_hitbox.hitstun_duration = 0.22
			anim_player.play("air_combo_1")
		2:
			# Air Hit 2: Mid-Air Right Hook
			attack_hitbox.damage = 9.0
			attack_hitbox.base_knockback = 260.0
			attack_hitbox.knockback_direction = Vector2(facing_direction, -0.15)
			attack_hitbox.hitstun_duration = 0.26
			anim_player.play("air_combo_2")
		3:
			# Air Hit 3: Mid-Air Downward Hammer Slam (Spike!)
			velocity.y = -60.0 # slight hop up before slam
			attack_hitbox.damage = 17.0
			attack_hitbox.base_knockback = 480.0
			attack_hitbox.knockback_direction = Vector2(facing_direction * 0.3, 0.95)
			attack_hitbox.hitstun_duration = 0.35
			anim_player.play("air_combo_3")

# Called by AnimationPlayer track during combo_uppercut strike
func apply_uppercut_impulse() -> void:
	# Launches Aron forward and skyward in the classic J-curve finisher!
	velocity.x = facing_direction * 220.0
	velocity.y = -490.0

# AnimationPlayer Method Track Callbacks
func enable_hitbox() -> void:
	if attack_hitbox:
		attack_hitbox.monitoring = true

func disable_hitbox() -> void:
	if attack_hitbox:
		attack_hitbox.monitoring = false

func open_combo_window() -> void:
	can_chain_combo = true
	if has_buffered_attack and combo_step < 3:
		_advance_combo()

func open_air_combo_window() -> void:
	# Allows transitioning from ground Uppercut apex directly into Mid-Air Combo!
	can_chain_combo = true
	is_air_combo = true
	if has_buffered_attack:
		combo_step = 1
		_play_air_combo_step(1)

func finish_combo_animation() -> void:
	disable_hitbox()
	can_chain_combo = false
	has_buffered_attack = false
	combo_step = 0
	is_air_combo = false
	change_state(State.IDLE if is_on_floor() else State.FALL)

func finish_air_combo_animation() -> void:
	disable_hitbox()
	can_chain_combo = false
	has_buffered_attack = false
	combo_step = 0
	is_air_combo = false
	change_state(State.IDLE if is_on_floor() else State.FALL)

# =============================================================================
# BLOCK & DASH IMPLEMENTATION
# =============================================================================
func start_dash(direction: float) -> void:
	dash_direction = direction
	set_facing(int(direction))
	dash_timer = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN
	change_state(State.DASH)

func start_block() -> void:
	if current_state != State.BLOCK:
		is_block_hit = false
		change_state(State.BLOCK)

# Overridden Damage Handling for Block State
func take_damage(data: CombatData) -> void:
	if current_state == State.DEAD or is_invulnerable:
		return

	if current_state == State.BLOCK:
		# Block defense: 75% damage reduction, 65% knockback reduction, no hurt stun
		var blocked_damage = data.damage * 0.25
		current_hp = max(0.0, current_hp - blocked_damage)
		hp_changed.emit(current_hp, max_hp)

		# Light pushback on block
		velocity = data.knockback_direction * (data.base_knockback * 0.35)
		block_impact_timer = 0.22
		is_block_hit = true
		if anim_player:
			anim_player.play("block_impact")

		# Hit flash in light blue/cyan for shield effect
		if sprite:
			sprite.modulate = Color(1.5, 2.0, 3.0, 1.0)
			var tween = create_tween()
			tween.tween_property(sprite, "modulate", base_modulate, 0.12)

		if current_hp <= 0.0:
			change_state(State.DEAD)
			died.emit("KO")
		return

	# Normal damage if not blocking
	super.take_damage(data)

# =============================================================================
# STATE ENTRY & ANIMATION PLAYBACK
# =============================================================================
func _on_enter_state(new_state: State) -> void:
	if new_state != State.WALL_SLIDE:
		if sprite:
			sprite.position.x = 0
		set_facing(facing_direction)

	if not anim_player:
		return

	match new_state:
		State.IDLE:
			anim_player.play("idle")
		State.RUN:
			anim_player.play("run")
		State.JUMP:
			anim_player.play("jump")
		State.FALL:
			anim_player.play("fall")
		State.WALL_SLIDE:
			anim_player.play("wall_slide")
		State.HURT:
			anim_player.play("hurt")
		State.BLOCK:
			is_block_hit = false
			block_impact_timer = 0.0
			anim_player.play("block")
		State.DASH:
			anim_player.play("dash")
		State.DEAD:
			anim_player.play("hurt")
