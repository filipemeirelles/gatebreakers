# Referência técnica: Pocket Monster League 1.0.8 (reverse engineering)

**Destinatário:** agente de código do Gatebreakers.
**Objetivo:** entregar fatos verificados sobre *como o Pocket Monster League (PML)* implementa os sistemas que o Gatebreakers usa como referência — principalmente recompensa AFK/offline, combate automático e progressão — para alimentar o MVP descrito em `gatebreakers-product-spec.md`.

**Uso permitido deste documento:** aprender padrões, arquitetura, fluxos e formulações de design.
**Uso proibido:** copiar código, texto, arte, áudio, modelos, tabelas de balanceamento ou qualquer outro asset do PML. É um jogo de terceiros, com direitos autorais e marcas (inclui conteúdo do universo Pokémon). O Gatebreakers já está descrito como protótipo privado sem publicação — mantenha assim.

---

## 1. Como isto foi obtido (reprodutível)

| Etapa | Ferramenta | Resultado |
|---|---|---|
| Abrir o XAPK | `unzip` | `com.pokeemode.and.apk` + `pad_sy.apk` (split) |
| Decodificar manifesto | `androguard` (`APK.get_android_manifest_xml`) | 198 activities, launcher identificado |
| Listar classes | `androguard` (`DEX`) | 11 DEX, ~2.929 classes do jogo |
| Decriptar strings | Script próprio + `androguard` | **87.001 strings, 0 falhas** |
| Achar o jogo real | varredura nas strings decriptadas | URL do H5 localizada |
| Baixar o jogo | `curl` no CDN | HTML + `manifest.*.json` + bundle de 8,2 MB |

A criptografia de strings é o **StringFog** open-source (`com.github.megatronking.stringfog`), implementação **XOR** (`xor.StringFogImpl`), com Base64 nas duas entradas:

```
plaintext = UTF8( base64decode(cipher) XOR ciclo(base64decode(key)) )
```

Os scripts usados ficam no scratch da sessão (`pml_decrypt2.py`, `pml_manifest.py`, `pml_ctx2.py`) — o resultado de 87 mil strings tem ~10 MB e **não** foi copiado para este repositório.

---

## 2. O que o APK realmente é

O APK **não contém o jogo**. É um *shell de WebView*:

- Sem `lib/*.so`, sem `assets/` no APK base, sem Unity/Unreal/Cocos nativo.
- Pacote do manifesto: `com.pokeemode.and`; a árvore de classes é `com.hsbkmpockmon1.and.*` (há 3 identidades de pacote convivendo: recursos, SDK de canal e jogo).
- Launcher: `pokeemodeand.hahiwu.lexokr.emujva.SplashScreenActivity`.
- A WebView é `com.hsbkmpockmon1.and.utils.MyWebView` + `AndroidBug5499Workaround` (ajuste de teclado).
- Toda a lógica do jogo vem da rede.

### 2.1 Ponte nativo ⇄ JavaScript

A `MainActivity` expõe ao JS (nomes originalmente em chinês):

- Identidade do papel: `roleID`, `roleName`, `roleLevel`, `serverId`, `serverName`, `roleVip`, `power`, `money`, `coin`, `guildId`, `guildName`.
- Eventos: `sdk_init_call`, `sdk_login_call`, `sdk_login_logout`, `sdk_role_info`, `game_load_webView`, `game_sendToJS`.
- Pagamento: `productId`, `productName`, `productDesc`, `orderID`, `callbackUrl`, `currency = USD`.
- Diálogos HTML nativos: `hs_title`, `hs_context`, `hs_okBtnText`, `hs_cancelBtnText`, `hs_openUrl`, `hs_exitGame`, `hs_version` (persistidos em SharedPreferences `my_cache`).
- Relatórios de tarefas/conquistas: `taskId`, `taskName`, `result`, `achId`, `achName`.

**Observação para o Gatebreakers:** não precisamos de ponte nativa nenhuma no MVP (offline, sem conta). Este bloco só se torna relevante se um dia houver SDK de canal/anúncio.

### 2.2 Stack do shell

AppsFlyer, Firebase Analytics, Facebook SDK, Google Ads, Play Billing, Play Integrity, Play Games, SDKs de canal chinês (`PolymerChannelSdk`, `cn.mj.sdk.PaymentActivity`) e dois endpoints chamativos de atribuição/antifraude (`api.qianxi5.com/ok.php`, `rh-api.neya.cc/dqgoogle_advertise.php`). **Nada disso é relevante para o Gatebreakers.**

---

## 3. O jogo H5 (onde está a lógica)

URL de entrada (dentro do APK):

```
https://cdn.hsbkmpock.com/monster_bt_free_foreign/
  monster_bt_free_foreign_chengwu_601_android_1.html?pack_version=1
```

### 3.1 Motor

- **Egret Engine** (白鹭), render **WebGL**, 60 fps, retrato **640×1386**, classe de entrada `LoadingCls`.
- Módulos carregados: `egret`, `egret.web`, `game`, `assetsmanager`, `eui`, `tween`, `socket`, `dragonBones`, `promise`, `loading`.
- Boot: `manifest.<version>.json` → `loadScriptList(initial)` → `egret.runEgret()` → `loadScriptList(game)`.
- Versão do build: `window.version = "20241106207"`; `window.isOversea = true`; `window.configFolder = "config"`.
- Jogo: `js/main.min_ea3c2cc2.js` (**8,2 MB**, minificado, 249 linhas) + `js/default.thm_ec588d6c.js` (tema EUI compilado, os `.exml` não são servidos).

### 3.2 Rede

- Jogo: **`mon-cw-1.hsbkmpock.com:30001`** (`window.SERVER_CONFIG`).
- Telemetria: `mon-cw-1.hsbkmpock.com:30098`; erros: `:30099/error`.
- Caminho próprio de log/erro: `logURL`, `errorURL` no HTML.

### 3.3 Limitação honesta

Os arquivos de balanceamento (tabelas `config.json` / `cq_<n>_json` carregados pelo `RES.loadConfig("config.json", "resource/")`) **não foram localizados no CDN** nas combinações testadas (`/config.json`, `/resource/config.json`, com e sem `?v=`, dois hosts). Ou seja: **não tenho as fórmulas numéricas do PML** — só o contrato de dados e os campos que o cliente lê. Não invente valores; se precisar das tabelas, alguém precisa capturar o tráfego do app rodando.

---

## 4. Arquitetura de código do cliente

Padrão consistente, tipo MVC + eventos:

- **`<Module>Model` / `ModelCls`** — estado do cliente. Ex.: `DunModel`, `FightAfkModel`, `RoleModel`, `BagModel`, `VipModel`, `TowerModel`.
- **`<Module>Proxy` / `ProxyCls`** — registro de mensagens e envio. Ex.: `DunProxy`, `FightAfkProxy`.
- **`MsgType.*`** — catálogo de mensagens do protocolo.
- **`NotifyType.*`** + `Notify.dispatch` — bus de eventos internos.
- **`<Module>Panel`** — telas (`PanelBase`), com `skinName`, `addNotifys`, `addUIEvents`, `onOpened/onClosed`.
- **Config** — `e.DunCfg`, `e.VipCfg`, `e.RoleCfg`, `e.TowerCfg` consultam `RES` (`_configJsons`), nunca números hardcoded na UI.
- **Red dot (ponto vermelho)** — `RedMgr.setStaticNodeRedValue(RedType.X, bool)` com tipo nominal, ex.: `RedType.QuickFight.FightQuickFightFreeTime`. **Modelo excelente para o MVP:** o Gatebreakers precisa de "tem coisa pra resgatar", e este padrão evita checagens espalhadas pela UI.
- **Skins** — `.exml` declarativos; o conteúdo é compilado para o bundle.

Registro de instâncias (trecho real):

```js
t.push(e.FightAfkModel = new e.fightAfk.FightAfkModelCls)
t.push(e.FightAfkProxy = new e.fightAfk.FightAfkProxyCls)
t.push(e.DunProxy      = new e.dungeon.DunProxyCls)
...
```

---

## 5. Protocolo relevante (cliente ⇄ servidor)

Mensagens verificadas no `MsgType` e nos handlers:

| Mensagem | Papel |
|---|---|
| `DUN_BATTLE_START` / `DUN_BATTLE_NO_START` | inicia combate do dungeon; resposta traz `battle_result_1` e `battle_result_2` |
| `DUN_AFK_INFO` | estado AFK: `g_dun_id`, `afk_type_list`, `can_draw_dun_chest_list` |
| `DUN_AFK_INFO_CLIENT` | espelha o estado AFK para a UI local |
| `SET_AFK_DUN` | escolher dungeon de farm ativo |
| `AFK_DUN_GUAJI_REWARD_PREVIEW` | **prévia** da recompensa offline acumulada |
| `AFK_DUN_GUAJI_REWARD` | **resgate** da recompensa offline |
| `AFK_REWARD_NUM_PUSH` | servidor empurra os minutos acumulados (`afk_reward_num`) |
| `AFK_REWARD_ABSORB` | animação de absorção das recompensas na tela |
| `AFK_DUN_BOX_CHEST_DRAW` | resgate de baú-marcos do farm |
| `AFK_DUN_SWEEP` | varredura (sweep) do dungeon AFK |
| `DUN_SWEEP`, `DUN_DAILY_SWEEP` | varredura comum / diária |
| `DUN_SECTION_AFK_FIGHT` | luta de seção do modo AFK |
| `DUN_AFK_BOSS_FINISH` | chefe do modo AFK concluído |
| `DUN_AFK_NUM_COST` | custo para estender/limite do AFK |
| `AFK_QUICK_AFK_INFO` | limites diários da **batalha rápida** |
| `AFK_QUICK_AFK` | executa a batalha rápida |
| `AFK_QUICK_AFK_PROGRESS_REWARD` / `..._RANK_LIST` | marcos acumulados + ranking da batalha rápida |
| `AFK_MISSION_TASK_VALUE` | tarefas vinculadas ao farm |
| `DUN_REPORT_REPALY` | replay/compartilhamento de relatório |
| `BATTLE_FAIL_AND_AUTO_STOP` | falha encerra o auto-progresso |

Campos observados nas respostas:

- `battle_result_1` / `battle_result_2` → `{ battle_id, actors: [...], rounds: [...] }`
- AFK offline → `dun_id`, `item_list_1`, `item_drop_list`
- Batalha rápida → `dun_id`, `reward_minute`, `item_list_1`, `item_list_2`
- Batalha rápida (info) → `free_day_num`, `gold_day_num`, `item_day_num`, `item_id`, `period_reward_list[]`
- Progressão → `cur_dun_id` por `afk_type`, `pre_dun` (dungeon anterior), `role_lev` (nível exigido)

---

## 6. Sistemas do PML — o que interessa ao Gatebreakers

### 6.1 Recompensa AFK / offline (o coração)

Verificado no cliente:

1. **Acúmulo em minutos, com teto.** O progresso é `afk_reward_num`, medido em minutos. O teto é a privilégio VIP `afk_max_hour`:

   ```js
   var o = e.VipModel.getRolePrivCfg(), n = o ? 60 * o.afk_max_hour : 720;
   this._pbrBox.maximum = n;   // 720 min = 12 h por padrão
   ```

   **Fato:** teto padrão = **12 horas**; VIP estende (`60 * afk_max_hour`).

2. **Barra de progresso + baú que "cresce".** O estado visual do baú muda com os minutos acumulados (faixas em 1, 5, 20 minutos; um aviso aparece quando `>= 60` minutos):

   ```js
   t < 1 ? idx = 1 : t < 5 ? idx = 3 : t < 20 ? idx = 5 : idx = 7;
   this._boxTipIsShow = (t >= 60)
   ```

3. **Baús-marcos vêm do servidor** (`can_draw_dun_chest_list`), resgatáveis via `AFK_DUN_BOX_CHEST_DRAW`. Ou seja: marcos de tempo ≠ recompensa contínua. São dois sistemas separados.

4. **Fluxo de offline é sempre em duas chamadas: PREVIEW → CLAIM.**

   ```
   AFK_DUN_GUAJI_REWARD_PREVIEW → FightAfkOutputPanel (mostra o ganho)
   AFK_DUN_GUAJI_REWARD         → FightAfkOutputRewardsPanel (confirma/resgata)
   ```

   O preview soma `item_list_1` + `item_drop_list`, agrupa por `id` e **ordena por prioridade fixa** (id 1 primeiro, depois 27, depois 5 = exp, resto depois) — atenção deliberada à hierarquia visual das recompensas.

5. **Ao resgatar:** `setTempRoleExp()` guarda XP e nível *antes* do crédito (para animar o ganho), a barra volta a 0 e o efeito `AFK_REWARD_ABSORB` anima a entrada dos itens.

6. **Relógio retroativo é problema do servidor.** O cliente só exibe. (No Gatebreakers, offline-first, somos nós quem calculamos — ver §7.)

**Mapa para o Gatebreakers:** o spec já manda `elapsed = clamp(now - last_background, 0, 28800)` (8 h). O PML confirma a *forma* da solução: **teto em minutos + prévia + resgate único + marcos separados + estado zerado após resgate**. A diferença é que o PML tem servidor; nós calculamos localmente.

### 6.2 Batalha rápida (快速战斗) — o "pular o farm"

Verificado:

- Devolve instantaneamente **`reward_minute` minutos de rendimento** do farm (`AFK_QUICK_TIP_2`: "可以立马获得 %s 分钟挂机收益").
- **Três cotas diárias independentes**: `free_day_num` (grátis), `gold_day_num` (comprado com ouro), `item_day_num` (consumindo `item_id`).
- O custo total diário é a soma das três: `free_day_num + gold_day_num + item_day_num`.
- Existe `period_reward_list` — **marcos acumulados** de batalhas rápidas no período, resgatáveis à parte (`AFK_QUICK_AFK_PROGRESS_REWARD`), mais um ranking (`..._PROGRESS_RANK_LIST`).
- Gate de desbloqueio: `SystemOpenModel.isSystemOpened(40)`.
- Red dot quando há `item_id` em estoque **ou** `free + gold < total máximo`.

**Tradução direta:** no Gatebreakers, "batalha rápida" = a **varredura (sweep)** já descrita no spec (§4, "Varredura") — resolução instantânea de um portal já vencido, com a recompensa normal. O que o PML **acrescenta** ao spec e vale considerar como pós-MVP:

1. Separar **limite diário grátis** de **limite estendível** (por recurso em vez de por anúncio/pagamento — o spec proíbe moeda paga, então ouro seria o candidato natural).
2. **Marcos de acúmulo** ("a cada N varreduras ganha X") dão uma segunda razão para voltar amanhã sem virar moeda paga.

*Não implementar no MVP.* É expansão.

### 6.3 Combate automático e aceleração

- Não existe "auto-battle" escondido: existe um **toggle explícito** (`_cboxAutoFight`) rotulado "自动在线闯关" (**limpeza automática online**), com aviso claro: *"a limpeza automática termina se você ficar offline"*.
- **Guarda de poder antes de aceitar**: se `0.8 * poder_inimigo >= meu_poder`, abre diálogo de confirmação com dois botões ("继续挑战" / "调整阵容" = continuar / ajustar formação).
- Aceleração (`_afkSpeed`, `加速`) existe, e o **servidor manda o resultado** — a velocidade só muda apresentação. Regra idêntica à do spec ("a aceleração altera apenas a apresentação, nunca os resultados determinísticos").
- Troca de formação durante o auto-progresso dispara aviso: formação inválida bloqueia (`LINEUP_INVALID_6`).

### 6.4 Combate: servidor autorita, cliente reproduz

- A resposta de `DUN_BATTLE_START` traz **`actors` + `rounds` completos**. O cliente **reproduz**, não calcula.
- O relatório de luta é **por rodada e por unidade**: `第%s回合:` (rodada N), `造成伤害` (dano causado), `承受伤害` (dano recebido), `治疗量` (curas), `控制 tempo` (tempo de controle), `触发被动技能` (passiva), `获得 buff`, `平局` (empate).
- Mensagens de derrota/vitória com contexto: *"Parabéns, você venceu %s em %s"*, *"Sair da batalha causará derrota imediata"*, *"Esta batalha não pode ser saída"*.

**Impacto no Gatebreakers:** nosso spec já escolhe **combate determinístico local** (`max(1, atk - floor(def/2))`, sem crítico/esquiva). Isso está correto e é *mais simples* que o PML. O que vale emprestar é a **estrutura do relatório**: gravar a batalha como lista de eventos `{rodada, atacante, alvo, dano, tipo}` e ter um renderer separado — isso torna `x2`, pausa, replay e teste unitário triviais, e é exatamente o que o spec pede ("a aceleração nunca altera resultados").

### 6.5 Tipos de conteúdo (catálogo verificado)

`COMMON_DUN_*` — os modos de dungeon do PML:

| Chave | Nome | Papel |
|---|---|---|
| `COMMON_DUN_AFK` | 挂机副本 | farm/idle — **nosso portal** |
| `COMMON_DUN_NORMOL` | 主线普通 | caminho principal normal |
| `COMMON_DUN_ELITE` | 主线精英 | variante difícil |
| `COMMON_DUN_NIGHTMARE` | 主线噩梦 | variante mais difícil |
| `COMMON_DUN_COIN` | 金币副本 | fonte de moeda |
| `COMMON_DUN_RIFINE` | 精炼副本 | moeda de upgrade |
| `COMMON_DUN_TOWER` | 爬塔副本 | torre/incremento |
| `COMMON_DUN_GYM_CHALLENGE` | 道馆挑战 | desafio temático |
| `COMMON_DUN_WING` | 翅膀副本 | fonte de equipamento |
| `COMMON_DUN_PET` | 跟宠副本 | fonte de unidade |
| `COMMON_DUN_ELITE_FOUR_CHALLENGE` | 挑战四天王 | desafio de chefe |
| `COMMON_DUN_CHAMPIONS` | 冠军 | conteúdo final |

**Leitura:** o PML usa **um modo de farm + vários modos "geradores de recurso"** (um por moeda) + desafios de chefe. O Gatebreakers MVP tem **um** modo (portais). Isso está certo — mas quando o spec falar em `shadow_essence`, pense que o PML separaria esse recurso em um "modo farm de essence", não no portal principal.

### 6.6 Progressão e economia observadas

- Recursos no shell de pagamento/report: **元宝** (yuanbao, id 1) e **钻石** (diamante, id 2) — moedas premium; **exp** é o item `id 5` (confirmado pelo código: `if (5 === l.id) r = l.num` → exp).
- Sistema de **VIP com privilégios tabulares** (`VipCfg.getRolePrivCfg()` → `afk_max_hour`, e `VipCfg.getMissionMaxValue(vipLev)` para limites de missão).
- **月卡 / 月卡 de semana** (`MonthCard.WEEK`) — cartão mensal que **acelera a recompensa offline** (o preview checa `checkHasCard`).
- **战力 / poder**: número agregado de combate, usado nas comparações (`0.8 * inimigo >= meu`) e no aviso de derrota.
- Sistemas presentes (contagem de ocorrências no bundle): 公会/guilda (92), 宠物/pet (241), 强化/upgrade (28), 突破/breakthrough (14), 扫荡/sweep (16), 副本/dungeon (21), 竞技场/arena (7), 签到/check-in (7), 商店/shop (35), 抽卡/gacha (4), 转盘/roleta (4).
- **Nenhum disso entra no MVP.** O spec já os exclui. A lista existe para calibrar escopo: é o tamanho que *não* queremos.

### 6.7 Sistema de desbloqueio progressivo

```js
checkDunIdCanFight(dunId):
  cfg = DunCfg.getBasicCfg(dunId)
  if RoleModel.level < cfg.role_lev      -> bloqueado
  if cfg.pre_dun && !passed(cfg.pre_dun) -> bloqueado
```

Dois gates: **nível do jogador** + **dungeon anterior concluída**. Mensagens distintas para cada caso (`NEW_EXTRACT_82` = "termine %s antes", `NEW_EXTRACT_83` = "precisa do nível %d").

O spec do Gatebreakers já tem o segundo gate (portais sequenciais) mas **não tem gate por nível**. Recomendação: manter sem gate por nível no MVP (menos uma tela de "você não pode") e, se o playtest mostrar progressão desequilibrada, adicionar como parâmetro em `BalanceConfig` — não como regra de tela.

---

## 7. Tradução concreta: PML → Gatebreakers MVP

Tabela de decisão para o agente de código. "Fazer" já está no spec; "PML confirma" é evidência; "PML acrescenta" é opção pós-MVP.

| Tema | O que o PML faz | O que o Gatebreakers faz | Veredito |
|---|---|---|---|
| Acúmulo AFK | minutos, teto 12 h, VIP estende | `clamp(elapsed, 0, 28800)` = 8 h | **Fazer** — o formato do PML confirma o do spec |
| Momento do crédito | preview → claim (2 chamadas) | creditar ao abrir e mostrar relatório | **Fazer** — é a mesma UX; aqui o crédito é local |
| Marcos de tempo | `can_draw_dun_chest_list` + `AFK_DUN_BOX_CHEST_DRAW` | não previsto | **PML acrescenta** — considerar se o relatório AFK parecer "genérico" no playtest |
| Zero ao resgatar | barra volta a 0, `setTempRoleExp` antes do crédito | não especificado explicitamente | **Fazer** — zere `last_background_unix` e anime o ganho |
| Hierarquia de recompensa | ordem fixa: id 1 → 27 → 5 → resto | lista simples | **PML confirma** — ordenar por tipo fixo (gold → essence → xp), nunca por id arbitrário |
| Varredura | batalha rápida com 3 cotas diárias + marcos | sweep de portal já vencido, recompensa normal | **Fazer** (versão simples do spec). Cotas e marcos = pós-MVP |
| Auto-combat | toggle com aviso "encerra ao ficar offline" | batalha é sempre automática; app só simula em primeiro plano | **Fazer** — já está no spec |
| Aceleração | muda só a apresentação | `x1`/`x2`, resultados determinísticos | **Fazer** — idêntico |
| Estrutura do relatório | eventos `{round, actor, target, damage, type}` gravados, depois renderizados | não detalhado no spec | **PML acrescenta** — implementar assim; destrava replay, teste e `x2` |
| Guarda de poder | confirmação se `0.8*inimigo >= meu` | não tem | **PML acrescenta** — barato de fazer e evita derrota frustrante no portal 5/10 |
| Gate de progressão | nível do jogador **+** dungeon anterior | só portal anterior | **Fazer** (só o portal) — ver §6.7 |
| Modos de recurso | um dungeon por moeda | um único portal | **Fazer** — mantenha um modo |
| Red dot | `RedMgr` com tipo nominal central | não tem | **PML acrescenta** — 1 função central evita checagem espalhada na UI |
| Pré-cálculo no offline | servidor calcula, cliente exibe | cliente calcula (offline-first) | **Fazer** — spec já define; aceitar risco de relógio adulterado |

### 7.1 Checklist de implementação derivado

Para o agente que implementar o MVP, o que a evidência do PML reforça:

1. Teto AFK em **minutos**, valor único em `BalanceConfig` (spec usa 8 h = 480 min).
2. Crédito **uma única vez** ao abrir, com `last_background_unix` zerado logo após.
3. Relatório AFK com **tempo computado + limite aplicado + itens detalhados** (spec §5, tela 2) — o PML dedica um painel inteiro (`FightAfkOutputPanel`) só para isso, o que confirma que é tela de primeira classe, não um toast.
4. Batalha gravada como **log de eventos determinísticos**, separado do renderer.
5. Sweep restrito a portals já vencidos (spec §4 "Varredura") — o PML tem até 3 variantes de sweep; não copie, uma basta.
6. Configuração de balanceamento **centralizada** (`BalanceConfig`), como o PML faz com `DunCfg`/`VipCfg` — nenhum número em script de UI.

---

## 8. O que explicitamente NÃO levar

- Nenhum asset, texto, sprite, som, modelagem ou nome do PML/ Pokémon.
- Nenhuma tabela de balanceamento do PML (nem obtenível — §3.3).
- Nenhum código do bundle Egret.
- Nenhum sistema de monetização, VIP, cartão mensal, gacha, roleta, guilda, arena ou anúncio — todos excluídos pelo spec.

---

## 9. Lacunas que ficaram abertas

1. **Tabelas de balanceamento** do PML: não localizadas no CDN (§3.3). Sem elas, não há como citar taxas por minuto, custos ou curvas de XP do PML.
2. **Fórmula exata** da recompensa AFK: o servidor envia `item_list_1`/`item_drop_list` prontos; o cliente nunca calcula. Para o Gatebreakers (offline) a fórmula é nossa e já está no spec.
3. **Conteúdo real do jogo** (quantos portais, bichos, evoluções): os dados vêm do servidor (`mon-cw-1:30001`) e exigem sessão de jogo para ler. O catálogo de *sistemas* (§6.5) é o que dá para afirmar com segurança.
4. O build foi analisado na versão **1.0.8 / `20241106207`**; um build diferente pode mudar números.
