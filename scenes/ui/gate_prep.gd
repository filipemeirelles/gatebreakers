extends Control
## Preparação do portal (spec §5.3): inimigos/chefe, equipe e ordem da
## formação, recompensas de primeira vitória e botão para começar.

const ArtHelper = preload("res://scripts/ui/art_helper.gd")

@onready var gate_label: Label = $Margin/VBox/GateLabel
@onready var enemy_portrait: TextureRect = $Margin/VBox/PreviewRow/EnemyPortrait
@onready var team_preview: HBoxContainer = $Margin/VBox/PreviewRow/TeamPreview
@onready var enemies_label: Label = $Margin/VBox/EnemiesLabel
@onready var boss_label: Label = $Margin/VBox/BossLabel
@onready var power_warning: Label = $Margin/VBox/PowerWarning
@onready var order_label: Label = $Margin/VBox/OrderLabel
@onready var rewards_label: Label = $Margin/VBox/RewardsLabel
@onready var unlock_label: Label = $Margin/VBox/UnlockLabel

var _gate: int = 0
var _risk_confirmation_pending: bool = false
var _is_high_risk: bool = false


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
		_risk_confirmation_pending = false
		_refresh()


func _on_state_changed() -> void:
	if is_visible_in_tree():
		_refresh()


func _refresh() -> void:
	var current_gate := GameState.current_gate()
	if current_gate != _gate:
		_risk_confirmation_pending = false
	_gate = current_gate
	var gate_def := ContentDB.gate(_gate)
	if gate_def.is_empty():
		return
	gate_label.text = "%s %d — %s · %s %s" % [
		Loc.t("ui.gate"), _gate, String(gate_def.get("display_name", "")),
		Loc.t("prep.rank"), String(gate_def.get("rank", "?")),
	]
	var risk_now := GameState.gate_is_high_risk(_gate)
	if risk_now != _is_high_risk:
		_risk_confirmation_pending = false
	_is_high_risk = risk_now
	_update_power_warning()
	var has_boss := bool(gate_def.get("has_boss", false))
	ArtHelper.configure_rect(enemy_portrait, ArtHelper.enemy_texture(has_boss), Vector2(112, 112))
	enemy_portrait.tooltip_text = String(gate_def.get("boss_name", "")) if has_boss else String(gate_def.get("enemy_name", ""))
	_rebuild_team_preview()
	enemies_label.text = Loc.t("prep.enemies") % [
		int(gate_def["total_enemies"]), (gate_def["waves"] as Array).size(),
	] + " · " + String(gate_def.get("enemy_name", ""))
	boss_label.visible = bool(gate_def.get("has_boss", false))
	boss_label.text = Loc.t("prep.boss_named") % String(gate_def.get("boss_name", ""))

	var names: Array = []
	for unit in GameState.team_units():
		names.append(str(unit["display_name"]))
	order_label.text = Loc.t("prep.order") % ", ".join(names)

	var parts: Array = [
		"+%d %s" % [int(gate_def["victory_gold"]), Loc.t("ui.gold")],
	]
	if int(gate_def.get("boss_shadow_essence", 0)) > 0:
		parts.append("+%d %s" % [int(gate_def["boss_shadow_essence"]), Loc.t("ui.essence")])
	parts.append("+%d %s" % [int(gate_def["victory_xp"]), Loc.t("ui.xp")])
	rewards_label.text = "%s %s" % [Loc.t("prep.rewards"), " · ".join(parts)]

	var unlock_id: Variant = gate_def.get("clear_unlocks_unit")
	if unlock_id is String and not GameState.is_unlocked(str(unlock_id)):
		var unit_name := str(ContentDB.unit(str(unlock_id)).get("display_name", unlock_id))
		unlock_label.text = Loc.t("prep.unlock") % unit_name
		unlock_label.visible = true
	else:
		unlock_label.visible = false


func _update_power_warning() -> void:
	power_warning.visible = _is_high_risk
	if not _is_high_risk:
		$Margin/VBox/StartButton.text = Loc.t("ui.start_battle")
		$Margin/VBox/BackButton.text = Loc.t("ui.exit_battle")
		return
	if _risk_confirmation_pending:
		power_warning.text = Loc.t("prep.confirm_risk") % [GameState.team_power(), GameState.gate_power(_gate)]
		$Margin/VBox/StartButton.text = Loc.t("prep.confirm_start")
	else:
		power_warning.text = Loc.t("prep.power_risk") % [GameState.team_power(), GameState.gate_power(_gate)]
		$Margin/VBox/StartButton.text = Loc.t("ui.start_battle")
	$Margin/VBox/BackButton.text = Loc.t("prep.adjust_team")


func _rebuild_team_preview() -> void:
	for child in team_preview.get_children():
		team_preview.remove_child(child)
		child.queue_free()
	for unit in GameState.team_units():
		var definition := ContentDB.unit(String(unit["id"]))
		if definition.is_empty():
			definition = ContentDB.hunter(String(unit["id"]))
		var portrait := TextureRect.new()
		ArtHelper.configure_rect(portrait, ArtHelper.texture(str(definition.get("art", ""))), Vector2(74, 74))
		portrait.tooltip_text = String(definition.get("display_name", unit["id"]))
		team_preview.add_child(portrait)


func _on_back() -> void:
	_risk_confirmation_pending = false
	get_tree().call_group("navigation", "close_overlay", "gate_prep")


func _on_start() -> void:
	if _is_high_risk and not _risk_confirmation_pending:
		_risk_confirmation_pending = true
		_update_power_warning()
		return
	get_tree().call_group("navigation", "close_overlay", "gate_prep")
	get_tree().call_group("navigation", "show_overlay", "battle", { "gate": _gate })
