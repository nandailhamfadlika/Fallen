extends Node

## LocalizationManager — Persistent Autoload Singleton for Language & Translation
## Manages game locale (English default 'en', Indonesian 'id'), loads CSV translations into
## Godot's TranslationServer, persists user preferences, and broadcasts locale change events.

signal locale_changed(new_locale: String)

const SETTINGS_PATH: String = "user://game_settings.cfg"
const CSV_TRANSLATIONS_PATH: String = "res://assets/localization/translations.csv"
const DEFAULT_LOCALE: String = "en"

const SUPPORTED_LOCALES: Array[Dictionary] = [
	{
		"code": "en",
		"name": "English",
		"flag": "EN"
	},
	{
		"code": "id",
		"name": "Bahasa Indonesia",
		"flag": "ID"
	}
]

var _current_locale: String = DEFAULT_LOCALE
var _en_translation: Translation
var _id_translation: Translation

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_translations()
	_load_saved_locale()

## Sets the active locale ("en" or "id") and optionally persists it to disk.
func set_locale(locale_code: String, persist: bool = true) -> void:
	var target := locale_code.to_lower().strip_edges()
	if not is_locale_supported(target):
		push_warning("LocalizationManager: Locale '%s' is not supported. Falling back to default '%s'." % [target, DEFAULT_LOCALE])
		target = DEFAULT_LOCALE

	_current_locale = target
	TranslationServer.set_locale(_current_locale)

	if persist:
		_save_locale(_current_locale)

	locale_changed.emit(_current_locale)

## Returns the current active locale code (e.g. "en" or "id").
func get_locale() -> String:
	return _current_locale

## Checks if a given locale code is supported.
func is_locale_supported(locale_code: String) -> bool:
	for entry in SUPPORTED_LOCALES:
		if entry["code"] == locale_code:
			return true
	return false

## Returns array of supported locale definitions.
func get_supported_locales() -> Array[Dictionary]:
	return SUPPORTED_LOCALES

## Returns display name of given locale code.
func get_locale_display_name(locale_code: String = "") -> String:
	var code := locale_code if not locale_code.is_empty() else _current_locale
	for entry in SUPPORTED_LOCALES:
		if entry["code"] == code:
			return entry["name"]
	return "English"

## Toggles between English and Indonesian.
func toggle_locale() -> String:
	var next_locale := "id" if _current_locale == "en" else "en"
	set_locale(next_locale, true)
	return next_locale

## Convenience wrapper around tr().
func tr_text(key: String, context: StringName = &"") -> String:
	return tr(key, context)

# ==============================================================================
# SPECIALIZED QUERY HELPERS
# ==============================================================================

## Returns character title translated according to active locale.
func get_character_title(char_id: String) -> String:
	var id := _normalize_key_id(char_id)
	var key := "CHAR_%s_TITLE" % id
	var val := tr(key)
	return val if val != key else char_id.capitalize()

## Returns character biography translated according to active locale.
func get_character_bio(char_id: String) -> String:
	var id := _normalize_key_id(char_id)
	var key := "CHAR_%s_BIO" % id
	var val := tr(key)
	return val if val != key else ""

func _normalize_key_id(raw_id: String) -> String:
	var id := raw_id.to_upper().strip_edges()
	if id.begins_with("THE_"):
		id = id.substr(4)
	return id

## Returns stage display name translated according to active locale.
func get_stage_name(stage_id: String) -> String:
	var key := "STAGE_%s_NAME" % stage_id.to_upper().strip_edges()
	var val := tr(key)
	return val if val != key else stage_id.capitalize()

## Returns stage description translated according to active locale.
func get_stage_desc(stage_id: String) -> String:
	var key := "STAGE_%s_DESC" % stage_id.to_upper().strip_edges()
	var val := tr(key)
	return val if val != key else ""

# ==============================================================================
# CSV LOADING & CONFIG PERSISTENCE
# ==============================================================================

func _load_translations() -> void:
	if not FileAccess.file_exists(CSV_TRANSLATIONS_PATH):
		push_warning("LocalizationManager: CSV translations file not found at '%s'" % CSV_TRANSLATIONS_PATH)
		return

	var f := FileAccess.open(CSV_TRANSLATIONS_PATH, FileAccess.READ)
	if not f:
		push_error("LocalizationManager: Could not open CSV translations at '%s'" % CSV_TRANSLATIONS_PATH)
		return

	var _header := f.get_csv_line()
	_en_translation = Translation.new()
	_en_translation.locale = "en"
	_id_translation = Translation.new()
	_id_translation.locale = "id"

	var entry_count := 0
	while not f.eof_reached():
		var line := f.get_csv_line()
		if line.size() >= 3:
			var key := line[0].strip_edges()
			if not key.is_empty():
				_en_translation.add_message(key, line[1])
				_id_translation.add_message(key, line[2])
				entry_count += 1
	f.close()

	TranslationServer.add_translation(_en_translation)
	TranslationServer.add_translation(_id_translation)

func _load_saved_locale() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)
	if err == OK:
		var saved_lang: String = config.get_value("localization", "language", DEFAULT_LOCALE)
		set_locale(saved_lang, false)
	else:
		set_locale(DEFAULT_LOCALE, false)

func _save_locale(locale_code: String) -> void:
	var config := ConfigFile.new()
	var _err := config.load(SETTINGS_PATH)
	config.set_value("localization", "language", locale_code)
	config.save(SETTINGS_PATH)
