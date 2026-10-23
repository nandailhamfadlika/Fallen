class_name OffscreenIndicator
extends Control

# Brawlhalla / Super Smash Bros Style Offscreen Telescope Bubble ("Teleskop")

const PORTRAITS = {
	"aron": "res://assets/ui/portraits/portrait_aron.png",
	"om_hami": "res://assets/ui/portraits/portrait_om_hami.png",
	"om hami": "res://assets/ui/portraits/portrait_om_hami.png",
	"kemet": "res://assets/ui/portraits/portrait_kemet.png",
	"butler": "res://assets/ui/portraits/portrait_butler.png",
	"mike": "res://assets/ui/portraits/portrait_mike.png",
	"the_first_fallen": "res://assets/ui/portraits/portrait_first_fallen.png",
	"the first fallen": "res://assets/ui/portraits/portrait_first_fallen.png",
	"muslan": "res://assets/ui/portraits/portrait_muslan.png",
	"rin": "res://assets/ui/portraits/portrait_rin.png",
	"sunkibo": "res://assets/ui/portraits/portrait_sunkibo.png"
}

@export var player_id: int = 1
@export var player_color: Color = Color(0.2, 0.85, 1.0)
@export var margin_x: float = 54.0
@export var margin_top: float = 90.0
@export var margin_bottom: float = 54.0

var target_fighter: CharacterBody2D
var target_screen_pos: Vector2 = Vector2.ZERO
var is_offscreen: bool = false
var is_active: bool = false

@onready var bubble_panel: Panel = $BubblePanel
@onready var portrait_texture: TextureRect = $BubblePanel/Clipper/PortraitTexture
@onready var badge_label: Label = $BadgeLabel
@onready var dist_label: Label = $DistanceLabel

func _ready() -> void:
	modulate.a = 0.0

func setup(fighter: CharacterBody2D, p_id: int, p_color: Color) -> void:
	target_fighter = fighter
	player_id = p_id
	player_color = p_color
	is_active = true
	
	if badge_label:
		badge_label.text = "P%d" % player_id
		badge_label.modulate = player_color
	
	# Tentukan gambar portrait petarung
	var char_key = ""
	if "fighter_name" in fighter:
		char_key = fighter.fighter_name.to_lower()
	elif player_id == 1 and GameManager.p1_character != "":
		char_key = GameManager.p1_character.to_lower()
	elif player_id == 2 and GameManager.p2_character != "":
		char_key = GameManager.p2_character.to_lower()
	
	var portrait_path = PORTRAITS.get(char_key, "res://assets/ui/portraits/portrait_aron.png")
	if ResourceLoader.exists(portrait_path) and portrait_texture:
		portrait_texture.texture = load(portrait_path)
	
	# Kustomisasi warna lingkaran & glow sesuai player
	if bubble_panel:
		var style = bubble_panel.get_theme_stylebox("panel")
		if style:
			var new_style = style.duplicate() as StyleBoxFlat
			new_style.border_color = player_color
			new_style.shadow_color = Color(player_color.r, player_color.g, player_color.b, 0.6)
			bubble_panel.add_theme_stylebox_override("panel", new_style)

	modulate.a = 0.0

func _process(delta: float) -> void:
	if not is_active or not is_instance_valid(target_fighter) or not target_fighter.is_inside_tree():
		modulate.a = move_toward(modulate.a, 0.0, 10.0 * delta)
		return
	
	# Cek apakah petarung masih hidup
	if "current_state" in target_fighter and "State" in target_fighter:
		if target_fighter.current_state == target_fighter.State.DEAD:
			modulate.a = 0.0
			return

	# Ambil koordinat layar (viewport coordinates) aktual dari petarung
	target_screen_pos = target_fighter.get_global_transform_with_canvas().origin
	
	var vp_size = get_viewport_rect().size
	if vp_size == Vector2.ZERO:
		vp_size = Vector2(1280, 720)

	# Deteksi apakah petarung sedang di luar batas layar (off-screen)
	var on_screen = (
		target_screen_pos.x >= 24.0 and target_screen_pos.x <= (vp_size.x - 24.0) and
		target_screen_pos.y >= 24.0 and target_screen_pos.y <= (vp_size.y - 24.0)
	)

	is_offscreen = not on_screen

	if is_offscreen:
		# Kunci koordinat indikator meluncur di sepanjang bibir layar
		var clamped_x = clamp(target_screen_pos.x, margin_x, vp_size.x - margin_x)
		var clamped_y = clamp(target_screen_pos.y, margin_top, vp_size.y - margin_bottom)
		var target_indicator_pos = Vector2(clamped_x, clamped_y) - (size / 2.0)
		
		# Meluncur halus mengikuti petarung di tepi layar
		if global_position == Vector2.ZERO or modulate.a < 0.05:
			global_position = target_indicator_pos
		else:
			global_position = global_position.lerp(target_indicator_pos, 16.0 * delta)
		
		# Hitung jarak dalam meter untuk indikator kedalaman
		var diff = target_screen_pos - (global_position + (size / 2.0))
		var dist_m = max(1, int(round(diff.length() / 40.0)))
		if dist_label:
			dist_label.text = "%dm" % dist_m
		
		# Fade in
		modulate.a = move_toward(modulate.a, 1.0, 8.0 * delta)
		queue_redraw()
	else:
		# Petarung kembali masuk layar, fade out halus
		modulate.a = move_toward(modulate.a, 0.0, 8.0 * delta)
		if modulate.a > 0.01:
			queue_redraw()

func _draw() -> void:
	if not is_active or modulate.a <= 0.05 or not is_offscreen:
		return
	
	var center = size / 2.0
	var diff = target_screen_pos - (global_position + center)
	if diff.length_squared() < 16.0:
		return
	
	# Gambar panah penunjuk arah teleskop menuju lokasi petarung
	var dir = diff.normalized()
	var arrow_center = center + dir * 32.0
	var perp = Vector2(-dir.y, dir.x)
	var tip = arrow_center + dir * 13.0
	var b1 = arrow_center - dir * 3.0 + perp * 7.5
	var b2 = arrow_center - dir * 3.0 - perp * 7.5
	
	draw_colored_polygon(PackedVector2Array([tip, b1, b2]), player_color)
