class_name IdleRewardTests
extends RefCounted
## Testes das recompensas AFK (spec §4 Recompensas AFK, §9 Fase 3 e
## critérios §10.7–10.10): zero tempo, duas horas, teto de oito horas,
## relógio retrocedido, reinício após crédito, relatório completo.
## `t` é o runner: precisa do método check(cond, name).


static func run(t: Node) -> void:
	print("-- Recompensas AFK --")
	var original := GameState.to_dict()

	_test_compute_elapsed(t)
	_test_two_hours(t)
	_test_cap(t)
	_test_clock_rollback(t)
	_test_double_credit(t)
	_test_first_start(t)
	_test_no_essence(t)
	_test_report_screen(t)

	# Repor o estado do jogador
	GameState.from_dict(original)
	GameState.save_now()


# --- Cálculo puro ---

static func _test_compute_elapsed(t: Node) -> void:
	var cap := BalanceConfig.afk_cap_seconds()
	t.check(IdleRewardService.compute_elapsed(1000, 1000, cap) == 0, "zero tempo → 0 segundos")
	t.check(IdleRewardService.compute_elapsed(1000, 5000, cap) == 0, "relógio retrocedido → 0 segundos")
	t.check(IdleRewardService.compute_elapsed(100000, 0, cap) == 0, "primeiro início (last ausente) → 0 segundos")
	t.check(IdleRewardService.compute_elapsed(100000, 92800, cap) == 7200, "duas horas contam 7200 s")
	t.check(IdleRewardService.compute_elapsed(100000, 60000, cap) == cap, "9 h contam só o teto de 8 h")


static func _test_two_hours(t: Node) -> void:
	var report := IdleRewardService.build_report(100000, 92800, 1)
	t.check(int(report["elapsed"]) == 7200, "relatório de 2 h contabiliza 7200 s")
	t.check(not bool(report["capped"]), "2 h não atinge o limite")
	var expected_gold := int(floor(float(BalanceConfig.afk_gold_per_hour(1)) * 7200.0 / 3600.0))
	var expected_xp := int(floor(float(BalanceConfig.afk_xp_per_hour(1)) * 7200.0 / 3600.0))
	t.check(int(report["gold"]) == expected_gold and int(report["xp"]) == expected_xp,
		"2 h concedem a recompensa calculada pela taxa do portal")
	t.check(int(report["gate"]) == 1 and int(report["gold_per_hour"]) == BalanceConfig.afk_gold_per_hour(1),
		"relatório indica o portal e a taxa utilizados (§10.9)")


static func _test_cap(t: Node) -> void:
	var cap := BalanceConfig.afk_cap_seconds()
	# 9 horas de ausência (now - last = 32400)
	var report := IdleRewardService.build_report(100000, 100000 - 32400, 2)
	t.check(int(report["elapsed"]) == cap, "ausência acima do teto fica limitada a 8 h (§10.7)")
	t.check(bool(report["capped"]), "relatório sinaliza o limite aplicado")
	var expected_gold := int(floor(float(BalanceConfig.afk_gold_per_hour(2)) * cap / 3600.0))
	t.check(int(report["gold"]) == expected_gold, "recompensa calculada sobre o teto, não sobre 9 h")


# --- Integração no GameState ---

static func _test_clock_rollback(t: Node) -> void:
	_set_afk(1, 100, 500000)
	var report := GameState.apply_afk_rewards(400000)  # relógio 100000 s atrás
	t.check(report.is_empty(), "relógio retrocedido não concede recompensa (§10.10)")
	t.check(GameState.gold == 100, "relógio retrocedido não altera recursos")
	t.check(GameState.hunter_xp == 0, "relógio retrocedido não gera XP negativo nem extra")
	t.check(GameState.last_background_unix == 400000, "horário guardado recupera para o horário atual")
	# Nova chamada ainda no passado continua a dar zero
	t.check(GameState.apply_afk_rewards(300000).is_empty(), "repetição no passado continua a dar zero")


static func _test_double_credit(t: Node) -> void:
	_set_afk(1, 100, 500000)
	var report := GameState.apply_afk_rewards(507200)  # 2 h depois
	t.check(not report.is_empty(), "ausência de 2 h credita recompensa ao abrir")
	t.check(GameState.gold == 120, "recompensa de 2 h creditada uma única vez (§10.7)")
	# Reabrir imediatamente (sem tempo adicional) não duplica (§10.8)
	t.check(GameState.apply_afk_rewards(507200).is_empty(), "reabrir sem tempo adicional não duplica")
	t.check(GameState.gold == 120, "segunda abertura não altera o ouro")
	# Reabrir com segundos extra não chega para nova recompensa (floor → 0)
	t.check(GameState.apply_afk_rewards(507260).is_empty(), "segundos extra não geram recompensa extra")
	t.check(GameState.gold == 120, "ouro intacto após reaberturas repetidas")


static func _test_first_start(t: Node) -> void:
	_set_afk(1, 100, 0)  # last_background ausente
	var report := GameState.apply_afk_rewards(900000)
	t.check(report.is_empty(), "primeiro início não concede recompensa retroativa")
	t.check(GameState.gold == 100, "primeiro início não altera recursos")
	t.check(GameState.last_background_unix == 900000, "primeiro início inicializa o horário atual")


static func _test_no_essence(t: Node) -> void:
	_set_afk(5, 100, 500000)
	GameState.shadow_essence = 10
	var report := GameState.apply_afk_rewards(507200)
	t.check(not report.is_empty(), "ausência de 2 h no portal 5 credita recompensa")
	t.check(int(report["gold"]) == BalanceConfig.afk_gold_per_hour(5) * 2, "taxa do portal 5 × 2 h em ouro")
	t.check(GameState.shadow_essence == 10, "essência nunca é concedida AFK (§4)")
	var persisted := SaveService.load_state()
	t.check(int(persisted["state"]["gold"]) == GameState.gold, "crédito AFK grava o save de imediato")


# --- Relatório visual (§5.2, §10.9) ---

static func _test_report_screen(t: Node) -> void:
	GameState.pending_afk_report = {
		"elapsed": 7200, "raw_elapsed": 7200, "capped": false,
		"gold": 20, "xp": 10, "gate": 1,
		"gold_per_hour": 10, "xp_per_hour": 5,
	}
	var main: Node = load("res://scenes/app/main.tscn").instantiate()
	t.add_child(main)
	var afk = main.get_node("Overlays/AfkReport")
	t.check(afk.visible, "relatório AFK abre no arranque quando há recompensa")
	t.check(afk.time_label.text.contains("2h"), "relatório mostra o tempo contado")
	t.check(afk.rewards_label.text == Loc.t("afk.gained")
		and afk.gold_amount.text == "+20 %s" % Loc.t("ui.gold")
		and afk.xp_amount.text == "+10 %s" % Loc.t("ui.xp"),
		"relatório mostra quantidades junto aos ícones de recurso")
	t.check(afk.get_node("Margin/VBox/RewardsStrip/GoldReward/GoldIcon").texture != null
		and afk.get_node("Margin/VBox/RewardsStrip/XpReward/XpIcon").texture != null,
		"relatório carrega ícones de ouro e XP")
	t.check(afk.rate_label.text == (Loc.t("afk.rate") % [1, 10, Loc.t("ui.gold"), 5, Loc.t("ui.xp")]),
		"relatório mostra portal e taxa")
	t.check(GameState.pending_afk_report.is_empty(), "relatório pendente é consumido ao abrir")

	# Limite aplicado aparece no ecrã (critério §10.9)
	afk.configure({
		"elapsed": 28800, "raw_elapsed": 32400, "capped": true,
		"gold": 80, "xp": 40, "gate": 1,
		"gold_per_hour": 10, "xp_per_hour": 5,
	})
	var cap_hours := int(BalanceConfig.afk_cap_seconds() / 3600)
	t.check(afk.time_label.text.contains(Loc.t("afk.capped") % cap_hours),
		"relatório indica o limite aplicado")

	afk._on_continue()
	t.check(not afk.visible, "continuar fecha o relatório")
	main.free()


# --- Auxiliares ---

static func _set_afk(highest: int, gold: int, last_background: int) -> void:
	GameState.from_dict({
		"schema_version": 1,
		"hunter_xp": 0,
		"gold": gold,
		"shadow_essence": 0,
		"highest_gate_cleared": highest,
		"last_background_unix": last_background,
		"roster": {
			"jinwoo": { "level": 1, "unlocked": true },
			"shadow_soldier": { "level": 1, "unlocked": true },
		},
		"formation": ["jinwoo", "shadow_soldier"],
	})
