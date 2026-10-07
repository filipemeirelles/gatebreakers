class_name CombatService
extends RefCounted
## Resolução determinística de ondas/combates (spec §4 — Combate).
##
## Regras documentadas (testáveis em tests/test_combat_service.gd):
## - Ordem de ação: velocidade decrescente. Empates: aliados antes de inimigos;
##   entre aliados, a posição na formação; entre inimigos, a posição na onda.
## - Alvo do aliado: primeiro inimigo vivo na ordem da onda.
## - Alvo do inimigo: primeiro aliado vivo na ordem da formação.
## - Dano: max(1, ataque - floor(defesa / 2)). Sem crítico, esquiva ou RNG.
## - Cada unidade viva ataca uma vez por rodada.
## - Aliados mantêm HP entre ondas do mesmo portal.
## - A velocidade x1/x2 só altera a apresentação; esta classe não vê tempo.

const MAX_STEPS_SAFETY := 100000


static func start_battle(allies: Array, gate_def: Dictionary) -> Dictionary:
	var state := {
		"gate": int(gate_def.get("gate", 1)),
		"waves": gate_def.get("waves", []),
		"wave_index": 0,
		"allies": [],
		"enemies": [],
		"round": 0,
		"action_queue": [],
		"phase": "running",
		"defeated_enemies": 0,
	}
	for unit in allies:
		var ally := _clone_unit(unit)
		ally["side"] = "ally"
		ally["max_hp"] = int(ally["hp"])
		state["allies"].append(ally)
	_load_wave(state)
	return state


## Executa um ataque (ou transição de onda/fim) e devolve um evento:
## { type: "attack", attacker, target, damage, killed, outcome?, wave, round }
## outcome: "" | "wave" | "victory" | "defeat"
static func step(state: Dictionary) -> Dictionary:
	if String(state["phase"]) != "running":
		return {}
	var safety: int = _alive_count(state) + 2
	while safety > 0:
		safety -= 1
		if (state["action_queue"] as Array).is_empty():
			state["round"] = int(state["round"]) + 1
			state["action_queue"] = _build_action_order(state)
		var actor := _pop_live_actor(state)
		if actor.is_empty():
			continue
		var target := _pick_target(state, actor)
		if target.is_empty():
			var outcome_no_target := _advance_wave_or_finish(state)
			return {
				"type": "outcome", "outcome": outcome_no_target,
				"wave": int(state["wave_index"]) + 1, "round": int(state["round"]),
			}
		var damage: int = BalanceConfig.basic_damage(int(actor["attack"]), int(target["defense"]))
		target["hp"] = maxi(int(target["hp"]) - damage, 0)
		var killed := int(target["hp"]) == 0
		if killed and String(target["side"]) == "enemy":
			state["defeated_enemies"] = int(state["defeated_enemies"]) + 1
		var outcome := ""
		if killed:
			if String(target["side"]) == "enemy" and _all_dead(state["enemies"]):
				outcome = _advance_wave_or_finish(state)
			elif String(target["side"]) == "ally" and _all_dead(state["allies"]):
				state["phase"] = "defeat"
				outcome = "defeat"
		return {
			"type": "attack",
			"attacker": _unit_summary(actor),
			"target": _unit_summary(target),
			"damage": damage,
			"killed": killed,
			"outcome": outcome,
			"wave": int(state["wave_index"]) + 1,
			"round": int(state["round"]),
		}
	return {}


static func is_finished(state: Dictionary) -> bool:
	return String(state.get("phase", "running")) != "running"


## Simulação completa (testes e verificação de determinismo).
static func run_to_completion(state: Dictionary) -> Dictionary:
	for i in MAX_STEPS_SAFETY:
		if is_finished(state):
			return state
		step(state)
	push_error("CombatService: limite de passos excedido (estado inválido).")
	state["phase"] = "defeat"
	return state


## Recompensas de conclusão do portal (fonte: BalanceConfig via ContentDB).
static func victory_rewards(gate_def: Dictionary) -> Dictionary:
	var boss := bool(gate_def.get("has_boss", false))
	return {
		"gold": int(gate_def.get("victory_gold", 0)),
		"xp": int(gate_def.get("victory_xp", 0)),
		"essence": int(gate_def.get("boss_shadow_essence", 0)) if boss else 0,
	}


# --- Internos ---

static func _clone_unit(unit: Dictionary) -> Dictionary:
	var out := {}
	for key in unit:
		out[key] = unit[key]
	return out


static func _load_wave(state: Dictionary) -> void:
	var waves: Array = state["waves"]
	var wave_index: int = state["wave_index"]
	var wave: Array = waves[wave_index]
	var enemies: Array = []
	for enemy in wave:
		var unit := _clone_unit(enemy)
		unit["side"] = "enemy"
		unit["max_hp"] = int(unit["hp"])
		enemies.append(unit)
	state["enemies"] = enemies
	# Fila da onda anterior é inválida: nova onda começa com rodada nova.
	state["action_queue"] = []


static func _build_action_order(state: Dictionary) -> Array:
	var entries: Array = []
	var allies: Array = state["allies"]
	for i in allies.size():
		if int(allies[i]["hp"]) > 0:
			entries.append({
				"side": "ally", "idx": i,
				"speed": int(allies[i]["speed"]), "side_rank": 0, "pos": i,
			})
	var enemies: Array = state["enemies"]
	for i in enemies.size():
		if int(enemies[i]["hp"]) > 0:
			entries.append({
				"side": "enemy", "idx": i,
				"speed": int(enemies[i]["speed"]), "side_rank": 1, "pos": i,
			})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a["speed"]) != int(b["speed"]):
			return int(a["speed"]) > int(b["speed"])
		if int(a["side_rank"]) != int(b["side_rank"]):
			return int(a["side_rank"]) < int(b["side_rank"])
		return int(a["pos"]) < int(b["pos"])
	)
	return entries


static func _pop_live_actor(state: Dictionary) -> Dictionary:
	var queue: Array = state["action_queue"]
	while not queue.is_empty():
		var ref: Dictionary = queue.pop_front()
		var unit := _unit_by_ref(state, ref)
		if not unit.is_empty() and int(unit["hp"]) > 0:
			return unit
	return {}


static func _unit_by_ref(state: Dictionary, ref: Dictionary) -> Dictionary:
	var side: Array = state["allies"] if String(ref["side"]) == "ally" else state["enemies"]
	var idx: int = int(ref["idx"])
	if idx < 0 or idx >= side.size():
		return {}
	return side[idx]


static func _pick_target(state: Dictionary, actor: Dictionary) -> Dictionary:
	var candidates: Array = state["enemies"] if String(actor["side"]) == "ally" else state["allies"]
	for unit in candidates:
		if int(unit["hp"]) > 0:
			return unit
	return {}


static func _advance_wave_or_finish(state: Dictionary) -> String:
	var waves: Array = state["waves"]
	if int(state["wave_index"]) + 1 < waves.size():
		state["wave_index"] = int(state["wave_index"]) + 1
		_load_wave(state)
		return "wave"
	state["phase"] = "victory"
	return "victory"


static func _all_dead(units: Array) -> bool:
	for unit in units:
		if int(unit["hp"]) > 0:
			return false
	return true


static func _alive_count(state: Dictionary) -> int:
	var count := 0
	for unit in state["allies"]:
		if int(unit["hp"]) > 0:
			count += 1
	for unit in state["enemies"]:
		if int(unit["hp"]) > 0:
			count += 1
	return count


static func _unit_summary(unit: Dictionary) -> Dictionary:
	return {
		"id": str(unit.get("id", "")),
		"name": str(unit.get("display_name", unit.get("name", "?"))),
		"side": str(unit.get("side", "")),
		"hp": int(unit.get("hp", 0)),
		"max_hp": int(unit.get("max_hp", unit.get("hp", 0))),
	}
