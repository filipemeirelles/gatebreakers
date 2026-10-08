class_name NavigationTests
extends RefCounted
## Testes de navegação (critério: "navegação não duplica telas" — spec §9 Fase 1).


static func run(t: Node) -> void:
	print("-- Navegação --")
	var original := GameState.to_dict()
	var main: Node = load("res://scenes/app/main.tscn").instantiate()
	t.add_child(main)

	var screens: Node = main.get_node("Screens")
	var overlays: Node = main.get_node("Overlays")
	var nav := main as NavigationController
	var hero_portrait: TextureRect = screens.get_node("Hunter/Margin/VBox/HeroSection/HeroPortrait")
	t.check(hero_portrait.texture != null, "tela do Caçador mostra arte de Jinwoo")
	var shadow_list: VBoxContainer = screens.get_node("Shadows/Margin/VBox/Scroll/UnitList")
	var shadow_portrait: TextureRect = shadow_list.get_child(0).get_node("Content/Portrait")
	t.check(shadow_portrait.texture != null, "tela de Sombras mostra retrato da unidade")
	var portal_icon: TextureRect = screens.get_node("Portals/Margin/VBox/StatsRow/GoldStat/GoldIcon")
	t.check(portal_icon.texture != null, "mapa de portais mostra ícone de recurso")
	t.check(screens.get_node("Portals/Margin/VBox/AfkChestPanel/AfkChestRow/ChestIcon").texture != null,
		"baú AFK mostra ilustração do Sistema")
	var hunter_badge: Label = main.get_node("BottomBar/HuntersButton/RedDot")
	GameState.hunter_xp = 100
	GameState.gold = 100
	GameState.state_changed.emit()
	t.check(hunter_badge.visible, "red dot central sinaliza melhoria do Caçador pronta")
	GameState.hunter_xp = 0
	GameState.gold = 100
	GameState.afk_chests_available = 1
	GameState.state_changed.emit()
	t.check(main.get_node("BottomBar/MapButton/RedDot").visible,
		"red dot central sinaliza baú AFK pronto")
	GameState.afk_chests_available = 0
	GameState.gold = 25
	GameState.shadow_essence = 5
	GameState.state_changed.emit()
	t.check(NavigationController.Destination.size() == 7, "destinos: mapa, caçadores, invocações, história, itens, missões, config")

	t.check(screens.get_child_count() == 7, "7 telas filhas criadas")
	t.check(overlays.get_child_count() == 7, "7 overlays criados")

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

	nav.goto_destination(NavigationController.Destination.MAP)
	nav.goto_destination(NavigationController.Destination.MAP)
	t.check(screens.get_child_count() == 7, "repetir destino não duplica telas")

	# Estado explícito: o save real do usuário não pode ditar a asserção.
	GameState.from_dict({
		"schema_version": 2,
		"hunter_level": 1,
		"hunter_xp": 0,
		"gold": 100,
		"shadow_essence": 0,
		"highest_gate_cleared": 0,
		"last_background_unix": 0,
		"roster": {
			"jinwoo": { "level": 1, "unlocked": true },
			"shadow_soldier": { "level": 1, "unlocked": true },
		},
		"formation": ["jinwoo", "shadow_soldier"],
	})
	nav.show_overlay("gate_prep")
	t.check(overlays.get_node("GatePrep").visible, "overlay gate_prep abre")
	var prep_enemy: TextureRect = overlays.get_node("GatePrep/Margin/VBox/PreviewRow/EnemyPortrait")
	t.check(prep_enemy.texture != null, "preparação mostra arte do inimigo")
	t.check(String(overlays.get_node("GatePrep/Margin/VBox/GateLabel").text).contains("Masmorra dos Goblins")
		and String(overlays.get_node("GatePrep/Margin/VBox/EnemiesLabel").text).contains("Goblin da Masmorra"),
		"preparação apresenta portal e inimigo pelo nome")
	t.check(overlays.get_node("GatePrep/Margin/VBox/PreviewRow/TeamPreview").get_child_count() == 2,
		"preparação mostra retratos da formação")
	nav.close_overlay("gate_prep")
	t.check(not overlays.get_node("GatePrep").visible, "overlay gate_prep fecha")

	# Guardrail de poder: pedir confirmação antes de entrar num portal perigoso.
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
	nav.show_overlay("gate_prep")
	var prep = overlays.get_node("GatePrep")
	t.check(prep.power_warning.visible, "portal perigoso mostra aviso de poder")
	t.check(String(prep.get_node("Margin/VBox/GateLabel").text).contains("Invasão de Antares")
		and String(prep.get_node("Margin/VBox/BossLabel").text).contains("Antares"),
		"preparação final identifica o portal e o chefe Antares")
	prep._on_start()
	t.check(not overlays.get_node("Battle").visible and prep._risk_confirmation_pending,
		"primeiro toque pede confirmação explícita do risco")
	prep._on_start()
	t.check(overlays.get_node("Battle").visible, "segundo toque confirma e inicia o combate")
	overlays.get_node("Battle")._on_exit()
	nav.close_overlay("gate_prep")

	nav.show_overlay("battle")
	t.check(overlays.get_node("Battle").visible, "overlay battle abre")
	nav.show_overlay("profile")
	t.check(overlays.get_node("ProfileOverlay").visible, "overlay profile abre")
	nav.close_overlay("profile")
	t.check(not overlays.get_node("ProfileOverlay").visible, "overlay profile fecha")
	nav.show_overlay("store")
	t.check(overlays.get_node("StoreOverlay").visible, "overlay store abre")
	nav.close_overlay("store")
	t.check(not overlays.get_node("StoreOverlay").visible, "overlay store fecha")
	nav.close_all_overlays()
	t.check(not overlays.get_node("Battle").visible, "close_all_overlays fecha tudo")

	main.free()
	GameState.from_dict(original)
	GameState.save_now()
