# Gatebreakers — validação do ciclo PML v0.3

**Data:** 06/10/2026

**Build exportado:** `0.3.0` (Android versionCode 3), Godot 4.7.2, APK debug `build/gatebreakers-debug.apk`

**Dispositivo:** `RXCT301TRHY`, Android 16 / API 36, 1080×2340, orientação retrato

## Verificações concluídas

- Suíte Godot headless: **281 passaram, 0 falharam**, exit 0.
- Cobertura nova: reprodução do time salvo no Portal 7, invariantes vivo/morto, distinção #1/#2 e alvo automático, farm com vitória/derrota/pausa, migração de save v1→v2, baús AFK, guardrail de poder, recompensa ordenada e red dots.
- Smoke headless (`--quit-after 120`): exit 0.
- Export Android: exit 0. `aapt` conferiu `com.gatebreakers.prototype`, `versionName=0.3.0`, `versionCode=3`.
- **Sem instalação/teste no celular nesta sessão**, conforme pedido de Filipe; o save do aparelho não foi acessado nem alterado.

## Teste manual reservado para amanhã

- Exportar/instalar o APK v0.3 com `adb install -r` e conferir versão/save preservado.
- Reproduzir batalha do Portal 7 com equipe atual; observar HP do último inimigo, alvo #1/#2 e morte em HP zero.
- Testar auto-farm: vitória avança e paga; derrota interrompe; segundo plano interrompe; batalha manual continua disponível.
- Deixar o Baú do Sistema acumular, resgatar marco, verificar red dot e persistência após reabrir.
- Verificar confirmação de risco alto, red dots de melhorias e layout/áreas seguras.
- Medir FPS em batalha ativa para a meta de 30 FPS; o reset fica fora do teste para preservar o save.
- Áudio/vibração continuam adiados; a arte atual ainda é SVG de protótipo.

O build v0.3 está em `build/gatebreakers-debug.apk`, pronto para instalar amanhã quando Filipe reconectar o telefone.
