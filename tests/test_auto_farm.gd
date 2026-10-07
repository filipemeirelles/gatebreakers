class_name AutoFarmTests
extends RefCounted
## Regressões do ciclo de auto-limpeza online do PML.


static func run(t: Node) -> void:
	print("-- Auto-limpeza online --")
	var original := GameState.to_dict()
	GameState.reset_to_new_game()
	var main: Node = load("res://scenes/app/main.tscn").instantiate()
	t.add_child(main)
	var controller: Node = main.get_node("AutoFarmController")
	var portal_map = main.get_node("Screens/Portals")
	var auto_status: Label = portal_map.get_node("Margin/VBox/AutoFarmPanel/AutoFarmRow/AutoFarmStatus")
	var result = main.get_node("Overlays/BattleResult")

	portal_map.call("_on_auto_farm_toggled", true)
	t.check(bool(controller.get("is_running")), "botão Portais inicia a auto-limpeza")
	var first_cycle: Dictionary = controller.call("run_one_battle")
	t.check(bool(first_cycle.get("victory", false)) and GameState.highest_gate_cleared == 1,
		"vitória automática concede recompensa e avança o portal")
	t.check(int(controller.get("victories")) == 1 and bool(controller.get("is_running")),
		"vitória mantém o farm ativo para o próximo portal")
	t.check(auto_status.text.contains("Portal 2"),
		"status mostra o próximo portal em farm")

	controller.call("set_running", false)
	GameState.from_dict({
		"schema_version": 1,
		"hunter_level": 1,
		"hunter_xp": 0,
		"gold": 100,
		"shadow_essence": 0,
		"highest_gate_cleared": 9,
		"last_background_unix": 0,
		"roster": {
			"jinwoo": { "level": 1, "unlocked": true },
			"shadow_soldier": { "level": 1, "unlocked": true },
		},
		"formation": ["jinwoo", "shadow_soldier"],
	})
	controller.call("set_running", true)
	var gold_before := GameState.gold
	var final_cycle: Dictionary = controller.call("run_one_battle")
	t.check(not bool(final_cycle.get("victory", true)) and not bool(controller.get("is_running")),
		"derrota interrompe a auto-limpeza")
	t.check(GameState.gold == gold_before and GameState.highest_gate_cleared == 9,
		"derrota automática não concede recompensa nem progressão")
	t.check(result.visible and result.title_label.text == Loc.t("result.defeat"),
		"derrota automática abre a tela de resultado")
	main.get_node("Overlays/BattleResult").visible = false

	controller.call("set_running", true)
	controller.call("stop_for_background")
	t.check(not bool(controller.get("is_running"))
		and String(controller.get("status_text")) == Loc.t("portal.auto_farm_paused"),
		"envio do app ao segundo plano interrompe o farm")

	main.free()
	GameState.from_dict(original)
	GameState.save_now()
