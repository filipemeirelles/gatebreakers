extends Control
## Preparação do portal (spec §5.3): inimigos/chefe, equipe e ordem da
## formação, recompensas de primeira vitória e botão para começar.

@onready var gate_label: Label = $Margin/VBox/GateLabel
@onready var enemies_label: Label = $Margin/VBox/EnemiesLabel
@onready var boss_label: Label = $Margin/VBox/BossLabel
@onready var order_label: Label = $Margin/VBox/OrderLabel
@onready var rewards_label: Label = $Margin/VBox/RewardsLabel
@onready var unlock_label: Label = $Margin/VBox/UnlockLabel

var _gate: int = 0


func _ready() -> void:
	$Margin/VBox/Title.text = Loc.t("portal.current")
	$Margin/VBox/BackButton.text = Loc.t("ui.exit_battle")
	$Margin/VBox/StartButton.text = Loc.t("ui.start_battle")
	$Margin/VBox/BackButton.pressed.connect(_on_back)
	$Margin/VBox/StartButton.pressed.connect(_on_start)
	GameState.state_changed.connect(_on_state_changed)
	_refresh()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
		_refresh()


func _on_state_changed() -> void:
	if is_visible_in_tree():
		_refresh()


func _refresh() -> void:
	_gate = GameState.current_gate()
	var gate_def := ContentDB.gate(_gate)
	if gate_def.is_empty():
		return
	gate_label.text = "%s %d" % [Loc.t("ui.gate"), _gate]
	enemies_label.text = Loc.t("prep.enemies") % [
		int(gate_def["total_enemies"]), (gate_def["waves"] as Array).size(),
	]
	boss_label.visible = bool(gate_def.get("has_boss", false))
	boss_label.text = Loc.t("prep.boss")

	var names: Array = []
	for unit_id in GameState.formation:
		names.append(str(ContentDB.unit(unit_id).get("display_name", unit_id)))
	order_label.text = Loc.t("prep.order") % ", ".join(names)

	var parts: Array = [
		"+%d %s" % [int(gate_def["victory_gold"]), Loc.t("ui.gold")],
		"+%d %s" % [int(gate_def["victory_xp"]), Loc.t("ui.xp")],
	]
	if int(gate_def.get("boss_shadow_essence", 0)) > 0:
		parts.append("+%d %s" % [int(gate_def["boss_shadow_essence"]), Loc.t("ui.essence")])
	rewards_label.text = "%s %s" % [Loc.t("prep.rewards"), " · ".join(parts)]

	var unlock_id: Variant = gate_def.get("clear_unlocks_unit")
	if unlock_id is String and not GameState.is_unlocked(str(unlock_id)):
		var unit_name := str(ContentDB.unit(str(unlock_id)).get("display_name", unlock_id))
		unlock_label.text = Loc.t("prep.unlock") % unit_name
		unlock_label.visible = true
	else:
		unlock_label.visible = false


func _on_back() -> void:
	get_tree().call_group("navigation", "close_overlay", "gate_prep")


func _on_start() -> void:
	get_tree().call_group("navigation", "close_overlay", "gate_prep")
	get_tree().call_group("navigation", "show_overlay", "battle", { "gate": _gate })
