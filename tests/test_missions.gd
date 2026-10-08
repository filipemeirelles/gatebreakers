class_name MissionTests
extends RefCounted
## Testes das Missões do Sistema e Galeria de Lore (E3).
## `t` é o runner: precisa do método check(cond, name).


static func run(t: Node) -> void:
	print("-- Missões do Sistema e Lore --")
	var original := GameState.to_dict()

	_test_definitions(t)
	_test_tracking_and_progress(t)
	_test_claim_and_rewards(t)
	_test_missions_red_dot(t)
	_test_action_triggers(t)
	_test_story_archive(t)

	GameState.from_dict(original)
	GameState.save_now()


static func _test_definitions(t: Node) -> void:
	var list := ContentDB.daily_missions()
	t.check(list.size() >= 4, "pelo menos 4 missões diárias configuradas")

	var m_battles := ContentDB.mission("daily_battles")
	t.check(not m_battles.is_empty(), "missão de batalhas encontrada")
	t.check(int(m_battles.get("target", 0)) == 3, "meta de 3 batalhas")
	t.check(int(m_battles.get("reward_gold", 0)) > 0, "recompensa de ouro configurada")
	t.check(int(m_battles.get("reward_sweep_charges", 0)) > 0, "recompensa de varreduras configurada")


static func _test_tracking_and_progress(t: Node) -> void:
	GameState.reset_to_new_game()
	var st := GameState.get_mission_status("daily_battles")
	t.check(int(st.get("progress", -1)) == 0, "progresso começa zerado")
	t.check(not bool(st.get("can_claim", true)), "não pode resgatar antes de completar")

	GameState.track_mission_event("battle_won", 1)
	st = GameState.get_mission_status("daily_battles")
	t.check(int(st["progress"]) == 1, "evento battle_won avança progresso para 1")

	GameState.track_mission_event("battle_won", 2)
	st = GameState.get_mission_status("daily_battles")
	t.check(int(st["progress"]) == 3, "evento battle_won avança para a meta (3)")
	t.check(bool(st["can_claim"]), "missão pronta para resgate na meta")

	# Avançar além do teto não ultrapassa o target
	GameState.track_mission_event("battle_won", 5)
	st = GameState.get_mission_status("daily_battles")
	t.check(int(st["progress"]) == 3, "progresso limitado à meta")


static func _test_claim_and_rewards(t: Node) -> void:
	GameState.reset_to_new_game()
	GameState.highest_gate_cleared = 1
	var initial_gold := GameState.gold
	var initial_xp := GameState.hunter_xp
	var initial_charges := int(GameState.sweep_charges.get("1", 0))

	# Completar a missão
	GameState.track_mission_event("battle_won", 3)
	var claim_res := GameState.claim_mission("daily_battles")
	t.check(bool(claim_res["ok"]), "resgate da missão tem sucesso")
	t.check(GameState.gold == initial_gold + int(claim_res["gold"]), "ouro da recompensa creditado")
	t.check(GameState.hunter_xp == initial_xp + int(claim_res["xp"]), "XP da recompensa creditado")
	t.check(int(GameState.sweep_charges.get("1", 0)) == initial_charges + int(claim_res["sweep_charges"]),
		"cargas de varredura creditadas")

	var st := GameState.get_mission_status("daily_battles")
	t.check(bool(st["claimed"]), "status marcado como resgatado")
	t.check(not bool(st["can_claim"]), "não pode resgatar novamente")

	# Tentativa de segundo resgate
	var repeat := GameState.claim_mission("daily_battles")
	t.check(not bool(repeat["ok"]), "segundo resgate recusado")


static func _test_missions_red_dot(t: Node) -> void:
	GameState.reset_to_new_game()
	t.check(not GameState.red_dots()["missions"], "sem missões prontas: sem red dot")

	GameState.track_mission_event("battle_won", 3)
	t.check(GameState.red_dots()["missions"], "missão pronta para resgate: red dot ativo")

	GameState.claim_mission("daily_battles")
	t.check(not GameState.red_dots()["missions"], "missão resgatada: red dot limpo")


static func _test_action_triggers(t: Node) -> void:
	GameState.reset_to_new_game()

	# Vitória em portal dispara battle_won automaticamente
	GameState.apply_battle_victory(1)
	var st_battle := GameState.get_mission_status("daily_battles")
	t.check(int(st_battle["progress"]) == 1, "apply_battle_victory avança missão de batalhas")

	# Subir nível de Jinwoo dispara upgrade_performed automaticamente
	GameState.hunter_xp = 500
	GameState.gold = 500
	GameState.upgrade_hunter()
	var st_up := GameState.get_mission_status("daily_upgrade")
	t.check(int(st_up["progress"]) == 1, "upgrade_hunter avança missão de fortalecimento")


static func _test_story_archive(t: Node) -> void:
	GameState.reset_to_new_game()
	t.check(GameState.story_cards_seen.is_empty(), "sem cartões vistos no início")

	# Abertura do jogo marca o system_intro como visto
	var card1: String = GameState.pop_pending_story()
	t.check(card1 == "system_intro", "system_intro desempilhado no arranque")
	t.check(GameState.story_cards_seen.has("system_intro"), "system_intro marcado como visto")

	# Cartão de conclusão do portal 1
	GameState.apply_battle_victory(1)
	var card2: String = GameState.pop_pending_story()
	t.check(card2 == "first_advance", "primeiro avanço disponível")
	t.check(GameState.story_cards_seen.has("first_advance"), "first_advance adicionado à galeria de vistos")
