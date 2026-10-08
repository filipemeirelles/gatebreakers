extends Control
## Overlay da Loja do Sistema: câmbio de suprimentos do jogo usando Ouro.

@onready var title_label: Label = $Margin/VBox/Title
@onready var subtitle_label: Label = $Margin/VBox/Subtitle
@onready var gold_label: Label = $Margin/VBox/ResourceBar/GoldValue
@onready var buy_sweep_button: Button = $Margin/VBox/CardSweep/Margin/HBox/BuyButton
@onready var buy_essence_button: Button = $Margin/VBox/CardEssence/Margin/HBox/BuyButton
@onready var buy_xp_button: Button = $Margin/VBox/CardXp/Margin/HBox/BuyButton
@onready var close_button: Button = $Margin/VBox/CloseButton


func _ready() -> void:
	GameState.state_changed.connect(_refresh)
	title_label.text = Loc.t("store.title")
	subtitle_label.text = Loc.t("store.subtitle")
	close_button.text = Loc.t("store.close")

	buy_sweep_button.pressed.connect(_on_buy.bind("sweep"))
	buy_essence_button.pressed.connect(_on_buy.bind("essence"))
	buy_xp_button.pressed.connect(_on_buy.bind("xp"))
	close_button.pressed.connect(_on_close)
	_refresh()


func configure(_data: Variant = null) -> void:
	_refresh()


func _refresh() -> void:
	gold_label.text = "%d %s" % [GameState.gold, Loc.t("ui.gold")]

	# Cargas de Varredura
	var can_sweep := GameState.gold >= 200 and GameState.highest_gate_cleared > 0
	buy_sweep_button.disabled = not can_sweep
	buy_sweep_button.text = Loc.t("store.cost") % 200

	# Essência
	var can_essence := GameState.gold >= 500
	buy_essence_button.disabled = not can_essence
	buy_essence_button.text = Loc.t("store.cost") % 500

	# XP
	var can_xp := GameState.gold >= 300
	buy_xp_button.disabled = not can_xp
	buy_xp_button.text = Loc.t("store.cost") % 300


func _on_buy(item_type: String) -> void:
	GameState.buy_store_item(item_type)


func _on_close() -> void:
	get_tree().call_group("navigation", "close_overlay", "store")
