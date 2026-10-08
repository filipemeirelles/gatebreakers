extends Control
## Tela de Itens e Arsenal: visualização de equipamentos, slots (arma/acessório),
## bônus de atributos e equipar/desequipar entre Jinwoo e caçadores da equipe.

const ArtHelper = preload("res://scripts/ui/art_helper.gd")

@onready var title_label: Label = $Margin/VBox/Title
@onready var subtitle_label: Label = $Margin/VBox/Subtitle
@onready var hunter_chips: HBoxContainer = $Margin/VBox/HunterChipsScroll/HunterChips
@onready var equipped_title: Label = $Margin/VBox/EquippedCard/Margin/VBox/EquippedTitle
@onready var weapon_name: Label = $Margin/VBox/EquippedCard/Margin/VBox/WeaponRow/WeaponInfo/WeaponName
@onready var weapon_stats: Label = $Margin/VBox/EquippedCard/Margin/VBox/WeaponRow/WeaponInfo/WeaponStats
@onready var weapon_action_button: Button = $Margin/VBox/EquippedCard/Margin/VBox/WeaponRow/WeaponActionButton
@onready var accessory_name: Label = $Margin/VBox/EquippedCard/Margin/VBox/AccessoryRow/AccessoryInfo/AccessoryName
@onready var accessory_stats: Label = $Margin/VBox/EquippedCard/Margin/VBox/AccessoryRow/AccessoryInfo/AccessoryStats
@onready var accessory_action_button: Button = $Margin/VBox/EquippedCard/Margin/VBox/AccessoryRow/AccessoryActionButton
@onready var total_bonus_label: Label = $Margin/VBox/EquippedCard/Margin/VBox/TotalBonusLabel

@onready var inventory_title: Label = $Margin/VBox/InventoryTitle
@onready var inventory_empty: Label = $Margin/VBox/InventoryEmpty
@onready var inventory_list: VBoxContainer = $Margin/VBox/InventoryScroll/InventoryList

var _selected_hunter: String = "jinwoo"


func _ready() -> void:
	GameState.state_changed.connect(_refresh)
	title_label.text = Loc.t("items.title")
	subtitle_label.text = Loc.t("items.subtitle")
	weapon_action_button.pressed.connect(_on_unequip_slot.bind("weapon"))
	accessory_action_button.pressed.connect(_on_unequip_slot.bind("accessory"))
	_refresh()


func _refresh() -> void:
	_refresh_hunter_chips()
	_refresh_equipped_card()
	_refresh_inventory_list()


func _refresh_hunter_chips() -> void:
	for child in hunter_chips.get_children():
		hunter_chips.remove_child(child)
		child.queue_free()

	# Jinwoo sempre disponível
	var jinwoo_btn := _make_chip("jinwoo", Loc.t("profile.hunter_name", "Sung Jinwoo"))
	hunter_chips.add_child(jinwoo_btn)

	# Caçadores contratados
	for hdef in ContentDB.all_hunters():
		var hid := String(hdef["id"])
		if GameState.hunter_is_hired(hid):
			var hbtn := _make_chip(hid, String(hdef.get("display_name", hid)))
			hunter_chips.add_child(hbtn)


func _make_chip(uid: String, dname: String) -> Button:
	var btn := Button.new()
	btn.text = dname
	btn.toggle_mode = true
	btn.button_pressed = uid == _selected_hunter
	btn.custom_minimum_size = Vector2(110, 42)
	btn.add_theme_font_size_override("font_size", 14)
	btn.pressed.connect(_on_select_hunter.bind(uid))
	return btn


func _on_select_hunter(uid: String) -> void:
	_selected_hunter = uid
	_refresh()


func _get_hunter_name(uid: String) -> String:
	if uid == "jinwoo":
		return Loc.t("profile.hunter_name", "Sung Jinwoo")
	var hdef := ContentDB.hunter(uid)
	return String(hdef.get("display_name", uid))


func _refresh_equipped_card() -> void:
	equipped_title.text = Loc.t("items.equipped_section") % _get_hunter_name(_selected_hunter)
	var eq := GameState.get_equipped(_selected_hunter)
	var wid := str(eq.get("weapon", ""))
	var aid := str(eq.get("accessory", ""))

	# Slot Arma
	if wid.is_empty():
		weapon_name.text = "%s: %s" % [Loc.t("items.slot_weapon"), Loc.t("items.empty_slot")]
		weapon_name.add_theme_color_override("font_color", Color(0.6, 0.63, 0.72))
		weapon_stats.text = "—"
		weapon_action_button.visible = false
	else:
		var wdef := ContentDB.item(wid)
		weapon_name.text = "%s: %s [%s]" % [
			Loc.t("items.slot_weapon"),
			str(wdef.get("display_name", wid)),
			str(wdef.get("rank", "E"))
		]
		weapon_name.add_theme_color_override("font_color", Color(0.216, 0.878, 1))
		weapon_stats.text = _format_stats(wdef)
		weapon_action_button.text = Loc.t("items.unequip")
		weapon_action_button.visible = true

	# Slot Acessório
	if aid.is_empty():
		accessory_name.text = "%s: %s" % [Loc.t("items.slot_accessory"), Loc.t("items.empty_slot")]
		accessory_name.add_theme_color_override("font_color", Color(0.6, 0.63, 0.72))
		accessory_stats.text = "—"
		accessory_action_button.visible = false
	else:
		var adef := ContentDB.item(aid)
		accessory_name.text = "%s: %s [%s]" % [
			Loc.t("items.slot_accessory"),
			str(adef.get("display_name", aid)),
			str(adef.get("rank", "E"))
		]
		accessory_name.add_theme_color_override("font_color", Color(0.216, 0.878, 1))
		accessory_stats.text = _format_stats(adef)
		accessory_action_button.text = Loc.t("items.unequip")
		accessory_action_button.visible = true

	# Bônus Totais
	var eq_stats := GameState.get_equipped_stats(_selected_hunter)
	total_bonus_label.text = Loc.t("items.stats_bonus") % [
		int(eq_stats["attack"]), int(eq_stats["defense"]), int(eq_stats["hp"])
	]


func _refresh_inventory_list() -> void:
	for child in inventory_list.get_children():
		inventory_list.remove_child(child)
		child.queue_free()

	var count := GameState.inventory.size()
	inventory_title.text = Loc.t("items.inventory_title") % count
	inventory_empty.visible = count == 0
	if count == 0:
		inventory_empty.text = Loc.t("items.empty_inventory")
		return

	for item_id in GameState.inventory:
		var item_def := ContentDB.item(String(item_id))
		if item_def.is_empty():
			continue
		var row := _make_item_row(String(item_id), item_def)
		inventory_list.add_child(row)


func _make_item_row(item_id: String, item_def: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.10, 0.17, 0.94)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.2, 0.25, 0.4, 0.5)
	card.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)

	# Ícone
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(44, 44)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var icon_path := str(item_def.get("icon", ""))
	ArtHelper.configure_rect(icon, ArtHelper.texture(icon_path), Vector2(44, 44))
	hbox.add_child(icon)

	# Info
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(vbox)

	var title := Label.new()
	title.text = "%s [%s]" % [
		str(item_def.get("display_name", item_id)),
		str(item_def.get("rank", "E"))
	]
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	vbox.add_child(title)

	var slot_name := Loc.t("items.slot_weapon") if str(item_def.get("slot", "")) == "weapon" else Loc.t("items.slot_accessory")
	var desc := Label.new()
	desc.text = "%s · %s" % [slot_name, _format_stats(item_def)]
	desc.add_theme_font_size_override("font_size", 13)
	desc.add_theme_color_override("font_color", Color(0.65, 0.70, 0.82))
	vbox.add_child(desc)

	var equipped_status := Label.new()
	var in_use := GameState.item_equipped_by(item_id)
	var action_btn := Button.new()
	action_btn.custom_minimum_size = Vector2(96, 38)
	action_btn.add_theme_font_size_override("font_size", 13)

	if in_use.is_empty():
		equipped_status.text = Loc.t("items.free")
		equipped_status.add_theme_color_override("font_color", Color(0.45, 0.75, 0.5))
		action_btn.text = Loc.t("items.equip")
		action_btn.pressed.connect(_on_equip_item.bind(item_id))
	elif str(in_use.get("unit_id", "")) == _selected_hunter:
		equipped_status.text = Loc.t("items.in_use_by") % _get_hunter_name(_selected_hunter)
		equipped_status.add_theme_color_override("font_color", Color(0.216, 0.878, 1))
		action_btn.text = Loc.t("items.unequip")
		var s := str(item_def.get("slot", ""))
		action_btn.pressed.connect(_on_unequip_slot.bind(s))
	else:
		var owner_name := _get_hunter_name(str(in_use["unit_id"]))
		equipped_status.text = Loc.t("items.in_use_by") % owner_name
		equipped_status.add_theme_color_override("font_color", Color(0.75, 0.55, 0.95))
		action_btn.text = Loc.t("items.transfer")
		action_btn.pressed.connect(_on_equip_item.bind(item_id))

	equipped_status.add_theme_font_size_override("font_size", 12)
	vbox.add_child(equipped_status)
	hbox.add_child(action_btn)

	return card


func _format_stats(def: Dictionary) -> String:
	var parts: Array = []
	var atk := int(def.get("attack_bonus", 0))
	var pdef := int(def.get("defense_bonus", 0))
	var hp := int(def.get("hp_bonus", 0))
	if atk > 0:
		parts.append("+%d ATK" % atk)
	if pdef > 0:
		parts.append("+%d DEF" % pdef)
	if hp > 0:
		parts.append("+%d HP" % hp)
	return " · ".join(parts) if not parts.is_empty() else "—"


func _on_equip_item(item_id: String) -> void:
	GameState.equip_item(_selected_hunter, item_id)


func _on_unequip_slot(slot: String) -> void:
	GameState.unequip_slot(_selected_hunter, slot)
