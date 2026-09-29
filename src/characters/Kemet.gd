class_name Kemet
extends FighterBase

# Kemet: Agile Claw Assassin (Wolverine-style Retractable Knuckle Claws)
# Fast sprint -> Quick Claw Thrust -> Dual X-Cross Slash -> Rising Crescent Finisher!

var combo_step: int = 0
var has_buffered_attack: bool = false
var can_chain_combo: bool = false

@onready var attack_hitbox: Hitbox = $AttackHitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	fighter_name = "Kemet"
	max_hp = 100.0
	speed = 310.0
	jump_velocity = -530.0
	wall_slide_max_speed = 120.0
	wall_jump_impulse = Vector2(400.0, -500.0)
	super._ready()

	if attack_hitbox:
		attack_hitbox.attacker_node = self
		attack_hitbox.monitoring = false

	if anim_player:
		anim_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("combo_") and current_state == State.ATTACK:
		finish_combo_animation()

func set_facing(dir: int) -> void:
	super.set_facing(dir)
	if attack_hitbox:
		attack_hitbox.position.x = abs(attack_hitbox.position.x) * facing_direction

func _handle_state_physics(delta: float) -> void:
	if current_state == State.DEAD:
		return

	var move_input = 0.0
	if player_id == 1:
		move_input = Input.get_axis("p1_move_left", "p1_move_right")
	elif player_id == 2:
		move_input = Input.get_axis("p2_move_left", "p2_move_right")

	var jump_just_pressed = false
	var attack_just_pressed = false

	if player_id == 1:
		jump_just_pressed = Input.is_action_just_pressed("p1_jump")
		attack_just_pressed = Input.is_action_just_pressed("p1_attack")
	elif player_id == 2:
		jump_just_pressed = Input.is_action_just_pressed("p2_jump")
		attack_just_pressed = Input.is_action_just_pressed("p2_attack")

	# Attacking state physics
	if current_state == State.ATTACK:
		velocity.x = move_toward(velocity.x, 0, 950.0 * delta)
		if attack_just_pressed:
			if can_chain_combo:
				_advance_combo()
			else:
				has_buffered_attack = true
		return

	# Hurt state physics
	if current_state == State.HURT:
		velocity.x = move_toward(velocity.x, 0, 520.0 * delta)
		return

	# Attack trigger from neutral
	if attack_just_pressed:
		start_combo()
		return

	# Wall slide & wall jump
	if current_state == State.WALL_SLIDE:
		var wall_normal_x = get_wall_normal().x
		if sprite and wall_normal_x != 0:
			# Menghadap ke arah dinding dengan cakar menancap
			sprite.flip_h = (wall_normal_x < 0)
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

	# Ground jump & double jump
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

	# Horizontal movement
	if move_input != 0:
		velocity.x = move_toward(velocity.x, move_input * speed, 2000.0 * delta)
		set_facing(sign(move_input))
		if is_on_floor() and current_state != State.RUN:
			change_state(State.RUN)
	else:
		velocity.x = move_toward(velocity.x, 0, 1500.0 * delta)
		if is_on_floor() and current_state != State.IDLE:
			change_state(State.IDLE)

	# In-air transitions
	if not is_on_floor() and current_state != State.WALL_SLIDE:
		if velocity.y > 0 and current_state != State.FALL:
			change_state(State.FALL)

func _on_enter_state(new_state: State) -> void:
	if new_state != State.WALL_SLIDE and sprite:
		sprite.position.x = 0
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
			# Hit 1: Straight Claw Thrust (Fast Poke)
			velocity.x = forward_x * 140.0
			attack_hitbox.damage = 8.0
			attack_hitbox.base_knockback = 200.0
			attack_hitbox.knockback_direction = Vector2(forward_x * 0.9, -0.2).normalized()
			attack_hitbox.hitstun_duration = 0.22
			attack_hitbox.hitstop_duration = 0.05
			anim_player.play("combo_thrust")
		2:
			# Hit 2: Dual Cross X-Slash (Forward Dash Slash)
			velocity.x = forward_x * 190.0
			attack_hitbox.damage = 12.0
			attack_hitbox.base_knockback = 300.0
			attack_hitbox.knockback_direction = Vector2(forward_x * 0.85, -0.3).normalized()
			attack_hitbox.hitstun_duration = 0.26
			attack_hitbox.hitstop_duration = 0.07
			anim_player.play("combo_cross")
		3:
			# Hit 3: Rising Crescent Finisher (Skyward Launcher)
			velocity.x = forward_x * 230.0
			attack_hitbox.damage = 18.0
			attack_hitbox.base_knockback = 560.0
			attack_hitbox.knockback_direction = Vector2(forward_x * 0.65, -0.85).normalized()
			attack_hitbox.hitstun_duration = 0.38
			attack_hitbox.hitstop_duration = 0.11
			anim_player.play("combo_rising")

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
	if current_state == State.ATTACK:
		change_state(State.IDLE if is_on_floor() else State.FALL)
