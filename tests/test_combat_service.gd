class_name CombatServiceTests
extends RefCounted
## Testes do combate determinístico e da progressão de portais
## (spec §9 Fase 2, §4 Combate/Varredura, §10.3–10.5 e §10.11).
## `t` é o runner: precisa do método check(cond, name).


static func run(t: Node) -> void:
	print("-- Combate e progressão --")
	var original := GameState.to_dict()

	_test_gate_definition(t)
	_test_victory(t)
	_test_defeat(t)
	_test_speed_ties(t)
	_test_targeting(t)
	_test_damage(t)
	_test_determinism(t)
	_test_hp_between_waves(t)
	_test_victory_rewards(t)
	_test_progression(t)
	_test_sweep(t)

	# Repor o estado do jogador
	GameState.from_dict(original)
	GameState.save_now()


# --- Definição do portal ---

static func _test_gate_definition(t: Node) -> void:
	var gate1 := ContentDB.gate(1)
	t.check((gate1["waves"] as Array).size() == 3, "cada portal tem três ondas")
	t.check(int(gate1["total_enemies"]) == 6, "ondas comuns têm 2 inimigos (3 × 2)")
	var enemy: Dictionary = (gate1["waves"] as Array)[0][0]
	var expected := BalanceConfig.common_enemy_stats(1)
	t.check(int(enemy["hp"]) == int(expected["hp"]) and int(enemy["attack"]) == int(expected["attack"]),
		"atributos do inimigo vêm do BalanceConfig (portal 1)")
	var gate5 := ContentDB.gate(5)
	var last_wave: Array = (gate5["waves"] as Array)[2]
	t.check(last_wave.size() == 1 and String(last_wave[0]["role"]) == "boss",
		"última onda do portal 5 é um chefe único")


# --- Vitória e derrota ---

static func _test_victory(t: Node) -> void:
	var gate_def := ContentDB.gate(1)
	var state := CombatService.start_battle(_team(), gate_def)
	CombatService.run_to_completion(state)
	t.check(String(state["phase"]) == "victory", "equipa inicial vence o portal 1")
	t.check(int(state["wave_index"]) == 2, "vitória atravessa as três ondas")
	t.check(int(state["defeated_enemies"]) == int(gate_def["total_enemies"]),
		"vitória derrota todos os inimigos do portal")


static func _test_defeat(t: Node) -> void:
	var weak := [
		_unit("a1", 5, 1, 0, 10),
		_unit("a2", 5, 1, 0, 9),
	]
	var state := CombatService.start_battle(weak, ContentDB.gate(1))
	CombatService.run_to_completion(state)
	t.check(String(state["phase"]) == "defeat", "equipa fraca é derrotada no portal 1")


# --- Empates de velocidade (spec §4) ---

static func _test_speed_ties(t: Node) -> void:
	var s1 := CombatService.start_battle(
		[_unit("tie_ally", 50, 5, 0, 8)],
		{ "gate": 1, "waves": [[_unit("tie_enemy", 50, 5, 0, 8)]] }
	)
	var ev1 := CombatService.step(s1)
	t.check(String(ev1["attacker"]["id"]) == "tie_ally",
		"empate de velocidade: aliado age antes do inimigo")

	var s2 := CombatService.start_battle(
		[_unit("first", 50, 5, 0, 8), _unit("second", 50, 5, 0, 8)],
		{ "gate": 1, "waves": [[_unit("e", 50, 5, 0, 8)]] }
	)
	var ev2 := CombatService.step(s2)
	t.check(String(ev2["attacker"]["id"]) == "first",
		"empate entre aliados segue a ordem da formação")

	var s3 := CombatService.start_battle(
		[_unit("slow_ally", 50, 5, 0, 1)],
		{ "gate": 1, "waves": [[_unit("enemy_a", 50, 5, 0, 8), _unit("enemy_b", 50, 5, 0, 8)]] }
	)
	var ev3 := CombatService.step(s3)
	t.check(String(ev3["attacker"]["id"]) == "enemy_a",
		"empate entre inimigos segue a posição na onda")


# --- Alvos (spec §4) ---

static func _test_targeting(t: Node) -> void:
	var s := CombatService.start_battle(
		[_unit("hero", 500, 5, 0, 20)],
		{ "gate": 1, "waves": [[_unit("e1", 3, 0, 0, 1), _unit("e2", 10, 0, 0, 1)]] }
	)
	var ev := CombatService.step(s)
	t.check(String(ev["target"]["id"]) == "e1", "aliado mira o primeiro inimigo vivo da onda")
	t.check(bool(ev["killed"]) and int(ev["damage"]) == BalanceConfig.basic_damage(5, 0),
		"ataque aplica a fórmula de dano e abate o alvo")
	var ev2 := CombatService.step(s)
	t.check(String(ev2["attacker"]["id"]) == "e2", "inimigo sobrevivente revida")
	var ev3 := CombatService.step(s)
	t.check(String(ev3["attacker"]["id"]) == "hero" and String(ev3["target"]["id"]) == "e2",
		"próximo alvo é o próximo inimigo vivo")

	var s2 := CombatService.start_battle(
		[_unit("tank", 50, 1, 0, 1), _unit("glass", 50, 1, 0, 1)],
		{ "gate": 1, "waves": [[_unit("e", 50, 10, 0, 20)]] }
	)
	var eve := CombatService.step(s2)
	t.check(String(eve["target"]["id"]) == "tank",
		"inimigo mira o primeiro aliado vivo da formação")


# --- Dano (spec §4) ---

static func _test_damage(t: Node) -> void:
	t.check(BalanceConfig.basic_damage(20, 6) == 17, "dano = max(1, ataque - floor(defesa / 2))")
	t.check(BalanceConfig.basic_damage(1, 100) == 1, "dano mínimo garantido é 1")
	t.check(BalanceConfig.basic_damage(17, 7) == 14, "defesa é dividida com arredondamento para baixo")


# --- Determinismo (spec §10.5) ---

static func _test_determinism(t: Node) -> void:
	var a := _event_log(CombatService.start_battle(_team(), ContentDB.gate(1)))
	var b := _event_log(CombatService.start_battle(_team(), ContentDB.gate(1)))
	t.check(a.size() > 0, "simulação completa do portal 1 gera eventos")
	t.check(a == b, "mesma entrada e estado inicial → mesma sequência de eventos")


# --- HP entre ondas (spec §4) ---

static func _test_hp_between_waves(t: Node) -> void:
	var state := CombatService.start_battle(_team(), ContentDB.gate(1))
	var ally: Dictionary = state["allies"][0]
	var hp_max := int(ally["max_hp"])
	var safety := 0
	while int(state["wave_index"]) == 0 and not CombatService.is_finished(state) and safety < 500:
		safety += 1
		var ev: Dictionary = CombatService.step(state)
		if ev.is_empty():
			break
	t.check(int(state["wave_index"]) == 1, "ao fim da 1.ª onda o combate avança para a 2.ª")
	var hp_kept := int(ally["hp"])
	t.check(hp_kept > 0 and hp_kept < hp_max, "HP do aliado mantém-se entre ondas (não reposto)")


# --- Recompensas de vitória (spec §4) ---

static func _test_victory_rewards(t: Node) -> void:
	var gate1 := ContentDB.gate(1)
	var r1 := CombatService.victory_rewards(gate1)
	t.check(int(r1["gold"]) == BalanceConfig.victory_gold(1, int(gate1["total_enemies"])),
		"recompensa de ouro: 10 × portal × inimigos derrotados")
	t.check(int(r1["xp"]) == BalanceConfig.victory_xp(1, int(gate1["total_enemies"])),
		"recompensa de XP: 5 × portal × inimigos derrotados")
	t.check(int(r1["essence"]) == 0, "portal sem chefe não concede essência")
	var gate5 := ContentDB.gate(5)
	var r5 := CombatService.victory_rewards(gate5)
	t.check(bool(gate5["has_boss"]), "portal 5 tem chefe")
	t.check(int(r5["essence"]) == BalanceConfig.boss_shadow_essence(),
		"chefe do portal 5 concede shadow_essence")


# --- Progressão (spec §10.3, §10.4, §10.11) ---

static func _test_progression(t: Node) -> void:
	_set_progress(0, 100, 0)
	var expected_gold := BalanceConfig.victory_gold(1, 6)
	var rewards := GameState.apply_battle_victory(1)
	t.check(int(rewards.get("gold", -1)) == expected_gold, "vitória no portal 1 devolve a recompensa")
	t.check(GameState.gold == 100 + expected_gold, "recompensa creditada exatamente uma vez")
	t.check(GameState.highest_gate_cleared == 1, "vitória desbloqueia o portal seguinte")
	var persisted := SaveService.load_state()
	t.check(int(persisted["state"]["gold"]) == GameState.gold, "vitória grava o save de imediato")

	var gold_before := GameState.gold
	t.check(GameState.resolve_battle_end({ "gate": 2, "phase": "defeat" }).is_empty(),
		"derrota não devolve recompensa")
	t.check(GameState.gold == gold_before and GameState.highest_gate_cleared == 1,
		"derrota não concede recursos nem progressão")
	t.check(GameState.resolve_battle_end({ "gate": 2, "phase": "running" }).is_empty(),
		"batalha incompleta não devolve recompensa")

	var jump := GameState.apply_battle_victory(3)
	t.check(jump.is_empty() and GameState.highest_gate_cleared == 1,
		"não é possível saltar o portal 2")

	var r2 := GameState.resolve_battle_end({ "gate": 2, "phase": "victory" })
	t.check(not r2.is_empty() and GameState.highest_gate_cleared == 2,
		"resolve_battle_end credita a vitória do portal 2")
	t.check(GameState.is_unlocked("shadow_ranged"),
		"concluir o portal 2 desbloqueia a Sombra Atiradora")

	var replay_gold := GameState.gold
	var replay := GameState.apply_battle_victory(2)
	t.check(not replay.is_empty() and GameState.gold > replay_gold,
		"repetir portal concluído concede recompensa")
	t.check(GameState.highest_gate_cleared == 2, "repetição não altera a progressão")


# --- Varredura (spec §4 Varredura, §10.11) ---

static func _test_sweep(t: Node) -> void:
	_set_progress(0, 100, 0)
	var locked := GameState.sweep_gate(1)
	t.check(locked.is_empty() and GameState.gold == 100,
		"varredura bloqueada em portal ainda não concluído")
	t.check(GameState.sweep_gate(0).is_empty() and GameState.sweep_gate(99).is_empty(),
		"varredura rejeita portal inexistente")

	_set_progress(5, 100, 0)
	var g5 := ContentDB.gate(5)
	var sweep5 := GameState.sweep_gate(5)
	t.check(not sweep5.is_empty(), "varredura do portal 5 concluído concede recompensa")
	t.check(GameState.gold == 100 + int(g5["victory_gold"]),
		"varredura credita o gold normal de conclusão")
	t.check(GameState.shadow_essence == int(g5["boss_shadow_essence"]),
		"chefe já vencido: varredura concede a essência do chefe")
	t.check(GameState.highest_gate_cleared == 5, "varredura não altera a progressão")
	var sweep2 := GameState.sweep_gate(2)
	t.check(not sweep2.is_empty() and not GameState.is_unlocked("shadow_ranged"),
		"varredura nunca concede desbloqueio novo")
	var persisted := SaveService.load_state()
	t.check(int(persisted["state"]["gold"]) == GameState.gold, "varredura grava o save de imediato")


# --- Auxiliares ---

static func _set_progress(highest: int, gold: int, essence: int) -> void:
	GameState.from_dict({
		"schema_version": 1,
		"hunter_xp": 0,
		"gold": gold,
		"shadow_essence": essence,
		"highest_gate_cleared": highest,
		"last_background_unix": 0,
		"roster": {
			"jinwoo": { "level": 1, "unlocked": true },
			"shadow_soldier": { "level": 1, "unlocked": true },
		},
		"formation": ["jinwoo", "shadow_soldier"],
	})


static func _team() -> Array:
	return GameState.team_units()


static func _unit(id: String, hp: int, attack: int, defense: int, speed: int) -> Dictionary:
	return {
		"id": id, "display_name": id, "role": "test",
		"hp": hp, "attack": attack, "defense": defense, "speed": speed,
	}


static func _event_log(state: Dictionary) -> Array:
	var out: Array = []
	var safety := 0
	while not CombatService.is_finished(state) and safety < 2000:
		safety += 1
		var ev: Dictionary = CombatService.step(state)
		if ev.is_empty():
			break
		if String(ev["type"]) == "attack":
			out.append("%s>%s:%d" % [str(ev["attacker"]["id"]), str(ev["target"]["id"]), int(ev["damage"])])
		else:
			out.append("outcome:%s" % str(ev["outcome"]))
	return out
