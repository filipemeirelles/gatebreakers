class_name Fase5Tests
extends RefCounted
## Testes da Fase 5 (spec §9 Fase 5, §4 cartões narrativos, §5.8 e §10.15):
## cartões narrativos (gatilhos, fila, persistência), preferências locais,
## reset local e o overlay de cartões na navegação.
## `t` é o runner: precisa do método check(cond, name).


static func run(t: Node) -> void:
	print("-- Fase 5: cartões, preferências e reset --")
	var original := GameState.to_dict()
	var sound0 := SettingsService.sound_enabled()
	var vibration0 := SettingsService.vibration_enabled()

	_test_story_content(t)
	_test_story_queue_and_save(t)
	_test_story_navigation(t)
	_test_settings_service(t)
	_test_reset(t)

	# Repor o estado do jogador e as preferências
	GameState.from_dict(original)
	GameState.save_now()
	SettingsService.set_sound_enabled(sound0)
	SettingsService.set_vibration_enabled(vibration0)
	SettingsService.reload()


# --- Conteúdo dos cartões (dados editáveis) ---

static func _test_story_content(t: Node) -> void:
	var cards: Array = ContentDB.story_cards()
	t.check(cards.size() == 3, "três cartões narrativos (spec §4)")
	var ids: Dictionary = {}
	for card in cards:
		ids[String(card.get("id", ""))] = true
		t.check(not String(card.get("title", "")).is_empty()
			and not String(card.get("text", "")).is_empty(),
			"cartão %s tem título e texto" % String(card.get("id", "?")))
	t.check(ids.size() == 3, "ids dos cartões únicos")
	t.check(not ContentDB.story_card("system_intro").is_empty(),
		"story_card encontra a introdução pelo id")
	t.check(ContentDB.story_card("inexistente").is_empty(),
		"id desconhecido devolve dicionário vazio")


# --- Fila, gatilhos e persistência ---

static func _test_story_queue_and_save(t: Node) -> void:
	GameState.reset_to_new_game()
	t.check(GameState.pending_story_cards == ["system_intro"],
		"novo jogo enfileira a introdução no arranque")

	var popped := GameState.pop_pending_story()
	t.check(popped == "system_intro", "primeiro pop devolve a introdução")
	t.check(GameState.story_cards_seen.has("system_intro"),
		"mostrar o cartão marca-o como visto")
	t.check(GameState.pop_pending_story() == "", "fila vazia depois de consumir")

	var loaded := SaveService.load_state()
	t.check(loaded["status"] == "loaded", "save carrega após marcar cartão")
	t.check((loaded["state"]["story_cards_seen"] as Array).has("system_intro"),
		"cartões vistos persistem no save")

	# Reconstrução da fila a partir do progresso (arranque com save antigo)
	GameState.reset_to_new_game()
	GameState.story_cards_seen = ["system_intro"]
	GameState.highest_gate_cleared = 4
	GameState.rebuild_story_queue()
	t.check(GameState.pending_story_cards == ["first_advance", "shadow_troop"],
		"arranque reconstrói a fila pelo progresso (portais 1 e 4)")

	# Gatilhos em clear_gate
	GameState.reset_to_new_game()
	GameState.clear_gate(1)
	t.check(GameState.pending_story_cards.has("first_advance"),
		"vencer o portal 1 enfileira o primeiro avanço")
	GameState.clear_gate(2)
	GameState.clear_gate(3)
	t.check(not GameState.pending_story_cards.has("shadow_troop"),
		"Kasaka não antecipa o cartão de aquisição de Igris")
	GameState.clear_gate(4)
	t.check(GameState.pending_story_cards.has("shadow_troop"),
		"vencer a Provação de Mudança de Classe enfileira o cartão de Igris")

	# Save legado sem o campo migra para lista vazia
	var legacy := GameState.to_dict()
	legacy.erase("story_cards_seen")
	SaveService.save_state(legacy)
	var res := SaveService.load_state()
	t.check(res["status"] == "loaded" and (res["state"]["story_cards_seen"] as Array).is_empty(),
		"save sem story_cards_seen migra para lista vazia")


# --- Overlay de cartões na navegação (inclui toque duplo) ---

static func _test_story_navigation(t: Node) -> void:
	GameState.pending_afk_report = {}
	GameState.reset_to_new_game()
	GameState.highest_gate_cleared = 1
	GameState.rebuild_story_queue()

	var main: Node = load("res://scenes/app/main.tscn").instantiate()
	t.add_child(main)
	var nav := main as NavigationController
	var story: Node = nav.get_node("Overlays/StoryCard")

	t.check(story.visible, "cartão abre no arranque quando há pendência")
	t.check(story.get_node("Margin/VBox/StoryImage").texture != null,
		"cartão narrativo mostra sua ilustração aprovada")
	t.check(GameState.story_cards_seen.has("system_intro"),
		"mostrar na navegação marca o cartão como visto")
	t.check(GameState.pending_story_cards == ["first_advance"],
		"só o cartão seguinte continua na fila")

	var continue_button: Button = story.get_node("Margin/VBox/ContinueButton")
	continue_button.pressed.emit()
	t.check(story.visible, "continuar avança para o cartão seguinte")
	t.check(str(story.get_node("Margin/VBox/TitleLabel").text) == "Primeiro portal concluído",
		"segundo cartão mostra o conteúdo certo")

	continue_button.pressed.emit()
	t.check(story.visible and GameState.pending_story_cards.is_empty(),
		"toque duplo não fecha nem salta o cartão seguinte")

	nav.close_and_check_story("story_card")
	t.check(not story.visible, "fechar com a fila vazia só fecha o cartão")

	main.free()


# --- Preferências locais (spec §5.8) ---

static func _test_settings_service(t: Node) -> void:
	SettingsService.set_sound_enabled(true)
	SettingsService.set_vibration_enabled(true)
	SettingsService.reload()
	t.check(SettingsService.sound_enabled() and SettingsService.vibration_enabled(),
		"preferências começam ativadas")

	SettingsService.set_sound_enabled(false)
	SettingsService.reload()
	t.check(not SettingsService.sound_enabled(), "preferência de som guardada")
	SettingsService.set_sound_enabled(true)
	SettingsService.reload()
	t.check(SettingsService.sound_enabled(), "preferência de som reativada")

	SettingsService.set_vibration_enabled(false)
	SettingsService.reload()
	t.check(not SettingsService.vibration_enabled(), "preferência de vibração guardada")
	SettingsService.set_vibration_enabled(true)
	SettingsService.reload()
	t.check(SettingsService.vibration_enabled(), "preferência de vibração reativada")


# --- Reset local (spec §5.8) ---

static func _test_reset(t: Node) -> void:
	GameState.highest_gate_cleared = 3
	GameState.gold = 999
	GameState.story_cards_seen = ["first_advance"]
	GameState.save_now()

	SaveService.delete_save()
	GameState.reset_to_new_game()
	GameState.save_now()

	t.check(GameState.highest_gate_cleared == 0 and GameState.gold == BalanceConfig.starting_gold(),
		"reset devolve o estado inicial")
	t.check(GameState.story_cards_seen.is_empty(), "reset limpa os cartões vistos")
	t.check(FileAccess.file_exists(SaveService.SAVE_PATH), "save recriado após o reset")
	var state := SaveService.load_state()
	t.check(state["status"] == "loaded"
		and int(state["state"]["highest_gate_cleared"]) == 0
		and (state["state"]["story_cards_seen"] as Array).is_empty(),
		"save pós-reset é válido, sem progresso e sem cartões vistos")
