class_name StageSelect
extends Control

# Mortal Kombat Style Stage Selection Screen
const STAGE_OPTIONS = [
	{
		"id": "ruined_school",
		"name": "RUINED ACADEMY",
		"desc": "Collapsed stone cathedral with ancient throne & torchlit abyss",
		"preview": "res://assets/stages/ruined_school_stage.png",
		"thumb": "res://assets/ui/stages/ruined_academy_thumb.png",
		"locked": false
	},
	{
		"id": "temple_ruin",
		"name": "TEMPLE RUIN",
		"desc": "Sacred Dragon Shrine flanked by stone effigies & suspended ledges",
		"preview": "res://assets/stages/temple_ruin_stage.png",
		"thumb": "res://assets/ui/stages/temple_ruin_thumb.png",
		"locked": false
	},
	{
		"id": "mad_lab",
		"name": "MAD LAB",
		"desc": "Overgrown bio-mechanical laboratory with toxic fluid vats & gantry",
		"preview": "res://assets/stages/Mad Lab.jpg",
		"thumb": "res://assets/ui/stages/mad_lab_thumb.png",
		"locked": false
	},
	{
		"id": "magic_waterfall",
		"name": "MAGIC WATERFALL",
		"desc": "Mystical moonlit cascading falls adorned with celestial tapestries",
		"preview": "res://assets/stages/Magic Waterfall.jpg",
		"thumb": "res://assets/ui/stages/magic_waterfall_thumb.png",
		"locked": false
	},
	{
		"id": "wild_west",
		"name": "WILD WEST",
		"desc": "Sun-drenched canyon mesa suspended amidst ancient sundial relics",
		"preview": "res://assets/stages/Wild West.jpg",
		"thumb": "res://assets/ui/stages/wild_west_thumb.png",
		"locked": false
	},
	{
		"id": "heaven_secret",
		"name": "HEAVEN'S SECRET",
		"desc": "Celestial sanctuary veiled above the clouds beneath the divine bonsai",
		"preview": "res://assets/stages/Heaven secret.jpg",
		"thumb": "res://assets/ui/stages/heaven_secret_thumb.png",
		"locked": false
	},
	{
		"id": "rooftop",
		"name": "ROOFTOP BRAWL",
		"desc": "Gritty urban sunset skyline with rooftop sparring ring & punchbag",
		"preview": "res://assets/stages/Rooftop.jpg",
		"thumb": "res://assets/ui/stages/rooftop_thumb.png",
		"locked": false
	},
	{
		"id": "random",
		"name": "RANDOM ARENA",
		"desc": "Fate decides the battlefield",
		"preview": "res://assets/stages/temple_ruin_stage.png",
		"thumb": "res://assets/ui/stages/random_stage_thumb.png",
		"locked": false
	}
]

var selected_index: int = 1 # Default to Temple Ruin
var is_locked_in: bool = false
var is_settings_open: bool = false

@onready var stage_preview: TextureRect = $TopSection/StagePanorama
@onready var stage_title_lbl: Label = $BannerContainer/StageTitle
@onready var stage_desc_lbl: Label = $BannerContainer/StageDesc
@onready var grid_container: GridContainer = $BottomSection/StoneBezel/GridContainer
@onready var p1_token: Panel = $BottomSection/StoneBezel/P1Token
@onready var status_lbl: Label = $StatusLabel

# Settings UI references
@onready var settings_btn: Button = $SettingsBtn
@onready var settings_popup: Control = $SettingsPopup
@onready var dialog_panel: PanelContainer = $SettingsPopup/DialogPanel
@onready var backdrop: ColorRect = $SettingsPopup/Backdrop

@onready var btn_99s: Button = $SettingsPopup/DialogPanel/Margin/VBox/TimeSection/TimeButtons/Btn99s
@onready var btn_120s: Button = $SettingsPopup/DialogPanel/Margin/VBox/TimeSection/TimeButtons/Btn120s
@onready var btn_150s: Button = $SettingsPopup/DialogPanel/Margin/VBox/TimeSection/TimeButtons/Btn150s
@onready var btn_inf: Button = $SettingsPopup/DialogPanel/Margin/VBox/TimeSection/TimeButtons/BtnInf

@onready var btn_stock_1: Button = $SettingsPopup/DialogPanel/Margin/VBox/StockSection/StockButtons/BtnStock1
@onready var btn_stock_2: Button = $SettingsPopup/DialogPanel/Margin/VBox/StockSection/StockButtons/BtnStock2
@onready var btn_stock_3: Button = $SettingsPopup/DialogPanel/Margin/VBox/StockSection/StockButtons/BtnStock3
@onready var btn_stock_5: Button = $SettingsPopup/DialogPanel/Margin/VBox/StockSection/StockButtons/BtnStock5

@onready var btn_close: Button = $SettingsPopup/DialogPanel/Margin/VBox/CloseBox/BtnClose

var style_opt_active: StyleBox
var style_opt_inactive: StyleBox
var slot_nodes: Array[Control] = []

func _ready() -> void:
	# Set initial selection from GameManager
	selected_index = 1
	for i in range(STAGE_OPTIONS.size()):
		if STAGE_OPTIONS[i]["id"] == GameManager.selected_stage:
			selected_index = i
			break

	_setup_slots()
	_setup_settings_popup()
	await get_tree().process_frame
	_update_display()
	_update_token_position()

func _setup_settings_popup() -> void:
	if not settings_popup:
		return
	settings_popup.visible = false

	# Cache styles from buttons
	if btn_99s.has_theme_stylebox_override("normal"):
		style_opt_active = btn_99s.get_theme_stylebox("normal")
	if btn_120s.has_theme_stylebox_override("normal"):
		style_opt_inactive = btn_120s.get_theme_stylebox("normal")

	settings_btn.pressed.connect(_open_settings_popup)
	btn_99s.pressed.connect(func(): _on_select_time(99))
	btn_120s.pressed.connect(func(): _on_select_time(120))
	btn_150s.pressed.connect(func(): _on_select_time(150))
	btn_inf.pressed.connect(func(): _on_select_time(-1))

	btn_stock_1.pressed.connect(func(): _on_select_stock(1))
	btn_stock_2.pressed.connect(func(): _on_select_stock(2))
	btn_stock_3.pressed.connect(func(): _on_select_stock(3))
	btn_stock_5.pressed.connect(func(): _on_select_stock(5))

	btn_close.pressed.connect(_close_settings_popup)

	# Click outside dialog to dismiss
	backdrop.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			_close_settings_popup()
	)

	# Setup gamepad/keyboard focus navigation
	# Row 1: Stock buttons
	btn_stock_1.focus_neighbor_right = btn_stock_2.get_path()
	btn_stock_2.focus_neighbor_left = btn_stock_1.get_path()
	btn_stock_2.focus_neighbor_right = btn_stock_3.get_path()
	btn_stock_3.focus_neighbor_left = btn_stock_2.get_path()
	btn_stock_3.focus_neighbor_right = btn_stock_5.get_path()
	btn_stock_5.focus_neighbor_left = btn_stock_3.get_path()

	btn_stock_1.focus_neighbor_bottom = btn_99s.get_path()
	btn_stock_2.focus_neighbor_bottom = btn_120s.get_path()
	btn_stock_3.focus_neighbor_bottom = btn_150s.get_path()
	btn_stock_5.focus_neighbor_bottom = btn_inf.get_path()

	# Row 2: Time buttons
	btn_99s.focus_neighbor_top = btn_stock_1.get_path()
	btn_120s.focus_neighbor_top = btn_stock_2.get_path()
	btn_150s.focus_neighbor_top = btn_stock_3.get_path()
	btn_inf.focus_neighbor_top = btn_stock_5.get_path()

	btn_99s.focus_neighbor_right = btn_120s.get_path()
	btn_120s.focus_neighbor_left = btn_99s.get_path()
	btn_120s.focus_neighbor_right = btn_150s.get_path()
	btn_150s.focus_neighbor_left = btn_120s.get_path()
	btn_150s.focus_neighbor_right = btn_inf.get_path()
	btn_inf.focus_neighbor_left = btn_150s.get_path()

	btn_99s.focus_neighbor_bottom = btn_close.get_path()
	btn_120s.focus_neighbor_bottom = btn_close.get_path()
	btn_150s.focus_neighbor_bottom = btn_close.get_path()
	btn_inf.focus_neighbor_bottom = btn_close.get_path()

	# Row 3: Close button
	btn_close.focus_neighbor_top = btn_120s.get_path()

	_update_settings_ui()

func _setup_slots() -> void:
	slot_nodes.clear()
	var children = grid_container.get_children()
	for i in range(children.size()):
		var slot = children[i] as Control
		slot_nodes.append(slot)
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		var idx = i
		slot.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed and not is_locked_in:
				if idx < STAGE_OPTIONS.size() and not STAGE_OPTIONS[idx]["locked"]:
					selected_index = idx
					_update_display()
					_update_token_position()
					if event.double_click:
						_confirm_selection()
		)

func _unhandled_input(event: InputEvent) -> void:
	if is_settings_open:
		if event.is_action_pressed("pause") or (event is InputEventKey and event.pressed and (event.physical_keycode == KEY_ESCAPE or event.physical_keycode == KEY_T or event.physical_keycode == KEY_S)):
			_close_settings_popup()
			get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_T or event.physical_keycode == KEY_S:
			_open_settings_popup()
			get_viewport().set_input_as_handled()
			return

	if is_locked_in:
		return

	if event.is_action_pressed("p1_move_left") or event.is_action_pressed("p2_move_left") or event.is_action_pressed("ui_left"):
		_move_selection(-1)
	elif event.is_action_pressed("p1_move_right") or event.is_action_pressed("p2_move_right") or event.is_action_pressed("ui_right"):
		_move_selection(1)
	elif event.is_action_pressed("p1_up") or event.is_action_pressed("p2_up") or event.is_action_pressed("ui_up"):
		_move_selection(-7)
	elif event.is_action_pressed("p1_down") or event.is_action_pressed("p2_down") or event.is_action_pressed("ui_down"):
		_move_selection(7)
	elif event.is_action_pressed("p1_attack") or event.is_action_pressed("p2_attack") or event.is_action_pressed("ui_accept"):
		_confirm_selection()
	elif event.is_action_pressed("pause"):
		GameManager.go_to_character_select()

func _open_settings_popup() -> void:
	if is_locked_in or is_settings_open or not settings_popup:
		return
	is_settings_open = true
	settings_popup.visible = true
	_update_settings_ui()

	dialog_panel.pivot_offset = dialog_panel.size / 2.0
	dialog_panel.scale = Vector2(0.92, 0.92)
	dialog_panel.modulate.a = 0.0

	var tween = create_tween().set_parallel(true)
	tween.tween_property(dialog_panel, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(dialog_panel, "modulate:a", 1.0, 0.15)

	# Focus current selected time
	if GameManager.round_time_limit == 120:
		btn_120s.grab_focus()
	elif GameManager.round_time_limit == 150:
		btn_150s.grab_focus()
	elif GameManager.round_time_limit <= 0:
		btn_inf.grab_focus()
	else:
		btn_99s.grab_focus()

func _close_settings_popup() -> void:
	if not is_settings_open:
		return
	is_settings_open = false
	var tween = create_tween()
	tween.tween_property(dialog_panel, "modulate:a", 0.0, 0.1)
	await tween.finished
	if not is_settings_open and settings_popup:
		settings_popup.visible = false

func _on_select_time(seconds: int) -> void:
	GameManager.set_time_limit(seconds)
	_update_settings_ui()
	
	var btn: Button = null
	if seconds == 99: btn = btn_99s
	elif seconds == 120: btn = btn_120s
	elif seconds == 150: btn = btn_150s
	elif seconds <= 0: btn = btn_inf
	if btn:
		btn.pivot_offset = btn.size / 2.0
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.07)
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)

func _on_select_stock(stocks: int) -> void:
	GameManager.set_stocks(stocks)
	_update_settings_ui()

	var btn: Button = null
	if stocks == 1: btn = btn_stock_1
	elif stocks == 2: btn = btn_stock_2
	elif stocks == 3: btn = btn_stock_3
	elif stocks == 5: btn = btn_stock_5
	if btn:
		btn.pivot_offset = btn.size / 2.0
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.07)
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)

func _update_settings_ui() -> void:
	var limit = GameManager.round_time_limit
	var stocks = GameManager.round_stocks
	var time_str = "∞" if limit <= 0 else "%ds" % limit
	if settings_btn:
		settings_btn.text = "⚙ SETTINGS [T] (%s | %d Souls)" % [time_str, stocks]

	var time_buttons_map = {
		99: btn_99s,
		120: btn_120s,
		150: btn_150s,
		-1: btn_inf
	}

	for time_val in time_buttons_map:
		var btn = time_buttons_map[time_val] as Button
		if not btn:
			continue
		var is_selected = (time_val == limit) or (time_val == -1 and limit <= 0)
		if is_selected:
			if style_opt_active:
				btn.add_theme_stylebox_override("normal", style_opt_active)
			btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
			btn.text = "✔ " + ("∞" if time_val <= 0 else "%ds" % time_val)
		else:
			if style_opt_inactive:
				btn.add_theme_stylebox_override("normal", style_opt_inactive)
			btn.add_theme_color_override("font_color", Color(0.7, 0.72, 0.8))
			btn.text = "∞ INFINITY" if time_val <= 0 else "%ds" % time_val

	var stock_buttons_map = {
		1: btn_stock_1,
		2: btn_stock_2,
		3: btn_stock_3,
		5: btn_stock_5
	}

	for s_val in stock_buttons_map:
		var btn = stock_buttons_map[s_val] as Button
		if not btn:
			continue
		var is_selected = (s_val == stocks)
		var label_str = "%d SOUL" % s_val if s_val == 1 else "%d SOULS" % s_val
		if is_selected:
			if style_opt_active:
				btn.add_theme_stylebox_override("normal", style_opt_active)
			btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
			btn.text = "✔ " + label_str
		else:
			if style_opt_inactive:
				btn.add_theme_stylebox_override("normal", style_opt_inactive)
			btn.add_theme_color_override("font_color", Color(0.7, 0.72, 0.8))
			btn.text = label_str

func _move_selection(dir: int) -> void:
	var total_selectable = STAGE_OPTIONS.size()
	if abs(dir) == 1:
		selected_index = (selected_index + dir + total_selectable) % total_selectable
	elif dir == 7: # Down
		if selected_index < 7:
			selected_index = 7 # Jump to random arena
		else:
			selected_index = 0
	elif dir == -7: # Up
		if selected_index == 7:
			selected_index = 0
		else:
			selected_index = 7
	_update_display()
	_update_token_position()

func _update_display() -> void:
	var data = STAGE_OPTIONS[selected_index]
	stage_title_lbl.text = data["name"]
	stage_desc_lbl.text = data["desc"]
	
	if ResourceLoader.exists(data["preview"]):
		stage_preview.texture = load(data["preview"])
	
	# Title bump animation
	stage_title_lbl.pivot_offset = stage_title_lbl.size / 2.0
	var tween = create_tween()
	tween.tween_property(stage_title_lbl, "scale", Vector2(1.15, 1.15), 0.08)
	tween.tween_property(stage_title_lbl, "scale", Vector2(1.0, 1.0), 0.12)

func _update_token_position() -> void:
	if selected_index < slot_nodes.size():
		var target_slot = slot_nodes[selected_index]
		var target_pos = target_slot.global_position - Vector2(4, 4)
		var target_sz = target_slot.size + Vector2(8, 8)
		
		var tween = create_tween().set_parallel(true)
		tween.tween_property(p1_token, "global_position", target_pos, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(p1_token, "size", target_sz, 0.1)

func _confirm_selection() -> void:
	is_locked_in = true
	var chosen_id = STAGE_OPTIONS[selected_index]["id"]
	
	if chosen_id == "random":
		var candidates: Array[String] = []
		for opt in STAGE_OPTIONS:
			if opt["id"] != "random" and not opt.get("locked", false):
				candidates.append(opt["id"])
		if candidates.size() > 0:
			chosen_id = candidates[randi() % candidates.size()]
		else:
			chosen_id = "temple_ruin"
	
	GameManager.selected_stage = chosen_id
	
	# Dramatic confirmation flash
	status_lbl.text = "ARENA CONFIRMED - ENTERING BATTLE!"
	status_lbl.modulate = Color(1.0, 0.3, 0.2)
	p1_token.modulate = Color(2.0, 1.5, 0.5) # Bright gold flash
	
	var tween = create_tween()
	tween.tween_property(status_lbl, "scale", Vector2(1.2, 1.2), 0.15)
	tween.tween_property(status_lbl, "scale", Vector2(1.0, 1.0), 0.15)
	
	await get_tree().create_timer(0.9).timeout
	GameManager.launch_match()
