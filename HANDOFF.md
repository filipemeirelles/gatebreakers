# Gatebreakers — Handoff (protótipo privado)

Protótipo idle RPG vertical para Android, universo *Solo Leveling* (uso privado/fan, não publicável).
Stack: **Godot 4.7.2 + GDScript**, offline-first, conteúdo editável em `data/*.json`, textos em `data/localization/pt_BR.json`.
Spec (fonte de verdade): `gatebreakers-product-spec.md`.

## 1. Como abrir e correr

```powershell
# Variáveis do ambiente (User) precisam estar definidas:
#   JAVA_HOME (Temurin 17), ANDROID_SDK_ROOT/ANDROID_HOME (Sdk), PATH com o Godot
$env:Path = [Environment]::GetEnvironmentVariable("Path","User") + ";" + [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + $env:Path

godot --path .                    # editor
godot --headless --path . --import   # OBRIGATÓRIO após criar scripts com class_name novo
godot --headless --path . --quit-after 120   # smoke (arranque headless sem crash)
```

Dependências usadas (instaladas via winget/Google, aprovadas por Filipe):

| Componente | Local |
|---|---|
| Godot 4.7.2 | shim `C:\Users\Desktop\bin\godot.cmd` |
| JDK Temurin 17 | `C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot` |
| Android SDK (build-tools 34.0.0) | `C:\Users\Desktop\AppData\Local\Android\Sdk` |
| Export templates 4.7.2.stable | `%APPDATA%\Godot\export_templates\4.7.2.stable\` |
| Keystore debug | `C:/Users/Desktop/.android/gatebreakers-debug.keystore` (alias `gatebreakers_debug`, pass `android`) |

## 2. Como exportar e instalar

```powershell
$env:JAVA_HOME     = [Environment]::GetEnvironmentVariable("JAVA_HOME","User")
$env:ANDROID_SDK_ROOT = [Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT","User")
$env:ANDROID_HOME  = [Environment]::GetEnvironmentVariable("ANDROID_HOME","User")

godot --headless --path . --export-debug "Android" "build/gatebreakers-debug.apk"
adb install -r build\gatebreakers-debug.apk
adb shell monkey -p com.gatebreakers.prototype -c android.intent.category.LAUNCHER 1
```

O projeto está na versão `0.7.0` (Android `versionCode=7`). `export_presets.cfg` é local/ignorado pelo git; ao recriá-lo numa máquina, alinhar `version/name` e `version/code` com a versão do projeto. O APK desta versão é `build/gatebreakers-0.7.0-debug.apk`.

Comandos úteis de diagnóstico:

```powershell
adb exec-out screencap -p > tela.png                  # screenshot
adb shell run-as com.gatebreakers.prototype cat files/save_v1.json   # ler save
adb shell am force-stop com.gatebreakers.prototype    # fechar o app
# Modo avião (criterio 12):
adb shell settings put global airplane_mode_on 1
adb shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true
adb shell settings put global airplane_mode_on 0
adb shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false
```

Se o aparelho aparecer `unauthorized`: `adb kill-server; adb start-server` e aceitar o aviso no telemóvel.

## 3. Como correr os testes

```powershell
godot --headless --path . res://tests/runner.tscn   # exit 0 = tudo passa, 1 = falha
```

**Validação (07/10/2026): `=== RESULTADO: 506 passaram, 0 falharam ===`, exit 0.** Inclui:
- Habilidades determinísticas por recarga de ações próprias;
- 4 Caçadores contratáveis (Yoo Jinho, Song Chi-yul, Lee Joohee com cura, Woo Jinchul);
- Equipe de combate combinada com cap de sombras invocadas;
- Cargas de varredura manual com teto configurável;
- Navegação de 5 abas ativas baseada em mockups (Mapa, Caçadores, História, Itens, Missões);
- Overlays do Hub: Perfil do Caçador e Loja de Suprimentos do Sistema;
- Sistema completo de Equipamentos & Inventário (10 peças temáticas de chefes, slots arma/acessório, cálculo em combate);
- Missões diárias do Sistema com metas dinâmicas, resgate e red dots;
- Galeria de Lore na aba História para releitura de cartões desbloqueados;
- SoundManager com síntese procedural em GDScript (8 efeitos sonoros WAV PCM 16-bit em memória) respeitando a configuração de áudio;
- Save schema v4 com migração atômica automática;
- Smoke headless `--quit-after 120` exit 0;
- Export Android `0.6.0` (`versionCode=6`) assinado com sucesso.

Suites (13): `test_save_service`, `test_navigation` (7 overlays), `test_combat_service`, `test_battle_screen`, `test_auto_farm`, `test_idle_rewards`, `test_upgrades`, `test_fase5`, `test_skills`, `test_hunters`, `test_items`, `test_missions`, `test_store`, `test_audio`.
Observação: em erro de *parse* o processo Godot não termina → usar timeout no CI; correr `--import` primeiro se aparecer "Identifier not declared".

## 4. Estado das fases (spec §9)

| Fase | Estado | Evidência |
|---|---|---|
| 0 Base técnica e build Android | concluída | APK instalado e aberto no aparelho `RXCT301TRHY` |
| 1 Estado, save e navegação | concluída | testes save/navegação verdes |
| 2 Combate e progressão | concluída | testes de combate/resultados verdes; verificado no aparelho |
| 3 Recompensas AFK | concluída | testes AFK verdes; verificado no aparelho ("tudo ok" de Filipe) |
| 4 Melhorias e sombras | concluída | testes melhorias verdes (migração de save incluída); verificado no aparelho |
| 5 Cartões, configurações, acessibilidade e validação Android | concluída | testes e instalação no aparelho confirmados |
| 6 Visual e gamefeel v0.2 | primeira entrega concluída | retratos SVG por onda, cenário de batalha, animações de golpes/dano, ícones e tema; suíte 238/238; Filipe confirmou teste visual positivo |
| 7 Ciclo PML v0.3 | implementação e teste de smoke no Android concluídos | auto-farm parou na derrota no Portal 8; baús resgatados; batalha mostrou morto em 0 HP e alvo vivo destacado; suíte 281/281 |
| 8 Arte e progressão narrativa v0.4 | integração, suíte, export e smoke visual Android concluídos | suíte 292/292; APK `0.4.0`/`versionCode=4` instalado no `RXCT301TRHY`; save schema v2, Portal 8 atual |
| 9 Habilidades, Caçadores e Mockups v0.5 | implementação, suíte e export Android concluídos | suíte 370/370; save schema v3; habilidades determinísticas, 4 caçadores contratáveis, cargas de varredura, 5 abas, overlay de Perfil; APK `0.5.0`/`versionCode=5` assinado |
| 10 Equipamentos e Inventário v0.5.1 | implementação, suíte e export Android concluídos | suíte 419/419; save schema v4; 10 itens de marco, drops de chefe, slots de equipamento, bônus em combate, tela funcional de Itens e red dots; APK assinado |
| 11 Missões, Lore, Loja e SFX v0.6.0 | implementação, suíte e export Android concluídos | suíte 506/506; todas as 5 abas ativas sem telas bloqueadas; SoundManager procedural integrado; Loja com Ouro ativa; APK `0.6.0`/`versionCode=6` assinado |
| 12 Primeira fatia visual v0.7.0 | implementada e instalada; playtest do proprietário pendente | correções de equipe/arte, hub com hotspots, arena sem cards, card de resultado sobre batalha, recortes PNG com alfa; suíte isolada 525/525; APK `0.7.0`/`versionCode=7` instalado por ADB no `RXCT301TRHY`; sem smoke visual executado no telefone nesta sessão |

## 5. Limitações conhecidas (aceites para o protótipo)

- **Áudio**: SoundManager procedural sintetiza efeitos sonoros em memória (clique, golpe, skill, cura, level up, vitória, derrota, baú) respeitando `SettingsService.sound_enabled()`. Trilha sonora de fundo (BGM) não implementada para manter o pacote enxuto.
- **Arte**: retratos originais em PNG transparente e ilustrações de arena/cartões em JPEG estão integrados. Os SVGs vetoriais anteriores permanecem no projeto, mas não são os retratos ativos. Nada de assets oficiais de *Solo Leveling* foi incorporado.
- **Relógio local manipulável**: recompensas AFK baseiam-se no relógio do aparelho (aceite no §11 para protótipo offline).
- **Sem serviços online**: nenhuma função depende de internet (critério 12); sem contas/nuvem/leaderboards.
- **Decisão de design**: varredura de portal de chefe já concluído concede a essência do chefe (1 linha de código se Filipe quiser mudar).
- **Decisão de design**: o level-up de Jinwoo consome XP (100×nível) + ouro (25×nível) e guarda `hunter_level` no save; saves antigos migram automaticamente.
- **Gatilhos dos cartões narrativos**: Abertura / Portal 1 / Portal 4 (Igris, aprovado em 07/10/2026).
- **Reset**: "Repor progresso" visível apenas em build de debug, com confirmação Sim/Não.

## 6. Arquitetura rápida (onde mexer)

- `scripts/autoload/game_state.gd` — todo o estado + regras de economia (fonte única).
- `scripts/autoload/sound_manager.gd` — síntese e reprodução de efeitos sonoros procedurais (PCM 16-bit).
- `scripts/systems/save_service.gd` — gravação atómica, validação, migrações (`SCHEMA_VERSION = 4`).
- Save schema atual v4: caçadores contratados (`hunter_roster`, `hunter_formation`), cargas de varredura (`sweep_charges`), inventário e equipamentos (`inventory`, `equipped`), missões (`missions_progress`), baús AFK; saves v1, v2 e v3 migram automaticamente.
- `scripts/systems/combat_service.gd` — combate determinístico puro (sem RNG).
- `scripts/systems/idle_reward_service.gd` — cálculo AFK puro.
- `scripts/systems/auto_farm_controller.gd` — auto-limpeza foreground; regras/recompensas continuam nos services.
- `scripts/systems/settings_service.gd` — preferências locais.
- `scripts/systems/content_db.gd` + `data/*.json` — unidades, caçadores, equipamentos, missões, portais, cartões narrativos.
- `scripts/ui/art_helper.gd` + `assets/` — carregamento de retratos PNG e arte original de arena/cartões.
- `scripts/ui/navigation_controller.gd` — telas/overlays, cartões pendentes, áreas seguras.
- `scenes/**` — UI apresenta o estado, efeitos visuais e encaminha ações (sem lógica económica); `CombatService` continua sendo a fonte determinística dos resultados.
- `tests/runner.tscn` — suíte headless; novos testes: criar `tests/test_*.gd` e registar em `test_runner.gd`.

## 7. Próximo passo

Próximo passo: Filipe abrir a build `0.7.0` já instalada no `RXCT301TRHY` e avaliar hub, recortes das figuras, legibilidade da arena e card de resultado. O smoke visual no aparelho ainda não foi feito por este agente. Só depois do feedback, continuar polindo arte/animações e medir FPS; não gerar mais imagens pagas sem necessidade demonstrada.
