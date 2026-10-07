extends Control
## Relatório AFK (spec §5.2): tempo contado, limite aplicado quando houver,
## recompensas detalhadas e portal/taxa utilizados (critério §10.9).

const ArtHelper = preload("res://scripts/ui/art_helper.gd")

@onready var time_label: Label = $Margin/VBox/TimeLabel
@onready var rewards_label: Label = $Margin/VBox/RewardsLabel
@onready var gold_amount: Label = $Margin/VBox/RewardsStrip/GoldReward/GoldAmount
@onready var xp_amount: Label = $Margin/VBox/RewardsStrip/XpReward/XpAmount
@onready var rate_label: Label = $Margin/VBox/RateLabel


func _ready() -> void:
	$Margin/VBox/Title.text = Loc.t("afk.title")
	$Margin/VBox/ContinueButton.text = Loc.t("ui.continue")
	ArtHelper.configure_rect($Margin/VBox/RewardsStrip/GoldReward/GoldIcon, ArtHelper.texture("res://assets/icons/icon_gold.svg"), Vector2(42, 42))
	ArtHelper.configure_rect($Margin/VBox/RewardsStrip/XpReward/XpIcon, ArtHelper.texture("res://assets/icons/icon_xp.svg"), Vector2(42, 42))
	$Margin/VBox/ContinueButton.pressed.connect(_on_continue)


## Chamado pela navegação antes de mostrar o overlay.
func configure(data: Dictionary) -> void:
	var elapsed := int(data.get("elapsed", 0))
	time_label.text = Loc.t("afk.time") % _format_duration(elapsed)
	if bool(data.get("capped", false)):
		var cap_hours := int(BalanceConfig.afk_cap_seconds() / 3600)
		time_label.text += "\n" + (Loc.t("afk.capped") % cap_hours)

	rewards_label.text = Loc.t("afk.gained")
	gold_amount.text = "+%d %s" % [int(data.get("gold", 0)), Loc.t("ui.gold")]
	xp_amount.text = "+%d %s" % [int(data.get("xp", 0)), Loc.t("ui.xp")]

	rate_label.text = Loc.t("afk.rate") % [
		int(data.get("gate", 0)),
		int(data.get("gold_per_hour", 0)), Loc.t("ui.gold"),
		int(data.get("xp_per_hour", 0)), Loc.t("ui.xp"),
	]


static func _format_duration(seconds: int) -> String:
	var hours := seconds / 3600
	var minutes := (seconds % 3600) / 60
	var secs := seconds % 60
	var parts: Array = []
	if hours > 0:
		parts.append("%d%s" % [hours, Loc.t("afk.h")])
	if minutes > 0 or hours > 0:
		parts.append("%d%s" % [minutes, Loc.t("afk.min")])
	if hours == 0 and minutes == 0:
		parts.append("%d%s" % [secs, Loc.t("afk.s")])
	return " ".join(parts)


func _on_continue() -> void:
	get_tree().call_group("navigation", "close_and_check_story", "afk_report")
