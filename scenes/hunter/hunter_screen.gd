extends Control
## Tela Caçadores: Jinwoo (nível/atributos/habilidade) + caçadores contratáveis
## com stats e skills próprios, contratação (portal + ouro) e formação (≤3).
## A UI só desenha estado; regras vivem em GameState/CombatService.

const ArtHelper = preload("res://scripts/ui/art_helper.gd")

@onready var hero_portrait: TextureRect = $Margin/VBox/HeroSection/HeroPortrait
@onready var hero_level_label: Label = $Margin/VBox/HeroSection/HeroInfo/HeroLevelLabel
@onready var hero_stats_label: Label = $Margin/VBox/HeroSection/HeroInfo/HeroStatsLabel
@onready var hero_skill_label: Label = $Margin/VBox/HeroSection/HeroInfo/HeroSkillLabel
@onready var hero_upgrade_button: Button = $Margin/VBox/HeroSection/HeroInfo/HeroUpgradeButton
@onready var section_title: Label = $Margin/VBox/SectionTitle
@onready var hunter_list: VBoxContainer = $Margin/VBox/Scroll/HunterList

const COLOR_COST := Color(1, 0.75, 0.3, 1)
const COLOR_MISSING := Color(1, 0.45, 0.45, 1)
const COLOR_MAX := Color(0.35, 0.85, 0.55, 1)
## Toque duplo rápido não pode comprar dois níveis (spec §7).
const DOUBLE_TAP_MS := 400

var _last_action_ms: int = -100000


func _ready() -> void:
	GameState.state_changed.connect(_refresh)
	$Margin/VBox/Title.text = Loc.t("hunters.title")
	ArtHelper.configure_rect(hero_portrait, ArtHelper.unit_texture("jinwoo"), Vector2(96, 104))
	hero_upgrade_button.pressed.connect(_on_upgrade_hunter.bind("jinwoo"))
	$Margin/VBox/SummonButton.text = Loc.t("hunters.open_summons")
	$Margin/VBox/SummonButton.pressed.connect(_on_open_summons)
	_refresh()


func _on_open_summons() -> void:
	get_tree().call_group("navigation", "goto_shadows")


func _refresh() -> void:
	var jinwoo_info := GameState.hunter_upgrade_info()
	hero_level_label.text = "%s %d" % [Loc.t("ui.level"), GameState.hunter_level()]
	var stats := GameState.unit_stats("jinwoo")
	hero_stats_label.text = Loc.t("ui.stats") % [
		int(stats.get("hp", 0)), int(stats.get("attack", 0)),
		int(stats.get("defense", 0)), int(stats.get("speed", 0)),
	]
	hero_skill_label.text = _skill_line("jinwoo")
	hero_upgrade_button.disabled = not bool(jinwoo_info["available"])
	hero_upgrade_button.text = (
		"%s — %s" % [Loc.t("ui.upgrade"), Loc.t("ui.max")]
		if bool(jinwoo_info["at_max"])
		else "%s → %d" % [Loc.t("ui.upgrade"), int(jinwoo_info["next_level"])]
	)
	section_title.text = Loc.t("hunters.section_hunters")
	for child in hunter_list.get_children():
		hunter_list.remove_child(child)
		child.queue_free()
	for def in ContentDB.all_hunters():
		hunter_list.add_child(_make_row(String(def["id"]), def))


func _skill_line(unit_id: String) -> String:
	var def: Dictionary = ContentDB.unit(unit_id)
	if def.is_empty():
		def = ContentDB.hunter(unit_id)
	var skill_id := str(def.get("skill_id", ""))
	if skill_id.is_empty():
		return ""
	var name := Loc.t("skill.%s" % skill_id, skill_id)
	var cd := BalanceConfig.skill_cooldown_actions(skill_id)
	var desc := _skill_description(skill_id)
	return "★ %s (a cada %d) — %s" % [name, cd, desc]


func _skill_description(skill_id: String) -> String:
	match BalanceConfig.skill_target(skill_id):
		"self_guard":
			return Loc.t("skill.desc.guard")
		"ally_heal":
			return Loc.t("skill.desc.heal")
		"last":
			return Loc.t("skill.desc.backline")
		_:
			return Loc.t("skill.desc.blast")


func _make_row(hunter_id: String, def: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 150)
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
	content.add_theme_constant_override("separation", 12)
	card.add_child(content)

	var portrait := TextureRect.new()
	ArtHelper.configure_rect(portrait, ArtHelper.texture(str(def.get("art", ""))), Vector2(96, 104))
	content.add_child(portrait)

	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 3)
	content.add_child(details)

	var title := Label.new()
	title.add_theme_font_size_override("font_size", 16)
	title.text = "%s [%s]" % [String(def.get("display_name", hunter_id)), String(def.get("rank", "?"))]
	details.add_child(title)

	var info := GameState.hunter_contract_info(hunter_id)
	if not bool(info["hired"]):
		portrait.modulate = Color(0.55, 0.57, 0.66, 0.85) if not bool(info["unlocked"]) else Color.WHITE
		var status := Label.new()
		status.add_theme_font_size_override("font_size", 13)
		if bool(info["unlocked"]):
			status.text = Loc.t("hunters.hire_cost") % int(info["gold_cost"])
			status.add_theme_color_override("font_color", COLOR_COST)
		else:
			status.text = Loc.t("hunters.needs_gate") % int(info["gate_needed"])
			status.add_theme_color_override("font_color", Color(0.62, 0.66, 0.76))
		details.add_child(status)
		var skill := Label.new()
		skill.add_theme_font_size_override("font_size", 12)
		skill.add_theme_color_override("font_color", Color(0.72, 0.75, 0.85, 1))
		skill.text = _skill_line(hunter_id)
		details.add_child(skill)
		var hire := Button.new()
		hire.custom_minimum_size = Vector2(200, 42)
		hire.add_theme_font_size_override("font_size", 14)
		hire.text = Loc.t("hunters.hire")
		hire.disabled = not bool(info["can_hire"])
		hire.pressed.connect(_on_hire.bind(hunter_id))
		details.add_child(hire)
		return card

	portrait.modulate = Color.WHITE
	var in_team := bool(info["in_team"])
	if in_team:
		title.text += " · %s" % Loc.t("shadows.in_formation")
	var up := GameState.hunter_unit_upgrade_info(hunter_id)
	var stats: Dictionary = up.get("current_stats", {})
	var stats_line := Label.new()
	stats_line.add_theme_font_size_override("font_size", 13)
	stats_line.add_theme_color_override("font_color", Color(0.66, 0.7, 0.8, 1))
	stats_line.text = Loc.t("ui.stats") % [
		int(stats.get("hp", 0)), int(stats.get("attack", 0)),
		int(stats.get("defense", 0)), int(stats.get("speed", 0)),
	]
	details.add_child(stats_line)
	var skill := Label.new()
	skill.add_theme_font_size_override("font_size", 12)
	skill.add_theme_color_override("font_color", Color(0.72, 0.75, 0.85, 1))
	skill.text = _skill_line(hunter_id)
	details.add_child(skill)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 8)
	var upgrade_button := Button.new()
	upgrade_button.custom_minimum_size = Vector2(150, 42)
	upgrade_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_button.add_theme_font_size_override("font_size", 14)
	upgrade_button.disabled = not bool(up["available"])
	if bool(up["at_max"]):
		upgrade_button.text = "%s — %s" % [Loc.t("ui.upgrade"), Loc.t("ui.max")]
	else:
		upgrade_button.text = "%s → %d (%d %s)" % [
			Loc.t("ui.upgrade"), int(up["next_level"]), int(up["gold_cost"]), Loc.t("ui.gold").to_lower(),
		]
	upgrade_button.pressed.connect(_on_upgrade_hunter.bind(hunter_id))
	buttons.add_child(upgrade_button)

	var toggle := Button.new()
	toggle.custom_minimum_size = Vector2(130, 42)
	toggle.add_theme_font_size_override("font_size", 14)
	if in_team:
		toggle.text = Loc.t("shadows.remove")
		toggle.pressed.connect(_on_remove.bind(hunter_id))
	else:
		toggle.text = Loc.t("hunters.add_team")
		toggle.disabled = GameState.hunter_formation.size() >= GameState.HUNTER_TEAM_SIZE
		toggle.pressed.connect(_on_add.bind(hunter_id))
	buttons.add_child(toggle)
	details.add_child(buttons)
	return card


func _on_hire(hunter_id: String) -> void:
	_throttled(func() -> void: GameState.hire_hunter(hunter_id))


func _on_upgrade_hunter(hunter_id: String) -> void:
	_throttled(func() -> void:
		if hunter_id == "jinwoo":
			GameState.upgrade_hunter()
		else:
			GameState.upgrade_hunter_unit(hunter_id)
	)


func _on_add(hunter_id: String) -> void:
	GameState.add_hunter_to_team(hunter_id)


func _on_remove(hunter_id: String) -> void:
	GameState.remove_hunter_from_team(hunter_id)


func _throttled(action: Callable) -> void:
	var now := Time.get_ticks_msec()
	if now - _last_action_ms < DOUBLE_TAP_MS:
		return
	_last_action_ms = now
	action.call()
