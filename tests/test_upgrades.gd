class_name UpgradeTests
extends RefCounted
## Testes das melhorias de nível e da edição de formação
## (spec §9 Fase 4, §4 linhas 119-128, §10.6 e critério de sucesso §11).
## `t` é o runner: precisa do método check(cond, name).


static func run(t: Node) -> void:
	print("-- Melhorias e sombras --")
	var original := GameState.to_dict()

	_test_hunter_upgrade(t)
	_test_hunter_migration(t)
	_test_shadow_upgrade(t)
	_test_locked_and_formation(t)
	_test_upgrade_changes_combat(t)

	# Repor o estado do jogador
	GameState.from_dict(original)
	GameState.save_now()


# --- Melhoria de Jinwoo (XP + gold, desconto único, persistência) ---

static func _test_hunter_upgrade(t: Node) -> void:
	GameState.reset_to_new_game()
	var info := GameState.hunter_upgrade_info()
	t.check(GameState.hunter_level() == 1, "jinwoo começa no nível 1")
	t.check(int(info["xp_cost"]) == 100 and int(info["gold_cost"]) == 25,
		"custo do nível 1 é 100 XP + 25 ouro")
	t.check(not bool(info["available"]), "sem XP a melhoria fica bloqueada")
	t.check(int(info["missing_xp"]) == 100 and int(info["missing_gold"]) == 0,
		"faltante de XP exposto (100)")
	t.check(int(info["next_stats"]["hp"]) == 110 and int(info["next_stats"]["attack"]) == 21,
		"atributos previstos do nível 2 (HP 110 · ATK 21)")

	GameState.hunter_xp = 500
	GameState.gold = 10
	info = GameState.hunter_upgrade_info()
	t.check(not bool(info["available"]) and int(info["missing_gold"]) == 15,
		"ouro insuficiente bloqueia e mostra o faltante (15)")

	GameState.gold = 100
	var stats_before := GameState.unit_stats("jinwoo")
	var result := GameState.upgrade_hunter()
	t.check(bool(result.get("ok", false)), "melhoria com recursos suficientes executa")
	t.check(GameState.hunter_level() == 2, "nível sobe para 2")
	t.check(GameState.hunter_xp == 400, "XP descontado uma única vez (500 - 100)")
	t.check(GameState.gold == 75, "ouro descontado uma única vez (100 - 25)")
	var stats_after := GameState.unit_stats("jinwoo")
	t.check(int(stats_after["hp"]) > int(stats_before["hp"])
		and int(stats_after["attack"]) > int(stats_before["attack"]),
		"atributos sobem após a melhoria")

	var loaded := SaveService.load_state()
	t.check(loaded["status"] == "loaded", "save carrega após a melhoria")
	t.check(int(loaded["state"]["hunter_level"]) == 2 and int(loaded["state"]["hunter_xp"]) == 400,
		"nível e XP persistem no save")

	var second := GameState.upgrade_hunter()
	t.check(bool(second.get("ok", false)) and GameState.hunter_level() == 3,
		"segunda melhoria executa com recursos")
	t.check(GameState.hunter_xp == 200 and GameState.gold == 25,
		"segunda desconta 200 XP + 50 ouro")

	var third := GameState.upgrade_hunter()
	t.check(not bool(third.get("ok", false)), "terceira recusa sem recursos")
	t.check(GameState.hunter_level() == 3 and GameState.hunter_xp == 200 and GameState.gold == 25,
		"recusa não altera nível nem recursos")

	GameState.hunter_level_value = BalanceConfig.max_level()
	GameState.hunter_xp = 9999
	GameState.gold = 9999
	info = GameState.hunter_upgrade_info()
	t.check(bool(info["at_max"]) and not bool(info["available"]),
		"nível máximo bloqueia a melhoria")
	t.check(not bool(GameState.upgrade_hunter().get("ok", false))
		and GameState.hunter_level() == BalanceConfig.max_level(),
		"não sobe além do nível máximo")


# --- Migração de saves v1 (sem hunter_level) ---

static func _test_hunter_migration(t: Node) -> void:
	var legacy := GameState.to_dict()
	legacy.erase("hunter_level")
	legacy["hunter_xp"] = 350
	SaveService.save_state(legacy)
	var result := SaveService.load_state()
	t.check(result["status"] == "loaded", "save v1 sem hunter_level continua válido")
	t.check(int(result["state"]["hunter_level"]) == 3, "nível migrado do XP total (350 → 3)")
	t.check(int(result["state"]["hunter_xp"]) == 50,
		"XP total convertido em não gasto (350 - 300)")

	GameState.from_dict(legacy)
	t.check(GameState.hunter_level() == 3 and GameState.hunter_xp == 50,
		"from_dict também migra saves sem hunter_level")


# --- Melhoria de sombra (gold + essência, desconto único, persistência) ---

static func _test_shadow_upgrade(t: Node) -> void:
	GameState.reset_to_new_game()
	var info := GameState.shadow_upgrade_info("shadow_soldier")
	t.check(int(info["gold_cost"]) == 25 and int(info["essence_cost"]) == 5,
		"custo da sombra nível 1 é 25 ouro + 5 essência")
	t.check(not bool(info["available"]), "essência em falta bloqueia a melhoria")
	t.check(int(info["missing_essence"]) == 5 and int(info["missing_gold"]) == 0,
		"faltante de essência exposto (5)")

	GameState.shadow_essence = 5
	var result := GameState.upgrade_shadow("shadow_soldier")
	t.check(bool(result.get("ok", false)), "melhoria de sombra executa com recursos")
	t.check(GameState.unit_level("shadow_soldier") == 2, "sombra sobe para o nível 2")
	t.check(GameState.gold == 75 and GameState.shadow_essence == 0,
		"custo descontado uma única vez (100 - 25, 5 - 5)")

	var loaded := SaveService.load_state()
	t.check(int(loaded["state"]["roster"]["shadow_soldier"]["level"]) == 2,
		"nível da sombra persiste no save")
	t.check(not bool(GameState.upgrade_shadow("jinwoo").get("ok", false)),
		"jinwoo não usa a rota de melhoria das sombras")
	t.check(not bool(GameState.upgrade_shadow("shadow_soldier").get("ok", false))
		and GameState.unit_level("shadow_soldier") == 2,
		"sem recursos a melhoria da sombra é recusada sem alterar o nível")


# --- Unidades bloqueadas e edição da formação ---

static func _test_locked_and_formation(t: Node) -> void:
	GameState.reset_to_new_game()
	t.check(not GameState.is_unlocked("igris"), "igris bloqueada no início")
	t.check(not GameState.add_to_formation("igris"), "unidade bloqueada não entra na formação")
	var info := GameState.shadow_upgrade_info("igris")
	t.check(not bool(info["unlocked"]) and not bool(info["available"]),
		"unidade bloqueada não pode ser melhorada")

	GameState.roster["shadow_ranged"] = { "level": 1, "unlocked": true }
	GameState.roster["shadow_guardian"] = { "level": 1, "unlocked": true }
	GameState.roster["igris"] = { "level": 1, "unlocked": true }
	t.check(GameState.add_to_formation("shadow_soldier"), "sombra inicial entra na formação")
	t.check(GameState.add_to_formation("shadow_ranged"), "unidade desbloqueada entra na formação")
	t.check(not GameState.add_to_formation("shadow_guardian"),
		"formação de invocações respeita o limite configurado")
	t.check(not GameState.remove_from_formation("jinwoo"), "jinwoo não faz parte da formação de invocações")
	t.check(GameState.remove_from_formation("shadow_soldier"), "sombra sai da formação")
	t.check(GameState.formation.size() == 1, "formação encolhe ao remover")


# --- Critério de sucesso §11: melhorar altera o combate de forma observável ---

static func _test_upgrade_changes_combat(t: Node) -> void:
	GameState.reset_to_new_game()
	var gate_def := ContentDB.gate(1)
	var team_before := GameState.team_units()
	var state_before := CombatService.start_battle(team_before, gate_def)
	var event_before := CombatService.step(state_before)

	GameState.hunter_xp = 100
	GameState.gold = 25
	GameState.upgrade_hunter()
	var team_after := GameState.team_units()
	t.check(int(team_after[0]["hp"]) > int(team_before[0]["hp"]),
		"melhoria altera os atributos da equipa usada no combate")
	var state_after := CombatService.start_battle(team_after, gate_def)
	var event_after := CombatService.step(state_after)
	t.check(int(event_after["damage"]) > int(event_before["damage"]),
		"melhoria altera o dano observado no primeiro combate")
	var finished := CombatService.run_to_completion(state_after)
	t.check(String(finished["phase"]) == "victory",
		"equipa melhorada vence o portal 1")
