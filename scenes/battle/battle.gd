extends Control
## Combate visual: retratos, barras de vida e feedback animado de ações.
##
## A velocidade só altera a apresentação (frequência de passos); os cálculos
## vêm do CombatService e são determinísticos (spec §4/§10.5). A batalha é
## simulada apenas enquanto este overlay está visível (primeiro plano).
## O fim da batalha encaminha para o resultado; só aí se credita recompensa.

const ArtHelper = preload("res://scripts/ui/art_helper.gd")
const STEP_SECONDS := 0.45
const ACTOR_W := 140.0
const ACTOR_H := 210.0
const DEAD_MODULATE := Color(0.46, 0.49, 0.58, 0.52)
const DEAD_SCALE := Vector2(0.72, 0.72)

# Slots 2×3 por lado, livres sobre a arena (sem cards).
# Cada slot: [x_pct, y_pct] no viewport 720×1280.
const ALLY_SLOTS := [
	Vector2(0.12, 0.38), Vector2(0.32, 0.38),
	Vector2(0.12, 0.58), Vector2(0.32, 0.58),
	Vector2(0.12, 0.78), Vector2(0.32, 0.78),
]
const ENEMY_SLOTS := [
	Vector2(0.68, 0.38), Vector2(0.88, 0.38),
	Vector2(0.68, 0.58), Vector2(0.88, 0.58),
	Vector2(0.68, 0.78), Vector2(0.88, 0.78),
]

@onready var title_label: Label = $Margin/VBox/TitleLabel
@onready var wave_label: Label = $Margin/VBox/WaveLabel
@onready var enemies_box: GridContainer = $Margin/VBox/BattleRow/MonstersSide/EnemiesBox
@onready var allies_box: GridContainer = $Margin/VBox/BattleRow/HuntersSide/AlliesBox
@onready var log_label: Label = $Margin/VBox/LogPanel/LogLabel
@onready var pause_button: Button = $Margin/VBox/Controls/PauseButton
@onready var speed_button: Button = $Margin/VBox/Controls/SpeedButton
@onready var exit_hint: Label = $Margin/VBox/ExitHintLabel
@onready var exit_button: Button = $Margin/VBox/ExitButton
@onready var fx_layer: Control = $FxLayer

var _gate: int = 0
var _state: Dictionary = {}
var _acc: float = 0.0
var _paused: bool = false
var _speed: int = 1
var _finished: bool = false
var _displayed_wave_index: int = -1
## chave "lado:id" -> { "bar", "hp_label", "name_label" }
var _rows: Dictionary = {}
var _node_tweens: Dictionary = {}


func _ready() -> void:
	title_label.text = Loc.t("battle.title")
	$Margin/VBox/BattleRow/MonstersSide/EnemiesTitle.text = Loc.t("battle.enemies")
	$Margin/VBox/BattleRow/HuntersSide/AlliesTitle.text = Loc.t("battle.allies")
	$Margin/VBox/ClashBanner/ClashLabel.text = Loc.t("battle.confrontation")
	pause_button.text = Loc.t("battle.pause")
	exit_hint.text = Loc.t("battle.exit_hint")
	exit_button.text = Loc.t("ui.exit_battle")
	pause_button.pressed.connect(_on_pause)
	speed_button.pressed.connect(_on_speed)
	exit_button.pressed.connect(_on_exit)


## Chamado pela navegação antes de mostrar o overlay: inicia uma batalha nova.
func configure(data: Dictionary) -> void:
	_stop_animations()
	_gate = int(data.get("gate", GameState.current_gate()))
	var gate_def := ContentDB.gate(_gate)
	title_label.text = "%s %d — %s" % [Loc.t("ui.gate"), _gate, String(gate_def.get("display_name", ""))]
	_state = CombatService.start_battle(GameState.team_units(), gate_def)
	_paused = false
	_speed = 1
	_finished = false
	_acc = 0.0
	pause_button.text = Loc.t("battle.pause")
	speed_button.text = "x1"
	log_label.text = Loc.t("battle.ready")
	for child in fx_layer.get_children():
		fx_layer.remove_child(child)
		child.queue_free()
	_build_rows()
	_render()


func _process(delta: float) -> void:
	if _finished or _paused or _state.is_empty() or not is_visible_in_tree():
		return
	# Clamp do delta: retomar do segundo plano não pode acelerar o combate.
	_acc += minf(delta, 0.1)
	var step_time := STEP_SECONDS / float(_speed)
	while _acc >= step_time:
		_acc -= step_time
		_advance()


func _advance() -> void:
	if _state.is_empty():
		return
	if int(_state["wave_index"]) != _displayed_wave_index:
		_build_rows()
		_render()
	if CombatService.is_finished(_state):
		return
	var ev: Dictionary = CombatService.step(_state)
	if not ev.is_empty():
		_log_event(ev)
		_render()
		_animate_event(ev)
	if CombatService.is_finished(_state):
		_finish()


func _log_event(ev: Dictionary) -> void:
	var outcome := String(ev.get("outcome", ""))
	if String(ev["type"]) == "skill":
		if bool(ev.get("heal", false)):
			SoundManager.play_heal()
			log_label.text = "%s cura %s em %d HP" % [
				str(ev["attacker"]["name"]), str(ev["target"]["name"]), abs(int(ev["damage"]))
			]
		else:
			SoundManager.play_skill()
			log_label.text = Loc.t("battle.log_guard") % str(ev["attacker"]["name"])
	elif String(ev["type"]) == "attack":
		if bool(ev.get("is_skill", false)):
			SoundManager.play_skill()
			var skill_name := Loc.t("skill.%s" % String(ev.get("skill_id", "")), String(ev.get("skill_id", "Habilidade")))
			var key := "battle.log_skill_kill" if bool(ev["killed"]) else "battle.log_skill"
			log_label.text = Loc.t(key) % [
				str(ev["attacker"]["name"]), skill_name, str(ev["target"]["name"]), int(ev["damage"]),
			]
		else:
			SoundManager.play_hit()
			var key := "battle.log_kill" if bool(ev["killed"]) else "battle.log_attack"
			log_label.text = Loc.t(key) % [
				str(ev["attacker"]["name"]), str(ev["target"]["name"]), int(ev["damage"]),
			]
	elif outcome == "wave":
		SoundManager.play_skill()
		# O evento já aponta para a onda seguinte; a onda concluída é a anterior.
		log_label.text = Loc.t("battle.wave_done") % (int(ev["wave"]) - 1)
		_pulse_wave()
	elif outcome == "victory":
		SoundManager.play_victory()
		log_label.text = Loc.t("result.victory")
	elif outcome == "defeat":
		SoundManager.play_defeat()
		log_label.text = Loc.t("result.defeat")


func _render() -> void:
	if _state.is_empty():
		return
	var waves: Array = _state["waves"]
	wave_label.text = "%s %d / %d" % [Loc.t("battle.wave"), int(_state["wave_index"]) + 1, waves.size()]
	_render_side(_state["allies"], "ally")
	_render_side(_state["enemies"], "enemy")


func _render_side(units: Array, side: String) -> void:
	for unit in units:
		var row: Dictionary = _rows.get("%s:%s" % [side, str(unit.get("id", ""))], {})
		if row.is_empty():
			continue
		var hp := int(unit["hp"])
		var max_hp := maxi(int(unit.get("max_hp", hp)), 1)
		var bar: ProgressBar = row["bar"]
		bar.max_value = max_hp
		bar.value = hp
		var hp_label: Label = row["hp_label"]
		hp_label.text = "%d/%d" % [hp, max_hp]
		var name_label: Label = row["name_label"]
		name_label.modulate = Color.WHITE if hp > 0 else Color(1, 1, 1, 0.4)
		var portrait: TextureRect = row["portrait"]
		# O estado de vida é a autoridade visual. Isto também desfaz uma animação
		# interrompida por um ataque seguinte, evitando que um vivo pareça morto.
		portrait.modulate = Color.WHITE if hp > 0 else DEAD_MODULATE
		portrait.scale = Vector2.ONE if hp > 0 else DEAD_SCALE
		portrait.rotation = 0.0
		var hp_color := Color(0.72, 0.82, 0.94)
		if hp > 0 and hp * 5 <= max_hp:
			hp_color = Color(1.0, 0.7, 0.34)
		hp_label.add_theme_color_override("font_color", hp_color if hp > 0 else Color(0.55, 0.58, 0.66))
	_mark_current_enemy_target()


## Vitória credita recompensa/progressão via GameState.resolve_battle_end
## (uma única vez); derrota não concede nada (spec §10.3/§10.4).
func _finish() -> void:
	if _finished:
		return
	_finished = true
	var victory := String(_state.get("phase", "")) == "victory"
	var unlock_id: Variant = ContentDB.gate(_gate).get("clear_unlocks_unit")
	var had_unit := unlock_id is String and GameState.is_unlocked(str(unlock_id))
	var prev_highest := GameState.highest_gate_cleared
	var rewards := GameState.resolve_battle_end(_state)
	var data := {
		"victory": victory,
		"gate": _gate,
		"rewards": rewards,
		"advanced": victory and GameState.highest_gate_cleared > prev_highest,
		"new_highest": GameState.highest_gate_cleared,
		"unlocked_unit": "",
	}
	if victory and unlock_id is String and not had_unit and GameState.is_unlocked(str(unlock_id)):
		data["unlocked_unit"] = str(ContentDB.unit(str(unlock_id)).get("display_name", unlock_id))
	get_tree().call_group("navigation", "show_overlay", "battle_result", data)


func _on_pause() -> void:
	if _finished:
		return
	_paused = not _paused
	pause_button.text = Loc.t("battle.resume") if _paused else Loc.t("battle.pause")


func _on_speed() -> void:
	_speed = 2 if _speed == 1 else 1
	speed_button.text = "x%d" % _speed


## Sair durante a batalha encerra sem conceder recompensa (spec §4/§5.4).
func _on_exit() -> void:
	_state = {}
	_finished = true
	get_tree().call_group("navigation", "close_overlay", "battle")


# --- Construção de linhas de vida ---

func _build_rows() -> void:
	_rows.clear()
	_displayed_wave_index = int(_state.get("wave_index", 0))
	# Remove atores antigos (não toca em FxLayer).
	for child in get_children():
		if child.has_meta("actor"):
			remove_child(child)
			child.queue_free()
	for i in _state["enemies"].size():
		add_child(_make_actor("enemy", _state["enemies"][i], false, i))
	for i in _state["allies"].size():
		add_child(_make_actor("ally", _state["allies"][i], true, i))


func _make_actor(side: String, unit: Dictionary, is_ally: bool, unit_index: int) -> Control:
	var slots := ALLY_SLOTS if is_ally else ENEMY_SLOTS
	var slot: Vector2 = slots[unit_index % slots.size()]
	var vp := Vector2(720, 1280)

	var actor := Control.new()
	actor.set_meta("actor", true)
	actor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	actor.position = Vector2(slot.x * vp.x - ACTOR_W * 0.5, slot.y * vp.y - ACTOR_H * 0.5)
	actor.size = Vector2(ACTOR_W, ACTOR_H)

	# Sombra de contato simples.
	var shadow := TextureRect.new()
	shadow.texture = null
	var shadow_rect := ColorRect.new()
	shadow_rect.color = Color(0, 0, 0, 0.28)
	shadow_rect.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	shadow_rect.offset_top = -12
	shadow_rect.offset_bottom = 0
	shadow_rect.offset_left = 18
	shadow_rect.offset_right = -18
	shadow_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shadow_rect.name = "ContactShadow"
	actor.add_child(shadow_rect)

	var portrait := TextureRect.new()
	ArtHelper.configure_rect(portrait, _portrait_for(unit, is_ally), Vector2(ACTOR_W, ACTOR_H))
	portrait.name = "Portrait"
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	actor.add_child(portrait)

	var target_badge := Label.new()
	target_badge.name = "TargetBadge"
	target_badge.text = Loc.t("battle.target")
	target_badge.add_theme_font_size_override("font_size", 12)
	target_badge.add_theme_color_override("font_color", Color(0.3, 0.91, 1.0))
	target_badge.add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.05, 0.95))
	target_badge.add_theme_constant_override("outline_size", 4)
	target_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_badge.set_anchors_preset(Control.PRESET_TOP_WIDE)
	target_badge.offset_top = -22
	target_badge.offset_bottom = -2
	target_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	target_badge.visible = false
	actor.add_child(target_badge)

	var name_label := Label.new()
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", Color(0.9, 0.94, 1.0))
	name_label.add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.05, 0.95))
	name_label.add_theme_constant_override("outline_size", 4)
	name_label.text = str(unit.get("display_name", unit.get("id", "?")))
	if not is_ally:
		name_label.text += " #%d" % (unit_index + 1)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.clip_text = true
	name_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	name_label.offset_top = 4
	name_label.offset_bottom = 24
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	actor.add_child(name_label)

	var bar := ProgressBar.new()
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_top = 26
	bar.offset_bottom = 38
	bar.offset_left = 10
	bar.offset_right = -10
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.12, 0.88, 0.96) if is_ally else Color(0.98, 0.28, 0.36)
	fill.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("fill", fill)
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.035, 0.045, 0.075, 0.75)
	background.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("background", background)
	actor.add_child(bar)

	var hp_label := Label.new()
	hp_label.add_theme_font_size_override("font_size", 11)
	hp_label.add_theme_color_override("font_color", Color(0.72, 0.82, 0.94))
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hp_label.offset_top = 38
	hp_label.offset_bottom = 54
	hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	actor.add_child(hp_label)

	_rows["%s:%s" % [side, str(unit.get("id", ""))]] = {
		"bar": bar,
		"hp_label": hp_label,
		"name_label": name_label,
		"portrait": portrait,
		"card": actor,
		"panel": null,
		"target_badge": target_badge,
		"is_ally": is_ally,
		"base_border_color": Color.TRANSPARENT,
	}
	return actor


func _mark_current_enemy_target() -> void:
	var target_id := ""
	for enemy in _state.get("enemies", []):
		if int(enemy.get("hp", 0)) > 0:
			target_id = String(enemy.get("id", ""))
			break
	for enemy in _state.get("enemies", []):
		var row_key := "enemy:%s" % String(enemy.get("id", ""))
		var row: Dictionary = _rows.get(row_key, {})
		if row.is_empty():
			continue
		var is_target := String(enemy.get("id", "")) == target_id
		var badge: Label = row["target_badge"]
		badge.visible = is_target


func _portrait_for(unit: Dictionary, is_ally: bool) -> Texture2D:
	if is_ally:
		return ArtHelper.unit_texture(String(unit.get("id", "")))
	return ArtHelper.enemy_texture_for_gate(_gate, String(unit.get("role", "common")))


func _animate_event(ev: Dictionary) -> void:
	if String(ev.get("type", "")) == "skill":
		if bool(ev.get("heal", false)):
			var healed_row: Dictionary = _rows.get("ally:%s" % String(ev["target"].get("id", "")), {})
			if not healed_row.is_empty():
				var healed_portrait: TextureRect = healed_row["portrait"]
				var heal_tween := _replace_node_tween(healed_portrait)
				heal_tween.tween_property(healed_portrait, "scale", Vector2(1.12, 1.12), 0.12)
				heal_tween.tween_property(healed_portrait, "scale", Vector2.ONE, 0.2)
				_add_damage_popup(healed_portrait, int(ev.get("damage", 0)), false)
			_skill_flash(Color(0.24, 0.92, 0.57, 0.18))
			return
		# A guarda é um buff, não um ataque: destaca o guardião e a equipe.
		var guard_row: Dictionary = _rows.get(
			"ally:%s" % String(ev["attacker"].get("id", "")), {}
		)
		if not guard_row.is_empty():
			var guard_portrait: TextureRect = guard_row["portrait"]
			_animate_attacker(guard_portrait, guard_portrait.get_global_rect().get_center())
		_skill_flash(Color(0.5, 0.34, 1.0, 0.18))
		return
	if String(ev.get("type", "")) != "attack":
		if String(ev.get("outcome", "")) == "victory":
			_pulse_wave()
		return

	var attacker: Dictionary = ev["attacker"]
	var target: Dictionary = ev["target"]
	var attacker_row: Dictionary = _rows.get(
		"%s:%s" % [String(attacker.get("side", "")), String(attacker.get("id", ""))], {}
	)
	var target_row: Dictionary = _rows.get(
		"%s:%s" % [String(target.get("side", "")), String(target.get("id", ""))], {}
	)
	if not attacker_row.is_empty() and not target_row.is_empty():
		_animate_attacker(attacker_row["portrait"], target_row["portrait"].get_global_rect().get_center())
	if target_row.is_empty():
		return

	var target_portrait: TextureRect = target_row["portrait"]
	var target_max_hp := maxi(int(target.get("max_hp", 1)), 1)
	var target_bar: ProgressBar = target_row["bar"]
	target_bar.max_value = target_max_hp
	target_bar.value = int(target.get("hp", 0))
	var target_hp_label: Label = target_row["hp_label"]
	target_hp_label.text = "%d/%d" % [int(target.get("hp", 0)), target_max_hp]
	if bool(ev.get("killed", false)):
		var death_tween := _replace_node_tween(target_portrait)
		death_tween.tween_property(target_portrait, "modulate", DEAD_MODULATE, 0.25)
		death_tween.parallel().tween_property(target_portrait, "scale", DEAD_SCALE, 0.25)
	else:
		var hit_color := Color(1.0, 0.42, 0.45) if String(target.get("side", "")) == "enemy" else Color(1.0, 0.66, 0.54)
		var hit_tween := _replace_node_tween(target_portrait)
		hit_tween.tween_property(target_portrait, "rotation", 0.045, 0.04)
		hit_tween.parallel().tween_property(target_portrait, "modulate", hit_color, 0.07)
		hit_tween.tween_property(target_portrait, "rotation", -0.035, 0.05)
		hit_tween.tween_property(target_portrait, "rotation", 0.0, 0.05)
		hit_tween.parallel().tween_property(target_portrait, "modulate", Color.WHITE, 0.16)
	_add_damage_popup(target_portrait, int(ev.get("damage", 0)), bool(ev.get("killed", false)), bool(ev.get("is_skill", false)))


func _animate_attacker(portrait: TextureRect, target_global_position: Vector2) -> void:
	var origin := portrait.position
	var current_center := portrait.get_global_rect().get_center()
	var direction := signf(target_global_position.x - current_center.x)
	var tween := _replace_node_tween(portrait)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(portrait, "rotation", 0.025 * direction, 0.09)
	tween.parallel().tween_property(portrait, "scale", Vector2(1.1, 1.1), 0.09)
	tween.parallel().tween_property(portrait, "position:x", origin.x + direction * 10.0, 0.09)
	tween.tween_property(portrait, "rotation", 0.0, 0.13)
	tween.parallel().tween_property(portrait, "scale", Vector2.ONE, 0.13)
	tween.parallel().tween_property(portrait, "position:x", origin.x, 0.13)


func _add_damage_popup(portrait: TextureRect, damage: int, killed: bool, is_skill: bool = false) -> void:
	var popup := Label.new()
	if damage < 0:
		popup.text = "+%d" % abs(damage)
		popup.add_theme_font_size_override("font_size", 30)
		popup.add_theme_color_override("font_color", Color(0.35, 0.95, 0.55))
	else:
		popup.text = "-%d%s" % [damage, "!" if killed else ""]
		popup.add_theme_font_size_override("font_size", 34 if is_skill else (30 if killed else 25))
		if is_skill:
			popup.add_theme_color_override("font_color", Color(0.45, 0.95, 1.0))
		else:
			popup.add_theme_color_override("font_color", Color(1.0, 0.84, 0.3) if killed else Color(1.0, 0.96, 0.86))
	popup.add_theme_color_override("font_outline_color", Color(0.08, 0.025, 0.09, 0.96))
	popup.add_theme_constant_override("outline_size", 5)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.size = Vector2(120, 44)
	var canvas_transform := fx_layer.get_global_transform_with_canvas()
	var center: Vector2 = canvas_transform.affine_inverse() * portrait.get_global_rect().get_center()
	popup.position = center - Vector2(popup.size.x * 0.5, popup.size.y * 0.35)
	fx_layer.add_child(popup)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "position:y", popup.position.y - 58.0, 0.48)
	tween.tween_property(popup, "modulate:a", 0.0, 0.48)
	tween.chain().tween_callback(popup.queue_free)


func _skill_flash(color: Color = Color(0.3, 0.91, 1.0, 0.14)) -> void:
	var flash := ColorRect.new()
	flash.color = Color(color.r, color.g, color.b, 0.0)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_layer.add_child(flash)
	var tween := create_tween()
	tween.tween_property(flash, "color:a", color.a, 0.06)
	tween.tween_property(flash, "color:a", 0.0, 0.22)
	tween.chain().tween_callback(flash.queue_free)


func _pulse_wave() -> void:
	var tween := _replace_node_tween(wave_label)
	tween.tween_property(wave_label, "scale", Vector2(1.16, 1.16), 0.1)
	tween.tween_property(wave_label, "scale", Vector2.ONE, 0.18)


func _replace_node_tween(target: Control) -> Tween:
	var instance_id := target.get_instance_id()
	var previous: Variant = _node_tweens.get(instance_id)
	if previous is Tween and previous.is_running():
		previous.kill()
	var tween := create_tween()
	_node_tweens[instance_id] = tween
	tween.finished.connect(_forget_node_tween.bind(instance_id, tween))
	return tween


func _stop_animations() -> void:
	for value in _node_tweens.values():
		if value is Tween and value.is_running():
			value.kill()
	_node_tweens.clear()


func _forget_node_tween(instance_id: int, tween: Tween) -> void:
	if _node_tweens.get(instance_id) == tween:
		_node_tweens.erase(instance_id)
