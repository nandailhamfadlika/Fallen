class_name Rin
extends FighterBase

@onready var attack_hitbox: Hitbox = $AttackHitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var astral_aura: GPUParticles2D = get_node_or_null("AstralAura")
@onready var gold_sparks: GPUParticles2D = get_node_or_null("GoldSparks")

var combo_step: int = 0
var has_buffered_attack: bool = false
var can_chain_combo: bool = false

func _ready() -> void:
	fighter_name = "Rin"
	max_hp = 235.0
	speed = 300.0
	jump_velocity = -535.0
	super._ready()
	if attack_hitbox:
		attack_hitbox.attacker_node = self
		attack_hitbox.monitoring = false
	if astral_aura:
		astral_aura.emitting = true
	if gold_sparks:
		gold_sparks.emitting = true

func _handle_state_physics(delta: float) -> void:
	if current_state == State.DEAD:
		return

	var move_input = get_move_input()
	var jump_just_pressed = is_jump_just_pressed()
	var attack_just_pressed = is_attack_just_pressed()

	# Handle attacking state
	if current_state == State.ATTACK:
		velocity.x = move_toward(velocity.x, 0, 950.0 * delta)
		if attack_just_pressed:
			if can_chain_combo:
				_advance_combo()
			else:
				has_buffered_attack = true
		return

	# Handle hurt state
	if current_state == State.HURT:
		velocity.x = move_toward(velocity.x, 0, 500.0 * delta)
		return

	# Attack trigger from neutral
	if attack_just_pressed:
		start_combo()
		return

	# Wall slide / hover cling
	if current_state == State.WALL_SLIDE:
		var wall_normal_x = get_wall_normal().x
		if sprite and wall_normal_x != 0:
			# Dinding di kanan (wall_normal_x < 0): raw sprite menghadap kanan -> flip_h = false
			# Dinding di kiri (wall_normal_x > 0): balik sprite ke kiri -> flip_h = true
			sprite.flip_h = (wall_normal_x > 0)
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

	# Normal jump & double jump
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

	# Movement left/right (Low hover flight sprint)
	if move_input != 0:
		velocity.x = move_toward(velocity.x, move_input * speed, 1900.0 * delta)
		set_facing(sign(move_input))
		if is_on_floor() and velocity.y >= 0 and current_state != State.RUN:
			change_state(State.RUN)
	else:
		velocity.x = move_toward(velocity.x, 0, 1400.0 * delta)
		if is_on_floor() and velocity.y >= 0 and current_state != State.IDLE:
			change_state(State.IDLE)

	# In-air transitions
	if not is_on_floor() and current_state != State.WALL_SLIDE:
		if velocity.y > 0 and current_state != State.FALL:
			change_state(State.FALL)

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
		State.DEAD:
			anim_player.play("hurt")
			if astral_aura:
				astral_aura.emitting = false
			if gold_sparks:
				gold_sparks.emitting = false

func start_combo() -> void:
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
		combo_step = 1
	_play_combo_step(combo_step)

func _play_combo_step(step: int) -> void:
	# Forward hovering momentum glide on ribbon attacks
	velocity.x = facing_direction * (140.0 if step < 3 else 210.0)

	# Dynamic particle surge on attacks
	if astral_aura:
		astral_aura.speed_scale = 1.35 + (step * 0.25)
	if gold_sparks:
		gold_sparks.speed_scale = 1.35 + (step * 0.25)

	match step:
		1:
			# Hit 1: Swift Ribbon Whip
			attack_hitbox.damage = 6.5
			attack_hitbox.base_knockback = 190.0
			attack_hitbox.knockback_direction = Vector2(facing_direction, -0.15)
			attack_hitbox.hitstun_duration = 0.22
			anim_player.play("combo_jab")
		2:
			# Hit 2: Double Spiral Ribbon Drill
			attack_hitbox.damage = 9.5
			attack_hitbox.base_knockback = 280.0
			attack_hitbox.knockback_direction = Vector2(facing_direction * 0.9, -0.3)
			attack_hitbox.hitstun_duration = 0.26
			anim_player.play("combo_cross")
		3:
			# Hit 3: Nova Ribbon Eruption Finisher
			attack_hitbox.damage = 19.0
			attack_hitbox.base_knockback = 560.0
			attack_hitbox.knockback_direction = Vector2(facing_direction * 0.75, -0.85)
			attack_hitbox.hitstun_duration = 0.40
			anim_player.play("combo_uppercut")

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

func finish_combo_animation() -> void:
	disable_hitbox()
	can_chain_combo = false
	has_buffered_attack = false
	combo_step = 0
	if astral_aura:
		astral_aura.speed_scale = 1.0
	if gold_sparks:
		gold_sparks.speed_scale = 1.0
	change_state(State.IDLE if is_on_floor() else State.FALL)
