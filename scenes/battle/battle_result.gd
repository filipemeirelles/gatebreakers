extends Control
## Resultado (spec §5.5): vitória/derrota, recursos ganhos, portal desbloqueado
## e botão para tentar novamente na derrota.
## A recompensa já foi creditada pelo combate ao fim da batalha; aqui só se
## apresenta o resultado.

const ArtHelper = preload("res://scripts/ui/art_helper.gd")

@onready var title_label: Label = $Margin/VBox/TitleLabel
@onready var result_portrait: TextureRect = $Margin/VBox/ResultPortrait
@onready var rewards_label: Label = $Margin/VBox/RewardsLabel
@onready var reward_strip: HBoxContainer = $Margin/VBox/RewardStrip
@onready var gold_amount: Label = $Margin/VBox/RewardStrip/GoldReward/GoldAmount
@onready var xp_amount: Label = $Margin/VBox/RewardStrip/XpReward/XpAmount
@onready var essence_reward: HBoxContainer = $Margin/VBox/RewardStrip/EssenceReward
@onready var essence_amount: Label = $Margin/VBox/RewardStrip/EssenceReward/EssenceAmount
@onready var unlock_label: Label = $Margin/VBox/UnlockLabel
@onready var retry_button: Button = $Margin/VBox/RetryButton
@onready var continue_button: Button = $Margin/VBox/ContinueButton


func _ready() -> void:
	continue_button.text = Loc.t("ui.continue")
	retry_button.text = Loc.t("ui.retry")
	ArtHelper.configure_rect($Margin/VBox/RewardStrip/GoldReward/GoldIcon, ArtHelper.texture("res://assets/icons/icon_gold.svg"), Vector2(32, 32))
	ArtHelper.configure_rect($Margin/VBox/RewardStrip/XpReward/XpIcon, ArtHelper.texture("res://assets/icons/icon_xp.svg"), Vector2(32, 32))
	ArtHelper.configure_rect($Margin/VBox/RewardStrip/EssenceReward/EssenceIcon, ArtHelper.texture("res://assets/icons/icon_essence.svg"), Vector2(32, 32))
	continue_button.pressed.connect(_on_continue)
	retry_button.pressed.connect(_on_retry)


## Chamado pela navegação antes de mostrar o overlay (dados vindos do combate).
func configure(data: Dictionary) -> void:
	var victory := bool(data.get("victory", false))
	var gate := int(data.get("gate", 1))
	title_label.text = Loc.t("result.victory") if victory else Loc.t("result.defeat")
	result_portrait.texture = (
		ArtHelper.unit_texture("jinwoo") if victory
		else ArtHelper.enemy_texture(bool(ContentDB.gate(gate).get("has_boss", false)))
	)
	result_portrait.modulate = Color(1, 1, 1, 0)
	result_portrait.scale = Vector2(0.86, 0.86)
	var reveal := create_tween()
	reveal.set_trans(Tween.TRANS_BACK)
	reveal.set_ease(Tween.EASE_OUT)
	reveal.tween_property(result_portrait, "scale", Vector2.ONE, 0.28)
	reveal.parallel().tween_property(result_portrait, "modulate:a", 1.0, 0.24)
	title_label.add_theme_color_override(
		"font_color",
		Color(0.216, 0.878, 1) if victory else Color(0.95, 0.4, 0.45)
	)

	if victory:
		var rewards: Dictionary = data.get("rewards", {})
		gold_amount.text = "+%d" % int(rewards.get("gold", 0))
		xp_amount.text = "+%d" % int(rewards.get("xp", 0))
		var essence := int(rewards.get("essence", 0))
		essence_reward.visible = essence > 0
		essence_amount.text = "+%d" % essence
		reward_strip.visible = true
		var parts: Array = [
			"+%d %s" % [int(rewards.get("gold", 0)), Loc.t("ui.gold")],
		]
		if int(rewards.get("essence", 0)) > 0:
			parts.append("+%d %s" % [int(rewards["essence"]), Loc.t("ui.essence")])
		parts.append("+%d %s" % [int(rewards.get("xp", 0)), Loc.t("ui.xp")])
		rewards_label.text = " · ".join(parts)
	else:
		rewards_label.text = Loc.t("result.no_reward")
		reward_strip.visible = false

	var unlocks: Array = []
	if bool(data.get("advanced", false)):
		var new_highest := int(data.get("new_highest", 0))
		if new_highest >= ContentDB.gate_count():
			unlocks.append(Loc.t("result.all_gates"))
		else:
			unlocks.append(Loc.t("result.gate_unlocked") % (new_highest + 1))
	var unit_name := str(data.get("unlocked_unit", ""))
	if not unit_name.is_empty():
		unlocks.append(Loc.t("result.new_unit") % unit_name)
	unlock_label.text = "\n".join(unlocks)
	unlock_label.visible = not unlocks.is_empty()
	retry_button.visible = not victory


func _on_continue() -> void:
	get_tree().call_group("navigation", "close_and_check_story", "battle_result")


func _on_retry() -> void:
	get_tree().call_group("navigation", "close_overlay", "battle_result")
	get_tree().call_group("navigation", "show_overlay", "gate_prep")
