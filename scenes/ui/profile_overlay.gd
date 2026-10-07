extends Control
## Ficha / Perfil do Caçador: resumo de progresso, rank, título, poder de equipe,
## portais concluídos, caçadores contratados e sombras desbloqueadas.

const ArtHelper = preload("res://scripts/ui/art_helper.gd")

@onready var portrait: TextureRect = $Margin/VBox/HeaderCard/Margin/HeroRow/Portrait
@onready var name_label: Label = $Margin/VBox/HeaderCard/Margin/HeroRow/InfoCol/NameLabel
@onready var level_label: Label = $Margin/VBox/HeaderCard/Margin/HeroRow/InfoCol/LevelLabel
@onready var rank_label: Label = $Margin/VBox/HeaderCard/Margin/HeroRow/InfoCol/RankLabel
@onready var title_label: Label = $Margin/VBox/HeaderCard/Margin/HeroRow/InfoCol/TitleLabel

@onready var power_title: Label = $Margin/VBox/StatsCard/Margin/StatsVBox/PowerTitle
@onready var power_value: Label = $Margin/VBox/StatsCard/Margin/StatsVBox/PowerRow/PowerValue
@onready var gate_stat_label: Label = $Margin/VBox/StatsCard/Margin/StatsVBox/GridStats/GateStatLabel
@onready var hunters_stat_label: Label = $Margin/VBox/StatsCard/Margin/StatsVBox/GridStats/HuntersStatLabel
@onready var shadows_stat_label: Label = $Margin/VBox/StatsCard/Margin/StatsVBox/GridStats/ShadowsStatLabel
@onready var sweep_stat_label: Label = $Margin/VBox/StatsCard/Margin/StatsVBox/GridStats/SweepStatLabel

@onready var close_button: Button = $Margin/VBox/CloseButton


func _ready() -> void:
	$Margin/VBox/Title.text = Loc.t("profile.title")
	power_title.text = Loc.t("profile.power")
	close_button.text = Loc.t("profile.close")
	close_button.pressed.connect(_on_close)
	ArtHelper.configure_rect(portrait, ArtHelper.unit_texture("jinwoo"), Vector2(96, 104))
	_refresh()


func configure(_data: Variant = null) -> void:
	_refresh()


func _refresh() -> void:
	var level := GameState.hunter_level()
	var highest := GameState.highest_gate_cleared
	var power := GameState.team_power()

	name_label.text = Loc.t("profile.hunter_name")
	level_label.text = "%s %d" % [Loc.t("ui.level"), level]

	var rank := _calculate_rank(highest)
	rank_label.text = Loc.t("profile.rank") % rank
	title_label.text = Loc.t("profile.title_label") % _calculate_title(highest)

	power_value.text = str(power)

	var gate_name := "—"
	if highest > 0:
		var gdef := ContentDB.gate_row(highest)
		gate_name = String(gdef.get("display_name", "Portal %d" % highest))
	gate_stat_label.text = Loc.t("profile.best_gate") % [highest, gate_name]

	var hired_count := 0
	var total_hunters := ContentDB.all_hunters().size()
	for def in ContentDB.all_hunters():
		if GameState.hunter_is_hired(String(def.get("id", ""))):
			hired_count += 1
	hunters_stat_label.text = Loc.t("profile.hired_hunters") % [hired_count, total_hunters]

	var shadows_unlocked := 0
	var all_units := ContentDB.all_units()
	var total_shadows := 0
	for def in all_units:
		var id := String(def.get("id", ""))
		if id == "jinwoo":
			continue
		total_shadows += 1
		if GameState.is_unlocked(id):
			shadows_unlocked += 1
	shadows_stat_label.text = Loc.t("profile.unlocked_shadows") % [shadows_unlocked, total_shadows]

	var sweep_sum := 0
	for g in GameState.sweep_charges:
		sweep_sum += int(GameState.sweep_charges[g])
	sweep_stat_label.text = Loc.t("profile.sweep_charges") % sweep_sum


func _calculate_rank(highest_gate: int) -> String:
	if highest_gate >= 9:
		return "S"
	elif highest_gate >= 7:
		return "A"
	elif highest_gate >= 5:
		return "B"
	elif highest_gate >= 3:
		return "C"
	elif highest_gate >= 1:
		return "D"
	return "E"


func _calculate_title(highest_gate: int) -> String:
	if highest_gate >= 10:
		return Loc.t("profile.title_monarch", "Monarca das Sombras")
	elif highest_gate >= 7:
		return Loc.t("profile.title_s_rank", "Caçador de Rank S")
	elif highest_gate >= 4:
		return Loc.t("profile.title_awakened", "Despertar das Sombras")
	elif highest_gate >= 1:
		return Loc.t("profile.title_reawakened", "Segundo Despertar")
	return Loc.t("profile.title_weakest", "O Mais Fraco da Humanidade")


func _on_close() -> void:
	get_tree().call_group("navigation", "close_overlay", "profile")
