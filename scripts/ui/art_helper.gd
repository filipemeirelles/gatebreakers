extends RefCounted
## Pequenos helpers para carregar os assets originais das unidades nas telas.


static func texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


static func unit_texture(unit_id: String) -> Texture2D:
	var definition := ContentDB.unit(unit_id)
	if definition.is_empty():
		definition = ContentDB.hunter(unit_id)
	return texture(String(definition.get("art", "")))


static func enemy_texture_for_gate(gate: int, role: String) -> Texture2D:
	var gate_def := ContentDB.gate_row(gate)
	var art_key := "boss_art" if role == "boss" else "enemy_art"
	var path := String(gate_def.get(art_key, ""))
	var image := texture(path)
	if image != null:
		return image
	return enemy_texture(role == "boss")


static func enemy_texture(is_boss: bool) -> Texture2D:
	return texture(
		"res://assets/units/enemy_boss.png" if is_boss
		else "res://assets/units/enemy_common.png"
	)


static func configure_rect(rect: TextureRect, image: Texture2D, minimum_size: Vector2) -> void:
	rect.texture = image
	rect.custom_minimum_size = minimum_size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
