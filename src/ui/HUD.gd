class_name HUD
extends CanvasLayer

@onready var p1_bar: ProgressBar = $P1Container/P1HPBar
@onready var p1_label: Label = $P1Container/P1NameLabel
@onready var p2_bar: ProgressBar = $P2Container/P2HPBar
@onready var p2_label: Label = $P2Container/P2NameLabel
@onready var banner_label: Label = $CenterContainer/BannerLabel
@onready var sub_banner: Label = $CenterContainer/SubBannerLabel
@onready var combo_label: Label = $ComboLabel

var combo_count: int = 0
var combo_timer: float = 0.0

func _ready() -> void:
	banner_label.visible = false
	sub_banner.visible = false
	combo_label.visible = false

func _process(delta: float) -> void:
	if combo_timer > 0.0:
		combo_timer -= delta
		if combo_timer <= 0.0:
			combo_count = 0
			combo_label.visible = false

func set_player_names(p1_name: String, p2_name: String) -> void:
	if p1_label:
		p1_label.text = p1_name
	if p2_label:
		p2_label.text = p2_name

func update_p1_hp(cur: float, max_hp: float) -> void:
	if p1_bar:
		p1_bar.value = (cur / max_hp) * 100.0

func update_p2_hp(cur: float, max_hp: float) -> void:
	if p2_bar:
		p2_bar.value = (cur / max_hp) * 100.0

func register_hit() -> void:
	combo_count += 1
	combo_timer = 1.2
	combo_label.visible = true
	combo_label.text = "%d HITS!" % combo_count
	combo_label.modulate = Color(0.2, 0.9, 1.0) if combo_count < 3 else Color(1.0, 0.8, 0.1)

func show_banner(title: String, subtitle: String = "") -> void:
	banner_label.text = title
	banner_label.visible = true
	if subtitle != "":
		sub_banner.text = subtitle
		sub_banner.visible = true
	else:
		sub_banner.visible = false

func hide_banner() -> void:
	banner_label.visible = false
	sub_banner.visible = false
