extends Control
## Tela Portais (spec §5.1): hub principal com perfil circular, recursos,
## portal e loja como imagens clicáveis (nome embaixo, sem botões quadrados),
## baú AFK, farm automático, varredura de portais concluídos (spec §4) e
## seletor com o caminho de portais concluídos/atuais/bloqueados.
## A composição visual fica em portal_map.tscn; este script liga dados e ações.

const ArtHelper = preload("res://scripts/ui/art_helper.gd")

@onready var level_value: Label = $HubPresentation/ResourcePanel/StatsRow/LevelStat/LevelValue
@onready var gold_value: Label = $HubPresentation/ResourcePanel/StatsRow/GoldStat/GoldValue
@onready var xp_value: Label = $HubPresentation/ResourcePanel/StatsRow/XpStat/XpValue
@onready var essence_value: Label = $HubPresentation/ResourcePanel/StatsRow/EssenceStat/EssenceValue
@onready var profile_button: TextureButton = $HubPresentation/ProfileHotspot
@onready var settings_button: TextureButton = $HubPresentation/SettingsButton
@onready var portal_hotspot: TextureButton = $HubPresentation/PortalPanel/PortalContent/PortalHotspot
@onready var portal_title: Label = $HubPresentation/PortalPanel/PortalContent/PortalTitle
@onready var gate_label: Label = $HubPresentation/PortalPanel/PortalContent/GateLabel
@onready var best_label: Label = $HubPresentation/PortalPanel/PortalContent/BestLabel
@onready var view_portals_button: Button = $HubPresentation/PortalPanel/PortalContent/ViewPortalsButton
@onready var store_hotspot: TextureButton = $HubPresentation/ShopHotspotPanel/StoreHotspot
@onready var shop_title: Label = $HubPresentation/ShopHotspotPanel/ShopTitle
@onready var shop_subtitle: Label = $HubPresentation/ShopHotspotPanel/ShopSubtitle
@onready var chest_title: Label = $HubPresentation/AfkChestPanel/AfkChestRow/ChestInfo/ChestTitle
@onready var chest_progress: ProgressBar = $HubPresentation/AfkChestPanel/AfkChestRow/ChestInfo/ChestProgress
@onready var chest_progress_label: Label = $HubPresentation/AfkChestPanel/AfkChestRow/ChestInfo/ChestProgressLabel
@onready var chest_claim_button: Button = $HubPresentation/AfkChestPanel/AfkChestRow/ChestClaimButton
@onready var auto_farm_status: Label = $HubPresentation/AutoFarmPanel/AutoFarmRow/AutoFarmStatus
@onready var auto_farm_button: Button = $HubPresentation/AutoFarmPanel/AutoFarmRow/AutoFarmButton
@onready var sweep_feedback: Label = $HubPresentation/SweepFeedbackLabel
@onready var warning_label: Label = $HubPresentation/WarningLabel
@onready var gate_selector: Control = $HubPresentation/GateSelector
@onready var gate_title: Label = $HubPresentation/GateSelector/SelectorCard/SelectorContent/SelectorHeader/GateSelectorTitle
@onready var close_gate_button: Button = $HubPresentation/GateSelector/SelectorCard/SelectorContent/SelectorHeader/CloseGateButton
@onready var gate_scroll: ScrollContainer = $HubPresentation/GateSelector/SelectorCard/SelectorContent/GateScroll
@onready var gate_list: VBoxContainer = $HubPresentation/GateSelector/SelectorCard/SelectorContent/GateScroll/GateList

var _auto_farm_controller: Node = null
var _syncing_auto_farm_button: bool = false
var _chest_refresh_accumulator: float = 0.0


func _ready() -> void:
	add_to_group("portal_map")
	GameState.state_changed.connect(_refresh)
	profile_button.pressed.connect(_on_profile)
	settings_button.pressed.connect(_on_settings)
	portal_hotspot.pressed.connect(_on_start_pressed)
	view_portals_button.pressed.connect(_toggle_gate_selector)
	store_hotspot.pressed.connect(_on_store)
	auto_farm_button.toggled.connect(_on_auto_farm_toggled)
	chest_claim_button.pressed.connect(_on_claim_afk_chests)
	close_gate_button.pressed.connect(_close_gate_selector)
	portal_title.text = Loc.t("portal.title", "Portais")
	view_portals_button.text = Loc.t("portal.gate_map")
	gate_title.text = Loc.t("portal.selector_title", "Mapa de portais")
	shop_title.text = Loc.t("store.title")
	shop_subtitle.text = Loc.t("store.subtitle")
	chest_title.text = Loc.t("afk.chest_title")
	profile_button.tooltip_text = Loc.t("profile.title")
	settings_button.tooltip_text = Loc.t("settings.title")
	_setup_hotspot(profile_button)
	_setup_hotspot(portal_hotspot)
	_setup_hotspot(store_hotspot)
	call_deferred("_connect_auto_farm_controller")
	_refresh()


## Imagem como botão: só o desenho conta como área de toque, e a imagem
## afunda levemente ao ser pressionada (sem moldura nem fundo de botão).
func _setup_hotspot(button: TextureButton) -> void:
	_apply_click_mask(button)
	button.resized.connect(_update_pivot.bind(button))
	_update_pivot(button)
	button.button_down.connect(_tween_press.bind(button, Vector2(0.96, 0.96)))
	button.button_up.connect(_tween_press.bind(button, Vector2.ONE))


func _apply_click_mask(button: TextureButton) -> void:
	var texture := button.texture_normal
	if texture == null:
		return
	var mask := BitMap.new()
	mask.create_from_image_alpha(texture.get_image(), 0.2)
	button.texture_click_mask = mask


func _update_pivot(button: Control) -> void:
	button.pivot_offset = button.size * 0.5


func _tween_press(button: Control, target_scale: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(button, "scale", target_scale, 0.08)


func _toggle_gate_selector() -> void:
	gate_selector.visible = not gate_selector.visible
	if gate_selector.visible:
		gate_scroll.scroll_vertical = 0


func _close_gate_selector() -> void:
	gate_selector.visible = false


func _refresh() -> void:
	level_value.text = "%s %d" % [Loc.t("ui.level"), GameState.hunter_level()]
	gold_value.text = str(GameState.gold)
	xp_value.text = str(GameState.hunter_xp)
	essence_value.text = str(GameState.shadow_essence)
	var current_gate := GameState.current_gate()
	var current_gate_def := ContentDB.gate_row(current_gate)
	if GameState.campaign_complete():
		gate_label.text = Loc.t("portal.campaign_complete") % GameState.highest_gate_cleared
		portal_hotspot.tooltip_text = Loc.t("portal.replay_gate") % current_gate
	else:
		gate_label.text = "%s %d — %s" % [
			Loc.t("portal.current"), current_gate, String(current_gate_def.get("display_name", "")),
		]
		portal_hotspot.tooltip_text = "%s %s %d" % [Loc.t("ui.start_battle"), Loc.t("ui.gate"), current_gate]
	best_label.text = "%s %d · %s" % [
		Loc.t("portal.best"), GameState.highest_gate_cleared, Loc.t("portal.tap_to_start"),
	]
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
