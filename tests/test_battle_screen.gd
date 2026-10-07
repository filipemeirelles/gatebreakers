class_name BattleScreenTests
extends RefCounted
## Testes da tela de combate e do resultado (spec §5.4/§5.5 e critérios
## §10.3–10.5): fluxo completo pela UI, recompensa creditada na vitória,
## derrota sem recompensa e saída sem vitória.
## `t` é o runner: precisa do método check(cond, name).


static func run(t: Node) -> void:
	print("-- Tela de combate --")
	var original := GameState.to_dict()
	var main: Node = load("res://scenes/app/main.tscn").instantiate()
	t.add_child(main)
	var nav := main as NavigationController
	var battle = main.get_node("Overlays/Battle")
	var result = main.get_node("Overlays/BattleResult")
	var gate_prep = main.get_node("Overlays/GatePrep")

	# 1) Fluxo de vitória completo
	_set_state(0, 100)
	nav.show_overlay("battle", { "gate": 1 })
	t.check(battle.visible, "overlay de combate abre com o portal escolhido")
	t.check(battle.wave_label.text == ("%s 1 / 3" % Loc.t("battle.wave")), "mostra a onda atual 1 / 3")
	t.check(battle.enemies_box.get_child_count() == 2, "2 inimigos desenhados na 1.ª onda")
	t.check(battle.allies_box.get_child_count() == 2, "2 unidades da equipe desenhadas")
	t.check(battle.log_label.text == Loc.t("battle.ready"), "mostra chamada visual antes do primeiro passo")
	var first_enemy_id := String(battle._state["enemies"][0]["id"])
	var enemy_row: Dictionary = battle._rows["enemy:%s" % first_enemy_id]
	t.check(enemy_row["portrait"] is TextureRect and enemy_row["portrait"].texture != null,
		"inimigo recebe retrato SVG da batalha")
	var first_ally_id := String(battle._state["allies"][0]["id"])
	var ally_row: Dictionary = battle._rows["ally:%s" % first_ally_id]
	t.check(ally_row["portrait"] is TextureRect and ally_row["portrait"].texture != null,
		"aliado recebe retrato definido nos dados da unidade")
	battle._advance()
	t.check(not battle.log_label.text.is_empty(), "primeiro golpe atualiza feedback da batalha")
	t.check(battle.fx_layer.get_child_count() == 1, "golpe cria número de dano flutuante")
	var wave_steps := 0
	while int(battle._state["wave_index"]) == 0 and wave_steps < 100:
		battle._advance()
		wave_steps += 1
	t.check(int(battle._state["wave_index"]) == 1, "primeira onda avança para a seguinte")
	var second_wave_enemy_id := String(battle._state["enemies"][0]["id"])
	battle._advance()
	t.check(battle._rows.has("enemy:%s" % second_wave_enemy_id),
		"retratos inimigos são reconstruídos ao iniciar a próxima onda")

	_drive(battle)
	t.check(battle._finished, "batalha termina por si")
	t.check(not battle.visible, "combate fecha ao terminar")
	t.check(result.visible, "resultado abre ao terminar")
	t.check(result.title_label.text == Loc.t("result.victory", "Vitória"), "resultado mostra vitória")
	t.check(result.result_portrait.texture != null, "resultado de vitória mostra retrato do caçador")
	t.check(result.reward_strip.visible
		and result.get_node("Margin/VBox/RewardStrip/GoldReward/GoldIcon").texture != null,
		"resultado organiza recompensas com ícones")
	var expected_rewards := "+%d %s · +%d %s" % [
		BalanceConfig.victory_gold(1, 6), Loc.t("ui.gold"),
		BalanceConfig.victory_xp(1, 6), Loc.t("ui.xp"),
	]
	t.check(result.rewards_label.text == expected_rewards, "resultado mostra os recursos ganhos")
	t.check(GameState.gold == 100 + BalanceConfig.victory_gold(1, 6),
		"vitória credita a recompensa exatamente uma vez")
	t.check(GameState.highest_gate_cleared == 1, "vitória desbloqueia o portal seguinte")
	t.check(result.unlock_label.visible and result.unlock_label.text == (Loc.t("result.gate_unlocked") % 2),
		"resultado anuncia o portal 2 desbloqueado")
	t.check(not result.retry_button.visible, "vitória não oferece tentar novamente")

	result._on_continue()
	t.check(not result.visible, "continuar fecha o resultado")

	# 2) Derrota não concede nada (portal 10 é forte demais)
	_set_state(0, 100)
	nav.show_overlay("battle", { "gate": 10 })
	_drive(battle)
	t.check(result.visible and result.title_label.text == Loc.t("result.defeat", "Derrota"),
		"resultado mostra derrota")
	t.check(result.result_portrait.texture != null, "resultado de derrota mostra retrato inimigo")
	t.check(result.rewards_label.text == Loc.t("result.no_reward"), "derrota explica que não há recompensa")
	t.check(GameState.gold == 100 and GameState.highest_gate_cleared == 0,
		"derrota não concede recursos nem progressão")
	t.check(not result.unlock_label.visible, "derrota não anuncia desbloqueios")
	t.check(result.retry_button.visible, "derrota oferece tentar novamente")

	result._on_retry()
	t.check(gate_prep.visible and not result.visible, "tentar novamente volta à preparação")
	nav.close_overlay("gate_prep")

	# 3) Sair durante a batalha não concede recompensa (spec §5.4)
	nav.show_overlay("battle", { "gate": 1 })
	battle._on_exit()
	t.check(not battle.visible, "sair fecha o combate")
	t.check(GameState.gold == 100 and GameState.highest_gate_cleared == 0,
		"sair concede a batalha sem recompensa")

	# 4) Pausa e velocidade são só apresentação (spec §4/§10.5)
	nav.show_overlay("battle", { "gate": 1 })
	battle._on_pause()
	t.check(battle._paused and battle.pause_button.text == Loc.t("battle.resume"),
		"pausa congela o combate e muda o texto do botão")
	battle._on_pause()
	t.check(not battle._paused and battle.pause_button.text == Loc.t("battle.pause"),
		"retomar reativa o combate")
	battle._on_speed()
	t.check(battle._speed == 2 and battle.speed_button.text == "x2", "x2 altera a velocidade de apresentação")
	battle._on_speed()
	t.check(battle._speed == 1 and battle.speed_button.text == "x1", "volta a x1")
	battle._on_exit()

	main.free()
	GameState.from_dict(original)
	GameState.save_now()


## O _process não corre durante os testes; avançamos a batalha manualmente.
static func _drive(battle) -> void:
	var safety := 0
	while not battle._finished and safety < 2000:
		safety += 1
		battle._advance()


static func _set_state(highest: int, gold: int) -> void:
	GameState.from_dict({
		"schema_version": 1,
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
	})
