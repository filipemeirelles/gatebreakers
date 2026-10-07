extends Control
## Tela Sombras (spec §5.7): unidades desbloqueadas, níveis, formação e
## melhoria usando gold + shadow essence (spec §4/Fase 4 — §10.6).

const ArtHelper = preload("res://scripts/ui/art_helper.gd")

@onready var formation_label: Label = $Margin/VBox/FormationLabel
@onready var unit_list: VBoxContainer = $Margin/VBox/Scroll/UnitList

const COLOR_COST := Color(1, 0.75, 0.3, 1)
const COLOR_MISSING := Color(1, 0.45, 0.45, 1)
const COLOR_MAX := Color(0.35, 0.85, 0.55, 1)
## Toque duplo rápido não pode comprar dois níveis (spec §7).
const DOUBLE_TAP_MS := 400

var _last_upgrade_ms: int = -100000


func _ready() -> void:
	GameState.state_changed.connect(_refresh)
	$Margin/VBox/Title.text = Loc.t("shadows.title")
	_refresh()


func _refresh() -> void:
	var names: Array = []
	for unit_id in GameState.formation:
		names.append(str(ContentDB.unit(unit_id).get("display_name", unit_id)))
	formation_label.text = Loc.t("shadows.formation") % ", ".join(names)
	for child in unit_list.get_children():
		unit_list.remove_child(child)
		child.queue_free()
	for def in ContentDB.all_units():
		var unit_id := String(def["id"])
		if unit_id == "jinwoo":
			continue
		unit_list.add_child(_make_row(unit_id, def))


func _make_row(unit_id: String, def: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 128)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.045, 0.05, 0.1, 0.94)
	panel.border_color = Color(0.29, 0.25, 0.52, 0.75)
	panel.set_border_width_all(1)
	panel.set_corner_radius_all(12)
	panel.content_margin_left = 10
	panel.content_margin_top = 8
	panel.content_margin_right = 10
	panel.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", panel)

	var content := HBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 12)
	card.add_child(content)

	var portrait := TextureRect.new()
	ArtHelper.configure_rect(portrait, ArtHelper.unit_texture(unit_id), Vector2(102, 102))
	portrait.name = "Portrait"
	content.add_child(portrait)

	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 4)
	content.add_child(details)

	var title := Label.new()
	title.add_theme_font_size_override("font_size", 16)
	title.text = String(def.get("display_name", unit_id))
	details.add_child(title)

	if not GameState.is_unlocked(unit_id):
		portrait.modulate = Color(0.5, 0.52, 0.62, 0.75)
		var unlock: Dictionary = def.get("unlock", {})
		var locked := Label.new()
		locked.add_theme_font_size_override("font_size", 14)
		locked.add_theme_color_override("font_color", Color(0.62, 0.66, 0.76))
		locked.text = "%s — Portal %d" % [Loc.t("ui.locked"), int(unlock.get("gate", 0))]
		details.add_child(locked)
		return card

	var info := GameState.shadow_upgrade_info(unit_id)
	var in_team := GameState.formation.has(unit_id)
	if in_team:
		title.text += " · %s" % Loc.t("shadows.in_formation")

	# Atributos atuais e previstos (spec §4 linha 128).
	var current: Dictionary = info["current_stats"]
	var stats_line := Label.new()
	stats_line.add_theme_font_size_override("font_size", 13)
	stats_line.add_theme_color_override("font_color", Color(0.66, 0.7, 0.8, 1))
	stats_line.text = Loc.t("ui.stats") % [
		int(current.get("hp", 0)), int(current.get("attack", 0)),
		int(current.get("defense", 0)), int(current.get("speed", 0)),
	]
	details.add_child(stats_line)

	var next_stats: Dictionary = info.get("next_stats", {})
	var cost_line := Label.new()
	cost_line.add_theme_font_size_override("font_size", 13)
	if bool(info["at_max"]):
		cost_line.text = Loc.t("ui.max")
		cost_line.add_theme_color_override("font_color", COLOR_MAX)
	elif bool(info["available"]):
		cost_line.text = Loc.t("shadows.cost") % [
			int(info["gold_cost"]), Loc.t("ui.gold").to_lower(),
			int(info["essence_cost"]), Loc.t("ui.essence").to_lower(),
		]
		cost_line.add_theme_color_override("font_color", COLOR_COST)
	else:
		cost_line.text = Loc.t("shadows.missing") % [
			int(info["missing_gold"]), Loc.t("ui.gold").to_lower(),
			int(info["missing_essence"]), Loc.t("ui.essence").to_lower(),
		]
		cost_line.add_theme_color_override("font_color", COLOR_MISSING)
	details.add_child(cost_line)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 8)

	var upgrade_button := Button.new()
	upgrade_button.custom_minimum_size = Vector2(160, 42)
	upgrade_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_button.add_theme_font_size_override("font_size", 14)
	upgrade_button.disabled = not bool(info["available"])
	if bool(info["at_max"]):
		upgrade_button.text = "%s — %s" % [Loc.t("ui.upgrade"), Loc.t("ui.max")]
	else:
		upgrade_button.text = "%s → %d" % [Loc.t("ui.upgrade"), int(info["next_level"])]
	upgrade_button.pressed.connect(_on_upgrade.bind(unit_id))
	buttons.add_child(upgrade_button)

	var toggle_button := Button.new()
	toggle_button.custom_minimum_size = Vector2(140, 42)
	toggle_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toggle_button.add_theme_font_size_override("font_size", 14)
	if in_team:
		toggle_button.text = Loc.t("shadows.remove")
		toggle_button.pressed.connect(_on_remove.bind(unit_id))
	else:
		toggle_button.text = Loc.t("shadows.add")
		toggle_button.disabled = GameState.formation.size() >= GameState.MAX_TEAM_SIZE
		toggle_button.pressed.connect(_on_add.bind(unit_id))
	buttons.add_child(toggle_button)
	details.add_child(buttons)
	return card


func _on_upgrade(unit_id: String) -> void:
	var now := Time.get_ticks_msec()
	if now - _last_upgrade_ms < DOUBLE_TAP_MS:
		return
	_last_upgrade_ms = now
	GameState.upgrade_shadow(unit_id)


func _on_add(unit_id: String) -> void:
	GameState.add_to_formation(unit_id)


func _on_remove(unit_id: String) -> void:
	GameState.remove_from_formation(unit_id)
