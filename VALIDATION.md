# Gatebreakers — validação do ciclo PML v0.3

**Data:** 06/10/2026

**Build instalado:** `0.3.0` (Android versionCode 3), Godot 4.7.2, APK debug `build/gatebreakers-debug.apk`

**Dispositivo:** `RXCT301TRHY`, Android 16 / API 36, 1080×2340, orientação retrato

## Verificações concluídas

- Suíte Godot headless: **281 passaram, 0 falharam**, exit 0.
- Cobertura nova: reprodução do time salvo no Portal 7, invariantes vivo/morto, distinção #1/#2 e alvo automático, farm com vitória/derrota/pausa, migração de save v1→v2, baús AFK, guardrail de poder, recompensa ordenada e red dots.
- Smoke headless (`--quit-after 120`): exit 0.
- Export Android: exit 0. `aapt` conferiu `com.gatebreakers.prototype`, `versionName=0.3.0`, `versionCode=3`.
- `adb install -r` e abertura via launcher: sucesso; processo permaneceu ativo.
- O save v1 migrou para schema v2, preservando formação e progresso; não houve reset. No smoke interativo, o save continuou válido e avançou para o Portal 7 com baús resgatados.
- Logcat do processo: sem `SCRIPT ERROR`, `FATAL EXCEPTION` ou erro de runtime Godot.
- Na tela Portais do aparelho: Baú do Sistema mostrou 4 baús; o resgate creditou +600 ouro/+240 XP; o auto-farm avançou pelo Portal 7 e parou após derrota no Portal 8, sem recompensa de derrota.
- Na batalha manual do Portal 8, a captura da onda 3 mostrou o inimigo #1 em `0/200` esmaecido e o inimigo #2 vivo em `85/200`, marcado como alvo. A derrota encerrou o combate sem alterar o progresso; o app permaneceu ativo.

## Verificação manual complementar

- Save atual: schema v2, Portal 7 concluído (próximo: Portal 8), formação/unidades preservadas, sem reset.
- Medir FPS durante uma batalha completa e verificar visualmente o aviso de poder/red dots com um perfil que os acione.
- Fazer um playtest prolongado do farm para avaliar ritmo/balanceamento; smoke breve confirmou vitória, avanço e parada por derrota.
- Conferir áreas seguras/notch; o aparelho usado é 1080×2340 (aprox. 20:9).
- O reset ficou intocado para preservar o save.
- Áudio/vibração continuam adiados; a arte atual ainda é SVG de protótipo.

O APK v0.3 está instalado e aberto; teste de tela realizado no aparelho. O build foi reexportado após o ajuste de posição dos números de dano; versão final `0.3.0`/`versionCode=3`.
