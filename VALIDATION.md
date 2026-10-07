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

## Verificação manual complementar

- Observar uma batalha completa do Portal 7: alvo #1/#2, HP do último inimigo e morte em HP zero.
- Testar na interface o toggle do auto-farm, parada por derrota/segundo plano e retorno à batalha manual.
- Conferir visualmente o Baú do Sistema, aviso de poder, badges, áreas seguras e notch.
- Medir FPS em batalha ativa para a meta de 30 FPS; o reset fica fora do teste para preservar o save.
- Áudio/vibração continuam adiados; a arte atual ainda é SVG de protótipo.

O APK v0.3 está instalado e aberto. Os testes headless cobrem as regras; a inspeção visual detalhada fica para a próxima sessão com o telefone em mãos.
