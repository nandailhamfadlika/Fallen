class_name CombatData
extends RefCounted

var damage: float = 10.0
var base_knockback: float = 300.0
var knockback_direction: Vector2 = Vector2.RIGHT
var hitstun_duration: float = 0.25
var hitstop_duration: float = 0.08
var attacker = null

func _init(dmg: float = 10.0, kb: float = 300.0, dir: Vector2 = Vector2.RIGHT, stun: float = 0.25, stop: float = 0.08, source = null):
	damage = dmg
	base_knockback = kb
	knockback_direction = dir.normalized()
	hitstun_duration = stun
	hitstop_duration = stop
	attacker = source
