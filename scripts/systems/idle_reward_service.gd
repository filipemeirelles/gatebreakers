class_name IdleRewardService
extends RefCounted
## IdleRewardService — cálculo puro das recompensas AFK (spec §4 Recompensas
## AFK, §6 IdleRewardService). Sem efeitos: só tempo/taxas → relatório.
##
## Regras (testáveis em tests/test_idle_rewards.gd):
## - elapsed = clamp(now - last_background, 0, teto de 8 h em BalanceConfig).
## - Relógio retrocedido (now < last) ou primeiro início (last ausente) → 0.
## - Recompensa = floor(taxa_hora × elapsed / 3600); sem essência AFK.
## - Taxas pelo maior portal concluído; sem portal concluído → 0/h.


## Segundos contados para a recompensa (spec §4).
static func compute_elapsed(now_unix: int, last_background_unix: int, cap_seconds: int) -> int:
	if last_background_unix <= 0 or now_unix <= last_background_unix:
		return 0
	return mini(now_unix - last_background_unix, cap_seconds)


## Relatório completo para o ecrã AFK (spec §5.2 e critério §10.9).
static func build_report(now_unix: int, last_background_unix: int, gate: int) -> Dictionary:
	var cap_seconds := BalanceConfig.afk_cap_seconds()
	var raw_elapsed := 0
	if last_background_unix > 0 and now_unix > last_background_unix:
		raw_elapsed = now_unix - last_background_unix
	var elapsed := mini(raw_elapsed, cap_seconds)
	var gold_per_hour := BalanceConfig.afk_gold_per_hour(gate) if gate >= 1 else 0
	var xp_per_hour := BalanceConfig.afk_xp_per_hour(gate) if gate >= 1 else 0
	return {
		"elapsed": elapsed,
		"raw_elapsed": raw_elapsed,
		"capped": raw_elapsed > cap_seconds,
		"gold": int(floor(float(gold_per_hour) * elapsed / 3600.0)),
		"xp": int(floor(float(xp_per_hour) * elapsed / 3600.0)),
		"gate": gate,
		"gold_per_hour": gold_per_hour,
		"xp_per_hour": xp_per_hour,
	}
