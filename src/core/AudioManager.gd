extends Node

## AudioManager — Persistent Autoload Singleton for BGM & SFX Playback
## Manages AudioServer buses (Master, BGM, SFX), seamless BGM crossfading,
## loop configuration, pause ducking, and a polyphonic SFX player pool.

signal bgm_changed(bgm_key: String)
signal sfx_played(sfx_key: String)
signal bus_volume_changed(bus_name: StringName, linear: float)

const BUS_MASTER := &"Master"
const BUS_BGM := &"BGM"
const BUS_SFX := &"SFX"
const AUDIO_SETTINGS_PATH: String = "user://audio_settings.cfg"

const DEFAULT_VOLUMES: Dictionary = {
	"Master": 1.0,
	"BGM": 0.85,
	"SFX": 1.0
}

const SFX_POOL_SIZE: int = 8
const DEFAULT_BGM_VOLUME_DB: float = -4.0
const DUCK_OFFSET_DB: float = -8.0
const SILENT_DB: float = -45.0
const SELECT_DEBOUNCE_MS: int = 35

const BGM_PATHS: Dictionary = {
	"main_menu": "res://assets/musics/bgm/main_menu.ogg",
	"story_prologue": "res://assets/musics/bgm/story_prologue.ogg",
	"stage_rooftop": "res://assets/musics/bgm/stage_rooftop.ogg",
	"stage_magic_waterfall": "res://assets/musics/bgm/stage_magic_waterfall.ogg",
	"stage_mad_lab": "res://assets/musics/bgm/stage_mad_lab.ogg",
	"stage_temple_ruin": "res://assets/musics/bgm/stage_temple_ruin.ogg",
	"stage_wild_west": "res://assets/musics/bgm/stage_wild_west.ogg",
	"stage_heaven_secret": "res://assets/musics/bgm/stage_heaven_secret.ogg"
}

const STAGE_BGM_MAP: Dictionary = {
	"rooftop": "stage_rooftop",
	"magic_waterfall": "stage_magic_waterfall",
	"mad_lab": "stage_mad_lab",
	"temple_ruin": "stage_temple_ruin",
	"wild_west": "stage_wild_west",
	"heaven_secret": "stage_heaven_secret"
}

const SFX_PATHS: Dictionary = {
	"jump": "res://assets/musics/sfx/sfx_jump.wav",
	"confirm": "res://assets/musics/sfx/sfx_confirm.wav",
	"select": "res://assets/musics/sfx/sfx_select.wav",
	"back": "res://assets/musics/sfx/sfx_back.wav",
	"text_blip": "res://assets/musics/sfx/sfx_text_blip.wav",
	"sudden_death": "res://assets/musics/sfx/sfx_sudden_death.wav",
	"dash": "res://assets/musics/sfx/sfx_dash.wav",
	"land": "res://assets/musics/sfx/sfx_land.wav",
	"respawn": "res://assets/musics/sfx/sfx_respawn.wav",
	"victory": "res://assets/musics/sfx/sfx_victory.wav",
	"wall_slide": "res://assets/musics/sfx/sfx_wall_slide.wav"
}

var _bgm_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_pool_idx: int = 0

var _bgm_cache: Dictionary = {}
var _sfx_cache: Dictionary = {}

var _current_bgm_key: String = ""
var _bgm_tween: Tween
var _is_ducked: bool = false
var _last_select_msec: int = 0
var _select_suppress_until_msec: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_audio_buses()
	_load_audio_settings()
	_setup_players()
	_preload_sfx()

func _setup_audio_buses() -> void:
	for bus_name in [BUS_BGM, BUS_SFX]:
		if AudioServer.get_bus_index(bus_name) == -1:
			var idx := AudioServer.bus_count
			AudioServer.add_bus(idx)
			AudioServer.set_bus_name(idx, bus_name)
			AudioServer.set_bus_send(idx, BUS_MASTER)

func _setup_players() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGMPlayer"
	_bgm_player.bus = BUS_BGM
	_bgm_player.volume_db = DEFAULT_BGM_VOLUME_DB
	add_child(_bgm_player)

	for i in range(SFX_POOL_SIZE):
		var sfx_player := AudioStreamPlayer.new()
		sfx_player.name = "SFXPlayer_%d" % i
		sfx_player.bus = BUS_SFX
		add_child(sfx_player)
		_sfx_players.append(sfx_player)

func _preload_sfx() -> void:
	for key in SFX_PATHS:
		var path: String = SFX_PATHS[key]
		if ResourceLoader.exists(path):
			_sfx_cache[key] = load(path)

func _get_bgm_stream(bgm_key: String) -> AudioStream:
	if _bgm_cache.has(bgm_key):
		return _bgm_cache[bgm_key]
	if not BGM_PATHS.has(bgm_key):
		return null
	var path: String = BGM_PATHS[bgm_key]
	if not ResourceLoader.exists(path):
		push_warning("AudioManager: BGM file not found: %s" % path)
		return null
	var stream := load(path) as AudioStream
	if stream:
		if "loop" in stream:
			stream.loop = true
		_bgm_cache[bgm_key] = stream
	return stream

func _get_effective_bgm_db() -> float:
	return DEFAULT_BGM_VOLUME_DB + (DUCK_OFFSET_DB if _is_ducked else 0.0)

func _kill_bgm_tween() -> void:
	if _bgm_tween and _bgm_tween.is_valid():
		_bgm_tween.kill()
	_bgm_tween = null

func _create_always_tween() -> Tween:
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return tw

## Plays a registered BGM track by key.
## If the same track is already playing, keeps playback seamless without restarting.
func play_bgm(bgm_key: String, fade_duration: float = 0.4) -> void:
	if bgm_key == _current_bgm_key and _bgm_player.playing:
		return

	var stream := _get_bgm_stream(bgm_key)
	if not stream:
		stop_bgm(fade_duration)
		return

	_current_bgm_key = bgm_key
	bgm_changed.emit(bgm_key)

	_kill_bgm_tween()
	var target_db := _get_effective_bgm_db()

	if fade_duration <= 0.0:
		_bgm_player.stream = stream
		_bgm_player.volume_db = target_db
		_bgm_player.play()
		return

	_bgm_tween = _create_always_tween()
	if _bgm_player.playing:
		var out_dur := fade_duration * 0.45
		var in_dur := fade_duration * 0.55
		_bgm_tween.tween_property(_bgm_player, "volume_db", SILENT_DB, out_dur)
		_bgm_tween.tween_callback(func():
			if _current_bgm_key == bgm_key:
				_bgm_player.stream = stream
				_bgm_player.volume_db = SILENT_DB
				_bgm_player.play()
		)
		_bgm_tween.tween_property(_bgm_player, "volume_db", target_db, in_dur)
	else:
		_bgm_player.stream = stream
		_bgm_player.volume_db = SILENT_DB
		_bgm_player.play()
		_bgm_tween.tween_property(_bgm_player, "volume_db", target_db, fade_duration)

## Plays BGM mapped to a stage ID, or stops BGM smoothly if the stage has no track assigned.
func play_stage_bgm(stage_id: String, fade_duration: float = 0.5) -> void:
	var bgm_key: String = STAGE_BGM_MAP.get(stage_id, "")
	if bgm_key.is_empty():
		stop_bgm(fade_duration)
	else:
		play_bgm(bgm_key, fade_duration)

## Stops currently playing BGM with an optional fade-out.
func stop_bgm(fade_duration: float = 0.4) -> void:
	_current_bgm_key = ""
	_kill_bgm_tween()

	if not _bgm_player or not _bgm_player.playing:
		return

	if fade_duration <= 0.0:
		_bgm_player.stop()
		return

	_bgm_tween = _create_always_tween()
	_bgm_tween.tween_property(_bgm_player, "volume_db", SILENT_DB, fade_duration)
	_bgm_tween.tween_callback(func():
		if _current_bgm_key.is_empty():
			_bgm_player.stop()
			_bgm_player.volume_db = _get_effective_bgm_db()
	)

## Smoothly lowers or restores BGM volume (e.g., while PauseMenu is open).
func set_bgm_ducked(ducked: bool, fade_duration: float = 0.2) -> void:
	if _is_ducked == ducked:
		return
	_is_ducked = ducked
	if not _bgm_player or not _bgm_player.playing:
		return

	_kill_bgm_tween()
	var target_db := _get_effective_bgm_db()
	if fade_duration <= 0.0:
		_bgm_player.volume_db = target_db
	else:
		_bgm_tween = _create_always_tween()
		_bgm_tween.tween_property(_bgm_player, "volume_db", target_db, fade_duration)

## Suppresses "select" SFX briefly (useful right after initial grab_focus on menu open).
func suppress_select_for(duration_ms: int = 80) -> void:
	_select_suppress_until_msec = maxi(_select_suppress_until_msec, Time.get_ticks_msec() + duration_ms)

## Connects hover/focus ("select") and optional press SFX ("confirm"/"back") to a BaseButton.
func wire_button_sfx(button: BaseButton, press_sfx: String = "confirm", include_select: bool = true) -> void:
	if not is_instance_valid(button):
		return
	if include_select:
		button.focus_entered.connect(func(): play_sfx("select"))
		button.mouse_entered.connect(func(): play_sfx("select"))
	if not press_sfx.is_empty():
		button.pressed.connect(func(): play_sfx(press_sfx))

## Plays a registered SFX from the polyphonic pool.
func play_sfx(sfx_key: String, pitch_variance: float = 0.0, volume_db: float = 0.0) -> void:
	if sfx_key == "select":
		var now := Time.get_ticks_msec()
		if now < _select_suppress_until_msec:
			return
		if now - _last_select_msec < SELECT_DEBOUNCE_MS:
			return
		_last_select_msec = now

	var stream: AudioStream = _sfx_cache.get(sfx_key, null)
	if not stream and SFX_PATHS.has(sfx_key):
		var path: String = SFX_PATHS[sfx_key]
		if ResourceLoader.exists(path):
			stream = load(path)
			_sfx_cache[sfx_key] = stream
	if not stream:
		push_warning("AudioManager: SFX key '%s' not found." % sfx_key)
		return

	var player := _acquire_sfx_player()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance) if pitch_variance > 0.0 else 1.0
	player.play()
	sfx_played.emit(sfx_key)

func _acquire_sfx_player() -> AudioStreamPlayer:
	for p in _sfx_players:
		if not p.playing:
			return p
	var fallback := _sfx_players[_sfx_pool_idx]
	_sfx_pool_idx = (_sfx_pool_idx + 1) % _sfx_players.size()
	return fallback

func get_current_bgm_key() -> String:
	return _current_bgm_key

func set_bus_volume_linear(bus_name: StringName, linear: float, persist: bool = true) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	var clamped := clampf(linear, 0.0, 1.0)
	AudioServer.set_bus_mute(idx, clamped <= 0.001)
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(clamped, 0.001)))
	bus_volume_changed.emit(bus_name, clamped)
	if persist:
		save_audio_settings()

func get_bus_volume_linear(bus_name: StringName) -> float:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return 1.0
	if AudioServer.is_bus_mute(idx):
		return 0.0
	return clampf(db_to_linear(AudioServer.get_bus_volume_db(idx)), 0.0, 1.0)

func _load_audio_settings() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(AUDIO_SETTINGS_PATH)
	for bus_key in DEFAULT_VOLUMES:
		var val: float = DEFAULT_VOLUMES[bus_key]
		if err == OK:
			val = float(cfg.get_value("audio", bus_key, val))
		set_bus_volume_linear(StringName(bus_key), val, false)

func save_audio_settings() -> void:
	var cfg := ConfigFile.new()
	for bus_key in DEFAULT_VOLUMES:
		cfg.set_value("audio", bus_key, get_bus_volume_linear(StringName(bus_key)))
	cfg.save(AUDIO_SETTINGS_PATH)
