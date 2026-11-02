class_name OmHami
extends FighterBase

# Om Hami: Mid-range Cane Zoner & Heavy Street Brawler
# Long reach poke -> Low cane sweep -> Heavy smoke smash finisher!

var combo_step: int = 1
var can_chain_combo: bool = false
var has_buffered_attack: bool = false

@onready var attack_hitbox: Hitbox = $AttackHitbox
@onready var smoke_particles: GPUParticles2D = get_node_or_null("SmokeParticles")

func _ready() -> void:
	fighter_name = "Om Hami"
	max_hp = 275.0
	speed = 250.0
	jump_velocity = -500.0
	super._ready()
	
	if attack_hitbox:
		attack_hitbox.attacker_node = self
		attack_hitbox.monitoring = false

	if smoke_particles:
		smoke_particles.emitting = true

	if anim_player:
		anim_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("combo_") and current_state == State.ATTACK:
		finish_combo_animation()

func set_facing(dir: int) -> void:
	super.set_facing(dir)
	if attack_hitbox:
		attack_hitbox.position.x = abs(attack_hitbox.position.x) * facing_direction
	if smoke_particles:
		smoke_particles.position.x = abs(smoke_particles.position.x) * facing_direction
		if smoke_particles.process_material is ParticleProcessMaterial:
			(smoke_particles.process_material as ParticleProcessMaterial).direction.x = 0.5 * facing_direction

func _handle_state_physics(delta: float) -> void:
	if current_state == State.DEAD:
		return

	var move_dir = get_move_input()
	var jump_just_pressed = is_jump_just_pressed()
	var attack_just_pressed = is_attack_just_pressed()

	# Attacking state
	if current_state == State.ATTACK:
		velocity.x = move_toward(velocity.x, 0, 800.0 * delta)
		if attack_just_pressed:
			if can_chain_combo:
				_advance_combo()
			else:
				has_buffered_attack = true
		return

	# Hurt state
	if current_state == State.HURT:
		velocity.x = move_toward(velocity.x, 0, 450.0 * delta)
		return

	# Attack trigger from neutral
	if attack_just_pressed:
		start_combo()
		return

	# Wall slide jump
	if current_state == State.WALL_SLIDE:
		var wall_normal_x = get_wall_normal().x
		if sprite and wall_normal_x != 0:
			# Dinding di kanan (wall_normal_x < 0): raw sprite bertumpu ke kanan -> flip_h = false
			# Dinding di kiri (wall_normal_x > 0): balik sprite ke kiri -> flip_h = true
			sprite.flip_h = (wall_normal_x > 0)
			sprite.position.x = 4.0 if (wall_normal_x < 0) else -4.0
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

	# Jump handling
	if jump_just_pressed:
		if is_on_floor():
			velocity.y = jump_velocity
			change_state(State.JUMP)
			return
		elif air_jumps_left > 0:
			velocity.y = jump_velocity * 0.9
			air_jumps_left -= 1
			change_state(State.JUMP)
			return

	# Horizontal movement
	if move_dir != 0.0:
		velocity.x = move_dir * speed
		set_facing(int(sign(move_dir)))
		if is_on_floor() and current_state != State.RUN:
			change_state(State.RUN)
	else:
		velocity.x = move_toward(velocity.x, 0, 1200.0 * delta)
		if is_on_floor() and current_state != State.IDLE:
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
	else:
		var wall_normal_x = get_wall_normal().x
		if sprite and wall_normal_x != 0:
			sprite.flip_h = (wall_normal_x > 0)
			sprite.position.x = 4.0 if (wall_normal_x < 0) else -4.0
	if not anim_player:
		return

	match new_state:
		State.IDLE:
			anim_player.play("idle")
		State.RUN:
			anim_player.play("walk")
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
	if not attack_hitbox:
		return

	var forward_x = float(facing_direction)

	match step:
		1:
			# Long-range cane thrust
			attack_hitbox.damage = 10.0
			attack_hitbox.base_knockback = 280.0
			attack_hitbox.knockback_direction = Vector2(forward_x * 0.9, -0.4).normalized()
			attack_hitbox.hitstun_duration = 0.25
			attack_hitbox.hitstop_duration = 0.06
			anim_player.play("combo_thrust")
		2:
			# Low cane sweep
			attack_hitbox.damage = 14.0
			attack_hitbox.base_knockback = 340.0
			attack_hitbox.knockback_direction = Vector2(forward_x * 0.85, -0.5).normalized()
			attack_hitbox.hitstun_duration = 0.28
			attack_hitbox.hitstop_duration = 0.08
			anim_player.play("combo_sweep")
		3:
			# Devastating smoke explosion cane smash
			attack_hitbox.damage = 24.0
			attack_hitbox.base_knockback = 600.0
			attack_hitbox.knockback_direction = Vector2(forward_x * 0.7, -0.7).normalized()
			attack_hitbox.hitstun_duration = 0.40
			attack_hitbox.hitstop_duration = 0.12
			if smoke_particles:
				smoke_particles.amount = 40
			anim_player.play("combo_smash")

func enable_hitbox() -> void:
	if attack_hitbox:
		attack_hitbox.monitoring = true

func disable_hitbox() -> void:
	if attack_hitbox:
		attack_hitbox.monitoring = false

func open_combo_window() -> void:
	can_chain_combo = true
	if has_buffered_attack:
		_advance_combo()

func finish_combo_animation() -> void:
	disable_hitbox()
	can_chain_combo = false
	has_buffered_attack = false
	combo_step = 1
	if smoke_particles:
		smoke_particles.amount = 20
	if current_state == State.ATTACK:
		change_state(State.IDLE if is_on_floor() else State.FALL)
