extends Control
## Cartão narrativo (spec §4 linha 86): texto curto e original sobre o
## Sistema, o primeiro avanço e a tropa de sombras. Conteúdo em
## data/story/story_cards.json; aqui só se apresenta e se encaminha.

## Janela do toque duplo no "Continuar": o cartão seguinte troca por baixo do
## mesmo botão, por isso um segundo toque rápido não pode fechá-lo (§7).
const DOUBLE_TAP_MS := 400
const ArtHelper = preload("res://scripts/ui/art_helper.gd")

@onready var title_label: Label = $Margin/VBox/TitleLabel
@onready var story_image: TextureRect = $Margin/VBox/StoryImage
@onready var text_label: Label = $Margin/VBox/TextLabel
@onready var continue_button: Button = $Margin/VBox/ContinueButton

var _last_continue_ms: int = -100000


func _ready() -> void:
	continue_button.text = Loc.t("ui.continue")
	continue_button.pressed.connect(_on_continue)


## Chamado pela navegação antes de mostrar o overlay.
func configure(data: Dictionary) -> void:
	var card := ContentDB.story_card(str(data.get("id", "")))
	title_label.text = str(card.get("title", ""))
	story_image.texture = ArtHelper.texture(String(card.get("art", "")))
	text_label.text = str(card.get("text", ""))


func _on_continue() -> void:
	var now := Time.get_ticks_msec()
	if now - _last_continue_ms < DOUBLE_TAP_MS:
		return
	_last_continue_ms = now
	get_tree().call_group("navigation", "close_and_check_story", "story_card")
