extends Node
## AutoFarmController — simula a limpeza automática dos portais atuais enquanto
## o app está em primeiro plano. As regras e recompensas permanecem nos serviços.

signal status_changed

const CYCLE_DELAY_SECONDS := 1.0

var is_running: bool = false
var victories: int = 0
var status_text: String = ""
var _cycle_accumulator: float = 0.0


func _ready() -> void:
	add_to_group("auto_farm")
	status_text = Loc.t("portal.auto_farm_ready")


func _process(delta: float) -> void:
	if not is_running:
		return
	_cycle_accumulator += minf(delta, 0.25)
	if _cycle_accumulator < CYCLE_DELAY_SECONDS:
		return
	_cycle_accumulator -= CYCLE_DELAY_SECONDS
	run_one_battle()


func set_running(enabled: bool) -> void:
	if enabled:
		if GameState.highest_gate_cleared >= ContentDB.gate_count():
			_stop_with_status(Loc.t("portal.auto_farm_complete"))
			return
		victories = 0
		is_running = true
		_cycle_accumulator = 0.0
		_update_running_status()
	else:
		_stop_with_status(Loc.t("portal.auto_farm_stopped"))


## Executa um ciclo determinístico. Público para teste; a UI usa _process.
func run_one_battle() -> Dictionary:
	if not is_running:
		return {}
	var gate := GameState.current_gate()
	var gate_def := ContentDB.gate(gate)
	if gate_def.is_empty():
		_stop_with_status(Loc.t("portal.auto_farm_complete"))
		return {}

	var battle_state := CombatService.start_battle(GameState.team_units(), gate_def)
	CombatService.run_to_completion(battle_state)
	if String(battle_state.get("phase", "")) == "victory":
		var rewards := GameState.resolve_battle_end(battle_state)
		victories += 1
		if GameState.highest_gate_cleared >= ContentDB.gate_count():
			_stop_with_status(Loc.t("portal.auto_farm_complete"))
		else:
			_update_running_status(gate, rewards)
		return { "victory": true, "gate": gate, "rewards": rewards }

	var result := {
		"victory": false,
		"gate": gate,
		"rewards": {},
		"advanced": false,
		"new_highest": GameState.highest_gate_cleared,
		"unlocked_unit": "",
	}
	_stop_with_status(Loc.t("portal.auto_farm_defeat") % gate)
	get_tree().call_group("navigation", "show_overlay", "battle_result", result)
	return result


func _update_running_status(last_gate: int = 0, rewards: Dictionary = {}) -> void:
	var message := Loc.t("portal.auto_farm_running") % [GameState.current_gate(), victories]
	if last_gate > 0:
		var reward_parts: Array = [
			"+%d %s" % [int(rewards.get("gold", 0)), Loc.t("ui.gold").to_lower()],
		]
		if int(rewards.get("essence", 0)) > 0:
			reward_parts.append("+%d %s" % [int(rewards["essence"]), Loc.t("ui.essence").to_lower()])
		reward_parts.append("+%d %s" % [int(rewards.get("xp", 0)), Loc.t("ui.xp")])
		message = Loc.t("portal.auto_farm_victory") % [
			last_gate, GameState.current_gate(), " · ".join(reward_parts), victories,
		]
	status_text = message
	status_changed.emit()


func _stop_with_status(message: String) -> void:
	is_running = false
	_cycle_accumulator = 0.0
	status_text = message
	status_changed.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		stop_for_background()


func stop_for_background() -> void:
	if is_running:
		_stop_with_status(Loc.t("portal.auto_farm_paused"))
