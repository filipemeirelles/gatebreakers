extends Control
## Tela Sombras (spec §5.7): unidades desbloqueadas, níveis, formação e
## melhoria usando gold + shadow essence (spec §4/Fase 4 — §10.6).

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
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	if not GameState.is_unlocked(unit_id):
		var locked := Label.new()
		locked.add_theme_font_size_override("font_size", 17)
		locked.add_theme_color_override("font_color", Color(0.55, 0.55, 0.62))
		var unlock: Dictionary = def.get("unlock", {})
		locked.text = "%s — %s (Portal %d)" % [
			def["display_name"], Loc.t("ui.locked"), int(unlock.get("gate", 0)),
		]
		box.add_child(locked)
		return box

	var info := GameState.shadow_upgrade_info(unit_id)
	var in_team := GameState.formation.has(unit_id)

	var title := Label.new()
	title.add_theme_font_size_override("font_size", 17)
	title.text = "%s — %s %d" % [def["display_name"], Loc.t("ui.level"), GameState.unit_level(unit_id)]
	if in_team:
		title.text += " · " + Loc.t("shadows.in_formation")
	box.add_child(title)

	# Atributos atuais e previstos (spec §4 linha 128).
	var current: Dictionary = info["current_stats"]
	var stats_line := Label.new()
	stats_line.add_theme_font_size_override("font_size", 14)
	stats_line.add_theme_color_override("font_color", Color(0.6, 0.6, 0.68, 1))
	stats_line.text = Loc.t("ui.stats") % [
		int(current.get("hp", 0)), int(current.get("attack", 0)),
		int(current.get("defense", 0)), int(current.get("speed", 0)),
	]
	box.add_child(stats_line)
	if not bool(info["at_max"]):
		var next_stats: Dictionary = info["next_stats"]
		var next_line := Label.new()
		next_line.add_theme_font_size_override("font_size", 14)
		next_line.add_theme_color_override("font_color", Color(0.216, 0.878, 1, 1))
		next_line.text = Loc.t("shadows.next") % [
			int(info["next_level"]),
			Loc.t("ui.stats") % [
				int(next_stats.get("hp", 0)), int(next_stats.get("attack", 0)),
				int(next_stats.get("defense", 0)), int(next_stats.get("speed", 0)),
			],
		]
		box.add_child(next_line)

	# Custo ou quantidade em falta (spec §4 linha 121 — bloquear e mostrar o faltante).
	var cost_line := Label.new()
	cost_line.add_theme_font_size_override("font_size", 14)
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
	box.add_child(cost_line)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)

	var upgrade_button := Button.new()
	upgrade_button.custom_minimum_size = Vector2(180, 46)
	upgrade_button.add_theme_font_size_override("font_size", 15)
	upgrade_button.disabled = not bool(info["available"])
	if bool(info["at_max"]):
		upgrade_button.text = "%s — %s" % [Loc.t("ui.upgrade"), Loc.t("ui.max")]
	else:
		upgrade_button.text = "%s → %d" % [Loc.t("ui.upgrade"), int(info["next_level"])]
	upgrade_button.pressed.connect(_on_upgrade.bind(unit_id))
	buttons.add_child(upgrade_button)

	var toggle_button := Button.new()
	toggle_button.custom_minimum_size = Vector2(160, 46)
	toggle_button.add_theme_font_size_override("font_size", 15)
	if in_team:
		toggle_button.text = Loc.t("shadows.remove")
		toggle_button.pressed.connect(_on_remove.bind(unit_id))
	else:
		toggle_button.text = Loc.t("shadows.add")
		toggle_button.disabled = GameState.formation.size() >= GameState.MAX_TEAM_SIZE
		toggle_button.pressed.connect(_on_add.bind(unit_id))
	buttons.add_child(toggle_button)
	box.add_child(buttons)
	return box


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
