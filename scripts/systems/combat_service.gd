class_name CombatService
extends RefCounted
## Resolução determinística de ondas/combates (spec §4 — Combate).
##
## Regras documentadas (testáveis em tests/test_combat_service.gd e test_skills.gd):
## - Ordem de ação: velocidade decrescente. Empates: aliados antes de inimigos;
##   entre aliados, a posição na formação; entre inimigos, a posição na onda.
## - Alvo básico do aliado: primeiro inimigo vivo na ordem da onda.
## - Exceção: Tiro na Retaguarda atinge o ÚLTIMO inimigo vivo da onda.
## - Alvo básico do inimigo: primeiro aliado vivo na ordem da formação.
## - Exceção: Postura de Guarda ativa redireciona inimigos para o guardião
##   (se vivo) do resto da rodada atual até o fim da próxima, com redução
##   de dano configurada; expira ao trocar de onda.
## - Dano: max(1, ataque - floor(defesa / 2)). Sem crítico, esquiva ou RNG.
## - Habilidade de dano: floor(dano_básico * multiplicador), mínimo 1.
## - Recarga: contada em ações PRÓPRIAS da unidade (a cada N ações usa a
##   habilidade em vez do básico); contadores persistem entre ondas do portal
##   e são transientes de batalha (não entram no save). Guarda expira no fim
##   da onda. Ordem de ação inalterada: habilidade substitui o básico no turno.
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
		"guard_ally_id": "",
		"guard_from_round": -1,
		"guard_until_round": -1,
	}
	for unit in allies:
		var ally := _clone_unit(unit)
		ally["side"] = "ally"
		ally["max_hp"] = int(ally["hp"])
		ally["skill_id"] = str(ally.get("skill_id", ""))
		ally["skill_clock"] = 0
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
		# Habilidade automática e determinística: na N-ésima ação própria,
		# a unidade usa a habilidade em vez do ataque básico.
		var skill_id := str(actor.get("skill_id", ""))
		var use_skill := _should_use_skill(state, actor, skill_id)
		if use_skill and BalanceConfig.skill_target(skill_id) == "self_guard":
			actor["skill_clock"] = 0
			state["guard_ally_id"] = str(actor.get("id", ""))
			state["guard_from_round"] = int(state["round"])
			state["guard_until_round"] = int(state["round"]) + 1
			state["guard_skill_id"] = skill_id
			return {
				"type": "skill",
				"skill_id": skill_id,
				"attacker": _unit_summary(actor),
				"target": _unit_summary(actor),
				"damage": 0,
				"killed": false,
				"guard": true,
				"outcome": "",
				"wave": int(state["wave_index"]) + 1, "round": int(state["round"]),
			}
		# Habilidade de cura: alvo = aliado vivo com menos HP (nunca inimigos).
		if use_skill and BalanceConfig.skill_target(skill_id) == "ally_heal":
			var healed := _pick_weakest_ally(state, actor)
			actor["skill_clock"] = 0
			if healed.is_empty():
				# Ninguém ferido: a cura vira um ataque básico (determinismo).
				use_skill = false
			else:
				var amount := BalanceConfig.skill_heal_amount(skill_id, int(healed["max_hp"]))
				healed["hp"] = mini(int(healed["hp"]) + amount, int(healed["max_hp"]))
				return {
					"type": "skill",
					"skill_id": skill_id,
					"attacker": _unit_summary(actor),
					"target": _unit_summary(healed),
					"damage": -amount,
					"killed": false,
					"heal": true,
					"outcome": "",
					"wave": int(state["wave_index"]) + 1, "round": int(state["round"]),
				}
		var target := _pick_target(state, actor, skill_id if use_skill else "")
		if target.is_empty():
			var outcome_no_target := _advance_wave_or_finish(state)
			return {
				"type": "outcome", "outcome": outcome_no_target,
				"wave": int(state["wave_index"]) + 1, "round": int(state["round"]),
			}
		var damage: int = BalanceConfig.basic_damage(int(actor["attack"]), int(target["defense"]))
		if use_skill:
			actor["skill_clock"] = 0
			var mult := BalanceConfig.skill_damage_multiplier(skill_id)
			damage = maxi(1, int(floor(float(damage) * mult)))
		else:
			actor["skill_clock"] = int(actor.get("skill_clock", 0)) + 1
		# Guarda ativa reduz o dano sofrido pelo guardião até o fim da rodada.
		if _is_guard_active(state, target):
			var factor := BalanceConfig.skill_guard_damage_factor(str(state.get("guard_skill_id", "guardian_stance")))
			if factor <= 0.0 or factor > 1.0:
				factor = 0.75
			damage = maxi(1, int(floor(float(damage) * factor)))
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
			"is_skill": use_skill,
			"skill_id": skill_id if use_skill else "",
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
	# A guarda é tática de onda: não vaza para a onda seguinte.
	state["guard_ally_id"] = ""
	state["guard_from_round"] = -1
	state["guard_until_round"] = -1
	state["guard_skill_id"] = ""


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


static func _pick_target(state: Dictionary, actor: Dictionary, skill_id: String = "") -> Dictionary:
	if String(actor["side"]) == "ally":
		# Tiro na Retaguarda: último vivo em vez do primeiro.
		if skill_id != "" and BalanceConfig.skill_target(skill_id) == "last":
			var last: Dictionary = {}
			for unit in state["enemies"]:
				if int(unit["hp"]) > 0:
					last = unit
			return last
		for unit in state["enemies"]:
			if int(unit["hp"]) > 0:
				return unit
		return {}
	# Inimigos respeitam a guarda ativa: miram o guardião se vivo.
	if _is_guard_active(state, {}):
		for unit in state["allies"]:
			if str(unit.get("id", "")) == str(state.get("guard_ally_id", "")) and int(unit["hp"]) > 0:
				return unit
	for unit in state["allies"]:
		if int(unit["hp"]) > 0:
			return unit
	return {}


## Recarga determinística por ações próprias: a habilidade dispara na
## N-ésima ação da unidade. Puro (sem efeito colateral); o incremento e o
## reset acontecem no step(). Inimigos e unidades sem skill: sempre false.
static func _should_use_skill(state: Dictionary, actor: Dictionary, skill_id: String) -> bool:
	if String(actor.get("side", "")) != "ally" or skill_id.is_empty():
		return false
	var cooldown := BalanceConfig.skill_cooldown_actions(skill_id)
	if cooldown <= 0:
		return false
	return int(actor.get("skill_clock", 0)) + 1 >= cooldown


## Aliado vivo mais ferido (fator de cura): primeiro da formação em empate,
## nunca o próprio ator (curador não se cura nesta versão).
static func _pick_weakest_ally(state: Dictionary, actor: Dictionary) -> Dictionary:
	var weakest: Dictionary = {}
	for unit in state["allies"]:
		if int(unit["hp"]) <= 0 or str(unit.get("id", "")) == str(actor.get("id", "")):
			continue
		if int(unit["hp"]) >= int(unit["max_hp"]):
			continue
		if weakest.is_empty() or int(unit["hp"]) < int(weakest["hp"]):
			weakest = unit
	return weakest


## Guarda ativa se: há guardião designado, vivo, dentro da janela
## [from_round, until_round] (resto da rodada atual + próxima completa).
## O segundo parâmetro (alvo) é opcional: quando informado, verifica se o
## alvo É o guardião protegido (para a redução de dano).
static func _is_guard_active(state: Dictionary, target: Dictionary) -> bool:
	var guard_id := str(state.get("guard_ally_id", ""))
	if guard_id.is_empty():
		return false
	var round := int(state.get("round", -2))
	if round < int(state.get("guard_from_round", -1)) or round > int(state.get("guard_until_round", -1)):
		return false
	var guardian: Dictionary = {}
	for unit in state["allies"]:
		if str(unit.get("id", "")) == guard_id and int(unit["hp"]) > 0:
			guardian = unit
			break
	if guardian.is_empty():
		return false
	if target.is_empty():
		return true
	return str(target.get("id", "")) == guard_id


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
		"role": str(unit.get("role", "")),
	}
