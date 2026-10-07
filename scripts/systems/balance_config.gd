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


static func _afk_chests() -> Dictionary:
	return config()["afk_chests"]


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


static func afk_chest_milestone_seconds() -> int:
	return int(_afk_chests()["milestone_seconds"])


static func afk_chest_gold_per_gate() -> int:
	return int(_afk_chests()["gold_per_gate"])


static func afk_chest_xp_per_gate() -> int:
	return int(_afk_chests()["xp_per_gate"])


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


## Melhoria de caçador contratado: apenas ouro (essência é das sombras).
static func hunter_gold_cost_to_next_level(current_level: int) -> int:
	return int(_leveling()["hunter_gold_cost_base_per_level"]) * current_level


## Máximo de sombras (invocações) que entram em combate junto da equipe.
static func summon_cap() -> int:
	return int(_combat().get("summon_cap", 2))


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


static func boss_enemy_stats(gate: int, boss_hp_multiplier_override: float = 0.0, boss_attack_multiplier_override: float = 0.0) -> Dictionary:
	var s := _scaling()
	var stats := common_enemy_stats(gate)
	var hp_mult := float(s["boss_hp_multiplier"])
	var atk_mult := float(s["boss_attack_multiplier"])
	if boss_hp_multiplier_override > 0.0:
		hp_mult = boss_hp_multiplier_override
	if boss_attack_multiplier_override > 0.0:
		atk_mult = boss_attack_multiplier_override
	return {
		"hp": int(floor(stats["hp"] * hp_mult)),
		"attack": int(floor(stats["attack"] * atk_mult)),
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


static func combat_power(stats: Dictionary) -> int:
	var cfg := _combat()
	return int(floor(
		float(stats.get("hp", 0)) / float(cfg["power_hp_divisor"])
		+ float(stats.get("attack", 0)) * float(cfg["power_attack_weight"])
		+ float(stats.get("defense", 0)) * float(cfg["power_defense_weight"])
		+ float(stats.get("speed", 0)) * float(cfg["power_speed_weight"])
	))


static func danger_enemy_power_ratio() -> float:
	return float(_combat()["danger_enemy_power_ratio"])


# --- Habilidades (primeira entrega: 1 por unidade, determinísticas) ---

static func _skills() -> Dictionary:
	return config().get("skills", {})


static func skill_def(skill_id: String) -> Dictionary:
	var all := _skills()
	if all.has(skill_id) and all[skill_id] is Dictionary:
		return all[skill_id]
	return {}


static func skill_cooldown_actions(skill_id: String) -> int:
	return maxi(int(skill_def(skill_id).get("cooldown_actions", 0)), 0)


static func skill_damage_multiplier(skill_id: String) -> float:
	return float(skill_def(skill_id).get("damage_multiplier", 1.0))


static func skill_target(skill_id: String) -> String:
	return str(skill_def(skill_id).get("target", "first"))


static func skill_guard_damage_factor(skill_id: String) -> float:
	return float(skill_def(skill_id).get("guard_damage_factor", 1.0))


## Cura: fração do max_hp do alvo. 0 = skill não é cura.
static func skill_heal_amount(skill_id: String, target_max_hp: int) -> int:
	var pct := float(skill_def(skill_id).get("heal_amount", 0.0))
	if pct <= 0.0:
		return 0
	return maxi(1, int(floor(float(target_max_hp) * pct / 100.0)))


# --- Varredura limitada (cargas por portal concluído) ---

static func _sweep() -> Dictionary:
	return config().get("sweep", {})


static func sweep_charges_per_clear() -> int:
	return maxi(int(_sweep().get("charges_per_clear", 0)), 0)


static func sweep_charges_cap() -> int:
	return maxi(int(_sweep().get("charges_cap", 0)), 0)


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
