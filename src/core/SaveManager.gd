extends Node

## Singleton SaveManager
## Manages persistent save data for campaign progression, records, and unlocks.

signal campaign_save_updated()

const SAVE_PATH: String = "user://campaign_save.json"
const SAVE_VERSION: int = 1

# Metadata dictionary for characters
const HERO_METADATA: Dictionary = {
	"aron": {
		"name": "ARON",
		"title": "Speed Brawler",
		"portrait": "res://assets/ui/portraits/portrait_aron.png",
		"color": Color(0.2, 0.85, 1.0)
	},
	"om_hami": {
		"name": "OM HAMI",
		"title": "Cane Martial Zoner",
		"portrait": "res://assets/ui/portraits/portrait_om_hami.png",
		"color": Color(1.0, 0.78, 0.25)
	},
	"kemet": {
		"name": "KEMET",
		"title": "Claw Assassin",
		"portrait": "res://assets/ui/portraits/portrait_kemet.png",
		"color": Color(0.95, 0.35, 0.25)
	},
	"butler": {
		"name": "BUTLER",
		"title": "Cloth Flame Vanguard",
		"portrait": "res://assets/ui/portraits/portrait_butler.png",
		"color": Color(1.0, 0.82, 0.35)
	},
	"mike": {
		"name": "MIKE",
		"title": "College Chair Vanguard",
		"portrait": "res://assets/ui/portraits/portrait_mike.png",
		"color": Color(0.95, 0.65, 0.25)
	},
	"muslan": {
		"name": "MUSLAN",
		"title": "The Southern Troubadour",
		"portrait": "res://assets/ui/portraits/portrait_muslan.png",
		"color": Color(0.35, 0.7, 0.95)
	},
	"rin": {
		"name": "RIN",
		"title": "The Mystic Weaver",
		"portrait": "res://assets/ui/portraits/portrait_rin.png",
		"color": Color(0.95, 0.4, 0.65)
	},
	"sunkibo": {
		"name": "SUNKIBO",
		"title": "The Ignored Scion",
		"portrait": "res://assets/ui/portraits/portrait_sunkibo.png",
		"color": Color(0.9, 0.6, 0.2)
	},
	"the_first_fallen": {
		"name": "THE FIRST FALLEN",
		"title": "Ancient Sovereign",
		"portrait": "res://assets/ui/portraits/portrait_first_fallen.png",
		"color": Color(0.85, 0.2, 0.2)
	}
}

const STAGE_NAMES: Dictionary = {
	"temple_ruin": "Temple Ruin",
	"ruined_school": "Throne Platform",
	"throne_platform": "Throne Platform",
	"mad_lab": "Mad Laboratory",
	"magic_waterfall": "Magic Waterfall",
	"wild_west": "Wild West Outpost",
	"heaven_secret": "Heaven Secret Realm",
	"rooftop": "Metropolis Rooftop"
}

var _cached_save_data: Dictionary = {}
var _is_loaded: bool = false

func _ready() -> void:
	load_campaign_data()

## Cek apakah ada file save run campaign yang sedang berlangsung
func has_active_campaign() -> bool:
	if not _is_loaded:
		load_campaign_data()
	return bool(_cached_save_data.get("has_active_run", false))

## Dapatkan data active run yang tersimpan
func get_active_campaign() -> Dictionary:
	if not _is_loaded:
		load_campaign_data()
	return _cached_save_data.duplicate(true)

## Simpan progres campaign saat ini
func save_campaign_progress(
	hero_id: String,
	difficulty: String,
	stage_idx: int,
	claimants: Array,
	stages: Array,
	dev_type: String = "keyboard_wasd",
	dev_id: int = -1
) -> bool:
	var date_dict = Time.get_datetime_dict_from_system()
	var formatted_time = "%04d-%02d-%02d %02d:%02d" % [
		date_dict.year, date_dict.month, date_dict.day,
		date_dict.hour, date_dict.minute
	]

	_cached_save_data = {
		"version": SAVE_VERSION,
		"has_active_run": true,
		"saved_at": formatted_time,
		"hero_id": hero_id,
		"difficulty": difficulty,
		"stage_index": stage_idx,
		"device_type": dev_type,
		"device_id": dev_id,
		"campaign_claimants": claimants.duplicate(),
		"campaign_stages": stages.duplicate()
	}

	var json_str := JSON.stringify(_cached_save_data, "\t")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("SaveManager: Gagal membuka file save untuk menulis: %d" % FileAccess.get_open_error())
		return false

	file.store_string(json_str)
	file.close()
	_is_loaded = true
	campaign_save_updated.emit()
	return true

## Bersihkan data active run (misal setelah tamat atau jika New Game dipilih)
func clear_campaign_save() -> bool:
	_cached_save_data = {
		"version": SAVE_VERSION,
		"has_active_run": false
	}
	if FileAccess.file_exists(SAVE_PATH):
		var err = DirAccess.remove_absolute(SAVE_PATH)
		if err != OK and err != ERR_FILE_NOT_FOUND:
			# Fallback: timpa dengan data kosong
			var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
			if file:
				file.store_string(JSON.stringify(_cached_save_data, "\t"))
				file.close()
	_is_loaded = true
	campaign_save_updated.emit()
	return true

## Load data save dari disk
func load_campaign_data() -> Dictionary:
	_is_loaded = true
	if not FileAccess.file_exists(SAVE_PATH):
		_cached_save_data = {
			"version": SAVE_VERSION,
			"has_active_run": false
		}
		return _cached_save_data

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		_cached_save_data = { "has_active_run": false }
		return _cached_save_data

	var content := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(content)
	if parsed is Dictionary and parsed.has("has_active_run"):
		_cached_save_data = parsed
	else:
		_cached_save_data = { "has_active_run": false }

	return _cached_save_data

## Helper untuk mendapatkan metadata visual Hero
func get_hero_meta(hero_id: String) -> Dictionary:
	if HERO_METADATA.has(hero_id):
		return HERO_METADATA[hero_id]
	return {
		"name": hero_id.to_upper(),
		"title": "Challenger",
		"portrait": "res://assets/ui/portraits/portrait_aron.png",
		"color": Color.WHITE
	}

## Helper nama panggung
func get_stage_display_name(stage_key: String) -> String:
	return STAGE_NAMES.get(stage_key, stage_key.capitalize())
