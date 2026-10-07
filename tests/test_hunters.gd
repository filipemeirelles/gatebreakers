class_name HunterTests
extends RefCounted
## Testes da expansão de caçadores: contratação (portal + ouro), melhoria,
## equipe combinada (Jinwoo + caçadores + invocações), cura, varredura
## limitada e migração de save para o schema atual.


static func run(t: Node) -> void:
	print("-- Caçadores e varredura limitada --")
	var original := GameState.to_dict()

	_test_contract(t)
	_test_hire_and_team(t)
	_test_hunter_upgrade(t)
	_test_heal_skill(t)
	_test_sweep_charges(t)
	_test_migration_v2(t)
	_test_gate2_beatable(t)

	GameState.from_dict(original)
	GameState.save_now()


static func _state(highest: int, gold: int) -> Dictionary:
	return {
		"schema_version": 2,
		"hunter_level": 1,
		"hunter_xp": 0,
		"gold": gold,
		"shadow_essence": 0,
		"highest_gate_cleared": highest,
		"last_background_unix": 0,
		"roster": {
			"jinwoo": { "level": 1, "unlocked": true },
			"shadow_soldier": { "level": 1, "unlocked": true },
		},
		"formation": ["jinwoo", "shadow_soldier"],
	}


static func _test_contract(t: Node) -> void:
	GameState.from_dict(_state(0, 100))
	var info := GameState.hunter_contract_info("yoojinho")
	t.check(not bool(info["unlocked"]), "Jinho exige Portal 1 concluído")
	t.check(not GameState.hire_hunter("yoojinho")["ok"], "contrato recusa portal não concluído")

	GameState.from_dict(_state(1, 100))
	info = GameState.hunter_contract_info("yoojinho")
	t.check(bool(info["unlocked"]) and not bool(info["can_hire"]), "portal ok, ouro insuficiente bloqueia")
	var info_song := GameState.hunter_contract_info("songchiyul")
	t.check(not bool(info_song["unlocked"]), "Song exige Portal 3")


static func _test_hire_and_team(t: Node) -> void:
	GameState.from_dict(_state(1, 1000))
	var hire := GameState.hire_hunter("yoojinho")
	t.check(bool(hire["ok"]), "contratação consome ouro e contrata")
	t.check(GameState.gold == 1000 - 150, "contrato desconta o ouro exatamente uma vez")
	t.check(GameState.hunter_formation.has("yoojinho"), "contratado entra na formação")
	var persisted := SaveService.load_state()
	t.check(bool(persisted["state"]["hunter_roster"].get("yoojinho", {}).get("hired", false)),
		"contratação persiste no save")
	t.check(GameState.hire_hunter("yoojinho")["ok"] == false, "contratado não é contratado de novo")

	var ids := GameState.battle_allies()
	t.check(ids.has("jinwoo") and ids.has("yoojinho"), "equipe = Jinwoo + caçador contratado")
	t.check(ids.has("shadow_soldier"), "sombras entram como invocações da equipe")
	var summons := 0
	for unit in GameState.team_units():
		if bool(unit.get("is_summon", false)):
			summons += 1
	t.check(summons == 1 and summons <= BalanceConfig.summon_cap(), "cap de invocações respeitado")

	GameState.from_dict(_state(5, 5000))
	GameState.hire_hunter("yoojinho")
	GameState.hire_hunter("songchiyul")
	GameState.hire_hunter("leejoohee")
	t.check(GameState.add_hunter_to_team("woojinchul") == false and not GameState.hunter_is_hired("woojinchul")
		or not GameState.add_hunter_to_team("woojinchul"), "não contratado não entra na equipe")
	t.check(GameState.hunter_formation.size() == 3, "equipe de caçadores tem no máximo 3")
	t.check(GameState.remove_hunter_from_team("songchiyul"), "caçador sai da equipe")


static func _test_hunter_upgrade(t: Node) -> void:
	GameState.from_dict(_state(1, 500))
	GameState.hire_hunter("yoojinho")
	var before := GameState.unit_stats("yoojinho")
	var up := GameState.upgrade_hunter_unit("yoojinho")
	t.check(bool(up["ok"]) and GameState.hunter_level_of("yoojinho") == 2, "melhoria de caçador sobe nível")
	var after := GameState.unit_stats("yoojinho")
	t.check(int(after["hp"]) > int(before["hp"]), "melhoria altera atributos do caçador")
	t.check(GameState.gold == 500 - 150 - 40, "custo de melhoria descontado uma vez (40 × nível)")


static func _test_heal_skill(t: Node) -> void:
	var state := CombatService.start_battle(
		[
			{"id": "wounded", "display_name": "w", "role": "fighter", "hp": 50, "max_hp": 100, "attack": 5, "defense": 0, "speed": 9, "skill_id": ""},
			{"id": "joohee", "display_name": "j", "role": "healer", "hp": 100, "max_hp": 100, "attack": 10, "defense": 0, "speed": 4, "skill_id": "joohee_soothing_light"},
		],
		{"gate": 1, "waves": [[{"id": "dummy", "display_name": "d", "role": "common", "hp": 400, "attack": 1, "defense": 0, "speed": 1}]]}
	)
	# start_battle define max_hp = hp; restauramos o HP ferido manualmente.
	(state["allies"] as Array)[0]["max_hp"] = 100
	(state["allies"] as Array)[0]["hp"] = 50
	(state["allies"] as Array)[1]["skill_clock"] = 3
	var heal_ev: Dictionary = {}
	var safety := 0
	while heal_ev.is_empty() and safety < 100:
		safety += 1
		var ev: Dictionary = CombatService.step(state)
		if ev.is_empty():
			break
		if String(ev.get("type", "")) == "skill" and String(ev.get("skill_id", "")) == "joohee_soothing_light":
			heal_ev = ev
	t.check(not heal_ev.is_empty() and int(heal_ev["damage"]) < 0, "cura emite evento próprio (dano negativo)")
	var expected_heal := BalanceConfig.skill_heal_amount("joohee_soothing_light", 100)
	t.check(int((state["allies"] as Array)[0]["hp"]) == 50 + expected_heal, "cura recupera o valor configurado")
	t.check(bool(heal_ev.get("heal", false)), "evento marca a cura")


static func _test_sweep_charges(t: Node) -> void:
	GameState.from_dict(_state(0, 100))
	t.check(GameState.sweep_gate(1).is_empty(), "sem carga: varredura recusada")
	var rewards := GameState.apply_battle_victory(1)
	t.check(not rewards.is_empty(), "limpeza manual funciona sem carga")
	var charges := int(GameState.sweep_charges.get(str(1), 0))
	t.check(charges == BalanceConfig.sweep_charges_per_clear(), "1ª limpeza concede as cargas iniciais")
	var gold_before := GameState.gold
	var sweep := GameState.sweep_gate(1)
	t.check(not sweep.is_empty(), "com carga: varredura concede recompensa")
	t.check(GameState.gold > gold_before, "varredura credita ouro")
	t.check(int(GameState.sweep_charges.get(str(1), 0)) == charges - 1, "varredura consome exatamente 1 carga")

	# Concessão única na migração: save sem flag recebe o pack; a segunda
	# leitura com flag não duplica.
	var raw := JSON.stringify({
		"schema_version": 2,
		"hunter_level": 2,
		"hunter_xp": 0,
		"gold": 100,
		"shadow_essence": 0,
		"highest_gate_cleared": 3,
		"last_background_unix": 0,
		"afk_chest_progress_seconds": 0,
		"afk_chests_available": 0,
		"afk_chest_last_tick_unix": 0,
		"roster": {"jinwoo": {"level": 2, "unlocked": true}, "shadow_soldier": {"level": 1, "unlocked": true}},
		"formation": ["jinwoo", "shadow_soldier"],
	})
	var file := FileAccess.open("user://save_v1.json", FileAccess.WRITE)
	file.store_string(raw)
	file.close()
	var result := SaveService.load_state()
	t.check(int(result["state"]["sweep_charges"].get("1", 0)) == BalanceConfig.sweep_charges_per_clear(),
		"migração concede o pack de cargas uma única vez")
	t.check(bool(result["state"]["sweep_grant_done"]), "flag de concessão marcada")


static func _test_migration_v2(t: Node) -> void:
	var raw := JSON.stringify({
		"schema_version": 2,
		"hunter_level": 4,
		"hunter_xp": 120,
		"gold": 777,
		"shadow_essence": 30,
		"highest_gate_cleared": 3,
		"last_background_unix": 0,
		"roster": {
			"jinwoo": { "level": 4, "unlocked": true },
			"shadow_soldier": { "level": 3, "unlocked": true },
			"igris": { "level": 2, "unlocked": true },
		},
		"formation": ["jinwoo", "shadow_soldier", "igris"],
		"afk_chest_progress_seconds": 100,
		"afk_chests_available": 1,
		"afk_chest_last_tick_unix": 0,
		"story_cards_seen": ["card_system"],
	})
	var path := "user://save_v1.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(raw)
	file.close()
	var result := SaveService.load_state()
	t.check(result["status"] == "loaded" and int(result["state"]["schema_version"]) == 3,
		"save v2 migra para o schema atual")
	GameState.from_dict(result["state"])
	t.check(GameState.hunter_is_hired("yoojinho"), "migração v2→v3 contrata Jinho com progresso (P3 concluído)")
	t.check(int(GameState.gold) == 777, "migração preserva ouro")
	t.check(GameState.is_unlocked("igris"), "migração preserva sombras desbloqueadas")


static func _test_gate2_beatable(t: Node) -> void:
	# Aceitação do rebalance: time inicial + Jinho contratado vence o Portal 2.
	GameState.from_dict(_state(1, 1000))
	GameState.hire_hunter("yoojinho")
	var state := CombatService.start_battle(GameState.team_units(), ContentDB.gate(2))
	CombatService.run_to_completion(state)
	t.check(String(state["phase"]) == "victory", "time inicial + Jinho vence o Portal 2 rebalanceado")
	GameState.from_dict(_state(0, 100))
	var solo := CombatService.start_battle(GameState.team_units(), ContentDB.gate(2))
	CombatService.run_to_completion(solo)
	t.check(String(solo["phase"]) == "defeat", "sem caçador/melhoria, o Portal 2 ainda exige progresso")
