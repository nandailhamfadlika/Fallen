class_name BrawlhallaCamera
extends Camera2D

## Dynamic Bounding Box Camera ala Brawlhalla / Super Smash Bros
## Mendukung tracking multi-target, aspect-ratio dynamic zoom, stage anchor, 
## strict stage boundary clamping (tidak tembus ke area hitam void), dan anti-jitter.

# Referensi opsional langsung ke kedua pemain
@export var player1: CharacterBody2D
@export var player2: CharacterBody2D

# Daftar target yang dilacak (bisa multi-pemain)
@export var targets: Array = []

# Batas area visual panggung utama (1280x720) agar background tidak pernah terpotong
@export var stage_bounds: Rect2 = Rect2(0, 0, 1280, 720)
@export var stage_center: Vector2 = Vector2(640, 360)
@export var stage_weight: float = 0.25 # Seberapa kuat kamera ditarik ke stage center

# Area arena aktif untuk kalkulasi kamera. Petarung di luar area ini (off-stage/terlempar)
# tidak akan menarik kamera keluar arena, melainkan ditracking oleh Offscreen Indicator ("teleskop").
@export var tracking_bounds: Rect2 = Rect2(120, 80, 1040, 560)

# Batas Zoom (1.0 = pas 1280x720 tanpa border hitam, 1.35 = zoom-in saat adu pukul)
@export var min_zoom: float = 1.0
@export var max_zoom: float = 1.35

# Margin ekstra di sekeliling pemain (pixel) saat framing zoom
@export var margin: Vector2 = Vector2(360, 220)

# Kecepatan transisi posisi & zoom (lerp)
@export var smooth_speed: float = 6.0
@export var zoom_speed: float = 5.0

@onready var screen_size: Vector2 = get_viewport_rect().size

func _ready() -> void:
	enabled = true
	if screen_size == Vector2.ZERO:
		screen_size = Vector2(1280, 720)
	if global_position == Vector2.ZERO:
		global_position = stage_center
	zoom = Vector2(1.0, 1.0)

func _physics_process(delta: float) -> void:
	# Kumpulkan target aktif (baik dari player1/player2 maupun array targets)
	var active_targets: Array[Node2D] = []
	
	if is_instance_valid(player1) and player1.is_inside_tree() and _is_fighter_alive(player1):
		active_targets.append(player1)
	if is_instance_valid(player2) and player2.is_inside_tree() and _is_fighter_alive(player2):
		active_targets.append(player2)

	for t in targets:
		if is_instance_valid(t) and t is Node2D and t.is_inside_tree() and not active_targets.has(t):
			if _is_fighter_alive(t):
				active_targets.append(t)

	if active_targets.is_empty():
		# Kembali ke stage center secara halus jika tidak ada target aktif
		global_position = global_position.lerp(stage_center, smooth_speed * delta)
		zoom = zoom.lerp(Vector2(1.0, 1.0), zoom_speed * delta)
		return

	_update_camera_zoom(active_targets, delta)
	_update_camera_position(active_targets, delta)

func _is_fighter_alive(node: Node2D) -> bool:
	if "current_state" in node and "State" in node:
		if node.current_state == node.State.DEAD:
			return false
	return true

func _clamp_to_tracking_bounds(pos: Vector2) -> Vector2:
	return Vector2(
		clamp(pos.x, tracking_bounds.position.x, tracking_bounds.end.x),
		clamp(pos.y, tracking_bounds.position.y, tracking_bounds.end.y)
	)

func _update_camera_zoom(active_targets: Array[Node2D], delta: float) -> void:
	var first_pos = _clamp_to_tracking_bounds(active_targets[0].global_position)
	var min_pos: Vector2 = first_pos
	var max_pos: Vector2 = first_pos

	for t in active_targets:
		var clamped_p = _clamp_to_tracking_bounds(t.global_position)
		min_pos.x = min(min_pos.x, clamped_p.x)
		min_pos.y = min(min_pos.y, clamped_p.y)
		max_pos.x = max(max_pos.x, clamped_p.x)
		max_pos.y = max(max_pos.y, clamped_p.y)

	# Bounding box dengan margin
	var distance_x: float = (max_pos.x - min_pos.x) + margin.x
	var distance_y: float = (max_pos.y - min_pos.y) + margin.y

	var vp_size: Vector2 = get_viewport_rect().size
	if vp_size == Vector2.ZERO:
		vp_size = screen_size

	var target_zoom_x: float = vp_size.x / max(1.0, distance_x)
	var target_zoom_y: float = vp_size.y / max(1.0, distance_y)

	var target_zoom_val: float = min(target_zoom_x, target_zoom_y)
	target_zoom_val = clamp(target_zoom_val, max(1.0, min_zoom), max_zoom)

	var target_zoom: Vector2 = Vector2(target_zoom_val, target_zoom_val)
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)

func _update_camera_position(active_targets: Array[Node2D], delta: float) -> void:
	var midpoint: Vector2 = Vector2.ZERO
	if active_targets.size() == 2:
		var p1_pos = _clamp_to_tracking_bounds(active_targets[0].global_position)
		var p2_pos = _clamp_to_tracking_bounds(active_targets[1].global_position)
		midpoint = (p1_pos + p2_pos) / 2.0
	else:
		var sum_pos: Vector2 = Vector2.ZERO
		for t in active_targets:
			sum_pos += _clamp_to_tracking_bounds(t.global_position)
		midpoint = sum_pos / float(active_targets.size())

	# Tarik sebagian midpoint ke arah panggung utama (Stage Anchor ala Brawlhalla)
	var desired_pos: Vector2 = midpoint.lerp(stage_center, stage_weight)

	# Strict Boundary Clamping:
	# Pastikan frame kamera TIDAK PERNAH keluar dari stage_bounds (1280x720)
	var cur_zoom = zoom.x
	if cur_zoom < 1.0:
		cur_zoom = 1.0
	
	var half_w = (screen_size.x / cur_zoom) / 2.0
	var half_h = (screen_size.y / cur_zoom) / 2.0

	var min_x = stage_bounds.position.x + half_w
	var max_x = stage_bounds.end.x - half_w
	var min_y = stage_bounds.position.y + half_h
	var max_y = stage_bounds.end.y - half_h

	if min_x > max_x:
		desired_pos.x = stage_center.x
	else:
		desired_pos.x = clamp(desired_pos.x, min_x, max_x)

	if min_y > max_y:
		desired_pos.y = stage_center.y
	else:
		desired_pos.y = clamp(desired_pos.y, min_y, max_y)

	global_position = global_position.lerp(desired_pos, smooth_speed * delta)

func add_target(target: Node2D) -> void:
	if target and not targets.has(target):
		targets.append(target)

func remove_target(target: Node2D) -> void:
	targets.erase(target)
