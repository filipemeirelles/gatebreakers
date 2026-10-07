# Referência — Pipeline de arte e animação do Gatebreakers

> Análise feita por Hermes em **06/10/2026**, com base no estado real do repositório (`C:\Users\Desktop\Documents\Projetos\gatebreakers`, v0.3.0) e em verificação web das ferramentas de geração disponíveis.
> Rótulos usados: **[F]** fato verificado · **[E]** estimativa · **[R]** recomendação.

---

## 1. Diagnóstico: onde o projeto está hoje

### 1.1 Estado do jogo **[F]**
- Godot **4.7.2** + GDScript, idle RPG vertical Android, offline-first; viewport **720×1280** (9:16), renderer **GL Compatibility**, compressão ETC2/ASTC ligada.
- Versão **0.3.0**, `versionCode` 2; fases 0–6 concluídas; suíte **281 testes** (era 238 na v0.2 — o projeto cresceu para o ciclo PML v0.3); último APK instalado no aparelho `RXCT301TRHY`.
- Conteúdo em `data/*.json`: 5 unidades, 10 portais, 3 cartões narrativos, balance config.
- Combate determinístico em `CombatService`, economia em `GameState`, save schema v2 com migração.

### 1.2 Estado da arte **[F]**
- **89 arquivos de arte, 100% SVG vetorial**, gerados por script (`scripts/tools/generate_assets.py`), não por IA generativa:
  - `assets/units/`: 7 arquivos — jinwoo, igris, shadow_soldier, shadow_ranged, shadow_guardian, enemy_common, enemy_boss (256×256).
  - `assets/icons/`: 17 ícones de recurso/navegação (96×96).
  - `assets/badges/`: 5 selos de rank (E–S).
  - `assets/skills/`: 3 ícones de habilidade.
  - `assets/story/`: 3 ilustrações de cartão narrativo.
  - `assets/battle/`: 1 backdrop de arena.
  - `assets/ui/gatebreakers_theme.tres` (tema); `assets/theme/` está **vazio**.
- O campo `art` em `data/units/*.json` é a única interface de arte das unidades (`res://assets/units/*.svg`), resolvido por `ArtHelper.unit_texture()`; inimigos são resolvidos por `ArtHelper.enemy_texture(is_boss)` → `enemy_common.svg` / `enemy_boss.svg`.
- **Não existe nenhuma animação no projeto**: zero `AnimatedSprite2D`, `SpriteFrames`, `AnimationPlayer`, `AtlasTexture` ou `GPUParticles2D`. Toda a arte é `TextureRect` estática.

### 1.3 O bloqueio atual **[F]**
- O `HANDOFF.md` registra: *"novas ilustrações manhwa estão bloqueadas até haver saldo pré-pago Gemini API; nenhuma imagem piloto foi gerada ainda"*.
- Ou seja: o bloqueio é de **API paga (pay-as-you-go)**, não de assinatura. **A assinatura Google AI Plus que você já paga resolve isso para uso manual** (gerar no app Gemini e salvar o arquivo), sem custo por imagem. É a mudança de rota mais importante daqui.

### 1.4 Segundo projeto, mesma marca **[F]**
- Existe um segundo projeto em `C:\Users\Desktop\Documents\GitHub\Gatebreakers` (+ pasta `GatebreakersUE 5.8`): Unreal Engine, com documentação de direção de arte em **3D anime cel-shaded** ("referências mentais: Genshin Impact, Honkai Star Rail, Solo Leveling, Granblue Fantasy: Relink") — última atividade em julho/2026, enquanto o Godot está em outubro/2026.
- **[R] Decisão a tomar explicitamente**: o pipeline 2D atual e o pipeline 3D não compartilham arte, shaders nem animação. Manter os dois em paralelo é o caminho mais provável para nenhum dos dois avançar. Recomendo **tratar o UE5 como arquivado** até o 2D estar apresentável, ou declarar a migração — mas não os dois ao mesmo tempo.

---

## 2. O que cada ferramenta entrega (verificado em 06/10/2026)

### 2.1 Google AI Plus — R$ 24,99/mês **[F]**
- Dá, no **app Gemini**: geração e edição de imagens com **Nano Banana** (Gemini 3 Pro Image / Nano Banana Pro e o modelo padrão), **geração de vídeo (Veo 3 Fast / 3.1 Fast)**, **200 créditos do Google Flow** (estúdio de cenas cinematográficas), acesso ao **Whisk**, Gemini 3 Pro, Deep Research, e 400 GB de armazenamento.
- O plano promete **limites 2× maiores que a versão gratuita**.
- Cotas aproximadas (fontes secundárias; o Google não publica tabela fixa e os números mudam): plano gratuito ≈ **100 imagens/dia** no Nano Banana padrão e **3 imagens/dia** no Nano Banana Pro; assinantes do AI Pro: 100/dia no Pro. Com o fator 2× do AI Plus, **[E]** ≈ 200 imagens/dia no modelo padrão e ≈ 6/dia no Pro.
- Vídeo: exclusivo de planos pagos; **[E]** 2–3 vídeos/dia nos modelos Fast com créditos de IA mensais. **[R] Validar no próprio app** antes de planejar em cima disso.
- **Ponto forte**: nenhuma cobrança por imagem, qualidade de topo em imagem+edição conversacional ("muda a cor da capa, mantém o rosto"), e o Flux dá vídeo.
- **Ponto fraco**: é interface manual, sem API e sem lote — serve para produzir, não para automatizar. E **vídeo não é spritesheet**: o vídeo precisa passar por extração de frames.

### 2.2 ChatGPT (plano gratuito) **[F/E]**
- Geração de imagem existe no plano gratuito, com limite não publicado oficialmente; fontes secundárias falam em ~2 gerações/dia com variantes. **[E]**
- **[R]** Serve como **terceira opinião** para um asset difícil (composição, cenário), não como base de produção: a cota é pequena e não é previsível.

### 2.3 Leonardo.ai (plano gratuito) **[F]**
- **150 Fast Tokens/dia**, que **não acumulam** — resetam a cada 24 h. Geração de **imagem e de vídeo** está liberada no free, com limites; "Ultra Quality", Elements e Image Guidance ficam limitados. Sem geração ilimitada relaxada (isso é Premium/Ultimate).
- O custo em tokens varia por modelo, resolução, nº de imagens e referências — a própria plataforma mostra o custo **no botão antes de gerar**, então calibre ali em vez de estimar.
- **Ponto forte**: presets de estilo (Anime, Cinematic Kino, Concept Art) e **Motion 2.0 / 2.0 Fast** para imagem→vídeo, mais controle fino (guidance, canvas em tempo real) do que o app Gemini.
- **Ponto fraco**: 150 tokens/dia dão poucas peças — é ferramenta de **refinamento**, não de volume. Vídeo no free consome a cota rápido.

### 2.4 Spriterrific **[F]**
- É o único dos quatro desenhado **exatamente para o problema do Gatebreakers**: caractere 2D animado pronto para engine.
- Fluxo documentado: **1)** descrever um personagem ou enviar imagem de referência e escolher a vista (side-scroller, top-down, isômetro); **2)** gerar uma **"âncora"** canônica de corpo inteiro em fundo chroma — toda animação deriva dela (é isso que mantém o personagem consistente); **3)** animar por **modelos de vídeo** com prompt de movimento controlado; **4)** exportar **PNG spritesheet transparente em grade de 256×256** + **`manifest.json`** (`frames`, `fps`, `columns`, `rows`, `anchor`) + preview GIF.
- Tem guias por engine (Unity 6, Phaser, Three.js) e posicionamento **"agent-first"**: instalar uma skill, criar API key e deixar o agente de código gerar os sprites.
- **[F] Lacuna**: a página de preços não retornou conteúdo na verificação — **não confirmei o free tier nem o custo**. Testar com 1 personagem é o único jeito honesto de saber.

### 2.5 Bônus descoberto nas buscas **[F]**
- Existem skills comunitárias de agente para esse fluxo: **`agent-sprite-forge`** (GitHub, `0x0funky/agent-sprite-forge` — spritesheets, mapas em camadas e cenas Godot/Unity geradas de linguagem natural) e **`godot-sprite-animation`** (agentskills.codes — workflow de integração de sprites no Godot: tamanho de frame, alinhamento, timing). Ambas podem ser instaladas como skill do Hermes.

### 2.6 Quadro-resumo
| Ferramenta | Imagem | Animação/spritesheet | Automação | Papel recomendado |
|---|---|---|---|---|
| **Gemini AI Plus** | Excelente (Nano Banana, edição conversacional) | Só vídeo (Veo), requer extração de frames | Não | **Produção principal de imagens** + vídeos de referência |
| **Leonardo free** | Boa, com presets de estilo | Motion 2.0 (imagem→vídeo) | Não | Refino e testes de estilo |
| **ChatGPT free** | Boa | Não | Não | Terceira opinião pontual |
| **Spriterrific** | Âncora consistente | **Sim — spritesheet + manifest** | **Sim (skill + API)** | **Animação de unidades** |

---

## 3. Estratégia recomendada: pipeline híbrido por camada de asset

**[R]** Nem tudo deve virar imagem gerada. Cada camada tem a ferramenta certa:

| Camada | Asset atual | O que fazer | Ferramenta |
|---|---|---|---|
| **A — UI** (17 ícones, 5 badges, tema) | SVG vetorial | **Manter como está.** Ícone vetorial é mais nítido em qualquer DPI, pesa menos e já está integrado. Só refazer se o estilo destoar das novas ilustrações | — |
| **B — Retratos de unidade/inimigo** (7) | SVG 256² | Gerar ilustração **PNG 512×512** com fundo removido; trocar o caminho no campo `art` do JSON | Gemini AI Plus (Nano Banana) |
| **C — Animação de batalha** | não existe | 4 animações mínimas em spritesheet: **idle, ataque, dano, morte** | Spriterrific (principal); Leonardo Motion ou Veo como alternativa manual |
| **D — Cenários** (arena, portal, telas) | 1 SVG | Imagem única **1080×1920** em WebP/JPG comprimido | Gemini AI Plus |
| **E — Cartões narrativos** (3) | SVG | 1 ilustração cinematográfica por card, **1080×1080** ou 1080×1920 | Gemini AI Plus |
| **F — VFX** (impactos, brilho, "arise") | não existe | **Particles do próprio Godot** (`GPUParticles2D`) + 2–3 texturas de brilho desenhadas; **não** usar vídeo | Godot + 1 textura gerada |

Regra de ouro do 2D mobile: **arte raster para o que é ilustrado, vetor para o que é interface, partícula para o que é efeito.**

---

## 4. Pipeline passo a passo

### Passo 0 — Folha de estilo (fazer uma vez, 1 dia) **[R]**
Sem isso, cada imagem sai com um estilo e o jogo fica com cara de colagem. Gerar **3 âncoras de estilo** (ex.: Jinwoo em 3 tratamentos: anime cel-shaded escuro, pintura semi-realista, webtoon coreano limpo) e **escolher 1**. Essa escolha vira o "prompt mestre" que vai em **todas** as gerações, junto com a mesma paleta.

### Passo 1 — Âncoras das unidades (Gemini AI Plus) **[R]**
- 1 geração por unidade, corpo inteiro, fundo **chroma puro (magenta #FF00FF ou verde #00FF00)**, luz consistente, vista de frente.
- Ordem: **Jinwoo → Igris → inimigo comum → boss → demais sombras**.
- Remover o fundo localmente (grátis):
  ```bash
  uv run --with "rembg[cpu]" rembg i entrada.png saida.png
  ```
- Salvar como `assets/units/<id>.png` (512×512) e trocar o campo `art` no JSON — **zero mudança de código**, a interface `ArtHelper` continua igual.

### Passo 2 — Animação (Spriterrific, com plano B) **[R]**
- **Plano A — Spriterrific**: enviar a âncora escolhida como referência, pedir `idle`, `attack`, `hurt`, `death`, exportar spritesheet + `manifest.json`. Começar por **um** personagem só (Jinwoo) e validar no aparelho antes de escalar.
- **Plano B — manual (Gemini/Leonardo)**: gerar um clipe curto de 2–4 s por animação (Veo 3 Fast ou Motion 2.0), extrair frames e montar a folha com ffmpeg:
  ```bash
  ffmpeg -i idle.mp4 -vf "fps=10,scale=256:256:flags=lanczos,tile=5x2" -frames:v 1 idle_sheet.png
  ```
  Se o vídeo saiu com fundo, processar os frames antes de montar (ou gerar o vídeo já sobre chroma e rodar `rembg` em lote na pasta de frames).
- **[F] Custo/limite**: cada clipe consome uma geração de vídeo (2–3/dia estimados no AI Plus) — por isso o Spriterrific (que já entrega sheet + manifest) é o caminho preferencial para as 4 animações × N unidades.

### Passo 3 — Importar no Godot **[R]**
- Salvar sheets em `assets/units/<id>/<acao>.png`. Importar PNG: **Filter ligado** (é arte lisa, não pixel art); mipmaps desligados; manter ETC2/ASTC ligado (já está no `project.godot`).
- Como hoje não existe animação, a integração exige a primeira estrutura de animação do projeto, por exemplo:
  - criar `SpriteFrames` por unidade e usar `AnimatedSprite2D` no lugar do `TextureRect` da unidade em `scenes/battle/battle.tscn`; **ou**
  - manter `TextureRect` e trocar a textura por `AtlasTexture` dentro de um `AnimationPlayer` (menos muda no layout).
- Se quiser carregar direto do `manifest.json` do Spriterrific, um util pequeno resolve (esqueleto a validar no editor):
  ```gdscript
  # scripts/ui/sprite_sheet_loader.gd  —  rascunho, ainda não no projeto
  static func frames_from_manifest(sheet_path: String, manifest_path: String) -> SpriteFrames:
      var m: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
      var sheet: Texture2D = load(sheet_path)
      var frames := SpriteFrames.new()
      frames.remove_animation("default")
      var action: String = m["action"]
      frames.add_animation(action)
      frames.set_animation_speed(action, float(m["fps"]))
      var fw: int = m["frameWidth"]
      var fh: int = m["frameHeight"]
      for i in int(m["frames"]):
          var col: int = i % int(m["columns"])
          var row: int = i / int(m["columns"])
          var at := AtlasTexture.new()
          at.atlas = sheet
          at.region = Rect2(col * fw, row * fh, fw, fh)
          frames.add_frame(action, at)
      return frames
  ```
- **Critério de aceitação da integração**: suíte `godot --headless --path . res://tests/runner.tscn` continua verde, smoke `--quit-after 120` exit 0, export Android exit 0, app aberto no aparelho com animação rodando e **30 FPS estáveis** (meta do spec §performance).

### Passo 4 — Validar no aparelho **[R]**
`adb install -r build/gatebreakers-debug.apk` (preserva o save) e checar: legibilidade da silhueta em tela pequena, custo de VRAM (quantas sheets por tela), e se o frame de dano/morte não dessincroniza do combate determinístico (o combate é calculado por `CombatService`; a animação é só apresentação — **nunca** deixar o resultado depender do tempo da animação).

---

## 5. Prompt pack (pronto para colar)

### 5.1 Prompt mestre de estilo (cole no início de toda geração)
```
Ilustração 2D para jogo mobile, estilo anime/webtoon coreano, cel-shading suave com contorno fino,
paleta escura e saturada (azul-noite, roxo sombra, ciano neon, magenta de portal), iluminação dramática
de baixo para cima, sombras em roxo, brilho ciano nas bordas, fundo chroma magenta puro (#FF00FF),
personagem de corpo inteiro centralizado, vista frontal, pose neutra de combate, alta legibilidade de
silhueta, sem texto, sem moldura, sem cenário, sem marca d'água.
```
**Negative prompt:** `texto, letras, logotipo, moldura, watermark, censura, fundo detalhado, vários personagens, corte de membros, anatomia deformada, artefato de pixel, estilo realista fotográfico`.

### 5.2 Prompts por unidade (adapte ao resultado da âncora)
| Alvo | Prompt |
|---|---|
| **Jinwoo** (hunter) | `caçador jovem de cabelo preto bagunçado, jaqueta escura, duas adagas curtas de lâmina azulada, aura de sombra roxa saindo dos ombros, olhos violeta brilhando, expressão determinada` |
| **Igris** (melee) | `cavaleiro alto de armadura negra completa, elmo com faixa vermelha de tecido, capa escura esfarrapada, espada longa na mão direita, brilho roxo saindo das juntas da armadura, postura de guarda` |
| **Soldado das Sombras** (melee) | `soldado de infantaria feito de escuridão sólida, silhueta negra com olhos violeta brilhantes, armadura simples, espada curta, corpo emanando fumaça roxa` |
| **Sombra Atiradora** (ranged) | `arqueiro de sombra, arco negro com corda de energia ciano, capuz, olhos lilás, corpo etéreo parcialmente translúcido` |
| **Sombra Guardiã** (tank) | `tanque de sombra robusto, escudo torre negro com runas roxas acesas, ombreiras largas, postura defensiva, silhueta massiva` |
| **Inimigo comum** | `goblin estilizado de rank E, verde musgo, olhos vermelhos, túnica de couro, adaga enferrujada, corpo pequeno e ágil` |
| **Boss** | `ogro xamã gigante, pele vermelho-escura, tatuagens teal brilhantes, capuz marrom, colar de caveiras, cajado de osso, aura de mana vazando, escala imponente` |
| **Cenário de arena** | `arena de masmorra rank E, caverna mística baixa-fantasia, portão dimensional azul brilhando ao fundo, pedras úmidas, névoa leve, iluminação dramática ciano e roxa, sem personagens, vista vertical 9:16` |
| **Portal (tela)** | `portal dimensional azul-violeta flutuando em ambiente urbano noturno, anéis de energia girando, reflexo no asfalto, sem personagens, vertical 9:16` |
| **Cartão 1 — O Sistema** | `tela de status holográfica azul flutuando diante de um homem ferido no chão de uma masmorra, estilo webtoon, composição dramática vertical` |
| **Cartão 2 — Primeiro portal** | `caçador só, de costas, diante de um portal azul gigante, luz fria, silhueta forte, vista vertical` |
| **Cartão 3 — Tropa de sombras** | `exército de soldados de sombra roxa emergindo do chão em formação, olhos violeta acesos em fileira, poeira subindo, vista vertical` |

### 5.3 Ordem de produção sugerida (1 semana, cabendo nas cotas)
- **Dia 1** — 3 âncoras de estilo (Nano Banana Pro, cota pequena diária) → escolher 1.
- **Dia 2** — 7 âncoras de unidade em chroma (modelo padrão, ~100–200/dia disponível) + `rembg` + troca do campo `art`.
- **Dia 3** — TESTE DE ANIMAÇÃO de 1 personagem (Jinwoo, 4 animações) no Spriterrific + integração no Godot + rodar suíte.
- **Dia 4** — Validar no aparelho (FPS, VRAM, legibilidade). Só seguir se passar.
- **Dia 5** — Animar inimigo comum + boss.
- **Dia 6** — Cenários (arena + portal) e 3 cartões narrativos.
- **Dia 7** — Animar as 3 sombras restantes; portas abertas para as ~20 sombras do documento de referência de lore.

---

## 6. Riscos, armadilhas e limites

1. **IP (importante)** **[R]**: o Gatebreakers é protótipo **privado de fã, não publicável** (o próprio spec diz isso). Imagens geradas que reproduzam personagens protegidos servem para estudo pessoal; se um dia houver intenção de publicar, é necessário **redesenhar** personagens e nomes. Não usar arte do anime em hipótese alguma.
2. **Cotas mudam sem aviso** **[F]**: os números de imagem/vídeo por dia variam entre fontes e o Google não publica tabela fixa. Planejar por *dia de trabalho*, não por "quantidade garantida".
3. **Não confundir assinatura do app com API paga** **[F]**: o bloqueio registrado no `HANDOFF` é do saldo pré-pago da Gemini **API**. A assinatura AI Plus gera imagem à vontade no app, mas sem automação — o download/renomeação/organização dos arquivos é manual (ou feito por mim, se você me passar os arquivos).
4. **Vídeo ≠ spritesheet** **[F]**: qualquer vídeo (Veo/Motion) precisa virar frames + folha + limpeza de fundo. Se a meta é animação de jogo, Spriterrific é o caminho curto; vídeo generativo é o caminho longo.
5. **Consistência é o risco real, não a qualidade** **[R]**: o perigo é Jinwoo parecer 3 pessoas diferentes em 3 telas. Sempre: 1 âncora por personagem → todas as variações derivam dela (edição por referência, não geração nova).
6. **Peso e performance** **[R]**: manter frames em 256×256 e sheets ≤ 2048×2048; arte raster animada multiplica VRAM rápido em celular. Meta do spec: 30 FPS estáveis.
7. **Dispersão** **[R]**: existem hoje **dois** projetos Gatebreakers (Godot 2D ativo, UE5 3D parado) e um cardápio de 4 ferramentas de imagem. O caminho seguro é: **um projeto, uma folha de estilo, uma ferramenta principal por camada**, e só escalar depois que o primeiro personagem animado estiver rodando no aparelho.
8. **Nada de arte antes do teste** **[R]**: gerar 30 imagens antes de validar a integração de 1 sprite animado no Godot é o desperdício mais provável deste plano.

---

## 7. Lacunas desta análise
- **Preço e free tier do Spriterrific**: a página de preços não retornou conteúdo na verificação → não confirmado.
- **Cotas exatas de imagem/vídeo do Google AI Plus**: não publicadas oficialmente; os valores usados são de fontes secundárias e marcados como estimativa.
- **Custo por ação no Leonardo free**: varia por modelo/resolução — só é confiável olhando o botão de gerar, dentro do app.
- **Nenhuma imagem foi gerada nesta análise**: o documento é plano e diagnóstico; a geração depende do seu acesso manual ao app Gemini / Spriterrific / Leonardo.
