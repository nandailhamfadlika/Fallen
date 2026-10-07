class_name AronEyeController
extends Node2D

## Mengontrol lirikan mata/pupil Aron agar fokus ke lawan (bukan menatap kamera)
## serta merespons situasi gameplay (lompat, serang, terkena damage).

@export var pupil_sprite: Sprite2D
@export var max_offset_x: float = 3.5
@export var max_offset_y: float = 2.0

## Referensi lawan yang sedang dilacak tatapannya
var target_opponent: Node2D = null

## Mode ekspresi: NORMAL, ATTACKING, HURT, BLINK
enum EyeMode { NORMAL, ATTACKING, HURT, BLINK }
var current_mode: EyeMode = EyeMode.NORMAL

func _ready() -> void:
	# Default: posisikan pupil sedikit melirik ke depan (arah lawan)
	if pupil_sprite:
		pupil_sprite.position = Vector2(max_offset_x * 0.7, 0.0)

func _process(delta: float) -> void:
	if not pupil_sprite:
		return
		
	match current_mode:
		EyeMode.HURT:
			# Saat terkena damage: pupil mendelik ke atas/terkejut
			var hurt_target = Vector2(0.0, -max_offset_y)
			pupil_sprite.position = pupil_sprite.position.lerp(hurt_target, 20.0 * delta)
			
		EyeMode.ATTACKING:
			# Saat menyerang: tatapan tajam dan lurus ke depan musuh
			var attack_target = Vector2(max_offset_x, 0.5)
			pupil_sprite.position = pupil_sprite.position.lerp(attack_target, 25.0 * delta)
			
		EyeMode.NORMAL:
			_track_target_gaze(delta)

func _track_target_gaze(delta: float) -> void:
	if target_opponent and is_instance_valid(target_opponent):
		# Hitung arah relatif ke musuh
		var diff = target_opponent.global_position - global_position
		var norm_x = clampf(diff.x / 200.0, -1.0, 1.0)
		var norm_y = clampf(diff.y / 200.0, -1.0, 1.0)
		
		# Sesuaikan dengan arah hadap parent
		var facing = 1.0
		var parent = get_parent()
		while parent:
			if "facing_direction" in parent:
				facing = float(parent.facing_direction)
				break
			parent = parent.get_parent()
			
		var target_pos = Vector2(norm_x * facing * max_offset_x, norm_y * max_offset_y)
		pupil_sprite.position = pupil_sprite.position.lerp(target_pos, 12.0 * delta)
	else:
		# Jika belum ada target, selalu melirik ke arah depan (bukan ke kamera)
		var forward_gaze = Vector2(max_offset_x * 0.65, 0.0)
		pupil_sprite.position = pupil_sprite.position.lerp(forward_gaze, 8.0 * delta)

func set_eye_mode(mode: EyeMode) -> void:
	current_mode = mode
