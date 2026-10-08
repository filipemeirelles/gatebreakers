class_name ItemTests
extends RefCounted
## Testes do Sistema de Equipamentos e Inventário (E2).
## `t` é o runner: precisa do método check(cond, name).


static func run(t: Node) -> void:
	print("-- Equipamentos e Inventário --")
	var original := GameState.to_dict()

	_test_item_definitions(t)
	_test_inventory_management(t)
	_test_equip_and_stats(t)
	_test_item_transfer(t)
	_test_unequip(t)
	_test_first_clear_drop(t)
	_test_schema_migration_v4(t)
	_test_items_red_dot(t)

	GameState.from_dict(original)
	GameState.save_now()


static func _test_item_definitions(t: Node) -> void:
	var all := ContentDB.all_items()
	t.check(all.size() >= 10, "pelo menos 10 equipamentos carregados do ContentDB")

	var kasaka := ContentDB.item("kasaka_fang")
	t.check(str(kasaka.get("slot", "")) == "weapon", "Presa de Kasaka é arma")
	t.check(str(kasaka.get("rank", "")) == "C", "Presa de Kasaka é Rank C")
	t.check(int(kasaka.get("attack_bonus", 0)) == 12, "Presa de Kasaka dá +12 ATK")

	var spider := ContentDB.item("spider_carapace")
	t.check(str(spider.get("slot", "")) == "accessory", "Carapaça de Buryura é acessório")
	t.check(int(spider.get("defense_bonus", 0)) == 8, "Carapaça dá +8 DEF")
	t.check(int(spider.get("hp_bonus", 0)) == 40, "Carapaça dá +40 HP")

	var weapons := ContentDB.items_for_slot("weapon")
	var accessories := ContentDB.items_for_slot("accessory")
	t.check(weapons.size() >= 4, "armas identificadas pelo slot")
	t.check(accessories.size() >= 4, "acessórios identificados pelo slot")


static func _test_inventory_management(t: Node) -> void:
	GameState.reset_to_new_game()
	t.check(GameState.inventory.is_empty(), "inventário começa vazio em novo jogo")
	t.check(not GameState.is_item_owned("dagger_goblin"), "item não possuído retorna falso")

	var added := GameState.add_item_to_inventory("dagger_goblin")
	t.check(added, "adiciona item ao inventário")
	t.check(GameState.is_item_owned("dagger_goblin"), "item agora é possuído")

	# Tentativa de duplicata não duplica
	GameState.add_item_to_inventory("dagger_goblin")
	t.check(GameState.inventory.size() == 1, "inventário não duplica item único")

	var invalid := GameState.add_item_to_inventory("item_fantasma_inexistente")
	t.check(not invalid, "item inexistente recusado")


static func _test_equip_and_stats(t: Node) -> void:
	GameState.reset_to_new_game()
	GameState.add_item_to_inventory("dagger_goblin")
	GameState.add_item_to_inventory("spider_carapace")

	var base_jinwoo := GameState.unit_stats_at_level("jinwoo", 1)
	var initial_stats := GameState.unit_stats("jinwoo")
	t.check(int(initial_stats["attack"]) == int(base_jinwoo["attack"]), "Jinwoo desarmado tem ATK base")

	# Equipar arma
	var eq_res := GameState.equip_item("jinwoo", "dagger_goblin")
	t.check(bool(eq_res["ok"]), "equipar arma em Jinwoo tem sucesso")
	t.check(GameState.get_equipped("jinwoo")["weapon"] == "dagger_goblin", "arma registrada no slot de Jinwoo")

	var equipped_stats := GameState.unit_stats("jinwoo")
	t.check(int(equipped_stats["attack"]) == int(base_jinwoo["attack"]) + 5,
		"ATK de Jinwoo aumenta pelo bônus da arma (+5)")
	t.check(int(equipped_stats["hp"]) == int(base_jinwoo["hp"]) + 15,
		"HP de Jinwoo aumenta pelo bônus da arma (+15)")

	# Equipar acessório
	GameState.equip_item("jinwoo", "spider_carapace")
	t.check(GameState.get_equipped("jinwoo")["accessory"] == "spider_carapace", "acessório registrado no slot")
	var both_stats := GameState.unit_stats("jinwoo")
	t.check(int(both_stats["defense"]) == int(base_jinwoo["defense"]) + 8,
		"DEF de Jinwoo aumenta pela carapaça (+8)")
	t.check(int(both_stats["hp"]) == int(base_jinwoo["hp"]) + 15 + 40,
		"HP de Jinwoo acumula bônus de arma e acessório")

	# Poder de equipe reflete equipamentos
	var power := GameState.team_power()
	t.check(power > 0, "poder de equipe calculado com equipamentos")


static func _test_item_transfer(t: Node) -> void:
	GameState.reset_to_new_game()
	GameState.gold = 1000
	GameState.highest_gate_cleared = 1
	GameState.hire_hunter("yoojinho")
	GameState.add_item_to_inventory("dagger_goblin")

	# Equipar no Jinwoo
	GameState.equip_item("jinwoo", "dagger_goblin")
	t.check(GameState.get_equipped("jinwoo")["weapon"] == "dagger_goblin", "arma em Jinwoo")

	# Transferir para Yoo Jinho
	var res := GameState.equip_item("yoojinho", "dagger_goblin")
	t.check(bool(res["ok"]), "equipar no Jinho transfere o item")
	t.check(GameState.get_equipped("yoojinho")["weapon"] == "dagger_goblin", "arma agora em Yoo Jinho")
	t.check(GameState.get_equipped("jinwoo")["weapon"] == "", "slot de Jinwoo desocupado após transferência")

	# Verificação de dono
	var in_use := GameState.item_equipped_by("dagger_goblin")
	t.check(str(in_use.get("unit_id", "")) == "yoojinho", "item_equipped_by identifica Jinho como dono")


static func _test_unequip(t: Node) -> void:
	GameState.reset_to_new_game()
	GameState.add_item_to_inventory("kasaka_fang")
	GameState.equip_item("jinwoo", "kasaka_fang")
	t.check(GameState.get_equipped("jinwoo")["weapon"] == "kasaka_fang", "arma equipada")

	var unequipped := GameState.unequip_slot("jinwoo", "weapon")
	t.check(unequipped, "desequipar slot devolve true")
	t.check(GameState.get_equipped("jinwoo")["weapon"] == "", "slot arma vazio após desequipar")

	var empty_un := GameState.unequip_slot("jinwoo", "weapon")
	t.check(not empty_un, "desequipar slot já vazio devolve false")


static func _test_first_clear_drop(t: Node) -> void:
	GameState.reset_to_new_game()
	t.check(GameState.inventory.is_empty(), "sem itens no início")

	# Vitória no Portal 1 (primeira vitória avança progressão)
	var rewards := GameState.apply_battle_victory(1)
	t.check(str(rewards.get("item_drop", "")) == "dagger_goblin", "vitória no Portal 1 concede Adaga de Goblin")
	t.check(GameState.is_item_owned("dagger_goblin"), "Adaga de Goblin está no inventário")

	# Repetição do Portal 1 já concluído NÃO concede o item drop novamente
	var rep_rewards := GameState.apply_battle_victory(1)
	t.check(str(rep_rewards.get("item_drop", "")) == "", "repetição não concede item drop novamente")
	t.check(GameState.inventory.size() == 1, "inventário permanece com 1 item")

	# Vitória no Portal 2 concede Presa de Kasaka
	var rewards_p2 := GameState.apply_battle_victory(2)
	t.check(str(rewards_p2.get("item_drop", "")) == "kasaka_fang", "Portal 2 concede Presa de Kasaka")
	t.check(GameState.is_item_owned("kasaka_fang"), "Presa de Kasaka no inventário")


static func _test_schema_migration_v4(t: Node) -> void:
	var legacy_v3 := {
		"schema_version": 3,
		"hunter_level": 2,
		"hunter_xp": 50,
		"gold": 500,
		"shadow_essence": 10,
		"highest_gate_cleared": 3,
		"last_background_unix": 1700000000,
		"afk_chest_progress_seconds": 0,
		"afk_chests_available": 0,
		"afk_chest_last_tick_unix": 1700000000,
		"roster": {
			"jinwoo": { "level": 2, "unlocked": true },
			"shadow_soldier": { "level": 1, "unlocked": true },
		},
		"formation": ["shadow_soldier"],
		"story_cards_seen": [],
		"hunter_roster": {},
		"hunter_formation": [],
		"sweep_charges": {},
		"sweep_grant_done": true,
	}
	var raw := JSON.stringify(legacy_v3)
	var path := "user://save_v1.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(raw)
	file.close()

	var result := SaveService.load_state()
	t.check(result["status"] == "loaded", "save v3 carrega com sucesso")
	t.check(int(result["state"]["schema_version"]) == SaveService.SCHEMA_VERSION, "migra para o schema atual v4")

	GameState.from_dict(result["state"])
	t.check(GameState.is_item_owned("dagger_goblin"), "migração concede item do portal 1")
	t.check(GameState.is_item_owned("kasaka_fang"), "migração concede item do portal 2")
	t.check(GameState.is_item_owned("spider_carapace"), "migração concede item do portal 3")
	t.check(GameState.get_equipped("jinwoo")["weapon"] != "", "arma auto-equipada no Jinwoo após migração")


static func _test_items_red_dot(t: Node) -> void:
	GameState.reset_to_new_game()
	t.check(not GameState.red_dots()["items"], "sem itens desequipados: sem red dot em itens")

	GameState.add_item_to_inventory("dagger_goblin")
	t.check(GameState.red_dots()["items"], "item livre e Jinwoo desarmado: red dot ativo")

	GameState.equip_item("jinwoo", "dagger_goblin")
	t.check(not GameState.red_dots()["items"], "item equipado: red dot limpo")
