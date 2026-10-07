class_name SettingsService
extends RefCounted
## SettingsService — preferências locais da app (som/vibração), fora do save
## do jogador (spec §5.8). Guardadas em user://settings.cfg via ConfigFile.

const PATH := "user://settings.cfg"

static var _config: ConfigFile = null


static func _load() -> ConfigFile:
	if _config == null:
		_config = ConfigFile.new()
		# Arquivo inexistente/inválido → valores por omissão.
		_config.load(PATH)
	return _config


static func reload() -> void:
	_config = null


static func sound_enabled() -> bool:
	return bool(_load().get_value("audio", "sound", true))


static func set_sound_enabled(value: bool) -> void:
	var cfg := _load()
	cfg.set_value("audio", "sound", value)
	cfg.save(PATH)


static func vibration_enabled() -> bool:
	return bool(_load().get_value("audio", "vibration", true))


static func set_vibration_enabled(value: bool) -> void:
	var cfg := _load()
	cfg.set_value("audio", "vibration", value)
	cfg.save(PATH)
