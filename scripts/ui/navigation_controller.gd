extends Control
class_name NavigationController
## Controla a navegação entre os destinos principais (spec §5):
## Portais, Caçador, Sombras e Configurações — máximo de quatro destinos.
## As telas são filhos fixos; navegar alterna `visible` — nunca duplica telas.
## Overlays (relatório AFK, preparação, combate, resultado) abrem por cima.
## A UI só desenha estado e encaminha ações; não calcula regras.

enum Destination { MAP, HUNTERS, SHADOWS, STORY, ITEMS, MISSIONS, SETTINGS }

const SCREEN_NAMES := {
	Destination.MAP: "Portals",
	Destination.HUNTERS: "Hunter",
	Destination.SHADOWS: "Shadows",
	Destination.STORY: "Story",
	Destination.ITEMS: "Items",
	Destination.MISSIONS: "Missions",
	Destination.SETTINGS: "Settings",
}
const OVERLAY_KEYS := {
	"afk_report": "AfkReport",
	"gate_prep": "GatePrep",
	"battle": "Battle",
	"battle_result": "BattleResult",
	"story_card": "StoryCard",
	"profile": "ProfileOverlay",
	"store": "StoreOverlay",
}
const BUTTON_NAMES := {
	Destination.MAP: "MapButton",
	Destination.HUNTERS: "HuntersButton",
	Destination.STORY: "StoryButton",
	Destination.ITEMS: "ItemsButton",
	Destination.MISSIONS: "MissionsButton",
}
const BUTTON_ICONS := {
	Destination.MAP: "res://assets/icons/icon_portals.svg",
	Destination.HUNTERS: "res://assets/icons/icon_hunter.svg",
	Destination.STORY: "res://assets/icons/icon_shadows.svg",
	Destination.ITEMS: "res://assets/icons/icon_gold.svg",
	Destination.MISSIONS: "res://assets/icons/icon_xp.svg",
}

var current: Destination = Destination.MAP
var _red_dot_accumulator: float = 0.0


func _ready() -> void:
	add_to_group("navigation")
	_setup_buttons()
	GameState.state_changed.connect(_refresh_red_dots)
	goto_destination(current)
	_refresh_red_dots()
	_apply_safe_area()
	resized.connect(_apply_safe_area)
	# Relatório AFK calculado pelo GameState no arranque (spec §4/§5.2);
	# os cartões narrativos vêm a seguir (fila do GameState).
	if not GameState.pending_afk_report.is_empty():
		show_overlay("afk_report", GameState.pending_afk_report)
		GameState.pending_afk_report = {}
	else:
		maybe_show_story()


func _setup_buttons() -> void:
	for destination in BUTTON_NAMES:
		var button := get_node_or_null("BottomBar/%s" % BUTTON_NAMES[destination]) as Button
		if button == null:
			continue
		button.text = Loc.t("ui.tab.%s" % Destination.keys()[destination].to_lower())
		button.flat = true
		button.expand_icon = true
		var icon_path: String = BUTTON_ICONS.get(destination, "")
		if not icon_path.is_empty():
			var icon_tex := load(icon_path) as Texture2D
			if icon_tex != null:
				button.icon = icon_tex
		button.add_theme_font_size_override("font_size", 11)
		button.pressed.connect(_on_tab_pressed.bind(destination))
		var badge := button.get_node_or_null("RedDot") as Label
		if badge == null:
			badge = Label.new()
			badge.name = "RedDot"
			badge.text = "●"
			badge.add_theme_font_size_override("font_size", 17)
			badge.add_theme_color_override("font_color", Color(1.0, 0.22, 0.32))
			badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
			badge.offset_left = -23
			badge.offset_top = -2
			badge.offset_right = -5
			badge.offset_bottom = 16
			button.add_child(badge)


func _on_tab_pressed(destination: Destination) -> void:
	SoundManager.play_click()
	goto_destination(destination)


func _process(delta: float) -> void:
	_red_dot_accumulator += delta
	if _red_dot_accumulator >= 1.0:
		_red_dot_accumulator = 0.0
		_refresh_red_dots()


func _refresh_red_dots() -> void:
	var dots := GameState.red_dots()
	# Sombras (invocações) e melhorias de caçador penduradas na aba Caçadores.
	for destination in BUTTON_NAMES:
		var button := get_node_or_null("BottomBar/%s" % BUTTON_NAMES[destination]) as Button
		if button == null:
			continue
		var badge := button.get_node_or_null("RedDot") as Label
		if badge == null:
			continue
		var visible := false
		match destination:
			Destination.MAP:
				visible = bool(dots.get("portals", false))
			Destination.HUNTERS:
				visible = bool(dots.get("hunter", false)) or bool(dots.get("shadows", false))
			Destination.ITEMS:
				visible = bool(dots.get("items", false))
			Destination.MISSIONS:
				visible = bool(dots.get("missions", false))
			_:
				pass
		badge.visible = visible


## Mostra exatamente uma tela de destino; as restantes ficam ocultas.
func goto_destination(destination: Destination) -> void:
	current = destination
	for key in SCREEN_NAMES:
		var screen := get_node_or_null("Screens/%s" % SCREEN_NAMES[key])
		if screen != null:
			screen.visible = key == destination
	for destination_key in BUTTON_NAMES:
		var button := get_node_or_null("BottomBar/%s" % BUTTON_NAMES[destination_key]) as Button
		if button != null:
			button.button_pressed = destination_key == destination


## Kit de invocações (Sombras): acessível de dentro da tela Caçadores.
func goto_shadows() -> void:
	goto_destination(Destination.SHADOWS)


func show_overlay(key: String, data: Variant = null) -> void:
	var overlay := get_node_or_null("Overlays/%s" % OVERLAY_KEYS.get(key, ""))
	if overlay == null:
		return
	# Toque duplo em "Começar" não pode reiniciar uma batalha em curso (§7).
	if key == "battle" and overlay.visible:
		return
	if data != null and overlay.has_method("configure"):
		overlay.configure(data)
	overlay.visible = true


func close_overlay(key: String) -> void:
	var overlay := get_node_or_null("Overlays/%s" % OVERLAY_KEYS.get(key, ""))
	if overlay != null:
		overlay.visible = false


## Fecha o overlay indicado e mostra o próximo cartão narrativo pendente.
## Usado pelos botões "Continuar" (relatório AFK, resultado, cartões).
func close_and_check_story(key: String) -> void:
	close_overlay(key)
	maybe_show_story()


## Mostra o próximo cartão da fila, se houver e não houver um já aberto.
func maybe_show_story() -> void:
	var overlay := get_node_or_null("Overlays/StoryCard")
	if overlay != null and overlay.visible:
		return
	var card_id := GameState.pop_pending_story()
	if card_id.is_empty():
		return
	show_overlay("story_card", { "id": card_id })


## Áreas seguras (notch/recorte) — spec §10.14 e §7 (proporções diferentes).
## Aplica os insets da área segura como frações do viewport, indiferente ao
## modo de stretch; em ecrãs sem recorte (ou desktop) não altera nada.
func _apply_safe_area() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var screen := DisplayServer.screen_get_size()
	var safe := DisplayServer.get_display_safe_area()
	if screen.x <= 0 or screen.y <= 0 or safe.size.x <= 0 or safe.size.y <= 0:
		return
	if safe == Rect2i(Vector2i.ZERO, screen):
		return
	var vp: Vector2 = get_viewport_rect().size
	offset_left = vp.x * (float(safe.position.x) / float(screen.x))
	offset_top = vp.y * (float(safe.position.y) / float(screen.y))
	offset_right = -vp.x * (float(screen.x - safe.position.x - safe.size.x) / float(screen.x))
	offset_bottom = -vp.y * (float(screen.y - safe.position.y - safe.size.y) / float(screen.y))


func close_all_overlays() -> void:
	for key in OVERLAY_KEYS:
		close_overlay(key)
