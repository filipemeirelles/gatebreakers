class_name SaveServiceTests
extends RefCounted
## Testes do SaveService (spec §7 e critérios 2/6/8 do §10).
## `t` é o runner: precisa do método check(cond, name).


static func run(t: Node) -> void:
	print("-- SaveService --")
	var original := GameState.to_dict()

	t.check(FileAccess.file_exists(SaveService.SAVE_PATH), "arranque cria save válido")

	# 1) Roundtrip
	var state := {
		"schema_version": 1,
		"hunter_xp": 123,
		"gold": 456,
		"shadow_essence": 7,
		"highest_gate_cleared": 2,
		"last_background_unix": 1700000000,
		"roster": {
			"jinwoo": { "level": 3, "unlocked": true },
			"shadow_soldier": { "level": 2, "unlocked": true },
		},
		"formation": ["jinwoo", "shadow_soldier"],
	}
	t.check(SaveService.save_state(state), "save_state devolve true")
	var result := SaveService.load_state()
	t.check(result["status"] == "loaded", "roundtrip devolve status loaded")
	t.check(int(result["state"]["gold"]) == 456, "gold preservado no roundtrip")
	t.check(int(result["state"]["roster"]["shadow_soldier"]["level"]) == 2, "nível da sombra preservado")
	t.check(int(result["state"]["last_background_unix"]) == 1700000000, "last_background_unix preservado")

	# 2) JSON corrompido
	_write_raw("{ isto nao é json !!")
	result = SaveService.load_state()
	t.check(result["status"] == "recovered_corrupt", "json inválido → recovered_corrupt")
	t.check(str(result["backup_path"]) != "" and FileAccess.file_exists(str(result["backup_path"])), "backup de diagnóstico criado")
	t.check(_is_valid(result["state"]), "estado novo após corrupção é válido")

	# 3) Valor negativo
	_write_raw(JSON.stringify(_valid_state({ "gold": -5 })))
	result = SaveService.load_state()
	t.check(result["status"] == "recovered_corrupt", "gold negativo → recovered_corrupt")

	# 4) Versão de schema desconhecida
	_write_raw(JSON.stringify(_valid_state({ "schema_version": 99 })))
	result = SaveService.load_state()
	t.check(result["status"] == "recovered_corrupt", "versão desconhecida → recovered_corrupt")

	# 5) Campo em falta
	var missing := _valid_state({})
	missing.erase("shadow_essence")
	_write_raw(JSON.stringify(missing))
	result = SaveService.load_state()
	t.check(result["status"] == "recovered_corrupt", "campo em falta → recovered_corrupt")

	# 6) Tipo errado (gold como texto)
	_write_raw(JSON.stringify(_valid_state({ "gold": "1000" })))
	result = SaveService.load_state()
	t.check(result["status"] == "recovered_corrupt", "tipo errado → recovered_corrupt")

	# 7) Formação com unidade desconhecida é filtrada
	_write_raw(JSON.stringify(_valid_state({ "formation": ["jinwoo", "ghost_unit"] })))
	result = SaveService.load_state()
	t.check(result["status"] == "loaded", "formação estranha não invalida o save")
	t.check(result["state"]["formation"] == ["jinwoo"], "unidade desconhecida removida da formação")

	# 8) Save perdido + temporário válido → recupera do temporário
	DirAccess.remove_absolute(SaveService.SAVE_PATH)
	var tmp := FileAccess.open(SaveService.TMP_PATH, FileAccess.WRITE)
	tmp.store_string(JSON.stringify(_valid_state({})))
	tmp.close()
	result = SaveService.load_state()
	t.check(result["status"] == "recovered_tmp", "temporário válido → recovered_tmp")
	t.check(FileAccess.file_exists(SaveService.SAVE_PATH), "save regravado a partir do temporário")

	# 9) Load repetido sem tempo adicional não altera o estado
	var first := SaveService.load_state()
	var second := SaveService.load_state()
	t.check(first["state"]["gold"] == second["state"]["gold"], "reload repetido não altera recursos")

	# Repor o save original do jogador
	SaveService.save_state(original)


static func _valid_state(overrides: Dictionary) -> Dictionary:
	var state := {
		"schema_version": 1,
		"hunter_xp": 10,
		"gold": 100,
		"shadow_essence": 0,
		"highest_gate_cleared": 0,
		"last_background_unix": 0,
		"roster": {
			"jinwoo": { "level": 1, "unlocked": true },
			"shadow_soldier": { "level": 1, "unlocked": true },
		},
		"formation": ["jinwoo", "shadow_soldier"],
	}
	for key in overrides:
		state[key] = overrides[key]
	return state


static func _write_raw(text: String) -> void:
	var file := FileAccess.open(SaveService.SAVE_PATH, FileAccess.WRITE)
	file.store_string(text)
	file.close()


static func _is_valid(state: Variant) -> bool:
	return state is Dictionary and not SaveService.validate_state(state).is_empty()
