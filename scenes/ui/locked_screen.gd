extends Control
## Tela de sistema ainda sem conteúdo: estado claro "Em breve", sem simular função.

@export var title_key: String = ""
@export var hint_key: String = ""


func _ready() -> void:
	if not title_key.is_empty():
		$Margin/VBox/Title.text = Loc.t(title_key)
	if not hint_key.is_empty():
		$Margin/VBox/Hint.text = Loc.t(hint_key)
