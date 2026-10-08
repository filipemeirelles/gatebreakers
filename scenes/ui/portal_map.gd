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
@onready var gate_scroll: ScrollContainer = $Margin/VBox/GateScroll
@onready var start_button: Button = $Margin/VBox/StartButton
@onready var warning_label: Label = $Margin/VBox/WarningLabel
@onready var auto_farm_status: Label = $Margin/VBox/AutoFarmPanel/AutoFarmRow/AutoFarmStatus
@onready var auto_farm_button: Button = $Margin/VBox/AutoFarmPanel/AutoFarmRow/AutoFarmButton
@onready var chest_progress: ProgressBar = $Margin/VBox/AfkChestPanel/AfkChestRow/ChestInfo/ChestProgress
@onready var chest_progress_label: Label = $Margin/VBox/AfkChestPanel/AfkChestRow/ChestInfo/ChestProgressLabel
@onready var chest_claim_button: Button = $Margin/VBox/AfkChestPanel/AfkChestRow/ChestClaimButton
@onready var afk_chest_panel: PanelContainer = $Margin/VBox/AfkChestPanel
@onready var farm_panel_control: PanelContainer = $Margin/VBox/AutoFarmPanel
@onready var profile_chip: Button = $Margin/VBox/HubHeader/ProfileChip
@onready var store_button: Button = $Margin/VBox/HubHeader/StoreButton
@onready var gear_button: Button = $Margin/VBox/HubHeader/GearButton

var _hub_ui: Control
var _portal_hotspot: Button
var _view_portals_button: Button
var _gate_selector: Control
var _auto_farm_controller: Node = null
var _syncing_auto_farm_button: bool = false
var _chest_refresh_accumulator: float = 0.0


func _ready() -> void:
	add_to_group("portal_map")
	GameState.state_changed.connect(_refresh)
	start_button.pressed.connect(_on_start_pressed)
	auto_farm_button.toggled.connect(_on_auto_farm_toggled)
	chest_claim_button.pressed.connect(_on_claim_afk_chests)
	$Margin/VBox/HubHeader/GearButton.pressed.connect(_on_settings)
	$Margin/VBox/HubHeader/ProfileChip.pressed.connect(_on_profile)
	$Margin/VBox/HubHeader/StoreButton.pressed.connect(_on_store)
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
	profile_chip.icon = ArtHelper.unit_texture("jinwoo")
	gear_button.icon = ArtHelper.texture("res://assets/icons/icon_settings.svg")
	store_button.icon = ArtHelper.texture("res://assets/icons/icon_gold.svg")
	_build_hub_presentation()
	_refresh()


func _build_hub_presentation() -> void:
	$HubDim.color = Color(0.015, 0.02, 0.055, 0.12)
	$Margin.visible = false
	_hub_ui = Control.new()
	_hub_ui.name = "HubPresentation"
	_hub_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hub_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hub_ui)

	# Perfil: círculo com rosto no canto superior esquerdo.
	var profile_btn := _make_image_button("ProfileHotspot", _hub_ui,
		ArtHelper.unit_texture("jinwoo"), "", Vector2(80, 80))
	_set_hub_region(profile_btn, 0.0, 0.0, 0.0, 0.0, 18.0, 18.0, 98.0, 98.0)
	profile_btn.pressed.connect(_on_profile)
	var profile_ring := ColorRect.new()
	profile_ring.color = Color(0.24, 0.72, 0.96, 0.7)
	profile_ring.set_anchors_preset(Control.PRESET_FULL_RECT)
	profile_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	profile_btn.add_child(profile_ring)
	profile_ring.move_to_front()
	# Moldura circular: usar TextureRect com máscara seria ideal; por ora o
	# recorte do Jinwoo já tem fundo transparente e lê como medalhão.

	# Recursos: faixa discreta no topo, sem painel.
	var resources := HBoxContainer.new()
	resources.name = "ResourceStrip"
	resources.add_theme_constant_override("separation", 18)
	_set_hub_region(resources, 0.0, 0.0, 1.0, 0.0, 110.0, 24.0, -18.0, 66.0)
	_hub_ui.add_child(resources)
	$Margin/VBox/StatsRow.add_theme_constant_override("separation", 6)
	_move_hub_control($Margin/VBox/StatsRow, resources)

	# Portal: imagem grande clicável com nome embaixo.
	var portal_vbox := VBoxContainer.new()
	portal_vbox.name = "PortalHotspot"
	portal_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	portal_vbox.add_theme_constant_override("separation", 6)
	_set_hub_region(portal_vbox, 0.42, 0.16, 0.98, 0.52, 0.0, 0.0, 0.0, 0.0)
	_hub_ui.add_child(portal_vbox)
	var portal_img := TextureRect.new()
	portal_img.texture = ArtHelper.texture("res://assets/icons/icon_portals.svg")
	portal_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portal_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portal_img.custom_minimum_size = Vector2(160, 160)
	portal_img.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	portal_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portal_vbox.add_child(portal_img)
	gate_label.add_theme_font_size_override("font_size", 18)
	gate_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gate_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_move_hub_control(gate_label, portal_vbox)
	best_label.add_theme_font_size_override("font_size", 12)
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_move_hub_control(best_label, portal_vbox)
	warning_label.add_theme_font_size_override("font_size", 12)
	_move_hub_control(warning_label, portal_vbox)
	_portal_hotspot = start_button
	_portal_hotspot.text = Loc.t("ui.start_battle")
	_portal_hotspot.custom_minimum_size = Vector2(180, 52)
	_portal_hotspot.add_theme_font_size_override("font_size", 17)
	_move_hub_control(_portal_hotspot, portal_vbox)
	_view_portals_button = Button.new()
	_view_portals_button.name = "ViewPortalsButton"
	_view_portals_button.text = Loc.t("portal.gate_map")
	_view_portals_button.flat = true
	_view_portals_button.add_theme_font_size_override("font_size", 13)
	_view_portals_button.pressed.connect(_toggle_gate_selector)
	portal_vbox.add_child(_view_portals_button)
	# Área de clique ampla: todo o VBox do portal.
	var portal_click := Button.new()
	portal_click.name = "PortalClickArea"
	portal_click.flat = true
	portal_click.set_anchors_preset(Control.PRESET_FULL_RECT)
	portal_click.mouse_filter = Control.MOUSE_FILTER_STOP
	portal_click.pressed.connect(_on_start_pressed)
	portal_vbox.add_child(portal_click)
	portal_click.move_to_front()

	# Loja: imagem clicável com nome embaixo.
	var shop_vbox := VBoxContainer.new()
	shop_vbox.name = "StoreHotspot"
	shop_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	shop_vbox.add_theme_constant_override("separation", 4)
	_set_hub_region(shop_vbox, 0.58, 0.54, 0.98, 0.72, 0.0, 0.0, 0.0, 0.0)
	_hub_ui.add_child(shop_vbox)
	var shop_img := TextureRect.new()
	shop_img.texture = ArtHelper.texture("res://assets/icons/icon_gold.svg")
	shop_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shop_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	shop_img.custom_minimum_size = Vector2(100, 100)
	shop_img.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	shop_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shop_vbox.add_child(shop_img)
	var shop_name := Label.new()
	shop_name.text = Loc.t("store.title")
	shop_name.add_theme_font_size_override("font_size", 13)
	shop_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shop_vbox.add_child(shop_name)
	var shop_click := Button.new()
	shop_click.name = "StoreClickArea"
	shop_click.flat = true
	shop_click.set_anchors_preset(Control.PRESET_FULL_RECT)
	shop_click.mouse_filter = Control.MOUSE_FILTER_STOP
	shop_click.pressed.connect(_on_store)
	shop_vbox.add_child(shop_click)
	shop_click.move_to_front()

	# Baú AFK: imagem + nome, sem painel.
	var chest_vbox := VBoxContainer.new()
	chest_vbox.name = "AfkChestPanel"
	chest_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	chest_vbox.add_theme_constant_override("separation", 3)
	_set_hub_region(chest_vbox, 0.025, 1.0, 0.68, 1.0, 0.0, -310.0, 0.0, -190.0)
	_hub_ui.add_child(chest_vbox)
	_move_hub_control(afk_chest_panel, chest_vbox)
	afk_chest_panel.add_theme_stylebox_override("panel", _hub_panel_style(0.0))

	# Farm: faixa discreta.
	_set_hub_region(farm_panel_control, 0.025, 1.0, 0.975, 1.0, 0.0, -174.0, 0.0, -10.0)
	_move_hub_control(farm_panel_control, _hub_ui)
	farm_panel_control.add_theme_stylebox_override("panel", _hub_panel_style(0.72))
	auto_farm_button.custom_minimum_size = Vector2(148, 48)

	# Feedback de varredura.
	var feedback_region := Control.new()
	feedback_region.name = "SweepFeedbackRegion"
	_set_hub_region(feedback_region, 0.025, 1.0, 0.975, 1.0, 0.0, -365.0, 0.0, -310.0)
	_hub_ui.add_child(feedback_region)
	_move_hub_control(sweep_feedback, feedback_region)
	sweep_feedback.set_anchors_preset(Control.PRESET_FULL_RECT)
	sweep_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sweep_feedback.add_theme_font_size_override("font_size", 14)

	_build_gate_selector()


func _make_image_button(btn_name: String, parent: Control, texture: Texture2D, label_text: String, min_size: Vector2) -> Button:
	var btn := Button.new()
	btn.name = btn_name
	btn.flat = true
	btn.custom_minimum_size = min_size
	btn.icon = texture
	btn.expand_icon = true
	btn.text = label_text
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(btn)
	return btn


func _build_gate_selector() -> void:
	_gate_selector = Control.new()
	_gate_selector.name = "GateSelector"
	_gate_selector.set_anchors_preset(Control.PRESET_FULL_RECT)
	_gate_selector.mouse_filter = Control.MOUSE_FILTER_STOP
	_gate_selector.visible = false
	_hub_ui.add_child(_gate_selector)
	var scrim := ColorRect.new()
	scrim.name = "Scrim"
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.005, 0.01, 0.025, 0.78)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	_gate_selector.add_child(scrim)
	var panel := _make_hub_panel("SelectorCard", _gate_selector, 0.98)
	_set_hub_region(panel, 0.055, 0.08, 0.945, 0.92, 0.0, 0.0, 0.0, 0.0)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)
	var header := HBoxContainer.new()
	content.add_child(header)
	var title := Label.new()
	title.text = Loc.t("portal.gate_map")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 23)
	title.add_theme_color_override("font_color", Color(0.55, 0.87, 1.0))
	header.add_child(title)
	var close_button := Button.new()
	close_button.text = "×"
	close_button.custom_minimum_size = Vector2(48, 46)
	close_button.add_theme_font_size_override("font_size", 24)
	close_button.pressed.connect(_close_gate_selector)
	header.add_child(close_button)
	gate_scroll.custom_minimum_size = Vector2(0, 560)
	gate_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	gate_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_move_hub_control(gate_scroll, content)


func _make_hub_panel(panel_name: String, parent: Control, alpha: float = 0.86) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = panel_name
	panel.add_theme_stylebox_override("panel", _hub_panel_style(alpha))
	parent.add_child(panel)
	return panel


func _hub_panel_style(alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.04, 0.09, alpha)
	style.border_color = Color(0.24, 0.72, 0.96, 0.64)
	style.set_border_width_all(1)
	style.set_corner_radius_all(16)
	style.content_margin_left = 13
	style.content_margin_top = 10
	style.content_margin_right = 13
	style.content_margin_bottom = 10
	return style


func _set_hub_region(node: Control, left: float, top: float, right: float, bottom: float,
		inset_left: float, inset_top: float, inset_right: float, inset_bottom: float) -> void:
	node.set_anchors_preset(Control.PRESET_FULL_RECT)
	node.anchor_left = left
	node.anchor_top = top
	node.anchor_right = right
	node.anchor_bottom = bottom
	node.offset_left = inset_left
	node.offset_top = inset_top
	node.offset_right = inset_right
	node.offset_bottom = inset_bottom


func _move_hub_control(node: Control, new_parent: Node) -> void:
	var previous := node.get_parent()
	if previous != null:
		previous.remove_child(node)
	new_parent.add_child(node)


func _toggle_gate_selector() -> void:
	if _gate_selector != null:
		_gate_selector.visible = not _gate_selector.visible
		if _gate_selector.visible:
			gate_scroll.scroll_vertical = 0


func _close_gate_selector() -> void:
	if _gate_selector != null:
		_gate_selector.visible = false


func _refresh() -> void:
	level_value.text = str(GameState.hunter_level())
	profile_chip.text = "%s · Nível %d" % [Loc.t("profile.hunter_name"), GameState.hunter_level()]
	profile_chip.tooltip_text = Loc.t("profile.title")
	gold_value.text = str(GameState.gold)
	xp_value.text = str(GameState.hunter_xp)
	essence_value.text = str(GameState.shadow_essence)
	best_label.text = "%s %d" % [Loc.t("portal.best"), GameState.highest_gate_cleared]
	var current_gate := GameState.current_gate()
	var current_gate_def := ContentDB.gate_row(current_gate)
	if GameState.campaign_complete():
		gate_label.text = Loc.t("portal.campaign_complete") % GameState.highest_gate_cleared
		start_button.text = Loc.t("portal.replay_gate") % GameState.current_gate()
	else:
		gate_label.text = "%s %d — %s" % [
			Loc.t("portal.current"), GameState.current_gate(), String(current_gate_def.get("display_name", "")),
		]
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
	SoundManager.play_chest()
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
	var base := "%s %d · %s [%s] — " % [
		Loc.t("ui.gate"), gate, String(gate_def.get("display_name", "")),
		String(gate_def.get("rank", "?")),
	]
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

	# Varredura apenas em portais já concluídos E com carga (E4).
	if is_cleared:
		var sweep_button := Button.new()
		var charges := int(GameState.sweep_charges.get(str(gate), 0))
		sweep_button.text = Loc.t("portal.sweep")
		if charges <= 0:
			sweep_button.disabled = true
			sweep_button.text = "%s (0)" % Loc.t("portal.sweep")
		else:
			sweep_button.text = "%s ×%d" % [Loc.t("portal.sweep"), charges]
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


func _on_profile() -> void:
	get_tree().call_group("navigation", "show_overlay", "profile")

func _on_store() -> void:
	get_tree().call_group("navigation", "show_overlay", "store")

func _on_settings() -> void:
	get_tree().call_group("navigation", "goto_destination", 6)

func _on_start_pressed() -> void:
	if _auto_farm_controller != null and bool(_auto_farm_controller.get("is_running")):
		_auto_farm_controller.call("set_running", false)
	get_tree().call_group("navigation", "show_overlay", "gate_prep")
