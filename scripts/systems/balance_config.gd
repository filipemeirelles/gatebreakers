class_name BalanceConfig
extends RefCounted
## BalanceConfig — fonte única de constantes e fórmulas de balanceamento (spec §4).
## Todos os números vêm de res://data/balance/balance_config.json.
## Nenhuma tela ou script pode duplicar estes valores.

const CONFIG_PATH := "res://data/balance/balance_config.json"

static var _config: Dictionary = {}


static func config() -> Dictionary:
	if _config.is_empty():
		var raw := FileAccess.get_file_as_string(CONFIG_PATH)
		var parsed: Variant = JSON.parse_string(raw)
		assert(parsed is Dictionary, "balance_config.json inválido")
		_config = parsed
	return _config


static func _afk() -> Dictionary:
	return config()["afk"]


static func _leveling() -> Dictionary:
	return config()["leveling"]


static func _combat() -> Dictionary:
	return config()["combat"]


static func _scaling() -> Dictionary:
	return config()["enemy_scaling"]


static func _rewards() -> Dictionary:
	return config()["rewards"]


static func _afk_rates() -> Dictionary:
	return config()["afk_rates"]


static func _starting() -> Dictionary:
	return config()["starting"]


# --- AFK ---

static func afk_cap_seconds() -> int:
	return int(_afk()["cap_seconds"])


static func afk_gold_per_hour(gate: int) -> int:
	return int(_afk_rates()["gold_per_hour_base"]) * gate


static func afk_xp_per_hour(gate: int) -> int:
	return int(_afk_rates()["hunter_xp_per_hour_base"]) * gate


# --- Nível de Jinwoo (XP necessário por nível; a derivação do total serve
# só para migrar saves v1 — o nível passou a ser guardado na Fase 4) ---

static func max_level() -> int:
	return int(_leveling()["max_level"])


static func hunter_xp_to_next_level(current_level: int) -> int:
	return int(_leveling()["hunter_xp_base_per_level"]) * current_level


static func hunter_level_from_total_xp(total_xp: int) -> int:
	var level := 1
	var remaining := maxi(total_xp, 0)
	while level < max_level() and remaining >= hunter_xp_to_next_level(level):
		remaining -= hunter_xp_to_next_level(level)
		level += 1
	return level


# --- Custos de melhoria ---

static func gold_cost_to_next_level(current_level: int) -> int:
	return int(_leveling()["gold_cost_base_per_level"]) * current_level


static func shadow_gold_cost_to_next_level(current_level: int) -> int:
	return int(_leveling()["shadow_gold_cost_base_per_level"]) * current_level


static func shadow_essence_cost_to_next_level(current_level: int) -> int:
	return int(_leveling()["shadow_essence_cost_base_per_level"]) * current_level


# --- Atributos de unidade por nível ---

static func stats_at_level(base_hp: int, base_attack: int, base_defense: int, base_speed: int, level: int) -> Dictionary:
	var lv := maxi(level, 1) - 1
	return {
		"hp": int(floor(base_hp * (1.0 + float(_leveling()["hp_growth_per_level"]) * lv))),
		"attack": int(floor(base_attack * (1.0 + float(_leveling()["attack_growth_per_level"]) * lv))),
		"defense": int(floor(base_defense * (1.0 + float(_leveling()["defense_growth_per_level"]) * lv))),
		"speed": base_speed,
	}


# --- Inimigos por portal ---

static func common_enemy_stats(gate: int) -> Dictionary:
	var s := _scaling()
	var n := maxi(gate, 1)
	return {
		"hp": int(s["base_hp"]) + int(s["hp_per_gate"]) * (n - 1),
		"attack": int(s["base_attack"]) + int(s["attack_per_gate"]) * (n - 1),
		"defense": int(s["base_defense"]) + int(s["defense_per_gate"]) * n,
		"speed": int(s["base_speed"]) + int(floor(float(n - 1) / float(s["speed_gate_divisor"]))),
	}


static func boss_enemy_stats(gate: int) -> Dictionary:
	var s := _scaling()
	var stats := common_enemy_stats(gate)
	return {
		"hp": int(floor(stats["hp"] * float(s["boss_hp_multiplier"]))),
		"attack": int(floor(stats["attack"] * float(s["boss_attack_multiplier"]))),
		"defense": int(floor(stats["defense"] * float(s["boss_defense_multiplier"]))),
		"speed": stats["speed"],
	}


# --- Combate ---

static func min_damage() -> int:
	return int(_combat()["min_damage"])


static func defense_divisor() -> int:
	return int(_combat()["defense_divisor"])


static func waves_per_gate() -> int:
	return int(_combat()["waves_per_gate"])


static func enemies_per_normal_wave() -> int:
	return int(_combat()["enemies_per_normal_wave"])


static func basic_damage(attack: int, defense: int) -> int:
	return maxi(min_damage(), attack - int(floor(float(defense) / float(defense_divisor()))))


# --- Recompensas ---

static func victory_gold(gate: int, defeated_enemies: int) -> int:
	return int(_rewards()["gold_per_enemy_per_gate"]) * gate * defeated_enemies


static func victory_xp(gate: int, defeated_enemies: int) -> int:
	return int(_rewards()["hunter_xp_per_enemy_per_gate"]) * gate * defeated_enemies


static func boss_shadow_essence() -> int:
	return int(_rewards()["boss_shadow_essence"])


# --- Estado inicial ---

static func starting_gold() -> int:
	return int(_starting()["gold"])


static func starting_hunter_xp() -> int:
	return int(_starting()["hunter_xp"])


static func starting_shadow_essence() -> int:
	return int(_starting()["shadow_essence"])


static func starting_highest_gate_cleared() -> int:
	return int(_starting()["highest_gate_cleared"])
