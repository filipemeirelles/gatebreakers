class_name StoreTests
extends RefCounted
## Testes da Loja do Sistema (E5).
## `t` é o runner: precisa do método check(cond, name).


static func run(t: Node) -> void:
	print("-- Loja do Sistema --")
	var original := GameState.to_dict()

	_test_store_insufficient_gold(t)
	_test_store_sweep_purchase(t)
	_test_store_essence_purchase(t)
	_test_store_xp_purchase(t)

	GameState.from_dict(original)
	GameState.save_now()


static func _test_store_insufficient_gold(t: Node) -> void:
	GameState.reset_to_new_game()
	GameState.gold = 50
	var res := GameState.buy_store_item("sweep")
	t.check(not bool(res["ok"]) and str(res["reason"]) == "gold", "ouro insuficiente recusa compra")

	GameState.gold = 200
	GameState.highest_gate_cleared = 0
	var no_gates := GameState.buy_store_item("sweep")
	t.check(not bool(no_gates["ok"]) and str(no_gates["reason"]) == "no_gates",
		"compra de varredura sem portais concluídos é recusada")


static func _test_store_sweep_purchase(t: Node) -> void:
	GameState.reset_to_new_game()
	GameState.gold = 500
	GameState.highest_gate_cleared = 2
	var prev_charges := int(GameState.sweep_charges.get("2", 0))

	var res := GameState.buy_store_item("sweep")
	t.check(bool(res["ok"]), "compra de varredura tem sucesso")
	t.check(GameState.gold == 300, "200 de ouro descontados")
	t.check(int(GameState.sweep_charges.get("2", 0)) == prev_charges + 3, "+3 cargas adicionadas ao portal mais alto")


static func _test_store_essence_purchase(t: Node) -> void:
	GameState.reset_to_new_game()
	GameState.gold = 1000
	var prev_ess := GameState.shadow_essence

	var res := GameState.buy_store_item("essence")
	t.check(bool(res["ok"]), "compra de essência tem sucesso")
	t.check(GameState.gold == 500, "500 de ouro descontados")
	t.check(GameState.shadow_essence == prev_ess + 10, "+10 essências de sombra adicionadas")


static func _test_store_xp_purchase(t: Node) -> void:
	GameState.reset_to_new_game()
	GameState.gold = 600
	var prev_xp := GameState.hunter_xp

	var res := GameState.buy_store_item("xp")
	t.check(bool(res["ok"]), "compra de XP tem sucesso")
	t.check(GameState.gold == 300, "300 de ouro descontados")
	t.check(GameState.hunter_xp == prev_xp + 300, "+300 hunter_xp adicionados")
