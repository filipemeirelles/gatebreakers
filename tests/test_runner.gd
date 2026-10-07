extends Node
## Runner de testes headless (spec §6 — tests/).
## Executar:  godot --headless --path . res://tests/runner.tscn
## Sai com código 0 se tudo passar, 1 se algum teste falhar.

var passed: int = 0
var failed: int = 0


func _ready() -> void:
	print("=== Gatebreakers test runner ===")
	print("  estado no arranque: gold=%d xp=%d essência=%d formação=%s" % [
		GameState.gold, GameState.hunter_xp, GameState.shadow_essence,
		str(GameState.formation),
	])
	_run_all()
	print("=== RESULTADO: %d passaram, %d falharam ===" % [passed, failed])
	get_tree().quit(0 if failed == 0 else 1)


func check(condition: bool, name: String) -> void:
	if condition:
		passed += 1
		print("  PASS  %s" % name)
	else:
		failed += 1
		print("  FAIL  %s" % name)


func _run_all() -> void:
	SaveServiceTests.run(self)
	NavigationTests.run(self)
	CombatServiceTests.run(self)
	BattleScreenTests.run(self)
	AutoFarmTests.run(self)
	IdleRewardTests.run(self)
	UpgradeTests.run(self)
	Fase5Tests.run(self)
