extends Control
## Tela Configurações (spec §5.8): som, vibração, versão do jogo e reset
## local — apenas em build de desenvolvimento e com confirmação explícita.
## As preferências ficam em SettingsService; o reset apaga o save e volta
## ao estado inicial (estado e save vêm do GameState/SaveService).

@onready var sound_button: Button = $Margin/VBox/SoundButton
@onready var vibration_button: Button = $Margin/VBox/VibrationButton
@onready var version_label: Label = $Margin/VBox/VersionLabel
@onready var status_label: Label = $Margin/VBox/StatusLabel
@onready var reset_button: Button = $Margin/VBox/ResetButton
@onready var confirm_row: HBoxContainer = $Margin/VBox/ConfirmRow
@onready var confirm_yes: Button = $Margin/VBox/ConfirmRow/ConfirmYesButton
@onready var confirm_no: Button = $Margin/VBox/ConfirmRow/ConfirmNoButton
@onready var confirm_label: Label = $Margin/VBox/ConfirmRow/ConfirmLabel


func _ready() -> void:
	$Margin/VBox/Title.text = Loc.t("settings.title")
	version_label.text = "%s %s" % [
		Loc.t("settings.version"),
		str(ProjectSettings.get_setting("application/config/version", "0.1.0")),
	]
	sound_button.text = _toggle_text("settings.sound", SettingsService.sound_enabled())
	vibration_button.text = _toggle_text("settings.vibration", SettingsService.vibration_enabled())
	sound_button.toggled.connect(_on_sound_toggled)
	vibration_button.toggled.connect(_on_vibration_toggled)
	# Reset apenas em build de desenvolvimento (spec §5.8).
	reset_button.visible = OS.is_debug_build()
	reset_button.text = Loc.t("settings.reset")
	confirm_yes.text = Loc.t("settings.reset_yes")
	confirm_no.text = Loc.t("settings.reset_no")
	confirm_label.text = Loc.t("settings.reset_confirm")
	reset_button.pressed.connect(_on_reset_pressed)
	confirm_yes.pressed.connect(_on_reset_confirmed)
	confirm_no.pressed.connect(_on_reset_cancelled)


func _toggle_text(label_key: String, enabled: bool) -> String:
	var state_key := "settings.on" if enabled else "settings.off"
	return "%s: %s" % [Loc.t(label_key), Loc.t(state_key)]


func _on_sound_toggled(pressed: bool) -> void:
	SettingsService.set_sound_enabled(pressed)
	sound_button.text = _toggle_text("settings.sound", pressed)


func _on_vibration_toggled(pressed: bool) -> void:
	SettingsService.set_vibration_enabled(pressed)
	vibration_button.text = _toggle_text("settings.vibration", pressed)


func _on_reset_pressed() -> void:
	status_label.visible = false
	reset_button.visible = false
	confirm_row.visible = true


func _on_reset_cancelled() -> void:
	confirm_row.visible = false
	reset_button.visible = OS.is_debug_build()


func _on_reset_confirmed() -> void:
	SaveService.delete_save()
	GameState.reset_to_new_game()
	GameState.load_warning = ""
	GameState.pending_afk_report = {}
	GameState.save_now()
	get_tree().call_group("navigation", "close_all_overlays")
	confirm_row.visible = false
	reset_button.visible = OS.is_debug_build()
	status_label.text = Loc.t("settings.reset_done")
	status_label.visible = true
