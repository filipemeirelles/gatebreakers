extends Control
## Tela Caçador (spec §5.6): nível/XP/atributos de Jinwoo e melhoria.
## A melhoria (spec §4/Fase 4) mostra nível atual, custo, nível/atributos
## previstos e botão de confirmação; bloqueada com recurso em falta.

const ArtHelper = preload("res://scripts/ui/art_helper.gd")

@onready var hero_portrait: TextureRect = $Margin/VBox/HeroPortrait
@onready var level_label: Label = $Margin/VBox/LevelLabel
@onready var xp_label: Label = $Margin/VBox/XpLabel
@onready var cost_label: Label = $Margin/VBox/CostLabel
@onready var attrs_label: Label = $Margin/VBox/AttrsLabel
@onready var predicted_label: Label = $Margin/VBox/PredictedLabel
@onready var upgrade_button: Button = $Margin/VBox/UpgradeButton

const COLOR_AVAILABLE := Color(1, 0.75, 0.3, 1)
const COLOR_MISSING := Color(1, 0.45, 0.45, 1)
## Toque duplo rápido não pode comprar dois níveis (spec §7).
const DOUBLE_TAP_MS := 400

var _last_upgrade_ms: int = -100000


func _ready() -> void:
	GameState.state_changed.connect(_refresh)
	$Margin/VBox/Title.text = Loc.t("hunter.title")
	ArtHelper.configure_rect(hero_portrait, ArtHelper.unit_texture("jinwoo"), Vector2(176, 188))
	hero_portrait.tooltip_text = "Sung Jinwoo"
	upgrade_button.pressed.connect(_on_upgrade)
	_refresh()


func _refresh() -> void:
	var info := GameState.hunter_upgrade_info()
	level_label.text = "%s %d" % [Loc.t("ui.level"), GameState.hunter_level()]
	var stats := GameState.unit_stats("jinwoo")
	attrs_label.text = Loc.t("ui.stats") % [
		int(stats.get("hp", 0)), int(stats.get("attack", 0)),
		int(stats.get("defense", 0)), int(stats.get("speed", 0)),
	]
	if bool(info["at_max"]):
		xp_label.text = "%s %d (%s)" % [Loc.t("ui.xp"), GameState.hunter_xp, Loc.t("ui.max")]
		cost_label.text = "—"
		predicted_label.text = ""
		upgrade_button.disabled = true
		upgrade_button.text = "%s — %s" % [Loc.t("ui.upgrade"), Loc.t("ui.max")]
		return
	xp_label.text = "%s %d / %d" % [Loc.t("ui.xp"), GameState.hunter_xp, int(info["xp_cost"])]
	if bool(info["available"]):
		cost_label.add_theme_color_override("font_color", COLOR_AVAILABLE)
		cost_label.text = Loc.t("hunter.cost_next") % [
			int(info["gold_cost"]), Loc.t("ui.gold").to_lower(),
		]
	else:
		cost_label.add_theme_color_override("font_color", COLOR_MISSING)
		cost_label.text = Loc.t("hunter.missing") % [
			int(info["missing_xp"]), Loc.t("ui.xp"),
			int(info["missing_gold"]), Loc.t("ui.gold").to_lower(),
		]
	var next_stats: Dictionary = info["next_stats"]
	predicted_label.text = Loc.t("hunter.predicted") % [
		int(info["next_level"]),
		Loc.t("ui.stats") % [
			int(next_stats.get("hp", 0)), int(next_stats.get("attack", 0)),
			int(next_stats.get("defense", 0)), int(next_stats.get("speed", 0)),
		],
	]
	upgrade_button.disabled = not bool(info["available"])
	upgrade_button.text = Loc.t("hunter.upgrade_to") % int(info["next_level"])


func _on_upgrade() -> void:
	var now := Time.get_ticks_msec()
	if now - _last_upgrade_ms < DOUBLE_TAP_MS:
		return
	_last_upgrade_ms = now
	GameState.upgrade_hunter()
