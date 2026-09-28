class_name Aron
extends FighterBase

@onready var attack_hitbox: Hitbox = $AttackHitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var combo_step: int = 0
var has_buffered_attack: bool = false
var can_chain_combo: bool = false

func _ready() -> void:
	fighter_name = "Aron"
	super._ready()
	if attack_hitbox:
		attack_hitbox.attacker_node = self
		attack_hitbox.monitoring = false

func _handle_state_physics(delta: float) -> void:
	if current_state == State.DEAD:
		return

	var move_input = 0.0
	if player_id == 1:
		move_input = Input.get_axis("p1_move_left", "p1_move_right")
	elif player_id == 2:
		move_input = Input.get_axis("p2_move_left", "p2_move_right")

	# Jump inputs
	var jump_just_pressed = false
	if player_id == 1:
		jump_just_pressed = Input.is_action_just_pressed("p1_jump")
	elif player_id == 2:
		jump_just_pressed = Input.is_action_just_pressed("p2_jump")

	# Attack inputs
	var attack_just_pressed = false
	if player_id == 1:
		attack_just_pressed = Input.is_action_just_pressed("p1_attack")
	elif player_id == 2:
		attack_just_pressed = Input.is_action_just_pressed("p2_attack")

	# Handle attacking state
	if current_state == State.ATTACK:
		# Friction deceleration while attacking
		velocity.x = move_toward(velocity.x, 0, 900.0 * delta)
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

	# Wall slide jump
	if current_state == State.WALL_SLIDE:
		var wall_normal_x = get_wall_normal().x
		if sprite and wall_normal_x != 0:
			# Jika dinding di kanan (normal ke kiri < 0), flip_h = true agar tangan mengarah ke kanan dinding
			# Jika dinding di kiri (normal ke kanan > 0), flip_h = false agar tangan mengarah ke kiri dinding
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

	# Normal jump & double jump
	if jump_just_pressed:
		if is_on_floor():
			velocity.y = jump_velocity
			change_state(State.JUMP)
		elif air_jumps_left > 0:
			velocity.y = jump_velocity * 0.95
			air_jumps_left -= 1
			change_state(State.JUMP)

	# Movement left/right
	if move_input != 0:
		velocity.x = move_toward(velocity.x, move_input * speed, 1800.0 * delta)
		set_facing(sign(move_input))
		if is_on_floor() and current_state != State.RUN:
			change_state(State.RUN)
	else:
		velocity.x = move_toward(velocity.x, 0, 1400.0 * delta)
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
	# Small step forward on each punch for dynamic combat feel
	velocity.x = facing_direction * (120.0 if step < 3 else 180.0)

	match step:
		1:
			# Hit 1: Jab
			attack_hitbox.damage = 6.0
			attack_hitbox.base_knockback = 180.0
			attack_hitbox.knockback_direction = Vector2(facing_direction, -0.15)
			attack_hitbox.hitstun_duration = 0.20
			anim_player.play("combo_jab")
		2:
			# Hit 2: Cross
			attack_hitbox.damage = 9.0
			attack_hitbox.base_knockback = 260.0
			attack_hitbox.knockback_direction = Vector2(facing_direction, -0.2)
			attack_hitbox.hitstun_duration = 0.25
			anim_player.play("combo_cross")
		3:
			# Hit 3: Rising Uppercut Finisher
			attack_hitbox.damage = 16.0
			attack_hitbox.base_knockback = 520.0
			attack_hitbox.knockback_direction = Vector2(facing_direction * 0.7, -0.9)
			attack_hitbox.hitstun_duration = 0.35
			anim_player.play("combo_uppercut")

# Called by AnimationPlayer tracks via Call Method Track
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
	change_state(State.IDLE if is_on_floor() else State.FALL)
