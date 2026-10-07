extends Control
## Combate (spec §5.4): onda atual, unidades com vida, feedback de ações,
## velocidade x1/x2, pausa e saída sem recompensa.
##
## A velocidade só altera a apresentação (frequência de passos); os cálculos
## vêm do CombatService e são determinísticos (spec §4/§10.5). A batalha é
## simulada apenas enquanto este overlay está visível (primeiro plano).
## O fim da batalha encaminha para o resultado; só aí se credita recompensa.

const STEP_SECONDS := 0.45

@onready var title_label: Label = $Margin/VBox/TitleLabel
@onready var wave_label: Label = $Margin/VBox/WaveLabel
@onready var enemies_box: VBoxContainer = $Margin/VBox/EnemiesBox
@onready var allies_box: VBoxContainer = $Margin/VBox/AlliesBox
@onready var log_label: Label = $Margin/VBox/LogLabel
@onready var pause_button: Button = $Margin/VBox/Controls/PauseButton
@onready var speed_button: Button = $Margin/VBox/Controls/SpeedButton
@onready var exit_hint: Label = $Margin/VBox/ExitHintLabel
@onready var exit_button: Button = $Margin/VBox/ExitButton

var _gate: int = 0
var _state: Dictionary = {}
var _acc: float = 0.0
var _paused: bool = false
var _speed: int = 1
var _finished: bool = false
## chave "lado:id" -> { "bar", "hp_label", "name_label" }
var _rows: Dictionary = {}


func _ready() -> void:
	title_label.text = Loc.t("battle.title")
	$Margin/VBox/EnemiesTitle.text = Loc.t("battle.enemies")
	$Margin/VBox/AlliesTitle.text = Loc.t("battle.allies")
	pause_button.text = Loc.t("battle.pause")
	exit_hint.text = Loc.t("battle.exit_hint")
	exit_button.text = Loc.t("ui.exit_battle")
	pause_button.pressed.connect(_on_pause)
	speed_button.pressed.connect(_on_speed)
	exit_button.pressed.connect(_on_exit)


## Chamado pela navegação antes de mostrar o overlay: inicia uma batalha nova.
func configure(data: Dictionary) -> void:
	_gate = int(data.get("gate", GameState.current_gate()))
	var gate_def := ContentDB.gate(_gate)
	_state = CombatService.start_battle(GameState.team_units(), gate_def)
	_paused = false
	_speed = 1
	_finished = false
	_acc = 0.0
	pause_button.text = Loc.t("battle.pause")
	speed_button.text = "x1"
	log_label.text = ""
	_build_rows()
	_render()


func _process(delta: float) -> void:
	if _finished or _paused or _state.is_empty() or not is_visible_in_tree():
		return
	# Clamp do delta: retomar do segundo plano não pode acelerar o combate.
	_acc += minf(delta, 0.1)
	var step_time := STEP_SECONDS / float(_speed)
	while _acc >= step_time:
		_acc -= step_time
		_advance()


func _advance() -> void:
	if _state.is_empty() or CombatService.is_finished(_state):
		return
	var ev: Dictionary = CombatService.step(_state)
	if not ev.is_empty():
		_log_event(ev)
	_render()
	if CombatService.is_finished(_state):
		_finish()


func _log_event(ev: Dictionary) -> void:
	var outcome := String(ev.get("outcome", ""))
	if String(ev["type"]) == "attack":
		var key := "battle.log_kill" if bool(ev["killed"]) else "battle.log_attack"
		log_label.text = Loc.t(key) % [
			str(ev["attacker"]["name"]), str(ev["target"]["name"]), int(ev["damage"]),
		]
	elif outcome == "wave":
		# O evento já aponta para a onda seguinte; a onda concluída é a anterior.
		log_label.text = Loc.t("battle.wave_done") % (int(ev["wave"]) - 1)
	elif outcome == "victory":
		log_label.text = Loc.t("result.victory")
	elif outcome == "defeat":
		log_label.text = Loc.t("result.defeat")


func _render() -> void:
	if _state.is_empty():
		return
	var waves: Array = _state["waves"]
	wave_label.text = "%s %d / %d" % [Loc.t("battle.wave"), int(_state["wave_index"]) + 1, waves.size()]
	_render_side(_state["allies"], "ally")
	_render_side(_state["enemies"], "enemy")


func _render_side(units: Array, side: String) -> void:
	for unit in units:
		var row: Dictionary = _rows.get("%s:%s" % [side, str(unit.get("id", ""))], {})
		if row.is_empty():
			continue
		var hp := int(unit["hp"])
		var max_hp := maxi(int(unit.get("max_hp", hp)), 1)
		var bar: ProgressBar = row["bar"]
		bar.max_value = max_hp
		bar.value = hp
		var hp_label: Label = row["hp_label"]
		hp_label.text = "%d/%d" % [hp, max_hp]
		var name_label: Label = row["name_label"]
		name_label.modulate = Color(1, 1, 1) if hp > 0 else Color(1, 1, 1, 0.4)


## Vitória credita recompensa/progressão via GameState.resolve_battle_end
## (uma única vez); derrota não concede nada (spec §10.3/§10.4).
func _finish() -> void:
	if _finished:
		return
	_finished = true
	var victory := String(_state.get("phase", "")) == "victory"
	var unlock_id: Variant = ContentDB.gate(_gate).get("clear_unlocks_unit")
	var had_unit := unlock_id is String and GameState.is_unlocked(str(unlock_id))
	var prev_highest := GameState.highest_gate_cleared
	var rewards := GameState.resolve_battle_end(_state)
	var data := {
		"victory": victory,
		"gate": _gate,
		"rewards": rewards,
		"advanced": victory and GameState.highest_gate_cleared > prev_highest,
		"new_highest": GameState.highest_gate_cleared,
		"unlocked_unit": "",
	}
	if victory and unlock_id is String and not had_unit and GameState.is_unlocked(str(unlock_id)):
		data["unlocked_unit"] = str(ContentDB.unit(str(unlock_id)).get("display_name", unlock_id))
	get_tree().call_group("navigation", "close_overlay", "battle")
	get_tree().call_group("navigation", "show_overlay", "battle_result", data)


func _on_pause() -> void:
	if _finished:
		return
	_paused = not _paused
	pause_button.text = Loc.t("battle.resume") if _paused else Loc.t("battle.pause")


func _on_speed() -> void:
	_speed = 2 if _speed == 1 else 1
	speed_button.text = "x%d" % _speed


## Sair durante a batalha encerra sem conceder recompensa (spec §4/§5.4).
func _on_exit() -> void:
	_state = {}
	_finished = true
	get_tree().call_group("navigation", "close_overlay", "battle")


# --- Construção de linhas de vida ---

func _build_rows() -> void:
	_rows.clear()
	_clear_box(enemies_box)
	_clear_box(allies_box)
	for unit in _state["enemies"]:
		enemies_box.add_child(_make_row("enemy", unit, false))
	for unit in _state["allies"]:
		allies_box.add_child(_make_row("ally", unit, true))


func _clear_box(box: VBoxContainer) -> void:
	for child in box.get_children():
		box.remove_child(child)
		child.queue_free()


func _make_row(side: String, unit: Dictionary, is_ally: bool) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var name_label := Label.new()
	name_label.custom_minimum_size = Vector2(196, 0)
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.text = str(unit.get("display_name", unit.get("id", "?")))
	row.add_child(name_label)

	var bar := ProgressBar.new()
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.custom_minimum_size = Vector2(0, 18)
	bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.35, 0.85, 0.55) if is_ally else Color(0.95, 0.4, 0.45)
	bar.add_theme_stylebox_override("fill", fill)
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.13, 0.14, 0.2)
	bar.add_theme_stylebox_override("background", background)
	row.add_child(bar)

	var hp_label := Label.new()
	hp_label.custom_minimum_size = Vector2(96, 0)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hp_label.add_theme_font_size_override("font_size", 14)
	row.add_child(hp_label)

	_rows["%s:%s" % [side, str(unit.get("id", ""))]] = {
		"bar": bar, "hp_label": hp_label, "name_label": name_label,
	}
	return row
