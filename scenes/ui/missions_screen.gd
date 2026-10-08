extends Control
## Tela de Missões do Sistema: tarefas diárias com progresso, metas e resgate.

@onready var title_label: Label = $Margin/VBox/Title
@onready var subtitle_label: Label = $Margin/VBox/Subtitle
@onready var hint_label: Label = $Margin/VBox/Hint
@onready var missions_list: VBoxContainer = $Margin/VBox/Scroll/MissionsList


func _ready() -> void:
	GameState.state_changed.connect(_refresh)
	title_label.text = Loc.t("missions.title")
	subtitle_label.text = Loc.t("missions.subtitle")
	hint_label.text = Loc.t("missions.reset_hint")
	_refresh()


func _refresh() -> void:
	for child in missions_list.get_children():
		missions_list.remove_child(child)
		child.queue_free()

	for m_def in ContentDB.daily_missions():
		var mid := String(m_def.get("id", ""))
		var card := _make_mission_card(mid, m_def)
		missions_list.add_child(card)


func _make_mission_card(mission_id: String, def: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.09, 0.16, 0.96)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.2, 0.25, 0.45, 0.6)
	card.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	# Título e Descrição
	var header_hbox := HBoxContainer.new()
	vbox.add_child(header_hbox)

	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)
	header_hbox.add_child(info_vbox)

	var title := Label.new()
	title.text = str(def.get("title", mission_id))
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	info_vbox.add_child(title)

	var desc := Label.new()
	desc.text = str(def.get("description", ""))
	desc.add_theme_font_size_override("font_size", 13)
	desc.add_theme_color_override("font_color", Color(0.7, 0.73, 0.82))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(desc)

	# Status e Progresso
	var status := GameState.get_mission_status(mission_id)
	var prog := int(status.get("progress", 0))
	var target := int(status.get("target", 1))
	var claimed := bool(status.get("claimed", false))
	var can_claim := bool(status.get("can_claim", false))

	var prog_row := HBoxContainer.new()
	prog_row.add_theme_constant_override("separation", 10)
	vbox.add_child(prog_row)

	var bar := ProgressBar.new()
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.custom_minimum_size = Vector2(0, 16)
	bar.min_value = 0
	bar.max_value = target
	bar.value = prog
	bar.show_percentage = false
	prog_row.add_child(bar)

	var prog_label := Label.new()
	prog_label.text = "%d / %d" % [prog, target]
	prog_label.add_theme_font_size_override("font_size", 13)
	prog_label.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
	prog_row.add_child(prog_label)

	# Recompensas e Botão de Ação
	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 8)
	vbox.add_child(bottom_row)

	var rewards_label := Label.new()
	rewards_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rewards_label.text = _format_rewards(def)
	rewards_label.add_theme_font_size_override("font_size", 13)
	rewards_label.add_theme_color_override("font_color", Color(0.4, 0.85, 0.55))
	bottom_row.add_child(rewards_label)

	var action_btn := Button.new()
	action_btn.custom_minimum_size = Vector2(104, 38)
	action_btn.add_theme_font_size_override("font_size", 13)

	if claimed:
		action_btn.text = Loc.t("missions.claimed")
		action_btn.disabled = true
	elif can_claim:
		action_btn.text = Loc.t("missions.claim")
		action_btn.pressed.connect(_on_claim.bind(mission_id))
	else:
		action_btn.text = Loc.t("missions.in_progress")
		action_btn.disabled = true

	bottom_row.add_child(action_btn)
	return card


func _format_rewards(def: Dictionary) -> String:
	var parts: Array = []
	var g := int(def.get("reward_gold", 0))
	var xp := int(def.get("reward_xp", 0))
	var ess := int(def.get("reward_essence", 0))
	var swp := int(def.get("reward_sweep_charges", 0))

	if g > 0:
		parts.append("+%d Ouro" % g)
	if xp > 0:
		parts.append("+%d XP" % xp)
	if ess > 0:
		parts.append("+%d Essência" % ess)
	if swp > 0:
		parts.append("+%d Varreduras" % swp)
	return " · ".join(parts)


func _on_claim(mission_id: String) -> void:
	GameState.claim_mission(mission_id)
