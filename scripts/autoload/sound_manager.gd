extends Node
## SoundManager — efeitos sonoros procedurais gerados em tempo de execução
## respeitando a preferência local em SettingsService (sem arquivos externos).

const SAMPLE_RATE := 22050
var _pool: Array[AudioStreamPlayer] = []
var _pool_index := 0
var _sounds: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in 6:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_pool.append(player)
	_generate_all_sounds()


func _generate_all_sounds() -> void:
	_sounds["click"] = _generate_click()
	_sounds["hit"] = _generate_hit()
	_sounds["skill"] = _generate_skill()
	_sounds["heal"] = _generate_heal()
	_sounds["level_up"] = _generate_level_up()
	_sounds["victory"] = _generate_victory()
	_sounds["defeat"] = _generate_defeat()
	_sounds["chest"] = _generate_chest()


func _play(sound_id: String) -> void:
	if not SettingsService.sound_enabled():
		return
	if not _sounds.has(sound_id):
		return
	var player: AudioStreamPlayer = _pool[_pool_index]
	_pool_index = (_pool_index + 1) % _pool.size()
	player.stream = _sounds[sound_id]
	player.play()


func play_click() -> void:
	_play("click")


func play_hit() -> void:
	_play("hit")


func play_skill() -> void:
	_play("skill")


func play_heal() -> void:
	_play("heal")


func play_level_up() -> void:
	_play("level_up")


func play_victory() -> void:
	_play("victory")


func play_defeat() -> void:
	_play("defeat")


func play_chest() -> void:
	_play("chest")


# --- Síntese de Formas de Onda ---

static func _make_wav(samples: PackedFloat32Array) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		var s := clampf(samples[i], -1.0, 1.0)
		var val := int(s * 32760.0)
		if val < 0:
			val += 65536
		bytes[i * 2] = val & 0xFF
		bytes[i * 2 + 1] = (val >> 8) & 0xFF
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = bytes
	return wav


func _generate_click() -> AudioStreamWAV:
	var duration := 0.025
	var count := int(SAMPLE_RATE * duration)
	var samples := PackedFloat32Array()
	samples.resize(count)
	for i in count:
		var t := float(i) / float(SAMPLE_RATE)
		var env := exp(-t * 120.0)
		samples[i] = env * sin(2.0 * PI * 900.0 * t) * 0.4
	return _make_wav(samples)


func _generate_hit() -> AudioStreamWAV:
	var duration := 0.12
	var count := int(SAMPLE_RATE * duration)
	var samples := PackedFloat32Array()
	samples.resize(count)
	for i in count:
		var t := float(i) / float(SAMPLE_RATE)
		var env := exp(-t * 26.0)
		var freq := 150.0 - t * 650.0
		var tone := sin(2.0 * PI * maxf(freq, 40.0) * t)
		var noise := sin(t * 12345.67) # ruído determinístico sem RNG
		samples[i] = env * (tone * 0.65 + noise * 0.35) * 0.7
	return _make_wav(samples)


func _generate_skill() -> AudioStreamWAV:
	var duration := 0.22
	var count := int(SAMPLE_RATE * duration)
	var samples := PackedFloat32Array()
	samples.resize(count)
	for i in count:
		var t := float(i) / float(SAMPLE_RATE)
		var env := exp(-t * 9.0)
		var freq := 260.0 + t * 900.0
		var tone := sin(2.0 * PI * freq * t)
		var harmonic := sin(4.0 * PI * freq * t) * 0.3
		samples[i] = env * (tone + harmonic) * 0.5
	return _make_wav(samples)


func _generate_heal() -> AudioStreamWAV:
	var duration := 0.24
	var count := int(SAMPLE_RATE * duration)
	var samples := PackedFloat32Array()
	samples.resize(count)
	for i in count:
		var t := float(i) / float(SAMPLE_RATE)
		var env := exp(-t * 9.5)
		var tone1 := sin(2.0 * PI * 523.25 * t)
		var tone2 := sin(2.0 * PI * 659.25 * t)
		samples[i] = env * (tone1 * 0.5 + tone2 * 0.5) * 0.45
	return _make_wav(samples)


func _generate_level_up() -> AudioStreamWAV:
	var duration := 0.36
	var count := int(SAMPLE_RATE * duration)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var freqs := [523.25, 659.25, 783.99, 1046.50]
	var note_dur := duration / 4.0
	for i in count:
		var t := float(i) / float(SAMPLE_RATE)
		var note_idx := mini(int(t / note_dur), 3)
		var note_t := fmod(t, note_dur)
		var env := exp(-note_t * 12.0)
		var tone := sin(2.0 * PI * freqs[note_idx] * note_t)
		samples[i] = env * tone * 0.5
	return _make_wav(samples)


func _generate_victory() -> AudioStreamWAV:
	var duration := 0.48
	var count := int(SAMPLE_RATE * duration)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var freqs := [392.00, 523.25, 659.25, 783.99]
	var note_dur := duration / 4.0
	for i in count:
		var t := float(i) / float(SAMPLE_RATE)
		var note_idx := mini(int(t / note_dur), 3)
		var note_t := fmod(t, note_dur)
		var env := exp(-note_t * 9.0)
		var tone := sin(2.0 * PI * freqs[note_idx] * note_t)
		var harmonic := sin(4.0 * PI * freqs[note_idx] * note_t) * 0.25
		samples[i] = env * (tone + harmonic) * 0.55
	return _make_wav(samples)


func _generate_defeat() -> AudioStreamWAV:
	var duration := 0.32
	var count := int(SAMPLE_RATE * duration)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var freqs := [330.0, 293.66, 220.0]
	var note_dur := duration / 3.0
	for i in count:
		var t := float(i) / float(SAMPLE_RATE)
		var note_idx := mini(int(t / note_dur), 2)
		var note_t := fmod(t, note_dur)
		var env := exp(-note_t * 8.0)
		var tone := sin(2.0 * PI * freqs[note_idx] * note_t)
		samples[i] = env * tone * 0.5
	return _make_wav(samples)


func _generate_chest() -> AudioStreamWAV:
	var duration := 0.22
	var count := int(SAMPLE_RATE * duration)
	var samples := PackedFloat32Array()
	samples.resize(count)
	for i in count:
		var t := float(i) / float(SAMPLE_RATE)
		var env := exp(-t * 11.0)
		var tone1 := sin(2.0 * PI * 880.0 * t)
		var tone2 := sin(2.0 * PI * 1318.5 * t)
		var tone3 := sin(2.0 * PI * 1760.0 * t) * 0.5
		samples[i] = env * (tone1 * 0.4 + tone2 * 0.4 + tone3 * 0.2) * 0.5
	return _make_wav(samples)
