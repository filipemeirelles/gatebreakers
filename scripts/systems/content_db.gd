class_name ContentDB
extends RefCounted
## ContentDB — carrega unidades e portais de res://data/ e constrói as
## definições calculadas (GateDefinition) usando BalanceConfig como fonte
## das fórmulas. Nenhum número é fixado aqui.

const UNITS_DIR := "res://data/units/"
const HUNTERS_DIR := "res://data/hunters/"
const GATES_PATH := "res://data/gates/gates.json"
const STORY_PATH := "res://data/story/story_cards.json"
const ITEMS_PATH := "res://data/items/items.json"

static var _units: Dictionary = {}
static var _hunters: Dictionary = {}
static var _hunter_order: Array = []
static var _unit_order: Array = []
static var _items: Dictionary = {}
static var _item_order: Array = []
static var _gate_rows: Array = []
static var _gate_count: int = 0
static var _story_cards: Array = []


static func _ensure_loaded() -> void:
	if not _units.is_empty():
		return
	for file_name in DirAccess.get_files_at(UNITS_DIR):
		if not file_name.ends_with(".json"):
			continue
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(UNITS_DIR + file_name))
		if parsed is Dictionary and parsed.has("id"):
			_units[String(parsed["id"])] = parsed
			_unit_order.append(String(parsed["id"]))
	for file_name in DirAccess.get_files_at(HUNTERS_DIR):
		if not file_name.ends_with(".json"):
			continue
		var parsed_hunter: Variant = JSON.parse_string(FileAccess.get_file_as_string(HUNTERS_DIR + file_name))
		if parsed_hunter is Dictionary and parsed_hunter.has("id"):
			_hunters[String(parsed_hunter["id"])] = parsed_hunter
			_hunter_order.append(String(parsed_hunter["id"]))
	var gates_parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(GATES_PATH))
	if gates_parsed is Dictionary:
		_gate_rows = gates_parsed.get("gates", [])
		_gate_count = int(gates_parsed.get("total_gates", _gate_rows.size()))
	var story_parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(STORY_PATH))
	if story_parsed is Dictionary:
		_story_cards = story_parsed.get("cards", [])
	var items_file := FileAccess.get_file_as_string(ITEMS_PATH)
	if not items_file.is_empty():
		var items_parsed: Variant = JSON.parse_string(items_file)
		if items_parsed is Dictionary:
			for row in items_parsed.get("items", []):
				if row is Dictionary and row.has("id"):
					var item_id := String(row["id"])
					_items[item_id] = row
					_item_order.append(item_id)


## Cartões narrativos (spec §4): temas e gatilhos em dados editáveis.
static func story_cards() -> Array:
	_ensure_loaded()
	return _story_cards


static func story_card(card_id: String) -> Dictionary:
	for card in story_cards():
		if String(card.get("id", "")) == card_id:
			return card
	return {}


static func unit(unit_id: String) -> Dictionary:
	_ensure_loaded()
	return _units.get(unit_id, {})


static func all_units() -> Array:
	_ensure_loaded()
	var out: Array = []
	for id in _unit_order:
		out.append(_units[id])
	return out


static func unit_ids_at_start() -> Array:
	var out: Array = []
	for def in all_units():
		if String(def.get("unlock", {}).get("type", "")) == "start":
			out.append(String(def["id"]))
	return out


## Definição de caçador contratável (não-shadow ally).
static func hunter(hunter_id: String) -> Dictionary:
	_ensure_loaded()
	return _hunters.get(hunter_id, {})


static func all_hunters() -> Array:
	_ensure_loaded()
	var out: Array = []
	for id in _hunter_order:
		out.append(_hunters[id])
	return out


## Definições de equipamentos (itens de marco/chefes).
static func item(item_id: String) -> Dictionary:
	_ensure_loaded()
	return _items.get(item_id, {})


static func all_items() -> Array:
	_ensure_loaded()
	var out: Array = []
	for id in _item_order:
		out.append(_items[id])
	return out


static func items_for_slot(slot: String) -> Array:
	_ensure_loaded()
	var out: Array = []
	for id in _item_order:
		var it: Dictionary = _items[id]
		if String(it.get("slot", "")) == slot:
			out.append(it)
	return out


static func gate_count() -> int:
	_ensure_loaded()
	return _gate_count


static func gate_row(gate: int) -> Dictionary:
	_ensure_loaded()
	for row in _gate_rows:
		if int(row["gate"]) == gate:
			return row
	return {}


## Constrói o GateDefinition completo do portal (spec §7).
static func gate(gate: int) -> Dictionary:
	var row := gate_row(gate)
	if row.is_empty():
		return {}
	var n := maxi(gate, 1)
	var boss_wave := bool(row.get("boss_wave", false))
	var wave_count := BalanceConfig.waves_per_gate()
	var enemies_per_wave := BalanceConfig.enemies_per_normal_wave()
	var waves: Array = []
	var total_enemies := 0
	for wave_index in wave_count:
		var wave: Array = []
		if boss_wave and wave_index == wave_count - 1:
			var boss := BalanceConfig.boss_enemy_stats(
				n, float(row.get("boss_hp_multiplier", 0.0)), float(row.get("boss_attack_multiplier", 0.0))
			)
			boss["id"] = "boss_g%d" % n
			boss["display_name"] = str(row.get("boss_name", "Chefe do Portal %d" % n))
			boss["role"] = "boss"
			wave.append(boss)
		else:
			for enemy_index in enemies_per_wave:
				var common := BalanceConfig.common_enemy_stats(n)
				common["id"] = "enemy_g%d_w%d_e%d" % [n, wave_index + 1, enemy_index + 1]
				common["display_name"] = str(row.get("enemy_name", "Guardião do Portal %d" % n))
				common["role"] = "common"
				wave.append(common)
		total_enemies += wave.size()
		waves.append(wave)
	return {
		"gate": n,
		"display_name": str(row.get("display_name", "Portal %d" % n)),
		"arc": str(row.get("arc", "")),
		"rank": str(row.get("rank", "")),
		"enemy_name": str(row.get("enemy_name", "")),
		"boss_name": str(row.get("boss_name", "")),
		"waves": waves,
		"total_enemies": total_enemies,
		"boss_wave": boss_wave,
		"has_boss": boss_wave,
		"afk_gold_per_hour": BalanceConfig.afk_gold_per_hour(n),
		"afk_xp_per_hour": BalanceConfig.afk_xp_per_hour(n),
		"victory_gold": BalanceConfig.victory_gold(n, total_enemies),
		"victory_xp": BalanceConfig.victory_xp(n, total_enemies),
		"boss_shadow_essence": int(row.get(
			"boss_shadow_essence", BalanceConfig.boss_shadow_essence() if boss_wave else 0
		)),
		"clear_unlocks_unit": row.get("clear_unlocks_unit"),
		"first_clear_bonus": float(row.get("first_clear_bonus", 0.0)),
		"first_clear_drop_item": str(row.get("first_clear_drop_item", "")),
	}
