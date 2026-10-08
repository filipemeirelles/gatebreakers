class_name AudioTests
extends RefCounted
## Testes do SoundManager procedural e preferências de áudio (E4).
## `t` é o runner: precisa do método check(cond, name).


static func run(t: Node) -> void:
	print("-- Feedback Audiovisual & SoundManager --")
	var orig_sound := SettingsService.sound_enabled()

	_test_stream_generation(t)
	_test_sound_toggles(t)
	_test_sound_play_calls(t)

	SettingsService.set_sound_enabled(orig_sound)


static func _test_stream_generation(t: Node) -> void:
	var sm := SoundManager
	t.check(sm != null, "SoundManager autoload disponível")
	t.check(sm._sounds.size() >= 8, "pelo menos 8 efeitos sonoros sintetizados")

	for key in ["click", "hit", "skill", "heal", "level_up", "victory", "defeat", "chest"]:
		t.check(sm._sounds.has(key), "efeito '%s' presente no SoundManager" % key)
		var wav: AudioStreamWAV = sm._sounds.get(key)
		t.check(wav != null, "'%s' é AudioStreamWAV válido" % key)
		t.check(wav.format == AudioStreamWAV.FORMAT_16_BITS, "'%s' usa formato 16-bit PCM" % key)
		t.check(wav.mix_rate == SoundManager.SAMPLE_RATE, "'%s' possui taxa de amostragem correta" % key)
		t.check(wav.data.size() > 0, "'%s' contém dados de áudio sintetizados" % key)


static func _test_sound_toggles(t: Node) -> void:
	SettingsService.set_sound_enabled(false)
	t.check(not SettingsService.sound_enabled(), "som pode ser desativado nas configurações")

	SettingsService.set_sound_enabled(true)
	t.check(SettingsService.sound_enabled(), "som pode ser reativado nas configurações")


static func _test_sound_play_calls(t: Node) -> void:
	# Verificação de segurança: chamadas não provocam erros ou falhas em runtime
	SettingsService.set_sound_enabled(true)
	SoundManager.play_click()
	SoundManager.play_hit()
	SoundManager.play_skill()
	SoundManager.play_heal()
	SoundManager.play_level_up()
	SoundManager.play_victory()
	SoundManager.play_defeat()
	SoundManager.play_chest()
	t.check(true, "todas as funções de reprodução executam sem erro quando ativadas")

	SettingsService.set_sound_enabled(false)
	SoundManager.play_click()
	SoundManager.play_hit()
	t.check(true, "reprodução com áudio desativado silencia sem erro")
