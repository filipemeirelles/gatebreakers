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

**Resultado real da última execução (06/10/2026): `=== RESULTADO: 222 passaram, 0 falharam ===`, exit 0**, smoke `--quit-after 120` exit 0, export exit 0.

Suites (6): `test_save_service`, `test_navigation` (5 overlays), `test_combat_service`, `test_battle_screen`, `test_idle_rewards`, `test_upgrades`, `test_fase5`.
Observação: em erro de *parse* o processo Godot não termina → usar timeout no CI; correr `--import` primeiro se aparecer "Identifier not declared".

## 4. Estado das fases (spec §9)

| Fase | Estado | Evidência |
|---|---|---|
| 0 Base técnica e build Android | concluída | APK instalado e aberto no aparelho `RXCT301TRHY` |
| 1 Estado, save e navegação | concluída | testes save/navegação verdes |
| 2 Combate e progressão | concluída | testes de combate/resultados verdes; verificado no aparelho |
| 3 Recompensas AFK | concluída | testes AFK verdes; verificado no aparelho ("tudo ok" de Filipe) |
| 4 Melhorias e sombras | concluída | testes melhorias verdes (migração de save incluída); verificado no aparelho |
| 5 Cartões, configurações, acessibilidade e validação Android | concluída (validação em aparelho pendente de sessão final) | suíte 222/222, smoke e export verdes |

## 5. Limitações conhecidas (aceites para o protótipo)

- **Sem áudio real**: toggles de som/vibração guardam a preferência (`user://settings.cfg`) mas não existem sons/haptics implementados.
- **Arte temporária**: placeholders (formas/ícones de texto), sem assets de arte; nada de conteúdo protegido de *Solo Leveling* (texto próprio PT-BR).
- **Relógio local manipulável**: recompensas AFK baseiam-se no relógio do aparelho (aceite no §11 para protótipo offline).
- **Sem serviços online**: nenhuma função depende de internet (critério 12); sem contas/nuvem/leaderboards.
- **Decisão de design**: varredura de portal de chefe já concluído concede a essência do chefe (1 linha de código se Filipe quiser mudar).
- **Decisão de design**: o level-up de Jinwoo consome XP (100×nível) + ouro (25×nível) e guarda `hunter_level` no save; saves antigos migram automaticamente.
- **Gatilhos dos cartões narrativos**: Abertura / Portal 1 / Portal 2 (escolhido por Filipe).
- **Reset**: "Repor progresso" visível apenas em build de debug, com confirmação Sim/Não.

## 6. Arquitetura rápida (onde mexer)

- `scripts/autoload/game_state.gd` — todo o estado + regras de economia (fonte única).
- `scripts/systems/save_service.gd` — gravação atómica, validação, migrações (`SCHEMA_VERSION`).
- `scripts/systems/combat_service.gd` — combate determinístico puro (sem RNG).
- `scripts/systems/idle_reward_service.gd` — cálculo AFK puro.
- `scripts/systems/settings_service.gd` — preferências locais.
- `scripts/systems/content_db.gd` + `data/*.json` — unidades, portais, cartões narrativos.
- `scripts/ui/navigation_controller.gd` — telas/overlays, cartões pendentes, áreas seguras.
- `scenes/**` — UI apenas desenha estado e encaminha ações (sem lógica económica).
- `tests/runner.tscn` — suíte headless; novos testes: criar `tests/test_*.gd` e registar em `test_runner.gd`.

## 7. Próximo passo

Validação final em aparelho real (sessão de teste curta, critérios §10.1/10.12/10.14): cartões narrativos, configurações/reset, modo avião, áreas seguras 9:16 e 20:9, sem crash, desempenho dentro da meta — e entrega do resumo final a Filipe.
