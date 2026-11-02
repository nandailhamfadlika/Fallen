class_name FighterAIController
extends RefCounted

## Intelligent AI Bot Controller for Fallen
## Compatible with FighterBase input interface (move_axis, jump_just_pressed, attack_just_pressed, etc.)
## Features adaptive tracking, platform recovery, 3-hit combo execution, and difficulty profiles.

enum Difficulty { EASY, MEDIUM, HARD }

var difficulty: Difficulty = Difficulty.MEDIUM
var fighter: CharacterBody2D = null # FighterBase
var target: CharacterBody2D = null  # FighterBase

# Input states read by FighterBase
var move_axis: float = 0.0
var jump_just_pressed: bool = false
var attack_just_pressed: bool = false
var dodge_just_pressed: bool = false
var down_just_pressed: bool = false
var up_just_pressed: bool = false
var left_just_pressed: bool = false
var right_just_pressed: bool = false
var start_just_pressed: bool = false

# Internal decision timers
var decision_timer: float = 0.0
var decision_interval: float = 0.2
var attack_cooldown: float = 0.0
var jump_cooldown: float = 0.0
var idle_pause_timer: float = 0.0

var stage_center_x: float = 640.0
var stage_kill_depth: float = 650.0

func _init(p_fighter: CharacterBody2D = null, diff_str: String = "medium") -> void:
	fighter = p_fighter
	set_difficulty(diff_str)

func set_difficulty(diff_str: String) -> void:
	match diff_str.to_lower():
		"easy":
			difficulty = Difficulty.EASY
			decision_interval = 0.42
		"hard":
			difficulty = Difficulty.HARD
			decision_interval = 0.10
		_:
			difficulty = Difficulty.MEDIUM
			decision_interval = 0.22

func update() -> void:
	# Reset single-frame action pulses
	jump_just_pressed = false
	attack_just_pressed = false
	dodge_just_pressed = false
	down_just_pressed = false
	up_just_pressed = false
	left_just_pressed = false
	right_just_pressed = false
	
	if not fighter or not is_instance_valid(fighter):
		move_axis = 0.0
		return
	
	# If dead or stunned, do nothing
	if "current_state" in fighter and fighter.current_state == 8: # DEAD
		move_axis = 0.0
		return
	
	# Cooldown updates (using standard frame delta ~1/60s)
	var dt = 0.0166
	decision_timer -= dt
	if attack_cooldown > 0.0:
		attack_cooldown -= dt
	if jump_cooldown > 0.0:
		jump_cooldown -= dt
	if idle_pause_timer > 0.0:
		idle_pause_timer -= dt
		move_axis = 0.0
		return

	# Acquire target if missing or dead
	if not target or not is_instance_valid(target) or ("current_state" in target and target.current_state == 8):
		_find_target()

	# 1. CRITICAL: Platform & Abyss Recovery
	if _handle_recovery():
		return

	# 2. Strategic Decision Tick
	if decision_timer <= 0.0:
		decision_timer = decision_interval + randf_range(-0.04, 0.04)
		_make_combat_decision()

func _find_target() -> void:
	target = null
	var tree = fighter.get_tree()
	if not tree:
		return
	
	var fighters = tree.get_nodes_in_group("fighters")
	var best_dist = 999999.0
	for f in fighters:
		if f != fighter and is_instance_valid(f):
			if "current_state" in f and f.current_state != 8: # not dead
				var d = fighter.global_position.distance_to(f.global_position)
				if d < best_dist:
					best_dist = d
					target = f

func _handle_recovery() -> bool:
	var f_pos = fighter.global_position
	var is_off_stage_horizontal = (f_pos.x < 240.0 or f_pos.x > 1040.0)
	var is_falling_deep = (f_pos.y > 480.0 and not fighter.is_on_floor())
	
	if is_off_stage_horizontal or is_falling_deep:
		# Direction towards center of the stage
		var dir_to_center = 1.0 if f_pos.x < stage_center_x else -1.0
		move_axis = dir_to_center
		
		# Wall slide recovery (Wall Jump towards center)
		if fighter.is_on_wall():
			if jump_cooldown <= 0.0:
				jump_just_pressed = true
				jump_cooldown = 0.25
				return true
		
		# Air Jump recovery if falling
		if not fighter.is_on_floor() and fighter.velocity.y > 20.0:
			var jumps_left = fighter.get("air_jumps_left") if "air_jumps_left" in fighter else 0
			if jumps_left > 0 and jump_cooldown <= 0.0:
				jump_just_pressed = true
				jump_cooldown = 0.35
				return true
		return true
	
	return false

func _make_combat_decision() -> void:
	if not target or not is_instance_valid(target):
		move_axis = 0.0
		return
	
	var my_pos = fighter.global_position
	var tgt_pos = target.global_position
	var dx = tgt_pos.x - my_pos.x
	var dy = tgt_pos.y - my_pos.y
	var dist_x = abs(dx)
	var dist_y = abs(dy)
	var dir_to_target = sign(dx) if dist_x > 8.0 else 0.0
	
	# Easy mode occasional idle hesitation
	if difficulty == Difficulty.EASY and randf() < 0.22:
		idle_pause_timer = randf_range(0.3, 0.5)
		move_axis = 0.0
		return

	# Attack range threshold (~75px horizontal, within 45px vertical)
	var attack_range = 80.0
	if dist_x <= attack_range and dist_y <= 50.0:
		# In attack range: face target and strike
		move_axis = dir_to_target * 0.15 # slight drift forward
		
		var attack_chance = 0.45
		if difficulty == Difficulty.MEDIUM:
			attack_chance = 0.78
		elif difficulty == Difficulty.HARD:
			attack_chance = 0.92
		
		if randf() < attack_chance and attack_cooldown <= 0.0:
			attack_just_pressed = true
			# Combo pacing: faster on hard, rhythmic on medium
			if difficulty == Difficulty.HARD:
				attack_cooldown = randf_range(0.12, 0.20)
			else:
				attack_cooldown = randf_range(0.18, 0.30)
		
		# Dodge reaction if target is actively attacking
		if difficulty == Difficulty.HARD and randf() < 0.40:
			if "current_state" in target and target.current_state in [3, 4, 5]: # ATTACK states
				dodge_just_pressed = true
		elif difficulty == Difficulty.MEDIUM and randf() < 0.18:
			if "current_state" in target and target.current_state in [3, 4, 5]:
				dodge_just_pressed = true
		return

	# Approaching Target
	move_axis = dir_to_target

	# Target is on higher platform
	if dy < -65.0:
		if fighter.is_on_floor() and jump_cooldown <= 0.0:
			if dist_x < 200.0:
				jump_just_pressed = true
				jump_cooldown = 0.45
	
	# Target is on lower platform
	elif dy > 75.0 and dist_x < 120.0 and fighter.is_on_floor():
		# Try drop-through platform
		down_just_pressed = true
		jump_just_pressed = true
		jump_cooldown = 0.35
