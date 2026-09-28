class_name Hurtbox
extends Area2D

signal hit_received(combat_data: CombatData)

var is_invulnerable: bool = false

func _ready() -> void:
	collision_layer = 8  # Layer 4: Hurtboxes
	collision_mask = 0
	monitoring = false
	monitorable = true

func take_hit(data: CombatData) -> void:
	if is_invulnerable:
		return
	hit_received.emit(data)
	if owner and owner.has_method("take_damage"):
		owner.take_damage(data)
