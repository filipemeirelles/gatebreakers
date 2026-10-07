# Gatebreakers — validação do protótipo

**Data:** 06/10/2026  
**Commit do código:** `017bd12` (`Initial Gatebreakers MVP prototype`)  
**Build instalado:** `0.1.0`, Godot 4.7.2, APK debug `build/gatebreakers-debug.apk`  
**Dispositivo:** `RXCT301TRHY`, Android 16 / API 36, 1080×2340, orientação retrato

## Verificações concluídas

- Suíte Godot headless: **222 passaram, 0 falharam**, exit 0.
- Smoke headless (`--quit-after 120`): exit 0.
- Instalação por `adb install -r` e abertura do APK no aparelho: sucesso; o processo permaneceu ativo.
- O save preexistente foi preservado. Antes da abertura: portal 1 concluído, 163 ouro e 31 XP. A abertura computou aproximadamente 2 h AFK e creditou 21 ouro e 10 XP. A reabertura imediata não duplicou o crédito.
- Modo avião: o jogo foi encerrado e aberto novamente com `cmd connectivity airplane-mode enable`; o save foi lido corretamente e permaneceu consistente. O modo avião foi desativado ao final.
- Amostra de renderização após inicialização: 25 frames, 2 frames janky (8%), percentil 90 de 12 ms. É uma amostra curta e não representa uma batalha completa.

## Validação manual ainda pendente

- Jogar visualmente uma batalha completa no aparelho, incluindo interação com pausa, x2, vitória/derrota e recompensa.
- Inspecionar legibilidade, recorte/notch e áreas seguras diretamente na tela. A resolução real tem recorte superior; a árvore de acessibilidade Android só expõe a `SurfaceView` do Godot, não os controles do jogo.
- Fazer um teste visual em proporção 9:16; o aparelho disponível é 1080×2340 (aprox. 20:9).
- Testar o reset pela interface. O save foi mantido intencionalmente, sem confirmar a ação destrutiva.
- Medir desempenho durante combate ativo para confirmar a meta de 30 FPS.

O APK está instalado e aberto no aparelho, pronto para o playtest. Esta validação confirma a inicialização, persistência, cálculo AFK e operação offline; os itens manuais acima devem ser observados durante a primeira sessão de jogo.
