extends Control
## Tela de Registros e Lore: galeria dos cartões narrativos desbloqueados
## permitindo reler a jornada do Sistema a qualquer momento.

const ArtHelper = preload("res://scripts/ui/art_helper.gd")

@onready var title_label: Label = $Margin/VBox/Title
@onready var subtitle_label: Label = $Margin/VBox/Subtitle
@onready var card_list: VBoxContainer = $Margin/VBox/Scroll/CardList


func _ready() -> void:
	GameState.state_changed.connect(_refresh)
	title_label.text = Loc.t("story.title")
	subtitle_label.text = Loc.t("story.subtitle")
	_refresh()


func _refresh() -> void:
	for child in card_list.get_children():
		card_list.remove_child(child)
		child.queue_free()

	for card_def in ContentDB.story_cards():
		var cid := String(card_def.get("id", ""))
		var is_seen := GameState.story_cards_seen.has(cid)
		var row := _make_story_row(cid, card_def, is_seen)
		card_list.add_child(row)


func _make_story_row(card_id: String, def: Dictionary, unlocked: bool) -> PanelContainer:
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
	style.border_color = Color(0.2, 0.25, 0.45, 0.6) if unlocked else Color(0.15, 0.17, 0.25, 0.4)
	card.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	margin.add_child(hbox)

	# Miniatura
	var thumb := TextureRect.new()
	thumb.custom_minimum_size = Vector2(72, 72)
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

	if unlocked:
		var art_path := str(def.get("art", ""))
		ArtHelper.configure_rect(thumb, ArtHelper.texture(art_path), Vector2(72, 72))
	else:
		thumb.modulate = Color(0.3, 0.3, 0.35, 0.5)
		ArtHelper.configure_rect(thumb, ArtHelper.texture("res://assets/icons/icon_lock.svg"), Vector2(72, 72))
	hbox.add_child(thumb)

	# Info
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(info_vbox)

	var title := Label.new()
	title.text = str(def.get("title", card_id)) if unlocked else Loc.t("story.locked")
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35) if unlocked else Color(0.55, 0.58, 0.65))
	info_vbox.add_child(title)

	var desc := Label.new()
	if unlocked:
		var raw_text := str(def.get("text", ""))
		desc.text = raw_text.substr(0, 75) + "…" if raw_text.length() > 75 else raw_text
		desc.add_theme_color_override("font_color", Color(0.7, 0.73, 0.82))
	else:
		desc.text = _requirement_text(card_id)
		desc.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
	desc.add_theme_font_size_override("font_size", 13)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(desc)

	# Botão de leitura
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(80, 40)
	btn.add_theme_font_size_override("font_size", 13)
	btn.text = Loc.t("story.read") if unlocked else Loc.t("story.locked")
	btn.disabled = not unlocked
	if unlocked:
		btn.pressed.connect(_on_read_card.bind(card_id))
	hbox.add_child(btn)

	return card


func _requirement_text(card_id: String) -> String:
	match card_id:
		"system_intro":
			return Loc.t("story.system_intro_req")
		"first_advance":
			return Loc.t("story.first_advance_req")
		"shadow_troop":
			return Loc.t("story.shadow_troop_req")
		_:
			return Loc.t("story.locked")


func _on_read_card(card_id: String) -> void:
	get_tree().call_group("navigation", "show_overlay", "story_card", { "id": card_id })
