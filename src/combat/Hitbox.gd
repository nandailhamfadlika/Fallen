class_name Hitbox
extends Area2D

signal hit_landed(target, combat_data)

@export var damage: float = 10.0
@export var base_knockback: float = 350.0
@export var knockback_direction: Vector2 = Vector2(1.0, -0.3)
@export var hitstun_duration: float = 0.22
@export var hitstop_duration: float = 0.08

var attacker_node = null

func _ready() -> void:
	collision_layer = 4  # Layer 3: Hitboxes
	collision_mask = 8   # Layer 4: Hurtboxes
	monitoring = true
	monitorable = true
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and area.owner != attacker_node:
		var dir = knockback_direction
		# Flip direction horizontally based on attacker facing direction
		if attacker_node and "facing_direction" in attacker_node:
			dir.x = abs(dir.x) * attacker_node.facing_direction
			
		var data = CombatData.new(damage, base_knockback, dir, hitstun_duration, hitstop_duration, attacker_node)
		area.take_hit(data)
		hit_landed.emit(area.owner, data)

func enable_hitbox() -> void:
	monitoring = true

func disable_hitbox() -> void:
	monitoring = false
