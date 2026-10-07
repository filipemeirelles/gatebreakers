class_name SaveService
extends RefCounted
## SaveService — carregar, validar, migrar e persistir estado local (spec §6).
## Contrato do spec §6/§7:
## - ficheiro em user://save_v1.json (fora da pasta do projeto);
## - valida tipos, valores negativos, campos em falta e versões desconhecidas;
## - grava em temporário e só substitui o save anterior após serialização válida;
## - save corrompido: não travar — preservar cópia de diagnóstico, criar save novo.

const SAVE_PATH := "user://save_v1.json"
const TMP_PATH := "user://save_v1.json.tmp"
const CORRUPT_BACKUP_PATH := "user://save_v1.corrupt.json"
const SCHEMA_VERSION: int = 1

## Resultado do último load: { status, state, backup_path }
static var last_result: Dictionary = {}


static func save_state(state: Dictionary) -> bool:
	var payload := state.duplicate(true)
	payload["schema_version"] = SCHEMA_VERSION
	var text := JSON.stringify(payload)
	if JSON.parse_string(text) == null:
		push_error("SaveService: serialização inválida, save não gravado.")
		return false
	var file := FileAccess.open(TMP_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveService: não foi possível abrir %s." % TMP_PATH)
		return false
	file.store_string(text)
	file.flush()
	file.close()
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	if DirAccess.rename_absolute(TMP_PATH, SAVE_PATH) != OK:
		push_error("SaveService: falha ao substituir o save.")
		return false
	return true


## Devolve { "status": "fresh"|"loaded"|"recovered_tmp"|"recovered_corrupt"|"recovered_invalid",
##           "state": Dictionary, "backup_path": String }.
static func load_state() -> Dictionary:
	if FileAccess.file_exists(SAVE_PATH):
		var raw := FileAccess.get_file_as_string(SAVE_PATH)
		var validated := validate_state(JSON.parse_string(raw))
		if not validated.is_empty():
			last_result = { "status": "loaded", "state": validated, "backup_path": "" }
			return last_result
		var backup := _backup_corrupt(raw)
		last_result = { "status": "recovered_corrupt", "state": _fresh_state(), "backup_path": backup }
		return last_result
	if FileAccess.file_exists(TMP_PATH):
		var tmp_raw := FileAccess.get_file_as_string(TMP_PATH)
		var tmp_validated := validate_state(JSON.parse_string(tmp_raw))
		if not tmp_validated.is_empty():
			save_state(tmp_validated)
			last_result = { "status": "recovered_tmp", "state": tmp_validated, "backup_path": "" }
			return last_result
	last_result = { "status": "fresh", "state": _fresh_state(), "backup_path": "" }
	return last_result


## Migração de saves v1: o nível de Jinwoo era derivado do XP total.
## Devolve { "level": int, "xp": int } com o nível derivado e o XP restante
## (total menos o consumido para chegar a esse nível) — o mesmo progresso
## que o ecrã Caçador mostrava antes da Fase 4.
static func migrate_hunter_level(total_xp: int) -> Dictionary:
	var level := BalanceConfig.hunter_level_from_total_xp(total_xp)
	var spent := 0
	for lv in range(1, level):
		spent += BalanceConfig.hunter_xp_to_next_level(lv)
	return { "level": level, "xp": maxi(total_xp - spent, 0) }


static func _fresh_state() -> Dictionary:
	var roster: Dictionary = {}
	for unit_id in ContentDB.unit_ids_at_start():
		roster[unit_id] = { "level": 1, "unlocked": true }
	return {
		"schema_version": SCHEMA_VERSION,
		"hunter_level": 1,
		"hunter_xp": BalanceConfig.starting_hunter_xp(),
		"gold": BalanceConfig.starting_gold(),
		"shadow_essence": BalanceConfig.starting_shadow_essence(),
		"highest_gate_cleared": BalanceConfig.starting_highest_gate_cleared(),
		"last_background_unix": 0,
		"roster": roster,
		"formation": ["jinwoo", "shadow_soldier"],
		"story_cards_seen": [],
	}


static func _backup_corrupt(raw: String) -> String:
	var file := FileAccess.open(CORRUPT_BACKUP_PATH, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(raw)
	file.close()
	return CORRUPT_BACKUP_PATH


## Valida e normaliza. Devolve Dictionary válido ou {} se inválido.
static func validate_state(data: Variant) -> Dictionary:
	if not (data is Dictionary):
		return {}
	var d: Dictionary = data
	if int(d.get("schema_version", -1)) != SCHEMA_VERSION:
		return {}
	for key in ["hunter_xp", "gold", "shadow_essence", "highest_gate_cleared", "last_background_unix"]:
		var ok: bool = false
		match typeof(d.get(key)):
			TYPE_INT, TYPE_FLOAT:
				ok = float(d[key]) >= 0.0 and float(d[key]) == floor(float(d[key]))
			_:
				ok = false
		if not ok:
			return {}
	# hunter_level: presente em saves novos; ausente em saves v1 (migração —
	# o nível era derivado do XP total e o XP não era gasto).
	var hunter_level: int
	var hunter_xp_unspent: int
	if d.has("hunter_level"):
		var lv: Variant = d["hunter_level"]
		if not (lv is int or (lv is float and float(lv) == floor(float(lv)))) or float(lv) < 1.0:
			return {}
		hunter_level = int(lv)
		hunter_xp_unspent = int(d["hunter_xp"])
	else:
		var migrated := migrate_hunter_level(int(d["hunter_xp"]))
		hunter_level = int(migrated["level"])
		hunter_xp_unspent = int(migrated["xp"])
	# story_cards_seen: opcional (saves anteriores não o tinham).
	var story_seen: Array = []
	if d.has("story_cards_seen"):
		var story_raw: Variant = d["story_cards_seen"]
		if not (story_raw is Array):
			return {}
		for entry in story_raw:
			if entry is String:
				story_seen.append(entry)
	var roster_raw: Variant = d.get("roster")
	if not (roster_raw is Dictionary):
		return {}
	var roster: Dictionary = {}
	for unit_id in roster_raw:
		if not (unit_id is String) or not ContentDB.unit(String(unit_id)).has("id"):
			return {}
		var entry: Variant = roster_raw[unit_id]
		if not (entry is Dictionary):
			return {}
		var level: Variant = entry.get("level")
		var unlocked: Variant = entry.get("unlocked")
		if not (level is int or (level is float and float(level) == floor(float(level)))) or float(level) < 1.0:
			return {}
		if not (unlocked is bool):
			return {}
		roster[String(unit_id)] = { "level": int(level), "unlocked": bool(unlocked) }
	for required_id in ContentDB.unit_ids_at_start():
		if not roster.has(required_id) or not bool(roster[required_id]["unlocked"]):
			return {}
	var formation_raw: Variant = d.get("formation")
	if not (formation_raw is Array):
		return {}
	var formation: Array = []
	for entry in formation_raw:
		if entry is String and roster.has(entry) and bool(roster[entry]["unlocked"]):
			formation.append(entry)
			if formation.size() >= GameState.MAX_TEAM_SIZE:
				break
	if not formation.has("jinwoo"):
		formation.push_front("jinwoo")
	formation.resize(mini(formation.size(), GameState.MAX_TEAM_SIZE))
	return {
		"schema_version": SCHEMA_VERSION,
		"hunter_level": hunter_level,
		"hunter_xp": hunter_xp_unspent,
		"gold": int(d["gold"]),
		"shadow_essence": int(d["shadow_essence"]),
		"highest_gate_cleared": int(d["highest_gate_cleared"]),
		"last_background_unix": int(d["last_background_unix"]),
		"roster": roster,
		"formation": formation,
		"story_cards_seen": story_seen,
	}


static func delete_save() -> void:
	for path in [SAVE_PATH, TMP_PATH, CORRUPT_BACKUP_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
