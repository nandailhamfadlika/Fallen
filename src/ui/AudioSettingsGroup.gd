class_name AudioSettingsGroup
extends VBoxContainer

## Reusable Audio & Language Settings Controls (Master, Music, SFX, Language)
## Syncs directly with AudioManager buses and LocalizationManager, persisting user preferences.

const BUS_ROWS := [
	{"node": "MasterRow", "label": "Master Volume", "bus": &"Master"},
	{"node": "MusicRow", "label": "Music Volume", "bus": &"BGM"},
	{"node": "SfxRow", "label": "SFX Volume", "bus": &"SFX"}
]

const SFX_PREVIEW_COOLDOWN_MS: int = 120

var _sliders: Dictionary = {}
var _value_labels: Dictionary = {}
var _is_refreshing: bool = false
var _last_sfx_preview_ms: int = 0
var _save_timer: Timer

@onready var language_row: HBoxContainer = get_node_or_null("LanguageRow")
@onready var language_label: Label = get_node_or_null("LanguageRow/NameLabel")
@onready var btn_language: Button = get_node_or_null("LanguageRow/BtnLanguage")

func _ready() -> void:
	_save_timer = Timer.new()
	_save_timer.one_shot = true
	_save_timer.wait_time = 0.25
	_save_timer.timeout.connect(_on_save_timer_timeout)
	add_child(_save_timer)

	var ordered_sliders: Array[HSlider] = []
	for row_cfg in BUS_ROWS:
		var row := get_node_or_null(row_cfg["node"])
		if not row:
			continue
		var slider := row.get_node_or_null("VolumeSlider") as HSlider
		var val_lbl := row.get_node_or_null("ValueLabel") as Label
		if slider and val_lbl:
			var bus_name: StringName = row_cfg["bus"]
			_sliders[bus_name] = slider
			_value_labels[bus_name] = val_lbl
			ordered_sliders.append(slider)
			slider.value_changed.connect(func(v: float): _on_slider_value_changed(bus_name, v))
			slider.focus_entered.connect(func():
				var am := get_node_or_null("/root/AudioManager")
				if am:
					am.play_sfx("select")
			)

	for i in range(ordered_sliders.size()):
		if i > 0:
			ordered_sliders[i].focus_neighbor_top = ordered_sliders[i - 1].get_path()
		if i < ordered_sliders.size() - 1:
			ordered_sliders[i].focus_neighbor_bottom = ordered_sliders[i + 1].get_path()

	if btn_language:
		if not ordered_sliders.is_empty():
			var last_sl: HSlider = ordered_sliders.back()
			last_sl.focus_neighbor_bottom = btn_language.get_path()
			btn_language.focus_neighbor_top = last_sl.get_path()
		btn_language.pressed.connect(_on_language_pressed)
		btn_language.focus_entered.connect(func():
			var am := get_node_or_null("/root/AudioManager")
			if am:
				am.play_sfx("select")
		)

	var am := get_node_or_null("/root/AudioManager")
	if am and am.has_signal("bus_volume_changed"):
		am.bus_volume_changed.connect(_on_external_bus_volume_changed)

	var lm := get_node_or_null("/root/LocalizationManager")
	if lm and lm.has_signal("locale_changed"):
		lm.locale_changed.connect(func(_l: String): _update_locale_texts())

	refresh()
	_update_locale_texts()

func refresh() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if not am:
		return
	_is_refreshing = true
	for bus_name in _sliders:
		var linear: float = am.get_bus_volume_linear(bus_name)
		var pct := int(round(linear * 100.0))
		(_sliders[bus_name] as HSlider).value = pct
		_update_value_label(bus_name, pct)
	_is_refreshing = false
	_update_locale_texts()

func _update_locale_texts() -> void:
	var lm := get_node_or_null("/root/LocalizationManager")
	var lang_name: String = lm.get_locale_display_name() if lm else "English"
	if btn_language:
		btn_language.text = "< %s >" % lang_name
	if language_label:
		language_label.text = tr("OPT_SECTION_LANGUAGE")

	var row_keys := {
		&"Master": "OPT_MASTER_VOL",
		&"BGM": "OPT_MUSIC_VOL",
		&"SFX": "OPT_SFX_VOL"
	}
	for row_cfg in BUS_ROWS:
		var row := get_node_or_null(row_cfg["node"])
		if row:
			var name_lbl := row.get_node_or_null("NameLabel") as Label
			if name_lbl:
				var k: String = row_keys.get(row_cfg["bus"], row_cfg["label"])
				name_lbl.text = tr(k)

func _on_language_pressed() -> void:
	var lm := get_node_or_null("/root/LocalizationManager")
	if lm:
		lm.toggle_locale()
		var am := get_node_or_null("/root/AudioManager")
		if am:
			am.play_sfx("confirm")

func get_first_focusable() -> Control:
	return _sliders.get(&"Master", null)

func get_last_focusable() -> Control:
	if btn_language:
		return btn_language
	return _sliders.get(&"SFX", null)

func _on_slider_value_changed(bus_name: StringName, value: float) -> void:
	var pct := int(round(value))
	_update_value_label(bus_name, pct)
	if _is_refreshing:
		return

	var am := get_node_or_null("/root/AudioManager")
	if am:
		am.set_bus_volume_linear(bus_name, float(pct) / 100.0, false)
		if bus_name == &"SFX" or bus_name == &"Master":
			var now := Time.get_ticks_msec()
			if now - _last_sfx_preview_ms >= SFX_PREVIEW_COOLDOWN_MS:
				_last_sfx_preview_ms = now
				am.play_sfx("select")
	if _save_timer:
		_save_timer.start()

func _on_external_bus_volume_changed(bus_name: StringName, linear: float) -> void:
	if _is_refreshing or not _sliders.has(bus_name):
		return
	var slider := _sliders[bus_name] as HSlider
	var pct := int(round(linear * 100.0))
	if int(round(slider.value)) != pct:
		slider.value = pct
		_update_value_label(bus_name, pct)

func _update_value_label(bus_name: StringName, pct: int) -> void:
	var lbl := _value_labels.get(bus_name, null) as Label
	if lbl:
		lbl.text = "%d%%" % pct

func _on_save_timer_timeout() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am and am.has_method("save_audio_settings"):
		am.save_audio_settings()
