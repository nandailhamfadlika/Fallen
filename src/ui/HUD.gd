class_name HUD
extends CanvasLayer

const OffscreenIndicatorScene = preload("res://src/ui/OffscreenIndicator.tscn")
const GEM_ACTIVE = preload("res://assets/ui/gem_active.png")
const GEM_EMPTY = preload("res://assets/ui/gem_empty.png")

const PLAYER_COLORS = [
	Color(0.2, 0.85, 1.0),   # P1 Cyan
	Color(1.0, 0.35, 0.2),   # P2 Red
	Color(0.27, 0.88, 0.36), # P3 Green
	Color(0.82, 0.38, 0.98)  # P4 Purple
]

# Player 1 UI
@onready var p1_container: Control = $P1Container
@onready var p1_bar: ProgressBar = $P1Container/P1HPBar
@onready var p1_label: Label = $P1Container/P1Header/P1NameLabel
@onready var p1_percent: Label = $P1Container/P1Header/P1HPPercent
@onready var p1_stock_container: HBoxContainer = $P1Container/P1StockContainer

# Player 2 UI
@onready var p2_container: Control = $P2Container
@onready var p2_bar: ProgressBar = $P2Container/P2HPBar
@onready var p2_label: Label = $P2Container/P2Header/P2NameLabel
@onready var p2_percent: Label = $P2Container/P2Header/P2HPPercent
@onready var p2_stock_container: HBoxContainer = $P2Container/P2StockContainer

# Player 3 UI
@onready var p3_container: Control = $P3Container
@onready var p3_bar: ProgressBar = $P3Container/P3HPBar
@onready var p3_label: Label = $P3Container/P3Header/P3NameLabel
@onready var p3_percent: Label = $P3Container/P3Header/P3HPPercent
@onready var p3_stock_container: HBoxContainer = $P3Container/P3StockContainer

# Player 4 UI
@onready var p4_container: Control = $P4Container
@onready var p4_bar: ProgressBar = $P4Container/P4HPBar
@onready var p4_label: Label = $P4Container/P4Header/P4NameLabel
@onready var p4_percent: Label = $P4Container/P4Header/P4HPPercent
@onready var p4_stock_container: HBoxContainer = $P4Container/P4StockContainer

@onready var banner_label: Label = $CenterContainer/VBoxContainer/BannerLabel
@onready var sub_banner: Label = $CenterContainer/VBoxContainer/SubBannerLabel
@onready var combo_label: Label = $ComboLabel
@onready var timer_label: Label = $TimerContainer/TimerLabel

var combo_count: int = 0
var combo_timer: float = 0.0

var indicators: Array[Control] = []

func _ready() -> void:
	banner_label.visible = false
	sub_banner.visible = false
	combo_label.visible = false

func setup_multiplayer(fighters: Array, players_data: Array[Dictionary]) -> void:
	var containers = [p1_container, p2_container, p3_container, p4_container]
	var bars = [p1_bar, p2_bar, p3_bar, p4_bar]
	var labels = [p1_label, p2_label, p3_label, p4_label]
	var percents = [p1_percent, p2_percent, p3_percent, p4_percent]

	# Hide all containers first
	for c in containers:
		if c: c.visible = false

	# Clear previous indicators
	for ind in indicators:
		if is_instance_valid(ind):
			ind.queue_free()
	indicators.clear()

	# Activate for each player
	for i in range(min(fighters.size(), players_data.size(), 4)):
		var fighter = fighters[i]
		var data = players_data[i]
		var p_id = data.get("player_id", i + 1)
		var p_color = data.get("color", PLAYER_COLORS[i % PLAYER_COLORS.size()])

		var idx = p_id - 1
		if idx >= 0 and idx < containers.size():
			containers[idx].visible = true
			if labels[idx]:
				labels[idx].text = fighter.fighter_name.to_upper()
			if bars[idx]:
				bars[idx].value = (fighter.current_hp / fighter.max_hp) * 100.0
			if percents[idx]:
				percents[idx].text = "100%"

		# Initialize stock gems display
		var max_st = GameManager.round_stocks
		update_fighter_stocks(p_id, max_st, max_st)

		# Spawn offscreen indicator
		var ind = OffscreenIndicatorScene.instantiate()
		add_child(ind)
		ind.setup(fighter, p_id, p_color)
		indicators.append(ind)

# Backward compatibility
func setup_offscreen_tracker(p1_fighter: CharacterBody2D, p2_fighter: CharacterBody2D) -> void:
	setup_multiplayer([p1_fighter, p2_fighter], [
		{"player_id": 1, "color": PLAYER_COLORS[0]},
		{"player_id": 2, "color": PLAYER_COLORS[1]}
	])

func update_fighter_stocks(player_id: int, current_stocks: int, max_stocks: int) -> void:
	var stock_containers = [p1_stock_container, p2_stock_container, p3_stock_container, p4_stock_container]
	var idx = player_id - 1
	if idx < 0 or idx >= stock_containers.size():
		return
	var container = stock_containers[idx]
	if not container:
		return

	# Re-create or update icons
	for child in container.get_children():
		child.queue_free()

	for i in range(max_stocks):
		var rect = TextureRect.new()
		rect.custom_minimum_size = Vector2(22, 28)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		var is_active = (i < current_stocks)
		rect.texture = GEM_ACTIVE if is_active else GEM_EMPTY
		if not is_active:
			rect.modulate = Color(0.65, 0.65, 0.7, 0.45)
		container.add_child(rect)

func update_fighter_hp(player_id: int, cur: float, max_hp: float) -> void:
	var bars = [p1_bar, p2_bar, p3_bar, p4_bar]
	var percents = [p1_percent, p2_percent, p3_percent, p4_percent]
	var idx = player_id - 1
	if idx >= 0 and idx < bars.size():
		var pct = (cur / max_hp) * 100.0
		if bars[idx]:
			bars[idx].value = pct
		if percents[idx]:
			percents[idx].text = "%d%%" % max(0, int(ceil(pct)))

func update_p1_hp(cur: float, max_hp: float) -> void:
	update_fighter_hp(1, cur, max_hp)

func update_p2_hp(cur: float, max_hp: float) -> void:
	update_fighter_hp(2, cur, max_hp)

func update_timer(seconds_left: int) -> void:
	if not timer_label:
		return
	if seconds_left < 0:
		timer_label.text = "∞"
		timer_label.modulate = Color(0.85, 0.9, 1.0)
	else:
		timer_label.text = "%02d" % seconds_left
		if seconds_left <= 10:
			timer_label.modulate = Color(1.0, 0.25, 0.25)
		elif seconds_left <= 20:
			timer_label.modulate = Color(1.0, 0.65, 0.2)
		else:
			timer_label.modulate = Color(1.0, 0.92, 0.25)

func _process(delta: float) -> void:
	if combo_timer > 0.0:
		combo_timer -= delta
		if combo_timer <= 0.0:
			combo_count = 0
			combo_label.visible = false

func set_player_names(p1_name: String, p2_name: String) -> void:
	if p1_label: p1_label.text = p1_name
	if p2_label: p2_label.text = p2_name

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
