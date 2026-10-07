extends Node2D

@onready var aron: Aron = $Aron
@onready var target_marker: Node2D = $TargetDummy
@onready var anim_player: AnimationPlayer = $Aron/AnimationPlayer

func _ready() -> void:
	# Hubungkan target marker ke EyeController Aron
	var head = aron.get_node_or_null("Rig/Skeleton2D/HipBone/TorsoBone/HeadBone/AronHead")
	if head:
		var eye_ctrl: AronEyeController = head.get_node_or_null("EyeController")
		if eye_ctrl:
			eye_ctrl.target_opponent = target_marker

	if anim_player:
		anim_player.play("idle")

func _process(delta: float) -> void:
	# Buat target dummy melayang-layang perlahan naik turun untuk menunjukkan eye-tracking
	var t = Time.get_ticks_msec() / 1000.0
	target_marker.position = Vector2(240, -40 + sin(t * 2.0) * 35.0)

	# Interaksi tombol untuk menguji ekspresi mata
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE):
		_test_attack_expression()
	elif Input.is_key_pressed(KEY_H):
		_test_hurt_expression()

func _test_attack_expression() -> void:
	var head = aron.get_node_or_null("Rig/Skeleton2D/HipBone/TorsoBone/HeadBone/AronHead")
	if head:
		var eye_ctrl: AronEyeController = head.get_node_or_null("EyeController")
		if eye_ctrl:
			eye_ctrl.set_eye_mode(AronEyeController.EyeMode.ATTACKING)
			await get_tree().create_timer(0.8).timeout
			eye_ctrl.set_eye_mode(AronEyeController.EyeMode.NORMAL)

func _test_hurt_expression() -> void:
	var head = aron.get_node_or_null("Rig/Skeleton2D/HipBone/TorsoBone/HeadBone/AronHead")
	if head:
		var eye_ctrl: AronEyeController = head.get_node_or_null("EyeController")
		if eye_ctrl:
			eye_ctrl.set_eye_mode(AronEyeController.EyeMode.HURT)
			await get_tree().create_timer(0.6).timeout
			eye_ctrl.set_eye_mode(AronEyeController.EyeMode.NORMAL)
