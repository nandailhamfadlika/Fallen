class_name DummyTarget
extends FighterBase

@onready var hp_label: Label = $HPLabel
@onready var name_label: Label = $NameLabel

var respawn_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	fighter_name = "Training Dummy"
	player_id = 0
	super._ready()
	base_modulate = Color(1.0, 0.8, 0.4)
	if sprite:
		sprite.modulate = base_modulate
	respawn_position = global_position
	hp_changed.connect(_on_hp_changed)
	_update_labels()

func _handle_state_physics(delta: float) -> void:
	if current_state == State.DEAD:
		return

	# Apply heavy ground friction for dummy
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 800.0 * delta)
		if current_state != State.HURT and current_state != State.DEAD:
			change_state(State.IDLE)
	else:
		velocity.x = move_toward(velocity.x, 0, 200.0 * delta)

func _on_enter_state(new_state: State) -> void:
	if not anim_player:
		return
	match new_state:
		State.IDLE:
			anim_player.play("idle")
		State.HURT:
			anim_player.play("hurt")
		State.DEAD:
			anim_player.play("hurt")

func _on_hp_changed(_cur: float, _max: float) -> void:
	_update_labels()

func _update_labels() -> void:
	if hp_label:
		hp_label.text = "HP: %d%%" % int(current_hp)
		# Color changes from green -> yellow -> red
		var ratio = current_hp / max_hp
		if ratio > 0.6:
			hp_label.modulate = Color(0.2, 1.0, 0.3)
		elif ratio > 0.3:
			hp_label.modulate = Color(1.0, 0.9, 0.2)
		else:
			hp_label.modulate = Color(1.0, 0.25, 0.25)

func respawn() -> void:
	global_position = respawn_position
	velocity = Vector2.ZERO
	current_hp = max_hp
	change_state(State.IDLE)
	hp_changed.emit(current_hp, max_hp)
	_update_labels()
	if sprite:
		sprite.modulate = Color(1.0, 0.8, 0.4) # Warm dummy tint
