class_name PlayerInput
extends RefCounted

## Universal Input Reader for Fallen
## Mendukung Keyboard WASD, Keyboard Arrows, dan Gamepad/Joystick (Device ID 0..3)

enum DeviceType {
	KEYBOARD_WASD,
	KEYBOARD_ARROWS,
	JOYPAD
}

var device_type: DeviceType = DeviceType.KEYBOARD_WASD
var joypad_id: int = -1 # ID Gamepad (0, 1, 2, 3...) atau -1 untuk keyboard

# State tombol saat ini dan sebelumnya untuk deteksi "just pressed"
var _prev_jump: bool = false
var _prev_attack: bool = false
var _prev_dodge: bool = false
var _prev_down: bool = false
var _prev_up: bool = false
var _prev_left: bool = false
var _prev_right: bool = false
var _prev_start: bool = false

var move_axis: float = 0.0
var jump_just_pressed: bool = false
var attack_just_pressed: bool = false
var dodge_just_pressed: bool = false
var down_just_pressed: bool = false
var up_just_pressed: bool = false
var left_just_pressed: bool = false
var right_just_pressed: bool = false
var start_just_pressed: bool = false

var jump_held: bool = false
var attack_held: bool = false
var down_held: bool = false

func update() -> void:
	var cur_jump = false
	var cur_attack = false
	var cur_dodge = false
	var cur_down = false
	var cur_up = false
	var cur_left = false
	var cur_right = false
	var cur_start = false
	var cur_axis = 0.0

	match device_type:
		DeviceType.KEYBOARD_WASD:
			# Navigasi & Gerakan (WASD)
			var left_press = Input.is_physical_key_pressed(KEY_A)
			var right_press = Input.is_physical_key_pressed(KEY_D)
			cur_left = left_press
			cur_right = right_press
			cur_axis = (1.0 if right_press else 0.0) - (1.0 if left_press else 0.0)

			# Lompat (W / Space)
			cur_jump = Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_SPACE)
			cur_up = Input.is_physical_key_pressed(KEY_W)
			cur_down = Input.is_physical_key_pressed(KEY_S)

			# Aksi (F = Serang / Konfirmasi, Shift = Dodge / Batal)
			cur_attack = Input.is_physical_key_pressed(KEY_F)
			cur_dodge = Input.is_physical_key_pressed(KEY_SHIFT)
			cur_start = Input.is_physical_key_pressed(KEY_ENTER) or Input.is_physical_key_pressed(KEY_F)

		DeviceType.KEYBOARD_ARROWS:
			# Navigasi & Gerakan (Panah Kiri / Kanan)
			var left_press = Input.is_physical_key_pressed(KEY_LEFT)
			var right_press = Input.is_physical_key_pressed(KEY_RIGHT)
			cur_left = left_press
			cur_right = right_press
			cur_axis = (1.0 if right_press else 0.0) - (1.0 if left_press else 0.0)

			# Lompat & Arah Atas/Bawah (Panah Atas / Bawah)
			cur_jump = Input.is_physical_key_pressed(KEY_UP)
			cur_up = Input.is_physical_key_pressed(KEY_UP)
			cur_down = Input.is_physical_key_pressed(KEY_DOWN)

			# Aksi (Enter / K = Serang / Konfirmasi, Period / L = Dodge / Batal)
			cur_attack = Input.is_physical_key_pressed(KEY_ENTER) or Input.is_physical_key_pressed(KEY_K)
			cur_dodge = Input.is_physical_key_pressed(KEY_PERIOD) or Input.is_physical_key_pressed(KEY_L)
			cur_start = Input.is_physical_key_pressed(KEY_ENTER)

		DeviceType.JOYPAD:
			if joypad_id >= 0:
				# Analog Stick Kiri
				var stick_x = Input.get_joy_axis(joypad_id, JOY_AXIS_LEFT_X)
				var stick_y = Input.get_joy_axis(joypad_id, JOY_AXIS_LEFT_Y)

				# D-Pad
				var dpad_left = Input.is_joy_button_pressed(joypad_id, JOY_BUTTON_DPAD_LEFT)
				var dpad_right = Input.is_joy_button_pressed(joypad_id, JOY_BUTTON_DPAD_RIGHT)
				var dpad_up = Input.is_joy_button_pressed(joypad_id, JOY_BUTTON_DPAD_UP)
				var dpad_down = Input.is_joy_button_pressed(joypad_id, JOY_BUTTON_DPAD_DOWN)

				# Hitung sumbu horizontal dengan deadzone 0.25
				if abs(stick_x) > 0.25:
					cur_axis = stick_x
				elif dpad_right:
					cur_axis = 1.0
				elif dpad_left:
					cur_axis = -1.0

				cur_left = (stick_x < -0.5) or dpad_left
				cur_right = (stick_x > 0.5) or dpad_right
				cur_up = (stick_y < -0.5) or dpad_up
				cur_down = (stick_y > 0.5) or dpad_down

				# Tombol Lompat: A (Xbox A / PS Cross) atau Y
				cur_jump = Input.is_joy_button_pressed(joypad_id, JOY_BUTTON_A) or Input.is_joy_button_pressed(joypad_id, JOY_BUTTON_Y)
				
				# Tombol Serang: X (Xbox X / PS Square) atau B (Xbox B / PS Circle)
				cur_attack = Input.is_joy_button_pressed(joypad_id, JOY_BUTTON_X) or Input.is_joy_button_pressed(joypad_id, JOY_BUTTON_B)

				# Tombol Dodge: RB (R1), LB (L1), atau R2 Trigger
				cur_dodge = (
					Input.is_joy_button_pressed(joypad_id, JOY_BUTTON_RIGHT_SHOULDER) or
					Input.is_joy_button_pressed(joypad_id, JOY_BUTTON_LEFT_SHOULDER) or
					Input.get_joy_axis(joypad_id, JOY_AXIS_TRIGGER_RIGHT) > 0.4
				)

				# Tombol Start / Menu
				cur_start = Input.is_joy_button_pressed(joypad_id, JOY_BUTTON_START)

	# Update "just pressed"
	jump_just_pressed = cur_jump and not _prev_jump
	attack_just_pressed = cur_attack and not _prev_attack
	dodge_just_pressed = cur_dodge and not _prev_dodge
	down_just_pressed = cur_down and not _prev_down
	up_just_pressed = cur_up and not _prev_up
	left_just_pressed = cur_left and not _prev_left
	right_just_pressed = cur_right and not _prev_right
	start_just_pressed = cur_start and not _prev_start

	move_axis = cur_axis
	jump_held = cur_jump
	attack_held = cur_attack
	down_held = cur_down

	# Simpan state sebelumnya
	_prev_jump = cur_jump
	_prev_attack = cur_attack
	_prev_dodge = cur_dodge
	_prev_down = cur_down
	_prev_up = cur_up
	_prev_left = cur_left
	_prev_right = cur_right
	_prev_start = cur_start
