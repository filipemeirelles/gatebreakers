extends Node
## Loc — textos de interface centralizados (spec §5: sem strings soltas no código).
## Idioma inicial: pt-BR, carregado de res://data/localization/pt_BR.json.

const DEFAULT_LOCALE := "pt_BR"
const STRINGS_PATH := "res://data/localization/%s.json"

var _strings: Dictionary = {}


func _ready() -> void:
	_load_locale(DEFAULT_LOCALE)


func _load_locale(locale: String) -> void:
	var path := STRINGS_PATH % locale
	if not FileAccess.file_exists(path):
		push_warning("Localização em falta: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		_strings = parsed


func t(key: String, fallback: String = "") -> String:
	if _strings.has(key):
		return String(_strings[key])
	return fallback if not fallback.is_empty() else key
