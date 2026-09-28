class_name DeathZone
extends Area2D

signal entity_fallen(entity)

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Characters
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is FighterBase:
		entity_fallen.emit(body)
		body.trigger_ring_out()
