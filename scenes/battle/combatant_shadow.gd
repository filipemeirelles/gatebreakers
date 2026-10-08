extends Control
## Sombra de contato elíptica sob cada combatente. Desenhada em código e sem
## retângulo de fundo: o personagem fica solto sobre a arena, sem caixa.


func _draw() -> void:
	var radius := size * 0.5
	if radius.x <= 0.0 or radius.y <= 0.0:
		return
	draw_set_transform(radius, 0.0, Vector2(1.0, radius.y / radius.x))
	draw_circle(Vector2.ZERO, radius.x, Color(0.0, 0.0, 0.0, 0.2))
	draw_circle(Vector2.ZERO, radius.x * 0.62, Color(0.0, 0.0, 0.0, 0.22))
	draw_set_transform(Vector2.ZERO)
