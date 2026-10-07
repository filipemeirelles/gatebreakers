class_name NavigationTests
extends RefCounted
## Testes de navegação (critério: "navegação não duplica telas" — spec §9 Fase 1).


static func run(t: Node) -> void:
	print("-- Navegação --")
	var main: Node = load("res://scenes/app/main.tscn").instantiate()
	t.add_child(main)

	var screens: Node = main.get_node("Screens")
	var overlays: Node = main.get_node("Overlays")
	var nav := main as NavigationController

	t.check(screens.get_child_count() == 4, "4 telas filhas criadas")
	t.check(overlays.get_child_count() == 5, "5 overlays criados")

	for destination in NavigationController.Destination.values():
		nav.goto_destination(destination)
		var visible_count := 0
		var visible_name := ""
		for child in screens.get_children():
			if child.visible:
				visible_count += 1
				visible_name = String(child.name)
		var expected: String = NavigationController.SCREEN_NAMES[destination]
		t.check(visible_count == 1, "destino %s: exatamente 1 tela visível" % expected)
		t.check(visible_name == expected, "destino %s mostra a tela certa (veio %s)" % [expected, visible_name])

	nav.goto_destination(NavigationController.Destination.PORTALS)
	nav.goto_destination(NavigationController.Destination.PORTALS)
	t.check(screens.get_child_count() == 4, "repetir destino não duplica telas")

	nav.show_overlay("gate_prep")
	t.check(overlays.get_node("GatePrep").visible, "overlay gate_prep abre")
	nav.close_overlay("gate_prep")
	t.check(not overlays.get_node("GatePrep").visible, "overlay gate_prep fecha")

	nav.show_overlay("battle")
	t.check(overlays.get_node("Battle").visible, "overlay battle abre")
	nav.close_all_overlays()
	t.check(not overlays.get_node("Battle").visible, "close_all_overlays fecha tudo")

	main.free()
