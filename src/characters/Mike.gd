class_name Mike
extends FighterBase

@onready var attack_hitbox: Hitbox = $AttackHitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var combo_step: int = 0
var has_buffered_attack: bool = false
var can_chain_combo: bool = false

func _ready() -> void:
	fighter_name = "Mike"
	max_hp = 270.0
	speed = 285.0
	jump_velocity = -520.0
	super._ready()
	if attack_hitbox:
		attack_hitbox.attacker_node = self
		attack_hitbox.monitoring = false

func _handle_state_physics(delta: float) -> void:
	if current_state == State.DEAD:
		return

	var move_input = get_move_input()
	var jump_just_pressed = is_jump_just_pressed()
	var attack_just_pressed = is_attack_just_pressed()

	# Handle attacking state
	if current_state == State.ATTACK:
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
			sprite.flip_h = (wall_normal_x < 0)
			_update_facing_nodes(int(-sign(wall_normal_x)))
		if jump_just_pressed:
			var jump_dir = wall_normal_x if wall_normal_x != 0 else 1.0
			velocity.x = jump_dir * wall_jump_impulse.x
			velocity.y = wall_jump_impulse.y
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
		velocity.x = move_toward(velocity.x, 0, 1500.0 * delta)
		if is_on_floor() and current_state != State.IDLE:
			change_state(State.IDLE)

	# In-air transitions
	if not is_on_floor() and current_state != State.WALL_SLIDE:
		if velocity.y > 0 and current_state != State.FALL:
			change_state(State.FALL)

func _on_enter_state(new_state: State) -> void:
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

func set_facing(dir: int) -> void:
	if dir != 0 and dir != facing_direction:
		facing_direction = dir
		_update_facing_nodes(dir)

func _update_facing_nodes(dir: int) -> void:
	if sprite:
		sprite.flip_h = (dir < 0)
		sprite.position.x = 18.0 * dir
	if attack_hitbox:
		attack_hitbox.position.x = abs(attack_hitbox.position.x) * dir

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
	velocity.x = facing_direction * (120.0 if step < 3 else 180.0)

	match step:
		1:
			# Hit 1: Horizontal Chair Thrust (Fast steel leg bash)
			attack_hitbox.damage = 8.0
			attack_hitbox.base_knockback = 200.0
			attack_hitbox.knockback_direction = Vector2(facing_direction, -0.15)
			attack_hitbox.hitstun_duration = 0.20
			_configure_hitbox(Vector2(60 * facing_direction, -45), Vector2(70, 38))
			anim_player.play("combo_jab")
		2:
			# Hit 2: Upward Crescent Chair Swing
			attack_hitbox.damage = 11.0
			attack_hitbox.base_knockback = 300.0
			attack_hitbox.knockback_direction = Vector2(facing_direction * 0.8, -0.4)
			attack_hitbox.hitstun_duration = 0.26
			_configure_hitbox(Vector2(55 * facing_direction, -50), Vector2(65, 55))
			anim_player.play("combo_cross")
		3:
			# Hit 3: Heavy Overhead Chair Slam Finisher
			attack_hitbox.damage = 18.0
			attack_hitbox.base_knockback = 560.0
			attack_hitbox.knockback_direction = Vector2(facing_direction * 0.7, -0.85)
			attack_hitbox.hitstun_duration = 0.40
			_configure_hitbox(Vector2(50 * facing_direction, -45), Vector2(80, 75))
			anim_player.play("combo_uppercut")

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
	if has_buffered_attack and combo_step < 3:
		_advance_combo()

func finish_combo_animation() -> void:
	disable_hitbox()
	can_chain_combo = false
	has_buffered_attack = false
	combo_step = 0
	change_state(State.IDLE if is_on_floor() else State.FALL)
