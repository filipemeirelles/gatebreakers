class_name SkillTests
extends RefCounted
## Testes da primeira entrega de habilidades (1 por unidade, determinísticas).
## `t` é o runner: precisa do método check(cond, name).


static func run(t: Node) -> void:
	print("-- Habilidades --")
	var original := GameState.to_dict()

	_test_config_present(t)
	_test_jinwoo_focused(t)
	_test_igris_strike(t)
	_test_ranged_backline(t)
	_test_guardian_stance(t)
	_test_guard_cleared_on_wave(t)
	_test_soldier_has_no_skill(t)
	_test_determinism_with_skills(t)
	_test_team_units_expose_skill(t)

	GameState.from_dict(original)
	GameState.save_now()


static func _test_config_present(t: Node) -> void:
	t.check(BalanceConfig.skill_cooldown_actions("jinwoo_focused") == 4, "Jinwoo: recarga 4 ações")
	t.check(BalanceConfig.skill_cooldown_actions("igris_strike") == 3, "Igris: recarga 3 ações")
	t.check(BalanceConfig.skill_cooldown_actions("guardian_stance") == 4, "Guardião: recarga 4 ações")
	t.check(BalanceConfig.skill_cooldown_actions("ranged_backline") == 3, "Ranged: recarga 3 ações")
	t.check(BalanceConfig.skill_damage_multiplier("jinwoo_focused") == 2.0, "Jinwoo: multiplicador 2x")
	t.check(BalanceConfig.skill_damage_multiplier("igris_strike") == 1.5, "Igris: multiplicador 1.5x")
	t.check(BalanceConfig.skill_target("ranged_backline") == "last", "Ranged: alvo é o último vivo")
	t.check(BalanceConfig.skill_target("guardian_stance") == "self_guard", "Guardião: alvo é guarda própria")
	t.check(BalanceConfig.skill_cooldown_actions("no_such_skill") == 0, "skill desconhecida: recarga 0 (sem efeito)")


static func _test_jinwoo_focused(t: Node) -> void:
	var state := CombatService.start_battle(
		[_ally("jinwoo", 500, 20, 0, 10, "jinwoo_focused")],
		{ "gate": 1, "waves": [[_enemy("dummy", 1000, 1, 0, 1)]] }
	)
	var hits: Array = []
	var safety := 0
	while hits.size() < 4 and safety < 200:
		safety += 1
		var ev: Dictionary = CombatService.step(state)
		if ev.is_empty():
			break
		if String(ev.get("type", "")) == "attack" and String(ev["attacker"]["id"]) == "jinwoo":
			hits.append(ev)
	t.check(hits.size() == 4, "Jinwoo age 4 vezes contra alvo tanky")
	var basic := BalanceConfig.basic_damage(20, 0)
	t.check(int(hits[0]["damage"]) == basic and not bool(hits[0].get("is_skill", false)), "Jinwoo ações 1: básico")
	t.check(int(hits[1]["damage"]) == basic and not bool(hits[1].get("is_skill", false)), "Jinwoo ações 2: básico")
	t.check(int(hits[2]["damage"]) == basic and not bool(hits[2].get("is_skill", false)), "Jinwoo ação 3: básico")
	t.check(int(hits[3]["damage"]) == basic * 2 and bool(hits[3].get("is_skill", false)), "Jinwoo 4ª ação: Golpe Concentrado 2x")
	t.check(String(hits[3].get("skill_id", "")) == "jinwoo_focused", "evento carrega o skill_id")
	t.check(String(hits[3]["target"]["id"]) == "dummy", "Jinwoo mira o primeiro vivo")


static func _test_igris_strike(t: Node) -> void:
	var state := CombatService.start_battle(
		[_ally("igris", 500, 10, 0, 10, "igris_strike")],
		{ "gate": 1, "waves": [[_enemy("dummy", 1000, 1, 0, 1)]] }
	)
	var hits: Array = []
	var safety := 0
	while hits.size() < 3 and safety < 200:
		safety += 1
		var ev: Dictionary = CombatService.step(state)
		if ev.is_empty():
			break
		if String(ev.get("type", "")) == "attack" and String(ev["attacker"]["id"]) == "igris":
			hits.append(ev)
	var basic := BalanceConfig.basic_damage(10, 0)
	t.check(int(hits[2]["damage"]) == int(floor(float(basic) * 1.5)) and bool(hits[2].get("is_skill", false)),
		"Igris 3ª ação: 1.5x com floor")


static func _test_ranged_backline(t: Node) -> void:
	var state := CombatService.start_battle(
		[_ally("ranged", 500, 10, 0, 10, "ranged_backline")],
		{ "gate": 1, "waves": [[_enemy("e1", 500, 1, 0, 1), _enemy("e2", 500, 1, 0, 1)]] }
	)
	var hits: Array = []
	var safety := 0
	while hits.size() < 3 and safety < 300:
		safety += 1
		var ev: Dictionary = CombatService.step(state)
		if ev.is_empty():
			break
		if String(ev.get("type", "")) == "attack" and String(ev["attacker"]["id"]) == "ranged":
			hits.append(ev)
	t.check(String(hits[0]["target"]["id"]) == "e1", "ranged básico mira o primeiro vivo")
	t.check(String(hits[1]["target"]["id"]) == "e1", "ranged 2ª ação ainda no primeiro vivo")
	t.check(bool(hits[2].get("is_skill", false)) and String(hits[2]["target"]["id"]) == "e2",
		"ranged 3ª ação: Tiro na Retaguarda atinge o ÚLTIMO vivo")
	t.check(int(hits[2]["damage"]) == BalanceConfig.basic_damage(10, 0), "retaguarda: dano 1x")


static func _test_guardian_stance(t: Node) -> void:
	# Formação: amigo frágil primeiro, guardião depois. Inimigo forte e rápido.
	var state := CombatService.start_battle(
		[
			_ally("friend", 500, 5, 0, 5, ""),
			_ally("guardian", 500, 5, 0, 4, "guardian_stance"),
		],
		{ "gate": 1, "waves": [[_enemy("foe", 1000, 20, 0, 20)]] }
	)
	# Acelera: guardião com 3 ações acumuladas usa a guarda no próximo turno.
	(state["allies"] as Array)[1]["skill_clock"] = 3
	var guard_ev: Dictionary = {}
	var safety := 0
	while guard_ev.is_empty() and safety < 200:
		safety += 1
		var ev: Dictionary = CombatService.step(state)
		if ev.is_empty():
			break
		if String(ev.get("type", "")) == "skill" and String(ev.get("skill_id", "")) == "guardian_stance":
			guard_ev = ev
	t.check(not guard_ev.is_empty(), "guardião ativa Postura de Guarda no 4º turno próprio")
	t.check(String(guard_ev["attacker"]["id"]) == "guardian", "guarda parte do guardião")
	# Próximo ataque inimigo deve mirar o guardião, com redução 0.75.
	var next_foe: Dictionary = {}
	safety = 0
	while next_foe.is_empty() and safety < 200:
		safety += 1
		var ev: Dictionary = CombatService.step(state)
		if ev.is_empty():
			break
		if String(ev.get("type", "")) == "attack" and String(ev["attacker"]["id"]) == "foe":
			next_foe = ev
	t.check(String(next_foe["target"]["id"]) == "guardian", "inimigo redirecionado ao guardião sob guarda")
	var expected := maxi(1, int(floor(float(BalanceConfig.basic_damage(20, 0)) * 0.75)))
	t.check(int(next_foe["damage"]) == expected, "guarda reduz o dano para floor(0.75x)")
	# Guarda expira fora da janela: dois rounds depois não há mais redirecionamento.
	state["round"] = int(state.get("guard_until_round", 0)) + 2
	t.check(not CombatService._is_guard_active(state, {}), "guarda expira após a janela")


static func _test_guard_cleared_on_wave(t: Node) -> void:
	var state := CombatService.start_battle(
		[
			_ally("friend", 500, 50, 0, 5, ""),
			_ally("guardian", 500, 50, 0, 4, "guardian_stance"),
		],
		{ "gate": 1, "waves": [
			[_enemy("w1a", 30, 1, 0, 1), _enemy("w1b", 30, 1, 0, 1)],
			[_enemy("w2", 500, 1, 0, 1)],
		] }
	)
	(state["allies"] as Array)[1]["skill_clock"] = 3
	var saw_guard := false
	var safety := 0
	while int(state["wave_index"]) == 0 and safety < 300:
		safety += 1
		var ev: Dictionary = CombatService.step(state)
		if String(ev.get("type", "")) == "skill":
			saw_guard = true
	t.check(int(state["wave_index"]) == 1, "batalha avança para a 2ª onda no teste")
	t.check(saw_guard, "guarda chegou a ativar antes da troca de onda")
	t.check(str(state.get("guard_ally_id", "")) == "", "guarda não vaza para a onda seguinte")


static func _test_soldier_has_no_skill(t: Node) -> void:
	var state := CombatService.start_battle(
		[_ally("soldier", 500, 15, 0, 8, "")],
		{ "gate": 1, "waves": [[_enemy("dummy", 2000, 1, 0, 1)]] }
	)
	var saw_skill := false
	var safety := 0
	var actions := 0
	while actions < 6 and safety < 400:
		safety += 1
		var ev: Dictionary = CombatService.step(state)
		if ev.is_empty():
			break
		if String(ev.get("type", "")) == "attack" and String(ev["attacker"]["id"]) == "soldier":
			actions += 1
			if bool(ev.get("is_skill", false)):
				saw_skill = true
	t.check(actions == 6 and not saw_skill, "unidade sem skill: 6 ações, nenhum evento de habilidade")


static func _test_determinism_with_skills(t: Node) -> void:
	var team := [
		_ally("jinwoo", 200, 20, 0, 10, "jinwoo_focused"),
		_ally("ranged", 200, 10, 0, 11, "ranged_backline"),
		_ally("guardian", 300, 5, 10, 4, "guardian_stance"),
	]
	var waves := [[_enemy("e1", 120, 8, 0, 7), _enemy("e2", 120, 8, 0, 6)]]
	var a := _event_log(CombatService.start_battle(team.duplicate(true), { "gate": 1, "waves": waves.duplicate(true) }))
	var b := _event_log(CombatService.start_battle(team.duplicate(true), { "gate": 1, "waves": waves.duplicate(true) }))
	t.check(a.size() > 0 and a == b, "mesma entrada com habilidades gera mesma sequência de eventos")


static func _test_team_units_expose_skill(t: Node) -> void:
	GameState.from_dict({
		"schema_version": 2,
		"hunter_level": 1,
		"hunter_xp": 0,
		"gold": 100,
		"shadow_essence": 0,
		"highest_gate_cleared": 7,
		"last_background_unix": 0,
		"roster": {
			"jinwoo": { "level": 1, "unlocked": true },
			"shadow_soldier": { "level": 1, "unlocked": true },
			"shadow_guardian": { "level": 1, "unlocked": true },
			"shadow_ranged": { "level": 1, "unlocked": true },
			"igris": { "level": 1, "unlocked": true },
		},
		"formation": ["jinwoo", "shadow_ranged", "shadow_guardian", "igris"],
	})
	var team := GameState.team_units()
	var by_id := {}
	var summons := 0
	for u in team:
		by_id[String(u["id"])] = u
		if bool(u.get("is_summon", false)):
			summons += 1
	t.check(String(by_id["jinwoo"]["skill_id"]) == "jinwoo_focused", "team_units expõe skill de Jinwoo")
	t.check(by_id.has("igris") or summons >= 1, "invocações desbloqueadas entram em combate (cap configurado)")
	t.check(summons <= BalanceConfig.summon_cap(), "número de invocações respeita o cap")


# --- Auxiliares ---

static func _ally(id: String, hp: int, attack: int, defense: int, speed: int, skill_id: String) -> Dictionary:
	return {
		"id": id, "display_name": id, "role": "test",
		"hp": hp, "attack": attack, "defense": defense, "speed": speed,
		"skill_id": skill_id,
	}


static func _enemy(id: String, hp: int, attack: int, defense: int, speed: int) -> Dictionary:
	return {
		"id": id, "display_name": id, "role": "common",
		"hp": hp, "attack": attack, "defense": defense, "speed": speed,
	}


static func _event_log(state: Dictionary) -> Array:
	var out: Array = []
	var safety := 0
	while not CombatService.is_finished(state) and safety < 3000:
		safety += 1
		var ev: Dictionary = CombatService.step(state)
		if ev.is_empty():
			break
		if String(ev.get("type", "")) == "attack":
			out.append("%s>%s:%d:%s" % [
				str(ev["attacker"]["id"]), str(ev["target"]["id"]),
				int(ev["damage"]), "S" if bool(ev.get("is_skill", false)) else "-",
			])
		elif String(ev.get("type", "")) == "skill":
			out.append("skill:%s" % str(ev.get("skill_id", "")))
		else:
			out.append("outcome:%s" % str(ev.get("outcome", "")))
	return out
