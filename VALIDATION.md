# Gatebreakers — validação visual v0.2

**Data:** 06/10/2026

**Build instalado:** `0.2.0` (Android versionCode 2), Godot 4.7.2, APK debug `build/gatebreakers-debug.apk`

**Dispositivo:** `RXCT301TRHY`, Android 16 / API 36, 1080×2340, orientação retrato

## Verificações concluídas

- Suíte Godot headless: **238 passaram, 0 falharam**, exit 0.
- Smoke headless (`--quit-after 120`): exit 0.
- Export Android: exit 0; `adb install -r` atualizou o APK sem limpar o save; o jogo abriu no aparelho.
- Versão conferida no pacote: `versionName=0.2.0`, `versionCode=2`.
- Teste visual manual informado por Filipe: as imagens foram exibidas e a verificação correu bem.
- A atualização por ondas reconstrói os retratos dos inimigos ao passar para a onda seguinte; o teste de tela cobre essa transição.
- O jogo foi aberto em modo avião na validação anterior; nesta sessão o modo avião permaneceu desativado.

## Validação manual ainda pendente

- Medir desempenho durante combate ativo para confirmar a meta de 30 FPS.
- Testar o reset pela interface; o save atual foi preservado intencionalmente.
- Conferir proporção 9:16; o aparelho usado é 1080×2340 (aprox. 20:9).
- Áudio/vibração continuam adiados; os SVGs atuais são arte vetorial de protótipo.

O APK `0.2.0` está instalado e aberto no aparelho, pronto para continuar o playtest. A camada visual usa os SVGs originais já existentes no projeto; o serviço de combate determinístico não foi alterado.
