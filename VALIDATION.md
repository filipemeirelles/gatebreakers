# Gatebreakers — histórico de validação

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

## v0.4.0 — arte e progressão narrativa

**Data:** 07/10/2026

**Build:** `0.4.0` (Android `versionCode=4`), Godot 4.7.2, APK debug `build/gatebreakers-debug.apk`

### Verificações concluídas

- Importação Godot (`godot --headless --path . --import`): exit 0; novos retratos PNG e ilustrações JPEG importados.
- Suíte Godot headless: **292 passaram, 0 falharam**, exit 0. Inclui novos nomes/ranks de portais, chefes, desbloqueios, cartões, retratos, rótulos de preparação e recompensas de essência preservadas.
- Smoke headless (`godot --headless --path . --quit-after 120`): exit 0.
- Export Android: exit 0. `aapt` confirmou `com.gatebreakers.prototype`, `versionName=0.4.0`, `versionCode=4`; APK com 44.556.103 bytes.

### Smoke no aparelho (07/10/2026)

- `adb install -r` e abertura via launcher: sucesso no `RXCT301TRHY` (1080×2340). `dumpsys package` confirmou `0.4.0`/`versionCode=4`; processo permaneceu ativo.
- Capturas em `build/gatebreakers-v04-device.png` e `build/gatebreakers-v04-map.png`: mapa apresenta os nomes/ranks da progressão e o combate mostra os retratos PNG, inimigos e cenário novo sem erro visual de carregamento.
- Save permaneceu no schema v2 e a formação continuou `jinwoo`, `shadow_ranged`, `shadow_guardian`, `igris`; nenhum reset ou edição direta do save foi feito. A abertura também creditou o relatório AFK pendente (+278 ouro, +139 XP, 2 baús prontos).
- Durante o smoke, o toque ADB usado para dispensar o relatório abriu o combate do Portal 8. A leitura final do save mostra o Portal 8 concluído e níveis/recursos alterados; não reverti o progresso mais recente.
- Playtest prolongado de ritmo/balanceamento dos chefes e da essência permanece pendente.

## v0.5.0 — habilidades, caçadores e mockups

**Data:** 07/10/2026

**Build:** `0.5.0` (Android `versionCode=5`), Godot 4.7.2, APK debug `build/gatebreakers-debug.apk`

### Verificações concluídas

- Suíte Godot headless: **370 passaram, 0 falharam**, exit 0.
- Novas coberturas adicionadas:
  - `test_skills`: ciclo de recarga por ações próprias, multiplicadores determinísticos, Golpe Concentrado (Jinwoo), Golpe de Igris, Postura de Guarda (taunt + redução de dano), Tiro na Retaguarda (mira último vivo), persistência de recargas entre ondas e expiração de buff ao trocar de onda.
  - `test_hunters`: contratação com requisito de portal e ouro único (Jinho, Song, Joohee, Jinchul), equipe combinada (Jinwoo + caçadores + limite de 2 sombras invocadas), melhoria de caçadores com ouro, cura determinística de aliado ferido, cargas limitadas de varredura (5 por vitória, máx 15), migração schema v2→v3 preservando dados e progresso.
  - `test_navigation`: 6 overlays verificados, incluindo o novo overlay de Perfil do Caçador com abertura, fechamento e dados dinâmicos.
- Smoke headless (`godot --headless --path . --quit-after 120`): exit 0.
- Export Android: exit 0, APK assinado com sucesso.
- Interface alinhada aos mockups: Hub com fundo e cabeçalho (Perfil, Loja, Config), combate em grid de duas colunas (Aliados vs Inimigos), e 5 abas na navegação inferior.

## v0.5.1 — sistema de equipamentos e inventário

**Data:** 07/10/2026

**Build:** `0.5.1` (Android `versionCode=5`), Godot 4.7.2, APK debug `build/gatebreakers-debug.apk`

### Verificações concluídas

- Suíte Godot headless: **419 passaram, 0 falharam**, exit 0.
- Nova cobertura `test_items` (49 asserções novas):
  - Definições de equipamentos em `data/items/items.json`: slots arma e acessório, ranks E a S, bônus de ATK, DEF e HP.
  - Gestão de inventário e unicidade de itens no `GameState`.
  - Equipar, desequipar e transferir armas e acessórios entre Sung Jinwoo e caçadores contratados (ex: Yoo Jinho).
  - Bônus de atributos aplicados em tempo real aos combatentes e refletidos no poder de combate da equipe (`team_power()`).
  - Drop determinístico na primeira vitória em portais de chefes (ex: *Adaga de Goblin* no Portal 1, *Presa de Kasaka* no Portal 2). Repetições não duplicam itens.
  - Card pós-batalha (`battle_result.gd`) agora apresenta o item conquistado com destaque dourado (`result.item_dropped`), concretizando a promessa de `mockupcardbatalhas.png`.
  - Migração de save automática para schema v4 (`SaveService.SCHEMA_VERSION = 4`): concede itens dos portais já concluídos e auto-equipa arma no Jinwoo.
  - Red dot da aba "Itens": ativado automaticamente quando há item livre na mochila e combatente com slot vazio.
- Smoke headless (`godot --headless --path . --quit-after 120`): exit 0.
- Export Android: exit 0, APK assinado com sucesso.

## v0.6.0 — missões, lore, loja com ouro e feedback audiovisual

**Data:** 07/10/2026

**Build:** `0.6.0` (Android `versionCode=6`), Godot 4.7.2, APK debug `build/gatebreakers-debug.apk`

### Verificações concluídas

- Suíte Godot headless: **506 passaram, 0 falharam**, exit 0.
- Nova cobertura `test_missions` (28 asserções novas):
  - Definições de missões diárias em `data/missions/missions.json` com metas e recompensas balanceadas.
  - Rastreamento e contagem de eventos: vitórias em portais, chefes derrotados, baús resgatados e melhorias de caçadores.
  - Resgate com verificação de metas, concessão atômica de ouro, XP e cargas de varredura.
  - Red dot da aba "Missões" ligado dinamicamente à presença de missões prontas para resgate.
  - Arquivo e galeria da aba "História" permitindo reler qualquer cartão visto em alta resolução.
- Nova cobertura `test_store` (13 asserções novas):
  - Câmbio de suprimentos da Loja do Sistema usando ouro obtido in-game: compra de cargas de varredura (+3), essência de sombras (+10) e XP de caçador (+300).
  - Bloqueio por saldo insuficiente e verificação de requisitos (ex: cargas exigem ao menos 1 portal concluído).
- Nova cobertura `test_audio` (16 asserções novas):
  - `SoundManager` procedural em GDScript gerando e mantendo 8 formas de onda WAV PCM 16-bit 22.050 Hz em memória.
  - Efeitos sintetizados: clique, golpe básico, habilidade, cura, level up, vitória, derrota e baú.
  - Respeito à preferência de som em `SettingsService.sound_enabled()`: silencia completamente quando desativado.
  - Pop-up de cura verde (+HP) e números de dano diferenciados no combate.
- Smoke headless (`godot --headless --path . --quit-after 120`): exit 0.
- Export Android: exit 0, `versionName=0.6.0`, `versionCode=6`, APK assinado com sucesso.


