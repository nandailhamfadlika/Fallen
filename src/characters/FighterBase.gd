class_name FighterBase
extends CharacterBody2D

signal hp_changed(current_hp: float, max_hp: float)
signal state_changed(old_state: int, new_state: int)
signal fallen_out_of_bounds()
signal died(cause: String)

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	WALL_SLIDE,
	ATTACK,
	HURT,
	DEAD,
	BLOCK,
	DASH
}

@export var fighter_name: String = "Fighter"
@export var player_id: int = 1 # 1 = P1, 2 = P2, 0 = Dummy
@export var max_hp: float = 250.0
@export var speed: float = 280.0
@export var jump_velocity: float = -520.0
@export var wall_slide_max_speed: float = 150.0
@export var wall_jump_impulse: Vector2 = Vector2(360.0, -480.0)

var current_hp: float = 250.0
var current_state: State = State.IDLE
var facing_direction: int = 1 # 1 = right, -1 = left
var air_jumps_left: int = 1
var hitstun_timer: float = 0.0
var hitstop_timer: float = 0.0
var is_invulnerable: bool = false

# Gravity values
var gravity: float = 1200.0
var fast_fall_gravity: float = 1800.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox: Hurtbox = $Hurtbox

const PlayerInputScript = preload("res://src/core/PlayerInput.gd")
const FighterAIControllerScript = preload("res://src/core/FighterAIController.gd")

var base_modulate: Color = Color.WHITE
var player_input = null
var ai_controller = null
var input_enabled: bool = true

func set_device(device_type_str: String, dev_id: int = -1) -> void:
	if device_type_str == "ai_bot":
		var diff = "medium"
		var gm = get_node_or_null("/root/GameManager")
		if gm and "campaign_difficulty" in gm:
			diff = gm.campaign_difficulty
		ai_controller = FighterAIControllerScript.new(self, diff)
		player_input = ai_controller
		return

	ai_controller = null
	player_input = PlayerInputScript.new()
	match device_type_str:
		"keyboard_wasd":
			player_input.device_type = player_input.DeviceType.KEYBOARD_WASD
		"keyboard_arrows":
			player_input.device_type = player_input.DeviceType.KEYBOARD_ARROWS
		"joypad":
			player_input.device_type = player_input.DeviceType.JOYPAD
			player_input.joypad_id = dev_id
		_:
			player_input.device_type = player_input.DeviceType.KEYBOARD_WASD

func get_move_input() -> float:
	if not input_enabled:
		return 0.0
	if player_input:
		return player_input.move_axis
	if player_id == 1:
		return Input.get_axis("p1_move_left", "p1_move_right")
	elif player_id == 2:
		return Input.get_axis("p2_move_left", "p2_move_right")
	return 0.0

func is_jump_just_pressed() -> bool:
	if not input_enabled:
		return false
	if player_input:
		return player_input.jump_just_pressed
	if player_id == 1:
		return Input.is_action_just_pressed("p1_jump")
	elif player_id == 2:
		return Input.is_action_just_pressed("p2_jump")
	return false

func is_attack_just_pressed() -> bool:
	if not input_enabled:
		return false
	var pressed = false
	if player_input:
		pressed = player_input.attack_just_pressed
	elif player_id == 1:
		pressed = Input.is_action_just_pressed("p1_attack")
	elif player_id == 2:
		pressed = Input.is_action_just_pressed("p2_attack")
	if pressed and is_invulnerable:
		is_invulnerable = false
		if sprite:
			sprite.modulate = base_modulate
	return pressed

func is_dodge_just_pressed() -> bool:
	if not input_enabled:
		return false
	if player_input:
		return player_input.dodge_just_pressed
	if player_id == 1:
		return Input.is_action_just_pressed("p1_dodge")
	elif player_id == 2:
		return Input.is_action_just_pressed("p2_dodge")
	return false

func is_dodge_held() -> bool:
	if not input_enabled:
		return false
	if player_input:
		return player_input.dodge_held
	if player_id == 1:
		return Input.is_action_pressed("p1_dodge")
	elif player_id == 2:
		return Input.is_action_pressed("p2_dodge")
	return false

func is_down_just_pressed() -> bool:
	if not input_enabled:
		return false
	if player_input:
		return player_input.down_just_pressed
	if player_id == 1:
		return Input.is_action_just_pressed("p1_down")
	elif player_id == 2:
		return Input.is_action_just_pressed("p2_down")
	return false

func _ready() -> void:
	add_to_group("fighters")
	current_hp = max_hp
	collision_layer = 2 # Characters
	collision_mask = 1  # World (platforms & walls)
	if sprite:
		base_modulate = sprite.modulate
	set_facing(facing_direction)

func _physics_process(delta: float) -> void:
	if player_input:
		player_input.update()

	if current_state != State.DEAD:
		if global_position.y < -380.0 or global_position.y > 850.0 or global_position.x < -280.0 or global_position.x > 1560.0:
			trigger_ring_out()
			return

	if hitstop_timer > 0.0:
		hitstop_timer -= delta
		return

	if hitstun_timer > 0.0:
		hitstun_timer -= delta
		if hitstun_timer <= 0.0 and current_state == State.HURT:
			change_state(State.FALL if not is_on_floor() else State.IDLE)

	_apply_gravity(delta)
	_handle_state_physics(delta)
	move_and_slide()
	_post_physics_checks()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		if current_state == State.WALL_SLIDE:
			velocity.y = min(velocity.y + (gravity * 0.4 * delta), wall_slide_max_speed)
		else:
			var grav = fast_fall_gravity if velocity.y > 0 else gravity
			velocity.y += grav * delta

func _handle_state_physics(_delta: float) -> void:
	# Virtual method implemented by Aron and other fighters
	pass

func _post_physics_checks() -> void:
	if is_on_floor():
		air_jumps_left = 1
		if current_state == State.FALL or current_state == State.WALL_SLIDE or current_state == State.JUMP:
			change_state(State.IDLE if abs(velocity.x) < 10 else State.RUN)

	# Check wall slide condition
	if not is_on_floor() and is_on_wall() and velocity.y > 0 and current_state != State.HURT and current_state != State.ATTACK and current_state != State.DASH and current_state != State.BLOCK:
		if current_state != State.WALL_SLIDE:
			change_state(State.WALL_SLIDE)
	elif current_state == State.WALL_SLIDE and not is_on_wall():
		change_state(State.FALL)

func change_state(new_state: State) -> void:
	if current_state == State.DEAD and new_state != State.IDLE and new_state != State.FALL:
		return
	var old_state = current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)
	_on_enter_state(new_state)

func respawn_to(spawn_pos: Vector2) -> void:
	global_position = spawn_pos
	velocity = Vector2.ZERO
	current_hp = max_hp
	hp_changed.emit(current_hp, max_hp)
	input_enabled = true
	hitstun_timer = 0.0
	hitstop_timer = 0.0
	air_jumps_left = 1
	if sprite:
		sprite.modulate = base_modulate
	set_facing(facing_direction)
	current_state = State.IDLE
	change_state(State.FALL)

func grant_spawn_invulnerability(duration: float = 1.5) -> void:
	is_invulnerable = true
	if sprite:
		var tween = create_tween().set_loops(int(duration / 0.24))
		tween.tween_property(sprite, "modulate:a", 0.35, 0.12)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.12)
	await get_tree().create_timer(duration).timeout
	is_invulnerable = false
	if sprite:
		sprite.modulate = base_modulate

func _on_enter_state(_new_state: State) -> void:
	# Virtual method for animation updates
	pass

func set_facing(dir: int) -> void:
	if dir == 0:
		return
	facing_direction = dir
	if sprite:
		sprite.flip_h = (facing_direction < 0)
	var attack_hb = get_node_or_null("AttackHitbox")
	if attack_hb:
		attack_hb.position.x = abs(attack_hb.position.x) * facing_direction

func take_damage(data: CombatData) -> void:
	if current_state == State.DEAD or is_invulnerable:
		return

	current_hp = max(0.0, current_hp - data.damage)
	hp_changed.emit(current_hp, max_hp)

	# Knockback scaling formula based on lost HP
	var hp_loss_ratio: float = 1.0 - (current_hp / max_hp)
	var knockback_multiplier: float = 1.0 + (hp_loss_ratio * 1.6)
	var final_knockback: float = data.base_knockback * knockback_multiplier
	
	velocity = data.knockback_direction * final_knockback
	hitstun_timer = data.hitstun_duration
	hitstop_timer = data.hitstop_duration

	# Hit flash effect
	_trigger_hit_flash()

	if current_hp <= 0.0:
		change_state(State.DEAD)
		died.emit("KO")
	else:
		change_state(State.HURT)

func _trigger_hit_flash() -> void:
	if sprite:
		sprite.modulate = Color(3.0, 3.0, 3.0, 1.0) # Flash bright white
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", base_modulate, 0.15)

func trigger_ring_out() -> void:
	if current_state != State.DEAD:
		change_state(State.DEAD)
		fallen_out_of_bounds.emit()
		died.emit("RING_OUT")
