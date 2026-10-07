extends Control
## Tela Portais (spec §5.1): perfil resumido, recursos, melhor portal,
## caminho visual com portais concluídos/atuais/bloqueados, varredura de
## portais concluídos (spec §4) e botão para enfrentar o portal atual.

@onready var stats_label: Label = $Margin/VBox/StatsLabel
@onready var best_label: Label = $Margin/VBox/BestLabel
@onready var gate_label: Label = $Margin/VBox/GateLabel
@onready var sweep_feedback: Label = $Margin/VBox/SweepFeedbackLabel
@onready var gate_list: VBoxContainer = $Margin/VBox/GateScroll/GateList
@onready var start_button: Button = $Margin/VBox/StartButton
@onready var warning_label: Label = $Margin/VBox/WarningLabel


func _ready() -> void:
	GameState.state_changed.connect(_refresh)
	start_button.pressed.connect(_on_start_pressed)
	$Margin/VBox/Title.text = Loc.t("ui.tab.portals")
	_refresh()


func _refresh() -> void:
	stats_label.text = "%s %d · %s %d · %s %d · %s %d" % [
		Loc.t("ui.level"), GameState.hunter_level(),
		Loc.t("ui.gold"), GameState.gold,
		Loc.t("ui.xp"), GameState.hunter_xp,
		Loc.t("ui.essence"), GameState.shadow_essence,
	]
	best_label.text = "%s %d" % [Loc.t("portal.best"), GameState.highest_gate_cleared]
	gate_label.text = "%s %d" % [Loc.t("portal.current"), GameState.current_gate()]
	start_button.text = "%s %s %d" % [Loc.t("ui.start_battle"), Loc.t("ui.gate"), GameState.current_gate()]
	warning_label.text = GameState.load_warning
	warning_label.visible = not GameState.load_warning.is_empty()
	_rebuild_gate_list()


func _rebuild_gate_list() -> void:
	for child in gate_list.get_children():
		gate_list.remove_child(child)
		child.queue_free()
	for gate in ContentDB.gate_count():
		gate_list.add_child(_make_gate_row(gate + 1))


func _make_gate_row(gate: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 15)
	var base := "%s %d — " % [Loc.t("ui.gate"), gate]
	var color := Color(0.55, 0.58, 0.66)
	if gate <= GameState.highest_gate_cleared:
		label.text = base + Loc.t("portal.cleared")
		color = Color(0.35, 0.85, 0.55)
	elif gate == GameState.current_gate():
		label.text = base + Loc.t("portal.current")
		color = Color(0.216, 0.878, 1)
	else:
		label.text = base + Loc.t("ui.locked")
	label.add_theme_color_override("font_color", color)
	row.add_child(label)

	# Varredura apenas em portais já concluídos (spec §4/§10.11).
	if gate <= GameState.highest_gate_cleared:
		var sweep_button := Button.new()
		sweep_button.text = Loc.t("portal.sweep")
		sweep_button.custom_minimum_size = Vector2(150, 44)
		sweep_button.add_theme_font_size_override("font_size", 15)
		sweep_button.pressed.connect(_on_sweep.bind(gate))
		row.add_child(sweep_button)
	return row


func _on_sweep(gate: int) -> void:
	var rewards := GameState.sweep_gate(gate)
	if rewards.is_empty():
		return
	var parts: Array = [
		"+%d %s" % [int(rewards["gold"]), Loc.t("ui.gold")],
		"+%d %s" % [int(rewards["xp"]), Loc.t("ui.xp")],
	]
	if int(rewards["essence"]) > 0:
		parts.append("+%d %s" % [int(rewards["essence"]), Loc.t("ui.essence")])
	sweep_feedback.text = "%s %d — %s %s" % [
		Loc.t("ui.gate"), gate, Loc.t("portal.sweep_got"), " · ".join(parts),
	]
	sweep_feedback.visible = true


func _on_start_pressed() -> void:
	get_tree().call_group("navigation", "show_overlay", "gate_prep")
