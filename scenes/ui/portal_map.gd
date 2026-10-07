extends Control
## Tela Portais (spec §5.1): perfil resumido, recursos, melhor portal,
## caminho visual com portais concluídos/atuais/bloqueados, varredura de
## portais concluídos (spec §4) e botão para enfrentar o portal atual.

const ArtHelper = preload("res://scripts/ui/art_helper.gd")

@onready var level_value: Label = $Margin/VBox/StatsRow/LevelStat/LevelValue
@onready var gold_value: Label = $Margin/VBox/StatsRow/GoldStat/GoldValue
@onready var xp_value: Label = $Margin/VBox/StatsRow/XpStat/XpValue
@onready var essence_value: Label = $Margin/VBox/StatsRow/EssenceStat/EssenceValue
@onready var best_label: Label = $Margin/VBox/BestLabel
@onready var gate_label: Label = $Margin/VBox/GateLabel
@onready var sweep_feedback: Label = $Margin/VBox/SweepFeedbackLabel
@onready var gate_list: VBoxContainer = $Margin/VBox/GateScroll/GateList
@onready var start_button: Button = $Margin/VBox/StartButton
@onready var warning_label: Label = $Margin/VBox/WarningLabel
@onready var auto_farm_status: Label = $Margin/VBox/AutoFarmPanel/AutoFarmRow/AutoFarmStatus
@onready var auto_farm_button: Button = $Margin/VBox/AutoFarmPanel/AutoFarmRow/AutoFarmButton
@onready var chest_progress: ProgressBar = $Margin/VBox/AfkChestPanel/AfkChestRow/ChestInfo/ChestProgress
@onready var chest_progress_label: Label = $Margin/VBox/AfkChestPanel/AfkChestRow/ChestInfo/ChestProgressLabel
@onready var chest_claim_button: Button = $Margin/VBox/AfkChestPanel/AfkChestRow/ChestClaimButton

var _auto_farm_controller: Node = null
var _syncing_auto_farm_button: bool = false
var _chest_refresh_accumulator: float = 0.0


func _ready() -> void:
	add_to_group("portal_map")
	GameState.state_changed.connect(_refresh)
	start_button.pressed.connect(_on_start_pressed)
	auto_farm_button.toggled.connect(_on_auto_farm_toggled)
	chest_claim_button.pressed.connect(_on_claim_afk_chests)
	$Margin/VBox/Title.text = Loc.t("ui.tab.portals")
	$Margin/VBox/AfkChestPanel/AfkChestRow/ChestInfo/ChestTitle.text = Loc.t("afk.chest_title")
	ArtHelper.configure_rect(
		$Margin/VBox/AfkChestPanel/AfkChestRow/ChestIcon,
		ArtHelper.texture("res://assets/icons/icon_chest.svg"), Vector2(46, 46)
	)
	call_deferred("_connect_auto_farm_controller")
	ArtHelper.configure_rect($Margin/VBox/StatsRow/LevelStat/LevelIcon, ArtHelper.texture("res://assets/icons/icon_hunter.svg"), Vector2(28, 28))
	ArtHelper.configure_rect($Margin/VBox/StatsRow/GoldStat/GoldIcon, ArtHelper.texture("res://assets/icons/icon_gold.svg"), Vector2(28, 28))
	ArtHelper.configure_rect($Margin/VBox/StatsRow/XpStat/XpIcon, ArtHelper.texture("res://assets/icons/icon_xp.svg"), Vector2(28, 28))
	ArtHelper.configure_rect($Margin/VBox/StatsRow/EssenceStat/EssenceIcon, ArtHelper.texture("res://assets/icons/icon_essence.svg"), Vector2(28, 28))
	_refresh()


func _refresh() -> void:
	level_value.text = str(GameState.hunter_level())
	gold_value.text = str(GameState.gold)
	xp_value.text = str(GameState.hunter_xp)
	essence_value.text = str(GameState.shadow_essence)
	best_label.text = "%s %d" % [Loc.t("portal.best"), GameState.highest_gate_cleared]
	gate_label.text = "%s %d" % [Loc.t("portal.current"), GameState.current_gate()]
	start_button.text = "%s %s %d" % [Loc.t("ui.start_battle"), Loc.t("ui.gate"), GameState.current_gate()]
	warning_label.text = GameState.load_warning
	warning_label.visible = not GameState.load_warning.is_empty()
	_rebuild_gate_list()
	_refresh_afk_chest()
	_refresh_auto_farm_ui()


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	_chest_refresh_accumulator += delta
	if _chest_refresh_accumulator >= 1.0:
		_chest_refresh_accumulator = 0.0
		_refresh_afk_chest()


func _connect_auto_farm_controller() -> void:
	if _auto_farm_controller != null and is_instance_valid(_auto_farm_controller):
		return
	var controllers := get_tree().get_nodes_in_group("auto_farm")
	if controllers.is_empty():
		return
	register_auto_farm_controller(controllers[0])


func register_auto_farm_controller(controller: Node) -> void:
	if _auto_farm_controller == controller:
		_refresh_auto_farm_ui()
		return
	_auto_farm_controller = controller
	if controller.has_signal("status_changed"):
		controller.connect("status_changed", _refresh_auto_farm_ui)
	_refresh_auto_farm_ui()


func _refresh_auto_farm_ui() -> void:
	if not is_instance_valid(auto_farm_button):
		return
	if _auto_farm_controller == null or not is_instance_valid(_auto_farm_controller):
		_connect_auto_farm_controller()
	if _auto_farm_controller == null:
		auto_farm_status.text = Loc.t("portal.auto_farm_ready")
		auto_farm_button.text = Loc.t("portal.auto_farm_start")
		return
	_syncing_auto_farm_button = true
	var running := bool(_auto_farm_controller.get("is_running"))
	auto_farm_button.set_pressed_no_signal(running)
	auto_farm_button.text = Loc.t("portal.auto_farm_stop") if running else Loc.t("portal.auto_farm_start")
	auto_farm_status.text = String(_auto_farm_controller.get("status_text"))
	_syncing_auto_farm_button = false


func _on_auto_farm_toggled(pressed: bool) -> void:
	if _syncing_auto_farm_button:
		return
	_connect_auto_farm_controller()
	if _auto_farm_controller == null:
		return
	_auto_farm_controller.call("set_running", pressed)
	_refresh_auto_farm_ui()


func _refresh_afk_chest() -> void:
	var status := GameState.afk_chest_status()
	var milestone := maxi(int(status["milestone_seconds"]), 1)
	var progress := int(status["progress_seconds"])
	var available := int(status["available"])
	chest_progress.max_value = milestone
	chest_progress.value = progress
	chest_claim_button.disabled = available <= 0
	if available > 0:
		chest_progress_label.text = Loc.t("afk.chest_ready") % available
		chest_claim_button.text = Loc.t("afk.chest_claim_count") % available
	else:
		chest_progress_label.text = Loc.t("afk.chest_progress") % [progress / 60, milestone / 60]
		chest_claim_button.text = Loc.t("afk.chest_waiting")


func _on_claim_afk_chests() -> void:
	var rewards := GameState.claim_afk_chests()
	if rewards.is_empty():
		return
	var parts := [
		"+%d %s" % [int(rewards["gold"]), Loc.t("ui.gold").to_lower()],
		"+%d %s" % [int(rewards["xp"]), Loc.t("ui.xp")],
	]
	sweep_feedback.text = Loc.t("afk.chest_claimed") % [int(rewards["count"]), " · ".join(parts)]
	sweep_feedback.visible = true
	_refresh_afk_chest()


func _rebuild_gate_list() -> void:
	for child in gate_list.get_children():
		gate_list.remove_child(child)
		child.queue_free()
	for gate in ContentDB.gate_count():
		gate_list.add_child(_make_gate_row(gate + 1))


func _make_gate_row(gate: int) -> PanelContainer:
	var is_cleared := gate <= GameState.highest_gate_cleared
	var is_current := gate == GameState.current_gate()
	var gate_def := ContentDB.gate_row(gate)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 48)
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.04, 0.055, 0.1, 0.88)
	panel.border_color = (
		Color(0.22, 0.86, 1, 0.62) if is_current
		else Color(0.25, 0.68, 0.48, 0.48) if is_cleared
		else Color(0.28, 0.31, 0.4, 0.4)
	)
	panel.set_border_width_all(1)
	panel.set_corner_radius_all(9)
	panel.content_margin_left = 7
	panel.content_margin_right = 7
	panel.content_margin_top = 3
	panel.content_margin_bottom = 3
	card.add_theme_stylebox_override("panel", panel)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 7)
	card.add_child(row)

	var image_path := "res://assets/icons/icon_lock.svg"
	if is_cleared or is_current:
		image_path = "res://assets/icons/icon_boss.svg" if bool(gate_def.get("boss_wave", false)) else "res://assets/icons/icon_portals.svg"
	var icon := TextureRect.new()
	ArtHelper.configure_rect(icon, ArtHelper.texture(image_path), Vector2(34, 34))
	icon.modulate = Color(0.48, 0.54, 0.7) if not (is_cleared or is_current) else Color.WHITE
	row.add_child(icon)

	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 15)
	var base := "%s %d — " % [Loc.t("ui.gate"), gate]
	var color := Color(0.58, 0.62, 0.72)
	if is_cleared:
		label.text = base + Loc.t("portal.cleared")
		color = Color(0.35, 0.85, 0.55)
	elif is_current:
		label.text = base + Loc.t("portal.current")
		color = Color(0.216, 0.878, 1)
	else:
		label.text = base + Loc.t("ui.locked")
	label.add_theme_color_override("font_color", color)
	icon.tooltip_text = label.text
	row.add_child(label)

	# Varredura apenas em portais já concluídos (spec §4/§10.11).
	if is_cleared:
		var sweep_button := Button.new()
		sweep_button.text = Loc.t("portal.sweep")
		sweep_button.custom_minimum_size = Vector2(150, 44)
		sweep_button.add_theme_font_size_override("font_size", 15)
		sweep_button.pressed.connect(_on_sweep.bind(gate))
		row.add_child(sweep_button)
	return card


func _on_sweep(gate: int) -> void:
	var rewards := GameState.sweep_gate(gate)
	if rewards.is_empty():
		return
	var parts: Array = [
		"+%d %s" % [int(rewards["gold"]), Loc.t("ui.gold")],
	]
	if int(rewards["essence"]) > 0:
		parts.append("+%d %s" % [int(rewards["essence"]), Loc.t("ui.essence")])
	parts.append("+%d %s" % [int(rewards["xp"]), Loc.t("ui.xp")])
	sweep_feedback.text = "%s %d — %s %s" % [
		Loc.t("ui.gate"), gate, Loc.t("portal.sweep_got"), " · ".join(parts),
	]
	sweep_feedback.visible = true


func _on_start_pressed() -> void:
	if _auto_farm_controller != null and bool(_auto_farm_controller.get("is_running")):
		_auto_farm_controller.call("set_running", false)
	get_tree().call_group("navigation", "show_overlay", "gate_prep")
