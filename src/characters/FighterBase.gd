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
	DEAD
}

@export var fighter_name: String = "Fighter"
@export var player_id: int = 1 # 1 = P1, 2 = P2, 0 = Dummy
@export var max_hp: float = 100.0
@export var speed: float = 280.0
@export var jump_velocity: float = -520.0
@export var wall_slide_max_speed: float = 150.0
@export var wall_jump_impulse: Vector2 = Vector2(360.0, -480.0)

var current_hp: float = 100.0
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

var base_modulate: Color = Color.WHITE

func _ready() -> void:
	current_hp = max_hp
	collision_layer = 2 # Characters
	collision_mask = 1  # World (platforms & walls)
	if sprite:
		base_modulate = sprite.modulate

func _physics_process(delta: float) -> void:
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
		if current_state == State.FALL or current_state == State.WALL_SLIDE:
			change_state(State.IDLE if abs(velocity.x) < 10 else State.RUN)

	# Check wall slide condition
	if not is_on_floor() and is_on_wall() and velocity.y > 0 and current_state != State.HURT and current_state != State.ATTACK:
		if current_state != State.WALL_SLIDE:
			change_state(State.WALL_SLIDE)
	elif current_state == State.WALL_SLIDE and not is_on_wall():
		change_state(State.FALL)

func change_state(new_state: State) -> void:
	if current_state == State.DEAD:
		return
	var old_state = current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)
	_on_enter_state(new_state)

func _on_enter_state(_new_state: State) -> void:
	# Virtual method for animation updates
	pass

func set_facing(dir: int) -> void:
	if dir != 0 and dir != facing_direction:
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
