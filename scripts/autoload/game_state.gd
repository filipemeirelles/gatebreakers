extends Node
## GameState — estado principal da sessão (spec §6).
## Autoload único. A UI lê este estado; regras de combate/AFK vivem nos services.

signal state_changed

## Versão do schema persistido — SaveService usa para migração.
const SCHEMA_VERSION: int = 3
## Jinwoo + até três sombras (spec §4).
const MAX_TEAM_SIZE: int = 4
## Caçadores contratáveis na equipe (além do Jinwoo).
const HUNTER_TEAM_SIZE: int = 3

## XP de Jinwoo não gasto — a melhoria de nível consome-o (spec §4).
var hunter_xp: int = 0
## Nível de Jinwoo guardado explicitamente (spec §4 — subir de nível custa
## XP + gold). Saves v1 migrados derivam o nível do XP total (SaveService).
var hunter_level_value: int = 1
var gold: int = 0
var shadow_essence: int = 0
var highest_gate_cleared: int = 0
var last_background_unix: int = 0
## Tempo residual para o próximo baú AFK e quantidade de baús prontos.
var afk_chest_progress_seconds: int = 0
var afk_chests_available: int = 0
var afk_chest_last_tick_unix: int = 0
## unit_id -> { "level": int, "unlocked": bool } — sombras (invocações do Jinwoo)
var roster: Dictionary = {}
## ordem de ativação das sombras (invocações)
var formation: Array = []
## portal -> cargas de varredura disponíveis
var sweep_charges: Dictionary = {}
## concessão única de cargas (migração) já realizada
var sweep_grant_done: bool = true
## hunter_id -> { "level": int, "hired": bool } — caçadores contratáveis
var hunter_roster: Dictionary = {}
## caçadores na equipe (máx HUNTER_TEAM_SIZE, sem Jinwoo)
var hunter_formation: Array = []


## Aviso de recuperação de save a mostrar à UI (vazio = tudo bem).
var load_warning: String = ""
## Relatório AFK pendente de mostrar (vazio = nada a mostrar).
var pending_afk_report: Dictionary = {}
## Cartões narrativos já mostrados (ids) — persistidos no save (spec §4).
var story_cards_seen: Array = []
## Fila de cartões por mostrar (derivada; reconstruída ao carregar o estado).
var pending_story_cards: Array = []


func _ready() -> void:
	reset_to_new_game()
	var result := SaveService.load_state()
	var status := String(result.get("status", "fresh"))
	if status == "loaded" or status == "recovered_tmp":
		from_dict(result["state"])
	else:
		if status == "recovered_corrupt":
			load_warning = "O save anterior estava corrompido. Criámos um save novo e guardámos uma cópia para diagnóstico."
		save_now()
	# Ao abrir: credita a ausência uma única vez, grava e deixa o relatório
	# pendente para a UI mostrar (spec §4 Recompensas AFK).
	pending_afk_report = apply_afk_rewards(int(Time.get_unix_time_from_system()))


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_CLOSE_REQUEST:
			# Segundo plano/fecho: regista o horário para a próxima ausência (spec §4).
			var now := int(Time.get_unix_time_from_system())
			_accrue_afk_chests(now)
			last_background_unix = now
			save_now()
			state_changed.emit()
		NOTIFICATION_APPLICATION_RESUMED:
			var report := apply_afk_rewards(int(Time.get_unix_time_from_system()))
			if not report.is_empty():
				get_tree().call_group("navigation", "show_overlay", "afk_report", report)


func save_now() -> bool:
	return SaveService.save_state(to_dict())


func reset_to_new_game() -> void:
	hunter_xp = BalanceConfig.starting_hunter_xp()
	hunter_level_value = 1
	gold = BalanceConfig.starting_gold()
	shadow_essence = BalanceConfig.starting_shadow_essence()
	highest_gate_cleared = BalanceConfig.starting_highest_gate_cleared()
	last_background_unix = 0
	afk_chest_progress_seconds = 0
	afk_chests_available = 0
	afk_chest_last_tick_unix = 0
	roster.clear()
	for unit_id in ContentDB.unit_ids_at_start():
		roster[unit_id] = { "level": 1, "unlocked": true }
	formation = []
	hunter_roster.clear()
	hunter_formation = []
	sweep_charges.clear()
	story_cards_seen.clear()
	rebuild_story_queue()
	state_changed.emit()


# --- Derivados ---

func hunter_level() -> int:
	return hunter_level_value


func current_gate() -> int:
	return highest_gate_cleared + 1


func unit_level(unit_id: String) -> int:
	if unit_id == "jinwoo":
		return hunter_level()
	if ContentDB.hunter(unit_id).has("id"):
		return hunter_level_of(unit_id)
	var entry: Dictionary = roster.get(unit_id, {})
	return int(entry.get("level", 1))


func is_unlocked(unit_id: String) -> bool:
	if ContentDB.hunter(unit_id).has("id"):
		return hunter_is_hired(unit_id)
	var entry: Dictionary = roster.get(unit_id, {})
	return bool(entry.get("unlocked", false))


func unit_stats(unit_id: String) -> Dictionary:
	return unit_stats_at_level(unit_id, unit_level(unit_id))


## Atributos de uma unidade num nível específico (para mostrar o previsto).
func unit_stats_at_level(unit_id: String, level: int) -> Dictionary:
	var def := ContentDB.unit(unit_id)
	if def.is_empty():
		def = ContentDB.hunter(unit_id)
	if def.is_empty():
		return {}
	return BalanceConfig.stats_at_level(
		int(def["base_hp"]), int(def["base_attack"]),
		int(def["base_defense"]), int(def["base_speed"]),
		level
	)


## Equipe de batalha: Jinwoo + caçadores contratados (formação) + sombras
## desbloqueadas como invocações (as sombras NÃO ocupam slots de caçador).
## Ordem = ordem de ação: Jinwoo, caçadores na ordem da formação, invocações.
func team_units() -> Array:
	var out: Array = []
	for unit_id in battle_allies():
		var def := ContentDB.unit(unit_id)
		var is_shadow: bool = def.is_empty()
		if is_shadow:
			def = ContentDB.hunter(unit_id)
		if def.is_empty():
			continue
		var stats := unit_stats(unit_id)
		out.append({
			"id": unit_id,
			"display_name": str(def.get("display_name", unit_id)),
			"role": str(def.get("role", "")),
			"skill_id": str(def.get("skill_id", "")),
			"is_summon": is_shadow,
			"hp": int(stats["hp"]),
			"attack": int(stats["attack"]),
			"defense": int(stats["defense"]),
			"speed": int(stats["speed"]),
		})
	return out


## IDs na ordem de batalha (contrato usado por telas e combate).
func battle_allies() -> Array:
	var out: Array = ["jinwoo"]
	for hunter_id in hunter_formation:
		if hunter_is_hired(String(hunter_id)):
			out.append(String(hunter_id))
	var summons := 0
	for def in ContentDB.all_units():
		var id := String(def["id"])
		if id == "jinwoo":
			continue
		if summons >= BalanceConfig.summon_cap():
			break
		if is_unlocked(id):
			out.append(id)
			summons += 1
	return out


func team_power() -> int:
	var power := 0
	for unit in team_units():
		power += BalanceConfig.combat_power(unit)
	return power


## Poder do maior grupo de inimigos em uma onda do portal.
func gate_power(gate: int) -> int:
	var definition := ContentDB.gate(gate)
	var best_wave_power := 0
	for wave in definition.get("waves", []):
		var wave_power := 0
		for enemy in wave:
			wave_power += BalanceConfig.combat_power(enemy)
		best_wave_power = maxi(best_wave_power, wave_power)
	return best_wave_power


func gate_is_high_risk(gate: int) -> bool:
	var power := team_power()
	return power > 0 and float(gate_power(gate)) * BalanceConfig.danger_enemy_power_ratio() >= float(power)


func red_dots() -> Dictionary:
	var hunter_ready := bool(hunter_upgrade_info().get("available", false))
	var shadow_ready := false
	for unit_id in roster:
		if String(unit_id) == "jinwoo" or not is_unlocked(String(unit_id)):
			continue
		if bool(shadow_upgrade_info(String(unit_id)).get("available", false)):
			shadow_ready = true
			break
	return {
		"portals": int(afk_chest_status(int(Time.get_unix_time_from_system()))["available"]) > 0,
		"hunter": hunter_ready,
		"shadows": shadow_ready,
	}


# --- Mutações ---

func add_rewards(p_gold: int, p_xp: int, p_essence: int) -> void:
	gold = maxi(gold + p_gold, 0)
	hunter_xp = maxi(hunter_xp + p_xp, 0)
	shadow_essence = maxi(shadow_essence + p_essence, 0)
	state_changed.emit()


func spend_gold(amount: int) -> bool:
	if amount < 0 or gold < amount:
		return false
	gold -= amount
	state_changed.emit()
	return true


# --- Melhorias de nível (spec §4 linhas 119-128, §10.6) ---
## O custo é descontado uma única vez, os atributos são recalculados a partir
## da definição base e o estado é gravado de imediato (persiste após reinício).
## Com recurso em falta, a melhoria é bloqueada e o faltante é exposto.

## Informação da melhoria de Jinwoo: custo, faltantes, nível/atributos previstos.
func hunter_upgrade_info() -> Dictionary:
	var level := hunter_level_value
	var at_max := level >= BalanceConfig.max_level()
	var xp_cost := 0
	var gold_cost := 0
	var missing_xp := 0
	var missing_gold := 0
	var next_level := level
	var next_stats: Dictionary = {}
	if not at_max:
		xp_cost = BalanceConfig.hunter_xp_to_next_level(level)
		gold_cost = BalanceConfig.gold_cost_to_next_level(level)
		missing_xp = maxi(xp_cost - hunter_xp, 0)
		missing_gold = maxi(gold_cost - gold, 0)
		next_level = level + 1
		next_stats = unit_stats_at_level("jinwoo", next_level)
	return {
		"available": not at_max and missing_xp == 0 and missing_gold == 0,
		"at_max": at_max,
		"level": level,
		"xp_cost": xp_cost,
		"gold_cost": gold_cost,
		"missing_xp": missing_xp,
		"missing_gold": missing_gold,
		"next_level": next_level,
		"next_stats": next_stats,
	}


## Sobe o nível de Jinwoo consumindo XP + gold uma única vez. { "ok": bool }.
func upgrade_hunter() -> Dictionary:
	var info := hunter_upgrade_info()
	if not bool(info["available"]):
		return { "ok": false, "info": info }
	hunter_xp -= int(info["xp_cost"])
	gold -= int(info["gold_cost"])
	hunter_level_value += 1
	save_now()
	state_changed.emit()
	return { "ok": true, "level": hunter_level_value, "stats": unit_stats("jinwoo") }


## Informação da melhoria de uma sombra: custo gold + essência, faltantes e previstos.
func shadow_upgrade_info(unit_id: String) -> Dictionary:
	var unlocked := is_unlocked(unit_id)
	var level := int(roster.get(unit_id, {}).get("level", 1))
	var at_max := level >= BalanceConfig.max_level()
	var gold_cost := 0
	var essence_cost := 0
	var missing_gold := 0
	var missing_essence := 0
	var next_level := level
	var next_stats: Dictionary = {}
	if not at_max:
		gold_cost = BalanceConfig.shadow_gold_cost_to_next_level(level)
		essence_cost = BalanceConfig.shadow_essence_cost_to_next_level(level)
		missing_gold = maxi(gold_cost - gold, 0)
		missing_essence = maxi(essence_cost - shadow_essence, 0)
		next_level = level + 1
		next_stats = unit_stats_at_level(unit_id, next_level)
	return {
		"unlocked": unlocked,
		"available": unlocked and not at_max and missing_gold == 0 and missing_essence == 0,
		"at_max": at_max,
		"level": level,
		"gold_cost": gold_cost,
		"essence_cost": essence_cost,
		"missing_gold": missing_gold,
		"missing_essence": missing_essence,
		"next_level": next_level,
		"next_stats": next_stats,
		"current_stats": unit_stats_at_level(unit_id, level),
	}


## Sobe o nível de uma sombra consumindo gold + essência uma única vez.
## Jinwoo tem rota própria (upgrade_hunter); unidades bloqueadas são recusadas.
func upgrade_shadow(unit_id: String) -> Dictionary:
	if unit_id == "jinwoo" or not roster.has(unit_id):
		return { "ok": false }
	var info := shadow_upgrade_info(unit_id)
	if not bool(info["available"]):
		return { "ok": false, "info": info }
	gold -= int(info["gold_cost"])
	shadow_essence -= int(info["essence_cost"])
	var entry: Dictionary = roster[unit_id]
	entry["level"] = int(entry.get("level", 1)) + 1
	roster[unit_id] = entry
	save_now()
	state_changed.emit()
	return { "ok": true, "level": int(entry["level"]), "stats": unit_stats(unit_id) }


# --- Caçadores contratáveis (contrato = portal concluído + ouro único) ---

func hunter_is_hired(hunter_id: String) -> bool:
	return bool(hunter_roster.get(hunter_id, {}).get("hired", false))


func hunter_level_of(hunter_id: String) -> int:
	return int(hunter_roster.get(hunter_id, {}).get("level", 1))


## Info de contrato: requisito de portal, custo, faltantes, disponibilidade.
func hunter_contract_info(hunter_id: String) -> Dictionary:
	var def := ContentDB.hunter(hunter_id)
	if def.is_empty():
		return {}
	var contract: Dictionary = def.get("contract", {})
	var gate_needed := int(contract.get("gate", 1))
	var gold_cost := int(contract.get("gold", 0))
	var gate_ok := highest_gate_cleared >= gate_needed
	var hired := hunter_is_hired(hunter_id)
	var in_team := hunter_formation.has(hunter_id)
	return {
		"unlocked": gate_ok,
		"hired": hired,
		"in_team": in_team,
		"gate_needed": gate_needed,
		"gold_cost": gold_cost,
		"missing_gold": maxi(gold_cost - gold, 0) if not hired else 0,
		"can_hire": gate_ok and not hired and gold >= gold_cost,
	}


## Contrata: consome o ouro uma vez, marca como contratado, entra na formação
## se houver vaga, e grava o save de imediato.
func hire_hunter(hunter_id: String) -> Dictionary:
	var info := hunter_contract_info(hunter_id)
	if info.is_empty() or bool(info["hired"]) or not bool(info["can_hire"]):
		return { "ok": false, "info": info }
	gold -= int(info["gold_cost"])
	hunter_roster[hunter_id] = { "level": 1, "hired": true }
	if hunter_formation.size() < HUNTER_TEAM_SIZE:
		hunter_formation.append(hunter_id)
	save_now()
	state_changed.emit()
	return { "ok": true, "hired": hunter_id }


func add_hunter_to_team(hunter_id: String) -> bool:
	if not hunter_is_hired(hunter_id) or hunter_formation.has(hunter_id):
		return false
	if hunter_formation.size() >= HUNTER_TEAM_SIZE:
		return false
	hunter_formation.append(hunter_id)
	state_changed.emit()
	save_now()
	return true


func remove_hunter_from_team(hunter_id: String) -> bool:
	if not hunter_formation.has(hunter_id):
		return false
	hunter_formation.erase(hunter_id)
	state_changed.emit()
	save_now()
	return true


## Melhoria de caçador: só ouro (essência é das sombras). Fonte única de fórmula.
func hunter_unit_upgrade_info(hunter_id: String) -> Dictionary:
	if not hunter_is_hired(hunter_id):
		return {}
	var level := hunter_level_of(hunter_id)
	var at_max := level >= BalanceConfig.max_level()
	var gold_cost := 0
	var missing_gold := 0
	var next_level := level
	var next_stats: Dictionary = {}
	if not at_max:
		gold_cost = BalanceConfig.hunter_gold_cost_to_next_level(level)
		missing_gold = maxi(gold_cost - gold, 0)
		next_level = level + 1
		next_stats = unit_stats_at_level(hunter_id, next_level)
	return {
		"available": not at_max and missing_gold == 0,
		"at_max": at_max,
		"level": level,
		"gold_cost": gold_cost,
		"missing_gold": missing_gold,
		"next_level": next_level,
		"next_stats": next_stats,
		"current_stats": unit_stats_at_level(hunter_id, level),
	}


func upgrade_hunter_unit(hunter_id: String) -> Dictionary:
	var info := hunter_unit_upgrade_info(hunter_id)
	if info.is_empty() or not bool(info["available"]):
		return { "ok": false, "info": info }
	gold -= int(info["gold_cost"])
	var entry: Dictionary = hunter_roster.get(hunter_id, { "level": 1, "hired": true })
	entry["level"] = int(entry.get("level", 1)) + 1
	hunter_roster[hunter_id] = entry
	save_now()
	state_changed.emit()
	return { "ok": true, "level": int(entry["level"]) }


func clear_gate(gate: int) -> void:
	if gate != highest_gate_cleared + 1:
		return
	var first_gate_clear := highest_gate_cleared == 0
	highest_gate_cleared = gate
	if first_gate_clear:
		afk_chest_progress_seconds = 0
		afk_chests_available = 0
		afk_chest_last_tick_unix = int(Time.get_unix_time_from_system())
	_unlock_rewards_for_gate(gate)
	queue_story_for_gate(gate)
	state_changed.emit()


func _unlock_rewards_for_gate(gate: int) -> void:
	for def in ContentDB.all_units():
		var unlock: Dictionary = def.get("unlock", {})
		if String(unlock.get("type", "")) == "gate_cleared" and int(unlock.get("gate", 0)) == gate:
			var unit_id := String(def["id"])
			if not roster.has(unit_id):
				roster[unit_id] = { "level": 1, "unlocked": true }
			else:
				var entry: Dictionary = roster[unit_id]
				entry["unlocked"] = true
				roster[unit_id] = entry


func add_to_formation(unit_id: String) -> bool:
	if unit_id == "jinwoo" or formation.has(unit_id) or not is_unlocked(unit_id):
		return false
	if formation.size() >= BalanceConfig.summon_cap():
		return false
	formation.append(unit_id)
	state_changed.emit()
	return true


func remove_from_formation(unit_id: String) -> bool:
	if unit_id == "jinwoo" or not formation.has(unit_id):
		return false
	formation.erase(unit_id)
	state_changed.emit()
	return true


# --- Vitória, derrota e varredura (Fase 2 / spec §4, §10.3–10.4, §10.11) ---

## Ponto único de entrada ao fim de uma batalha (a tela de combate chama isto).
## Vitória: credita a recompensa exatamente uma vez e desbloqueia progressão.
## Derrota ou batalha incompleta: não concede nada (spec §10.4).
func resolve_battle_end(battle_state: Dictionary) -> Dictionary:
	if String(battle_state.get("phase", "")) != "victory":
		return {}
	return apply_battle_victory(int(battle_state.get("gate", 0)))


## Concede a recompensa de conclusão do portal, avança a progressão (portal
## seguinte + desbloqueios automáticos) e grava o save de imediato.
## Recusado se o portal estiver além do portal atual (não se pode saltar
## progressão) — portals já concluídos podem ser repetidos com recompensa.
func apply_battle_victory(gate: int) -> Dictionary:
	if gate < 1 or gate > highest_gate_cleared + 1:
		return {}
	var gate_def := ContentDB.gate(gate)
	if gate_def.is_empty():
		return {}
	var rewards := CombatService.victory_rewards(gate_def)
	# Bônus de primeira vitória (por portal, em dados): só quando a vitória
	# avança a progressão de verdade — repetição/varredura não recebem.
	var advancing := gate == highest_gate_cleared + 1
	var bonus := float(gate_def.get("first_clear_bonus", 0.0))
	if advancing and bonus > 0.0:
		rewards["gold"] = int(floor(float(rewards["gold"]) * (1.0 + bonus)))
		rewards["xp"] = int(floor(float(rewards["xp"]) * (1.0 + bonus)))
	add_rewards(int(rewards["gold"]), int(rewards["xp"]), int(rewards["essence"]))
	# Primeira limpeza manual do portal concede cargas de varredura (E4).
	if advancing and BalanceConfig.sweep_charges_per_clear() > 0:
		var cap := BalanceConfig.sweep_charges_cap()
		var current := int(sweep_charges.get(str(gate), 0))
		sweep_charges[str(gate)] = mini(current + BalanceConfig.sweep_charges_per_clear(), cap)
	clear_gate(gate)
	save_now()
	return rewards


## Varredura instantânea de portal já concluído (spec §4 Varredura).
## Concede a recompensa normal de conclusão daquele portal. Nunca desbloqueia
## nada novo e não pode ser usada em portal ainda não concluído (§10.11);
## a recompensa de chefe só existe para chefes já vencidos (portais concluídos).
func sweep_gate(gate: int) -> Dictionary:
	if gate < 1 or gate > highest_gate_cleared:
		return {}
	# Sem carga, sem varredura — o jogador limpa o portal manualmente para
	# repor cargas (funciona offline, sem timer: nunca trava a progressão).
	if int(sweep_charges.get(str(gate), 0)) <= 0:
		return {}
	var gate_def := ContentDB.gate(gate)
	if gate_def.is_empty():
		return {}
	var rewards := CombatService.victory_rewards(gate_def)
	add_rewards(int(rewards["gold"]), int(rewards["xp"]), int(rewards["essence"]))
	# Varredura consumindo carga do portal (1 por varredura, vence nada novo).
	var charges := maxi(int(sweep_charges.get(str(gate), 0)) - 1, 0)
	sweep_charges[str(gate)] = charges
	save_now()
	return rewards


# --- Recompensas AFK (spec §4, §10.7–10.10) ---

## Calcula a ausência, credita uma única vez, atualiza o horário guardado e
## grava o save. Devolve o relatório a mostrar ou {} quando não há recompensa
## (primeiro início, tempo zero, relógio retrocedido ou valores a zero).
## Sempre que corre, `last_background_unix` passa a ser `now_unix` — a
## repetição não duplica e o relógio retrocedido recupera sem negativos.
func apply_afk_rewards(now_unix: int) -> Dictionary:
	var report := IdleRewardService.build_report(now_unix, last_background_unix, highest_gate_cleared)
	var chest_progress_changed := _accrue_afk_chests(now_unix)
	last_background_unix = now_unix
	if int(report["gold"]) <= 0 and int(report["xp"]) <= 0:
		save_now()
		if chest_progress_changed:
			state_changed.emit()
		return {}
	add_rewards(int(report["gold"]), int(report["xp"]), 0)
	save_now()
	return report


func _accrue_afk_chests(now_unix: int) -> bool:
	if afk_chest_last_tick_unix <= 0:
		afk_chest_last_tick_unix = now_unix
		return false
	var elapsed := IdleRewardService.compute_elapsed(
		now_unix, afk_chest_last_tick_unix, BalanceConfig.afk_cap_seconds()
	)
	afk_chest_last_tick_unix = now_unix
	if highest_gate_cleared <= 0 or elapsed <= 0:
		return false
	var milestone_seconds := BalanceConfig.afk_chest_milestone_seconds()
	var accumulated := afk_chest_progress_seconds + elapsed
	afk_chests_available += int(floor(float(accumulated) / float(milestone_seconds)))
	afk_chest_progress_seconds = accumulated % milestone_seconds
	return true


func afk_chest_status(now_unix: int = -1) -> Dictionary:
	if now_unix < 0:
		now_unix = int(Time.get_unix_time_from_system())
	var elapsed := 0
	if highest_gate_cleared > 0:
		elapsed = IdleRewardService.compute_elapsed(
			now_unix, afk_chest_last_tick_unix, BalanceConfig.afk_cap_seconds()
		)
	var milestone_seconds := BalanceConfig.afk_chest_milestone_seconds()
	var accumulated := afk_chest_progress_seconds + elapsed
	return {
		"progress_seconds": accumulated % milestone_seconds,
		"milestone_seconds": milestone_seconds,
		"available": afk_chests_available + int(floor(float(accumulated) / float(milestone_seconds))),
	}


## Resgata todos os baús-marcos acumulados separadamente do AFK normal.
func claim_afk_chests(now_unix: int = -1) -> Dictionary:
	if now_unix < 0:
		now_unix = int(Time.get_unix_time_from_system())
	_accrue_afk_chests(now_unix)
	var count := afk_chests_available
	if count <= 0:
		return {}
	var gate := maxi(highest_gate_cleared, 1)
	var rewards := {
		"count": count,
		"gold": BalanceConfig.afk_chest_gold_per_gate() * gate * count,
		"xp": BalanceConfig.afk_chest_xp_per_gate() * gate * count,
	}
	afk_chests_available = 0
	add_rewards(int(rewards["gold"]), int(rewards["xp"]), 0)
	save_now()
	return rewards


# --- Cartões narrativos (spec §4 linha 86) ---
## Gatilhos: "boot" na primeira abertura; "gate_cleared" ao concluir o portal
## indicado. A fila é derivada (seen + progresso) e reconstruída ao carregar;
## mostrar um cartão marca-o como visto e grava o save de imediato.

func rebuild_story_queue() -> void:
	pending_story_cards.clear()
	for card in ContentDB.story_cards():
		_enqueue_story_if_pending(card)


func queue_story_for_gate(gate: int) -> void:
	for card in ContentDB.story_cards():
		if String(card.get("trigger", "")) == "gate_cleared" and int(card.get("gate", 0)) == gate:
			_enqueue_story_if_pending(card)


func _enqueue_story_if_pending(card: Dictionary) -> void:
	var card_id := String(card.get("id", ""))
	if card_id.is_empty() or story_cards_seen.has(card_id) or pending_story_cards.has(card_id):
		return
	var trigger := String(card.get("trigger", ""))
	if trigger == "boot":
		pending_story_cards.append(card_id)
	elif trigger == "gate_cleared" and highest_gate_cleared >= int(card.get("gate", 0)):
		pending_story_cards.append(card_id)


## Consome o próximo cartão da fila, marca-o como visto e grava o save.
## Devolve o id ou "" quando não há nada para mostrar.
func pop_pending_story() -> String:
	while not pending_story_cards.is_empty():
		var card_id: String = pending_story_cards.pop_front()
		if not story_cards_seen.has(card_id):
			story_cards_seen.append(card_id)
			save_now()
			return card_id
	return ""


# --- Serialização (spec §7 PlayerState) ---

func to_dict() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"hunter_level": hunter_level_value,
		"hunter_xp": hunter_xp,
		"gold": gold,
		"shadow_essence": shadow_essence,
		"highest_gate_cleared": highest_gate_cleared,
		"last_background_unix": last_background_unix,
		"afk_chest_progress_seconds": afk_chest_progress_seconds,
		"afk_chests_available": afk_chests_available,
		"afk_chest_last_tick_unix": afk_chest_last_tick_unix,
		"roster": roster.duplicate(true),
		"formation": formation.duplicate(),
		"story_cards_seen": story_cards_seen.duplicate(),
		"hunter_roster": hunter_roster.duplicate(true),
		"hunter_formation": hunter_formation.duplicate(),
		"sweep_charges": sweep_charges.duplicate(true),
		"sweep_grant_done": sweep_grant_done,
	}


func from_dict(data: Dictionary) -> void:
	var xp := int(data["hunter_xp"])
	if data.has("hunter_level"):
		hunter_level_value = int(data["hunter_level"])
	else:
		# Save v1 sem nível guardado: deriva do XP total e converte em XP não gasto.
		var migrated := SaveService.migrate_hunter_level(xp)
		hunter_level_value = int(migrated["level"])
		xp = int(migrated["xp"])
	hunter_xp = xp
	gold = int(data["gold"])
	shadow_essence = int(data["shadow_essence"])
	highest_gate_cleared = int(data["highest_gate_cleared"])
	last_background_unix = int(data["last_background_unix"])
	afk_chest_progress_seconds = int(data.get("afk_chest_progress_seconds", 0))
	afk_chests_available = int(data.get("afk_chests_available", 0))
	afk_chest_last_tick_unix = int(data.get("afk_chest_last_tick_unix", last_background_unix))
	roster.clear()
	for unit_id in data.get("roster", {}):
		var entry: Dictionary = data["roster"][unit_id]
		roster[String(unit_id)] = {
			"level": int(entry.get("level", 1)),
			"unlocked": bool(entry.get("unlocked", false)),
		}
	formation = Array(data.get("formation", []))
	story_cards_seen.clear()
	for entry in data.get("story_cards_seen", []):
		if entry is String:
			story_cards_seen.append(entry)
	hunter_roster.clear()
	hunter_formation.clear()
	for hunter_id in data.get("hunter_roster", {}):
		var hentry: Dictionary = data["hunter_roster"][hunter_id]
		hunter_roster[String(hunter_id)] = {
			"level": int(hentry.get("level", 1)),
			"hired": bool(hentry.get("hired", false)),
		}
	for hunter_id in data.get("hunter_formation", []):
		if hunter_id is String and hunter_is_hired(String(hunter_id)):
			hunter_formation.append(String(hunter_id))
	hunter_formation.resize(mini(hunter_formation.size(), HUNTER_TEAM_SIZE))
	sweep_charges.clear()
	if data.has("sweep_charges") and data["sweep_charges"] is Dictionary:
		for gate_key in data["sweep_charges"]:
			var charges: Variant = data["sweep_charges"][gate_key]
			if gate_key is String and gate_key.is_valid_int() and charges is int and int(charges) > 0:
				sweep_charges[gate_key] = int(charges)
	sweep_grant_done = bool(data.get("sweep_grant_done", true))
	rebuild_story_queue()
	state_changed.emit()
