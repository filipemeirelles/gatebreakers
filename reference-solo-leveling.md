# Referência completa — Universo de Solo Leveling (para o Gatebreakers)

> Documento de referência de conteúdo (personagens, locais, monstros, sistema, itens, poderes, caçadores e história).
> Montado por Hermes em **06/10/2026** a partir da wiki oficial de fandom (solo-leveling.fandom.com, ~487 páginas analisadas por API), das páginas de anime e de uma verificação web sobre o estado atual do anime.
> Uso pretendido: protótipo privado **Gatebreakers** (idle RPG, uso privado/fan, **não publicável**). Este arquivo é referência factual/descritiva — **não** é autorização para redistribuir arte, áudio, textos ou tabelas de balanceamento originais da obra. Nomes e conceitos pertencem aos detentores dos direitos (Chu-Gong / D&C Media / Kakao / A-1 Pictures).

---

## 0. Índice

1. A obra e suas mídias
2. A história: arcos, capítulos e episódios
3. O mundo: Portais (Gates) e Masmorras (Dungeons)
4. O Sistema (o "Player")
5. Caçadores: ranks, classes, licença, guildas e associações
6. Personagens (elenco por relevância e por país)
7. Exército das Sombras
8. Monarcas, Governantes, Apóstolos e Itarim (cosmologia)
9. Bestas Mágicas / monstros (taxonomia + tabela)
10. Chefes (bosses) notáveis
11. Locais: países, cidades, masmorras e dimensões
12. Itens: armas, equipamentos, consumíveis, materiais
13. Habilidades e poderes
14. Guildas e organizações
15. Glossário rápido (terminologias)
16. Ganchos para o Gatebreakers (mapa para `data/*.json`) e lacunas

---

## 1. A obra e suas mídias

- **Título**: Solo Leveling (나 혼자만 레벨업 / 俺だけレベルアップな件, *Ore dake Level Up na Ken*). Tradução literal alternativa: "Só Eu Subo de Nível" / "I Alone Level Up".
- **Autor original**: Chu-Gong (web novel sul-coreana, 2016–2018, 270+ capítulos).
- **Webtoon/Manhwa**: adaptação ilustrada (Dubai/D&C Media, Kakao), 179 capítulos na história principal + side stories / *Academy Arc*.
- **Sequência**: *Solo Leveling: Ragnarok* (novel + manhwa, protagonista **Sung Suho**, filho de Jinwoo) — 25 arcos. Continuação *Solo Leveling: Ragnarok* é a fonte de boa parte da lore mais recente (Monarcas sucessores, Apóstolos, Itarim, Denver).
- **Anime**: estúdio **A-1 Pictures**, direção de **Shunsuke Nakashige**, roteiro de **Noboru Kimura**, design de personagens **Tomoko Sudo**, trilha **Hiroyuki Sawano**. Streaming: Crunchyroll.
  - **Temporada 1**: 12 episódios, 06/01/2024 – 30/03/2024 (Japão); adapta do *D-Rank Dungeon Arc* até o *Job Change Arc*.
  - **Temporada 2 — "Arise from the Shadow"**: 13 episódios (totais 13–25), 04/01/2025 – 29/03/2025; cobre do *Red Gate* à *Ilha de Jeju*.
  - **Filme *Solo Leveling: ReAwakening***: 29/11/2024 (Japão) / 06/12/2024 (internacional) — recapitulação da S1 + estreia dos 2 primeiros episódios da S2.
  - **Episódio 7.5** "How to Get Stronger": especial de recapitulação.
  - **Estado em 2026** (verificado): **3ª temporada confirmada e em produção, sem data oficial**. Relatório financeiro da D&C Media (09/06/2026) indica janela **2027–2028**. Em julho/2026 (Anime Expo) foi revelado um **novo filme: *Solo Leveling: Beyond the System*** (primeiro key visual e teaser), que **não** é a temporada 3. *(Fato verificado em fontes secundárias; tratar a janela como estimativa.)*
- **Músicas**: OP S1 "LEveL" (SawanoHiroyuki[nZk]:TOMORROW X TOGETHER); ED S1 "Request" (krage); OP S2 "ReawakeR" (LiSA ft. Felix do Stray Kids); ED S2 "UN-APEX" (TK from Ling tosite sigure); OST do filme "4eVR".
- **Elenco principal (voz JP)**: Taito Ban (Sung Jinwoo), Reina Ueda (Cha Hae-In), Hiroki Touchi (Baek Yoonho), Daisuke Hirakawa (Choi Jong-In), Genta Nakamura (Yoo Jinho), Makoto Furukawa (Woo Jinchul), Ginga Banjou (Go Gunhee + narrador).

---

## 2. A história: arcos, capítulos e episódios

### 2.1 Premissa
Há cerca de 10 anos surgiram os **Portais (Gates)**, ligando o mundo humano a dimensões habitadas por **Bestas Mágicas**. Pessoas despertaram com mana e viraram **Caçadores**. **Sung Jinwoo**, 20 anos, é o "Caçador mais fraco da humanidade" (rank E), explorando portais de baixo nível para pagar o tratamento da mãe, **Park Kyung-Hye**, vítima do **Sono Eterno**. Numa incursão de rank D ele entra, sem saber, numa **masmorra dupla (Double Dungeon / Templo de Cartenon)**; no limite da morte, aceita uma missão misteriosa e se torna o **Player do Sistema** — o único humano capaz de **subir de nível**. A partir daí ele cresce de forma explosiva, se torna o 10º caçador rank S da Coreia, obtém a classe **Monarca das Sombras** e passa a comandar um exército de sombras extraídas dos inimigos que mata.

### 2.2 Arcos de *Solo Leveling* (22) com episódios e capítulos

| # | Arco | Episódios (anime) | Capítulos (webtoon) |
|---|---|---|---|
| 1 | D-Rank Dungeon Arc | 1–3 | 1–10 |
| 2 | Reawakening Arc | — | 11–12 |
| 3 | Instant Dungeon Arc | 4 | 13–17 |
| 4 | Dungeon & Lizards Arc | 5–6 | 18–24 |
| 5 | Dungeon & Prisoners Arc | 7–9 | 25–34 |
| 6 | Yoo Jinho Raid Party Arc | 10 | 35–37 |
| 7 | Job Change Arc | 11–12 | 38–45 |
| 8 | Red Gate Arc | 13–14 | 46–55 |
| 9 | Demon Castle Arc | 15 | 56–61 |
| 10 | Retesting Rank Arc | 16 | 62–64 |
| 11 | Hunters Guild Gate Arc | 17–18 | 65–75 |
| 12 | Return to Demon Castle Arc | 19–21 | 76–89 |
| 13 | Jeju Island Arc | 22–25 | 90–107 |
| 14 | Recruitment Arc | — | 108–110 |
| 15 | Ahjin Guild Arc | — | 111–122 |
| 16 | Double Dungeon Arc (revanche) | — | 123–131 |
| 17 | Japan Crisis Arc | — | 132–139 |
| 18 | International Guild Conference Arc | — | 140–149 |
| 19 | Monarchs War Arc | — | 150–166 |
| 20 | Final Battle Arc | — | 167–177 |
| 21 | Epilogue | — | 178–179 |
| 22 | Academy Arc (final) | — | 180–200 |

### 2.3 Arcos de *Solo Leveling: Ragnarok* (25)
1 Hunter Awakening · 2 D-Rank Dungeon (Ragnarok) · 3 Gwanak Mount Field · 4 Seoul Station Field · 5 Beast Sanctuary · 6 Times Square Field · 7 Pyramid · 8 Times Square Field (cont.) · 9 Insect Sanctuary · 10 (Beast Sanctuary/insetos) · 11 Demon Realm · 12 Preparation · 13 Glacier Dungeon · 14 Jisan Prison Break · 15 Woojin Guild · 16 Busan Haeundae Beach Dungeon Break · 17 Black Market · 18 Asura Guild · 19 Second Retesting · 20 Demon Monarch Successor · 21 North Korea · 22 Frost Elf Monarch Successor · 23 Solo Leveling: Ragnarok Project · 24 North Pole / White Abyss · 25 Outer God War (final).

### 2.4 Episódios do anime (títulos oficiais)

**Temporada 1**
1. *I'm Used to It* ("Já estou acostumado")
2. *If I Had One More Chance*
3. *It's Like a Game*
4. *I Gotta Get Stronger*
5. *A Pretty Good Deal*
6. *The Real Hunt Begins*
7. *Let's See How Far I Can Go*
7.5 *How to Get Stronger* (recap)
8. *This is Frustrating*
9. *You've Been Hiding Your Skills*
10. *What Is This? A Picnic?*
11. *A Knight Who Defends an Empty Throne?*
12. *Arise*

**Temporada 2 — Arise from the Shadow**
13. *You aren't E-rank, are You*
14. *I Suppose You aren't Aware*
15. *Still a Long Way to Go*
16. *I Need to Stop Faking*
17. *This is What We're Trained to Do*
18. *Don't Look Down on My Guys*
19. *The 10th S-Rank Hunter*
20. *Looking Up Was Tiring Me Out*
21. *It Was All Worth It*
22. *We Need a Hero*
23. *It's Going to Get Even More Intense*
24. *Are You the King of Humans?*
25. *On to The Next Target*

### 2.5 Resumo da espinha dorsal do enredo
1. **Portais duplos e o Sistema** — Jinwoo sobrevive ao Templo de Cartenon (arquiteto **Kandiaru**, **Estátua de Deus**), é escolhido como Player e cumpre a missão diária "The Preparation To Become Powerful" (penalidade: **Zona de Penalidade**).
2. **Ascensão** — reavaliação, rank S; Masmorra Instantânea (metrô de Hapjeong) contra **Kasaka**; golpe dos **Lizards** (Hwang Dongsuk) → primeiras mortes humanas e a missão automática *Kill the Enemies*.
3. **Job Change** — aos nível 40, a *Job Change Quest* o leva ao comandante **Igris** (Blood-Red Commander) → extração de sombras.
4. **Red Gate** — portal vermelho que sela a saída; **Baruka** (rei dos Elfos de Gelo), **Tank** (urso branco alfa), **Iron** (Kim Chul).
5. **Castelo dos Demônios** — busca do **Elixir/Água Sagrada da Vida** para curar a mãe; chefes **Cerberus**, **Vulcan**, **Metus**, **Baran** (rei demônios); aliada **Esil Radiru**.
6. **Portão da Hunters Guild** — **Kargalgan** (orcos altos) → sombra **Tusk**.
7. **Ilha de Jeju** — quarta incursão: **Rainha das Formigas** e **Rei das Formigas** (**Beru**); morte de Goto Ryuji e de 8 caçadores rank S.
8. **Guilda Ahjin** — Jinwoo funda sua guilda com Yoo Jinho e Cha Hae-In; revela a **Monarquia das Sombras** ao mundo.
9. **Masmorra dupla (revanche)** — aos nível 100, Kandiaru o convoca para que **Ashborn** tome seu corpo; Ashborn o trai positivamente e o torna **sucessor**, entregando o **Coração Negro**.
10. **Crise do Japão / Conferência Internacional** — **Legia** (Monarca do Início) em Tóquio; morte de **Christopher Reed** e **Jonas** (vasos dos Governantes).
11. **Guerra dos Monarcas** — **Sillad** mata Go Gunhee; Rakan, Querehsha e Sillad invadem Seul; Jinwoo desperta como 2º Monarca das Sombras; morte do pai, **Sung Il-Hwan**.
12. **Batalha Final** — **Antares** (Monarca da Destruição) invade o Canadá; Jinwoo distorce o espaço para trazer os **Governantes** em forma pura, que matam Antares.
13. **Epílogo / Reset** — Jinwoo pede o **Cálice da Reencarnação**, volta 10 anos no tempo (linha revisada), caça os Monarcas renascidos por 27 anos e, ao retornar, vive com a família; segue *Ragnarok* com o filho **Sung Suho** enfrentando os **Apóstolos** e os **Itarim** (Deuses Exteriores).

---

## 3. O mundo: Portais (Gates) e Masmorras (Dungeons)

### 3.1 Portais (Gates / 차원의 문)
- Portais mágicos azuis que ligam o mundo humano às **Masmorras**. Começaram a aparecer ~10 anos antes do início da história, por ação dos **Governantes**, para saturar o mundo de **mana** antes da guerra contra os Monarcas.
- Aparecem aleatoriamente (rodovias, áreas abandonadas, escolas). Permanecem abertos até o chefe da masmorra ser derrotado.
- **Rank S–E**, medido por sensores mágicos. Rank E = risco baixo; rank S = emergência nacional.
- **Dungeon Break**: se a masmorra não for limpa em **7 dias**, os monstros escapam para o mundo. Em ranks altos, isso pode destruir cidades ou países.
- **Portais Vermelhos (Red Gates)**: só ocorrem em portais **rank B ou superior**; indetectáveis antes da entrada. Selam entrada e saída, deixam de emitir mana, e o que existe além pode ser deserto, selva ou geleira. **Dilatação temporal: 1 hora fora = 1 dia dentro.** Saída só derrotando o chefe ou esperando um dungeon break.
- **Tamanho por rank**: rank D ≈ uma porta grande; rank S ≈ o tamanho de um furacão.
- Os **Monarcas** também podem criar portais para invadir a Terra.
- Portais notáveis: **Jeju Island S-Rank Gate**, **First S-Rank Gate**, **Tokyo S-Rank Gate** (S); **Red Gate Incident**, **Hunters Guild Gate**, **Busan Gate** (A); **Magok Field**, **North Korea Field**, **Seoul Station Field** (campos).
- Trivia útil ao balanceamento: lucro máximo de um portal rank C ≈ 200.000.000 won; na época da história apenas **seis equipes** já haviam limpado um portal rank S, de quatro países (EUA, China, Rússia, França).

### 3.2 Masmorras (Dungeons)
- "Bolsões do mundo do caos" ligados ao mundo humano por portais. Contêm hordas de bestas mágicas lideradas por um **chefe**; fecham ~1 hora depois da morte do chefe.
- Classificadas no sistema **S–E**; a força dos monstros acompanha o rank.
- Tipos: **Low-Rank** (E/D), **High-Rank** (A/S), **Red Gates**, **Masmorras Instantâneas** (exclusivas do Player/Sistema), **Field-Type Dungeon** (masmorra de campo: dungeon break contínuo infecta a área com mana e vira território de monstros — ex.: Magok Field, North Korea Field, Seoul Station Field, Pyramid Field, Pyeongtaek).
- Masmorras notáveis por rank:
  - **S**: Templo de Cartenon (Double Dungeon), Castelo dos Demônios, Pyramid Field
  - **A**: Red Gate Dungeon, Hunters Guild Dungeon, Busan A-Rank Dungeon
  - **C**: Insects Dungeon, Goblins Dungeon
  - **D**: D-Rank Dungeon, Gwanak Mountain Dungeon
  - **E**: Hapjeong Subway Station (Instant Dungeon)

---

## 4. O Sistema (o "Player")

- **O que é**: programa mágico criado por **Kandiaru (o Arquiteto)** para desenvolver um **vaso humano** capaz de absorver os poderes do Monarca das Sombras; interface de videogame para ser intuitiva. Escolheu **Sung Jinwoo** como **Player**; depois do reset, foi modificado por Jinwoo, entregue a **Sung Suho** (que obteve a classe **"Irregular: White Shadow"** ao fundir 3 classes) e existem versões paralelas para outros herdeiros de Monarcas.
- **Funções**: bestowal de poder (Power Bestowal), recuperação de status, masmorras instantâneas, quests, loja do Sistema, inventário ilimitado, recompensas, sistema de níveis/atributos, habilidades que evoluem com o Player.
- **Economia**: moeda em ouro obtido por inimigo morto, gasta na **Loja do Sistema** (ex.: comprou a adaga **Knight Killer**).
- **Atributos** (cada ponto investido):
  - **Força (Strength)**: força física, velocidade e poder de ataque.
  - **Agilidade (Agility)**: visão dinâmica, tempo de reação e esquiva.
  - **Vitalidade/Stamina**: HP máximo e velocidade de recuperação.
  - **Inteligência (Intelligence)**: MP máximo e recuperação de MP.
  - **Sentido (Sense)**: aguça os cinco sentidos e a percepção de perigo.
  - Regra: **+1 em todos os atributos por nível**; **+3 pontos livres** ao completar a quest diária.
- **Quests conhecidas**:
  - *The Preparation To Become Powerful* (quest diária; falhar = ser teleportado à Zona de Penalidade).
  - *Survival* (quest de penalidade: sobreviver 4 horas na **Zona de Penalidade** — deserto sem vento, sol, lua ou estrelas, com centopeias gigantes).
  - *Courage of the Weak* (quest secreta concluída no Templo de Cartenon).
  - *Kill the Enemies* (quest de emergência: se outro humano atacar Jinwoo com intenção de matar, ele deve matar todos ao redor; se falhar, o próprio Sistema para seu coração).
  - *Job Change Quest* (nível 40 → classe e habilidades de Sombras).
  - *Collect Demon Souls! (1) e (2)* (Castelo dos Demônios; a primeira dá a receita da Água Sagrada da Vida).
  - **Tutorial** (versão criada por Jinwoo para testar Suho).
- **Itens do Sistema**: Caixa Aleatória (Random Box), Chave de Masmorra (Dungeon Key), Pedra de Teleporte Instantâneo (Instant Return Stone/Hearthstone), Baú de Loot Amaldiçoado (Cursed Random Loot Box).
- **Módulos especiais**: sistema de **Domínio** (Monarca das Sombras), loja, e — na versão de Suho — recursos que nunca existiram na de Jinwoo (pet/companion e resistência a ataques de Apóstolos).

---

## 5. Caçadores: ranks, classes, licença, guildas e associações

### 5.1 Processo e números
- Caçadores surgiram quando a humanidade foi exposta à mana; quem desperta recebe poderes próprios.
- **Rank e atributos são fixados no despertar e não sobem naturalmente** — exceto no raro caso de **Reawakening** (segundo despertar), em que houve E→C e B→S.
- Estatísticas canônicas: **0,001%** da população mundial desperta como caçador; **0,0002%** têm rank C ou superior; na Coreia do Sul há ~**50.000** despertos numa população de ~51 milhões, e menos de 1 em cada 10 desperto vira caçador profissional.
- **Licença de caçador** dá direito a entrar em portais, assistência médica, auxílio financeiro e seguro de morte transferível à família; recusar 3 convocações seguidas = perda da licença.
- Renda: mesmo caçadores fracos ganham milhares de dólares por incursão; Jinwoo afirmou que **US$ 2 milhões é "dinheiro de bolso" para um rank S**.

### 5.2 Escala de ranks (Class Ranks / sistema internacional S–E)
| Rank | Significado |
|---|---|
| **S** | Mais alto. Emergência nacional; países inteiros param |
| **A** | Alto; exige equipes de elite |
| **B** | Intermediário-alto |
| **C** | Intermediário (rank médio) |
| **D** | Segunda menor |
| **E** | Mais baixo; portais de baixo risco |

- **National Level Hunters** (국가권력급 헌터, "rank poder nacional"): caçadores que rivalizam com todo o exército de uma nação. Título criado após a morte do dragão **Kamish**, dado aos 5 ranks S que o derrotaram. Requisito mínimo informal: ter limpado ao menos um portal rank S. Vivem como realeza e não respondem a ninguém.
  - **Top 4 (por pontos)**: 1. Thomas Andre (EUA) · 2. Liu Zhigang (China) · 3. Christopher Reed (EUA) · 4. Siddharth Bachchan (Índia). O **5º** é citado pela obra como o quinto caçador da incursão de Kamish; Sung Il-Hwan teria alcançado o título se não tivesse desaparecido antes do sistema de rankings existir.
  - Os 4 primeiros são mais fortes que um rank S comum porque **receberam poder dos Governantes** (assim como Jinwoo recebeu de Ashborn).
- Outras posições de ranking mundial citadas: **Jonas** (Brasil) 6º, **Lennart Niermann** (Alemanha) 12º, **Jay Mills** (Canadá) 17º.
- **S-Rank da Coreia**: originalmente **10** (só 6 vivos depois da guerra; 4 mortos em ação). Jinwoo é o **10º rank S coreano**.
- **China** usa um sistema próprio de **1 a 5 estrelas** em vez de S–E; Liu Zhigang tem **7 estrelas** (6 na linha revisada).
- **False Rankers (부정 등록자)**: caçadores que controlam a emissão de mana e escondem a força real, registrando rank muito abaixo. Raros e, na maioria, psicopatas que matam outros caçadores por diversão.
- **Lizards**: caçadores que convidam grupos fracos para incursões e os deixam morrer para lucrar dentro da masmorra (sem câmeras nem investigação possível).
- **Villains**: despertos que cometem crimes na sociedade; classificados pelas Associações como bestas mágicas humanoides, com recompensa por captura ou eliminação.

### 5.3 Classes (6)
| Classe | Foco |
|---|---|
| **Fighter** | Corpo a corpo, equilíbrio ataque/defesa, adaptável |
| **Mage** | Feitiçaria e magia à distância; frágil em melee |
| **Assassin** | Velocidade + combate de curta distância; camuflagem |
| **Tanker** | Defesa, provocação (Taunt), escudos de mana |
| **Ranger** | Magia de arco/flecha |
| **Healer** | Magia de cura |

Além disso: caçadores se dividem em **combate** e **não-combate**, e o Sistema atribui a Jinwoo a classe **Mage** com o título/classe especial **Monarca das Sombras** (job skills de sombra).

### 5.4 Estrutura de uma incursão
- **Strike Team / Strike Squad**: o grupo de combate (fighters, rangers, tanks, mages, healers). Pode incluir **Porter** (carregador de equipamento).
- **Mining Team**: minera **Cristais de Mana** depois que a strike team limpa tudo menos o chefe (eletricidade não funciona em masmorras → picaretas encantadas e carrinhos).
- **Collecting Team**: recolhe os **cadáveres de bestas mágicas** (pedras de essência) após a limpeza.
- **Guilds**: organizações de caçadores dedicadas a portais/masmorras. Guild Masters de guildas de elite são normalmente rank S; guildas de elite pagam salários altos e planejam incursões; guildas fracas recrutam ranks variados e levam grupos além da capacidade (mortalidade alta). Caçadores **independentes** existem (ex.: Lee Eunseok).
- **Associações**: órgãos governamentais que supervisionam caçadores, portais e guildas — **Korean Hunters Association** (sede em Guro, Seul), **Japanese Hunters Association**, **Federal Bureau of Hunters** (EUA), **World Hunter Association** (linha revisada; garante que caçadores sejam escudo, não arma de guerra).

### 5.5 Caçadores citados (por país)

**Coreia do Sul** — S: Sung Jinwoo (S, classe Mage / Monarca das Sombras) · Cha Hae-In (S, vice-guild master da Hunters) · Choi Jong-In (S, mestre da Hunters; mago mais forte da Coreia) · Baek Yoonho (S, mestre da White Tiger) · Go Gunhee (S, presidente da Associação; vaso dos Governantes) · Sung Il-Hwan (S, pai de Jinwoo; vaso dos Governantes) · Min Byung-Gyu (S healer, falecido; virou sombra) · Lim Tae-Gyu (S, mestre da Fiend) · Ma Dongwook (S, mestre da Fame) · Lee Eunseok (S independente, 1º rank S coreano morto em ação) · Hyeonmoo Gang (S, mestre da Black Tortoise) · Choi Hasul (S, tornou-se villain/refugiada na Coreia do Norte) · Hwang Dongsoo (S coreano-americano).
**A**: Woo Jinchul (A, presidente da Associação depois de Gunhee) · Baek Miho (A, vice-mestre da White Tiger, filha de Yoonho) · Son Kihoon (A, líder da Strike Team B) · Han Semi (A healer, esquadrão B) · Seo Jiwoo (A fighter, esquadrão B; rank S após reawakening) · Kim Chul (A, White Tiger; virou a sombra Iron) · Lee Bora, Gina (A, Hunters) · Park Jongsoo (A, mestre da Knights) · Jung Yoontae (A, vice-mestre da Knights) · Jung Yerim (A healer, Knights) · Lee Minsung (A, ator e vice-mestre da Fiend; virou a sombra Kwei) · Shin Seokjin (A, 2ª strike team) · Yoo Soohyun (A, atriz/modelo, prima de Jinho, guilda Ahjin) · Kang Taeshik (B, inspetor corrupto; virou a sombra Kira) · Yuri Orloff → russo.
**B**: Lee Joohee (B healer, amiga antiga de Jinwoo, sobrevivente da masmorra dupla) · Park Heejin (B, sobrevivente do Red Gate) · Lee Yeongho (B, Black Tortoise) · Han Jaehyuk (C, fiscal).
**C**: Song Chi-Yul (C, professor de kumdo, sobrevivente) · Yoon Kijoong (C, White Tiger) · Go Myung-Hwan (C, White Tiger) · Jinsuk, Sukmin, Lee Chul-Jin, Cho Kyuhwan, Goo Juntae (C/D — quadrilha dos Lizards morta por Jinwoo).
**D**: Yoo Jinho (D, CEO da Ahjin Soft) · Kim Sangshik (D, sobrevivente; virou sombra? — sua espada virou item) · Park Beom-Shik (D) · Joo Jae-Hwan (D, morto na 1ª masmorra dupla) · Kang Jeongho (D) · Sung Jinah (civil; irmã de Jinwoo) · Han Song-Yi (E, amiga de Jinah).
**Civis/apoio**: Park Kyung-Hye (mãe; Sono Eterno) · Choi Yoora (enfermeira) · Lee Seong-Chul (diretor do hospital Ilsin) · Yoo Myunghan (pai de Jinho, Yoojin Construction) · Yoo Jinsung / Yoo Jinhee (irmãos de Jinho) · Lee Wong-Yu (vice-presidente da Yoojin) · Ahn Sangmin (chefe do 2º Depto. de Gestão, White Tiger) · Hyun Kichul (assistente de Ahn) · Joo Sungchan (chefe de vigilância) · Jung Gi-Soo (avaliação) · Lim Do-Gyu (rank E, professor de arte).

**Japão** — Goto Ryuji (S, mestre da Draw Sword; morto pelo Rei das Formigas) · Akari Shimizu (S healer) · Atsushi Kumamoto, Ippei Izawa, Kanae Tawata, Kei, Kenzo Tanaka, Mari Ishida, Minoru Hoshino, Tatsumi Fujishima (S, Draw Sword) · Reiji Sugimoto (S, atual mestre da Draw Sword) · Hanekawa (A, tradutor) · Matsumoto Shigeo (presidente da Associação Japonesa).

**EUA** — Thomas Andre (National, 1º do mundo) · Christopher Reed (National, 3º; morto) · David Brennon (diretor do FBH) · Michael Connor (vice-diretor) · Adam White (chefe da filial asiática) · Norma Selner ("upgrader", aumenta o poder de caçadores além do limite — arma secreta dos EUA) · Derek Johson (A, Scavenger) · Gerald (B, Scavenger) · Randolph (A, Scavenger) · Laura (secretária da Scavenger).

**China** — Liu Zhigang (National, 2º do mundo; 7 estrelas).

**Índia** — Siddharth Bachchan (National, 4º; virou a sombra Sita) · Ali Hassan (B, mestre da Imphal) · Rio Singh (B, Asura) · Jackson (C, ex-Asura).

**Ásia/África/Oceania** — Tatsumi/Sukmin/… (ver acima); **Etiópia/Egito**: Shika (A, carcereiro do Pyramid Field); **Ilha de Nauru**: Glacier Dungeon; **Índia**: Loktak Lake Field.

**Europa** — Jonas (Brasil, 6º; morto) · Lennart Niermann (Alemanha, 12º) · Yuri Orloff (Rússia, S mais forte do país, Ministro da Defesa) · Jay Mills (Canadá, 17º).

*Observação: esta lista é nominal; o rank só foi anotado quando a wiki o informa explicitamente. Caçadores citados apenas pelo nome (sem rank declarado): Kim Yongjun, Lee Se-Hwan (A, diretor-chefe na Ragnarok), Lim Do-Gyu, Jhonson, Hanekawa, Gerald, Gina, Kei, Kim.*

---

## 6. Personagens (perfil resumido)

### 6.1 Protagonistas
- **Sung Jinwoo (성진우)** — protagonista. Ex-rank E ("O Caçador mais fraco da humanidade"), depois 10º rank S da Coreia, 6º National Level informal e **2º Monarca das Sombras**. Títulos: "The Ghost", "2nd-Rate Asian Hunter" (apelido pejorativo de Christopher Reed). Classe: **Mage**; classe especial: **Monarca das Sombras**. Poderes: força imensurável, maestria em combate, **imortalidade biológica** (não envelhece; altera a própria aparência), **umbracinese** (controle absoluto de sombras/escuridão), hipnose (estalar de dedos), ilusões, **herança de poder** (usa todas as habilidades das suas sombras), defesa absoluta (barreira que anula ataques), **mana infinita**, vontade indomável.
- **Cha Hae-In** — rank S coreana, vice-mestre da **Hunters Guild**, esposa de Jinwoo e mãe de Suho. Ex-atleta de atletismo (carreira encerrada por lesão no tornozelo). Metódica, calma, sem preconceito com ranks baixos; socialmente desajeitada. Usa armadura vermelha e espada negra (depois a *Demon King's Longsword*). Detecção de mana aguçada; foi treinada por um "cheiro" peculiar — ela percebe que Jinwoo é "diferente".
- **Sung Suho (성수호)** — filho de Jinwoo e Hae-In, protagonista de **Ragnarok**. Classe obtida: **Irregular: White Shadow**; títulos de Monarca: **Monarca da Transcendência** / Guardião da Árvore do Mundo. Poderes: **Shadow Creation**, **Transcendence Authority**, **Shadow of the World Tree Authority**, **Breath of Destruction**, **Twin Swords**, armas (Kamish's Wrath + Shadow Nidhogg).
- **Yoo Jinho** — rank D, humor central da série, CEO da **Ahjin Soft** (criou o VR "Beautiful World"); vice-mestre da guilda Ahjin; amigo/irmão adotivo de Jinwoo; gags: armaduras caras e inúteis, bebida fraca.
- **Sung Jinah** — irmã de Jinwoo; amiga de Han Song-Yi; em perigo na Ahjin Guild Arc (resgatada de Groctar).
- **Sung Il-Hwan** — pai; ex-bombeiro, depois um dos primeiros rank S da Coreia; **vaso dos Governantes** (recebeu **Ruler's Authority**); desapareceu 10 anos numa masmorra; morreu ao usar poder demais na Guerra dos Monarcas.
- **Park Kyung-Hye** — mãe; adoeceu com **Sono Eterno** e foi curada com a **Água Sagrada da Vida**.
- **Ashborn (아스본)** — Rei dos Mortos, Monarca das Sombras, "Maior Fragmento da Luz Brilhante", o mais forte dos Governantes antes de se tornar Monarca; criou o exército de sombras e escolheu Jinwoo como sucessor.

### 6.2 Núcleo de apoio (Coreia)
- **Go Gunhee** — rank S, presidente da Associação Coreana; vaso dos Governantes; morto por Sillad.
- **Woo Jinchul** — A; inspetor-chefe da Vigilância e depois presidente da Associação; personagem central em Ragnarok.
- **Choi Jong-In** — rank S, mestre da Hunters Guild, mago mais forte da Coreia, fumante; oito anéis e capa vermelha.
- **Baek Yoonho** — rank S, mestre da **White Tiger**; ambicioso e perceptivo (1º a notar que Jinwoo não tinha limite); sabe que Jinwoo se contém.
- **Hwang Dongsoo** — rank S coreano-americano da Scavenger, irmão de Hwang Dongsuk; torturou Jinho; morto por Jinwoo → sombra **Greed**.
- **Hwang Dongsuk** — "Lizard", líder da quadrilha que tentou matar Jinwoo; virou NPC de vilania inicial.
- **Kang Taeshik** — B, inspetor corrupto e assassino de aluguel; matou Kang Jeongho e Kim Sangshik → sombra **Kira**.
- **Lee Minsung** — ator famoso, A, vice-mestre da Fiend; distribuiu **Stardust**; virou **Kwei** (Ragnarok).
- **Min Byung-Gyu** — S healer, amigo de Baek Yoonho; morto na 4ª incursão a Jeju; ressuscitado como sombra para curar Cha Hae-In.
- **Lee Joohee** — B healer, amiga de Jinwoo; trauma da masmorra dupla.
- **Song Chi-Yul** — C, professor de kumdo, sobrevivente.
- **Yoo Soohyun** — A, atriz/modelo, prima de Jinho; entra na Ahjin.
- **Go Myung-Hwan / Ahn Sangmin / Hyun Kichul** — burocracia da White Tiger.
- **Kim Sangshik, Park Beom-Shik, Joo Jae-Hwan, Kang Jeongho** — vítimas dos eventos iniciais.

### 6.3 Antagonistas humanos
- **Goto Ryuji** — rank S, o mais forte do Japão, mestre da Draw Sword; armou a morte dos coreanos em Jeju para lucrar; morreu pelo **Rei das Formigas**. Egocêntrico, cínico, incapaz de admitir inferioridade.
- **Matsumoto Shigeo** — presidente da Associação Japonesa; entregou-se às autoridades após o desastre de Tóquio.
- **Hwang Dongsoo** — ver acima.

### 6.4 Internacional
- **Thomas Andre** — 1º do mundo (EUA), National Level, vaso dos Governantes; lutador monstruoso, senso de camaradagem, "força define o certo"; usa camisa havaiana; virou **Monarca da Conquista** em Ragnarok.
- **Liu Zhigang** — 2º do mundo (China), vaso dos Governantes; briguento e direto, respeita quem é forte; resistiu 2 anos a tentativa de possessão dos Itarim.
- **Christopher Reed** — 3º do mundo (EUA), vaso; morto pelos Monarcas.
- **Siddharth Bachchan** — 4º do mundo (Índia), National; corrupto na linha revisada (distribuiu colares de Stardust); virou sombra **Sita**.
- **Jonas** (Brasil, 6º) — vaso dos Governantes; morto pelos Monarcas.
- **Yuri Orloff** (Rússia) — S mais forte do país; Ministro da Defesa, criou barreiras de mana nas cidades e o projeto **Unwithering Spring** (extraía energia divina dos Deuses Exteriores).
- **Norma Selner** (EUA) — "upgrader"; eleva o poder de caçadores além do limite natural; foi usada como moeda de troca para recrutar rank S estrangeiros.
- **Lennart Niermann** (Alemanha, 12º) e **Jay Mills** (Canadá, 17º) — Jay Mills desprezou o aviso de Jinwoo e morreu com milhões de canadenses no ataque de Antares.

---

## 7. Exército das Sombras

### 7.1 Como funciona
- **Extração de Sombras (Shadow Extraction)** — habilidade de ressurreição exclusiva do Monarca das Sombras: extrai mana de um corpo sem vida e o transforma em soldado-sombra. Não custa mana, funciona em grande raio (pode extrair centenas de uma vez) e é acionada por uma palavra de comando.
  - **Limitações**: não funciona em alvos significativamente mais fortes que o usuário; só **3 tentativas** por alvo; falha quanto maior o tempo desde a morte; não funciona em seres de biologia de mana (Monarcas, Governantes); originalmente exigia que o alvo possuísse mana (Jinwoo contornou isso após herdar os poderes verdadeiros).
  - **Nível 2** adiciona *Shape Transformation* (mudança livre de forma dos soldados).
- **Graus de Sombra** (equivalência com ranks de caçadores):
  - **Normal** — E/D/C; soldados rasos.
  - **Elite** — ~B; o mais comum.
  - **Knight** — ~A; pode receber nome.
  - **Elite Knight** — ~S básico (nível de Baek Yoonho) — ex.: Iron, Harmakan.
  - **Commander/General** — enfrenta e supera rank S avançado (ex.: Goto Ryuji); fala — ex.: Greed, Jima, Sita.
  - **Marshal/Commander** — topo evolutivo da maioria.
  - **Grand Marshal** — reservado ao mais forte do exército e tenente do Monarca — **Bellion**.
  - Subir de grau exige **autorização direta do Monarca das Sombras**.
- **Habilidades comuns a todas as sombras**: regeneração extrema (não morrem para monstros/caçadores comuns, mesmo rank S), **conversação** (a partir de General, em língua dos monstros), **crescimento** (evoluem matando), **infiltração em sombras** (escondem-se e espionam dentro da sombra de humanos; Jinwoo plantou espiões em Goto Ryuji e Cha Hae-In sem serem detectados), **transformação** em arma/item, **estamina infinita** e **imortalidade** parcial (só seres superiores, como Monarcas, conseguem apagá-las — o sopro de Antares destruía sombras permanentemente).
- **Armazenamento**: as sombras vivem no **Mundo do Sono Eterno** (World of Eternal Sleep), não numa "dimensão de invocação" — concepção errada dos personagens.
- **Fraqueza geral**: a força das sombras depende do **Shadow Authority**, nível e atributo de inteligência do amo; as sombras de Jinwoo eram muito mais fortes que as de Suho.

### 7.2 Sombras nomeadas de Jinwoo
| Nome | Origem | Notas |
|---|---|---|
| **Bellion** | Nasceu do fruto da Árvore do Mundo; tenente de Ashborn | **Grand Marshal**, o mais forte de todos; asas negras duplas, lâmina centopeia |
| **Igris** | Blood-Red Commander Igris (A, chefe da Job Change Quest Dungeon) | General e "mão direita"; cavaleiro de armadura negra, nobre e cavalheiresco, entrega cabeças dos inimigos como gag |
| **Beru** | Rei das Formigas (Ilha de Jeju) | Sombra mais emblemática; brutal, leal, apaixonado por dramas de época coreanos; fala humano por **Gluttony** (devorou caçadores japoneses e absorveu habilidades/idiomas); nome vem do autor do livro "As Formigas" |
| **Iron** | Kim Chul (A, White Tiger) | **Elite Knight**; machado duplo; desastrado/impulsivo, gosta do Taunt; era o "cabeça-oca" do exército |
| **Tusk** | Kargalgan (xamã orco alto, chefe do Hunters Guild Gate) | Mago das sombras; timido, competitivo, usa feitiços de área |
| **Tank** | Urso branco alfa (Red Gate) | Grau **Knight** (~rank A); usado na Ilha de Jeju |
| **Kaisel** | Kaisellin (wyvern montaria de Baran) | Sombras voadoras/montaria; virou notícia em redes sociais |
| **Greed** | Hwang Dongsoo (S) | General; humilde e servil; matou por vingança a tortura de Jinho |
| **Kira** | Kang Taeshik (B) | Grau Knight; **Stealth**; caçador de villains (usado por Suho) |
| **Jima** | Chefe Naga | General; tridentes, pode crescer de tamanho |
| **Kamish** | Dragão Kamish (chefe do 1º portal rank S) | Ressuscitado 8 anos depois com 2 tentativas; tentou atacar humanos e **se dissolveu** — serviu pouquíssimo tempo |
| **Min Byung-Gyu** | S healer coreano | Curador das sombras; curou Cha Hae-In por conta própria |
| **Ant Queen** | Rainha das Formigas | Sombras temporária |
| **Shadow Giants** | Gigantes do Tokyo S-Rank Gate | "Gigantes Nº 1–29" |
| **Shadow Nidhogg** | Serpente de oito cabeças | Versão branca pura, criada pela Escuridão Primordial + autoridade de Suho |
| **Kwei (Quay)** | Lee Minsung (A) | Sombra de Suho; armadura de vespa, asas, braço-lança |
| **Harmakan** | Xamã-mor dos Espectros Demoníacos | Elite Knight (~S); magias estudadas na biblioteca de Kandiaru; cria portais |
| **Gordon** | Naga | Grau Knight (~A); escala de aço; de Suho |
| **Sita** | Siddharth Bachchan (National) | General; dragonoide com asas; um dos mais fortes de Suho |
| **Shika** | Carcereiro do Pyramid Field | Sombras de Suho (webtoon) |
| **Brocky** | Líder da Hyena Guild (C, Gwanak) | Servo de Rakan; sombra temporária de Suho |

### 7.3 Sombras sem nome (categorias)
- **De Jinwoo**: Infantaria das Sombras, Magos das Sombras, Ursos de Gelo, Orcos Altos, Formigas, Nagas, Dragões, Anões Barbados, Titãs, Soldados Apóstolos, Espectros Demoníacos (exército de Yogumunt), Humanoides monstruosos (exército de Tarnak).
- **Herdadas de Ashborn**: Infantaria Celestial, Corcel, Dragões Ancestrais, Elfos de Gelo, Orcos Altos, Goblins, Gigantes, Golem de Pedra, Lagarto.

---

## 8. Monarcas, Governantes, Apóstolos e Itarim (cosmologia)

### 8.1 Origem
- No início existia apenas luz e escuridão. O **Ser Absoluto (Absolute Being)** dividiu a luz para criar os **Governantes (Rulers)** e a escuridão para criar os **Monarcas (Monarchs)**: os Monarcas nasceram para destruir o mundo, os Governantes para protegê-lo.
- O Ser Absoluto usava a guerra como entretenimento. Sete dos oito Governantes se rebelaram e o mataram; **Ashborn**, o mais forte e último, permaneceu leal, foi derrotado e sobreviveu transformando-se no **Monarca das Sombras**.
- Depois, os Governantes usaram ferramentas com fragmentos do poder do deus para caçar os Monarcas (capturaram **Legia** vivo), Ashborn mudou de lado e matou **Baran**.
- Séculos depois os Monarcas tentaram destruir o mundo humano para reconstruir exércitos; os Governantes tentaram impedi-los e, ao falhar, usaram o **Cálice da Reencarnação** (retrocede o tempo em 10 anos por uso, poder finito e que se esgotou) repetidas vezes.
- 10 anos antes da história, os Governantes abriram portais para saturar o mundo de mana e deram poder a **7 vasos humanos** (futuros mais fortes do mundo), ordenando a **Sung Il-Hwan** matar o novo Monarca das Sombras que estava por nascer.
- Depois de tudo, em Ragnarok, os verdadeiros antagonistas passam a ser os **Itarim (Deuses Exteriores)** e seus **Apóstolos**.

### 8.2 Fortalezas e fraquezas dessas raças
- Monarcas e Governantes são as criaturas mais fortes da existência, superados só pelos **Itarim**. Nenhum caçador rank S, nem mesmo um **National Level Hunter**, tem chance contra eles. Cada Monarca tem milhões de soldados.
- Ambos usam **Manifestação do Corpo Espiritual (Spiritual Body Manifestation)** para assumir a forma e o poder verdadeiros, e podem criar portais para viajar entre mundos.
- Como não têm corpo orgânico (biologia de mana), precisam de um **vaso humano** para o mundo humano: os Monarcas **possuem** o vaso completamente (e morrem se o vaso for morto); os Governantes **emprestam** o corpo, deixando o humano no controle (e não morrem com o vaso, mas não podem usar o poder total).

### 8.3 Os nove Monarcas originais
| Monarca | Título | Raça / domínio |
|---|---|---|
| **Antares** | Monarca da Destruição, Rei dos Dragões | O mais antigo e forte dos nove; antagonista final; sopro destruidor que apaga até sombras |
| **Ashborn** | Monarca das Sombras, Rei dos Mortos | "Maior Fragmento da Luz Brilhante"; criou o exército de sombras; passou o poder a Jinwoo |
| **Baran** | Monarca das Chamas Brancas, Rei dos Demônios | Senhor do Castelo dos Demônios; morto por Ashborn (relatado) e depois por Jinwoo; montaria wyvern **Kaisellin** |
| **Rakan** | Monarca das Presas, Rei das Feras | Traiu Ashborn; atacou Seul; morto por Jinwoo |
| **Sillad** | Monarca da Geada, Rei do Povo da Neve | Matou Go Gunhee; líder do ataque a Seul |
| **Tarnak** | Monarca do Corpo de Ferro, Rei dos Humanoides Monstruosos | Recusou participar do ataque; morto por Jinwoo |
| **Legia** | Monarca do Início, Rei dos Gigantes | Chefe oculto do portal rank S de Tóquio; morto por Jinwoo |
| **Querehsha** | Monarca das Pragas, Rainha dos Insetos | Atacou Seul; morta por Jinwoo |
| **Yogumunt** | Monarca da Transfiguração, Rei dos Espectros Demoníacos | Aliado de Kandiaru; morto por Jinwoo |

- **Kandiaru (o Arquiteto)** — Rei dos Espectros Demoníacos e **Monarca do Submundo**; criou o **Sistema**; chefe oculto da masmorra dupla e mestre da **Estátua de Deus**.
- **Sucessão em Ragnarok** (o sucessor é escolhido pelo Ser Absoluto ou pelo sacerdote do Monarca morto e precisa cortar uma cabeça da serpente **Nidhogg**): **Sung Suho** (Transcendência) · **Esil Radiru** (Gula, Rainha dos Demônios) · **Gray** (Caçada, Rei das Feras) · **Sirka** (Pesadelos, Rainha do Povo da Neve) · **Ammut** (Provações, Rei dos Humanoides Monstruosos) · **Thomas Andre** (Conquista, Rei dos Gigantes) · **Arsha** (Vazio, Rainha dos Insetos).

### 8.4 Os Governantes (Rulers) e seus vasos
- **Vasos humanos (7)**: **Thomas Andre** · **Liu Zhigang** · **Christopher Reed** · **Siddharth Bachchan** · **Sung Il-Hwan** · **Go Gunhee** · **Jonas**. Quatro deles foram mortos em batalha contra os Monarcas.
- Habilidade exclusiva: **Ruler's Authority** (telecinesia, chamada "Capture"), forte o bastante para que nem Monarcas consigam resistir, a menos que usem a mesma habilidade.
- Na linha revisada (Ragnarok): não escolheram mais vasos; o título de National Level foi reintroduzido por Liu Zhigang e oficializado após Thomas Andre virar Monarca e derrotar o Apóstolo da Conquista.

### 8.5 Itarim, Apóstolos e o Ser Absoluto
- **Ser Absoluto (절대자)** — o deus criador de tudo e dos dois lados da guerra; morto pelos Governantes. **Criação (Authority of Creation)**: poder dos "Seres Supremos", cria existência do nada.
- **Itarim (이타림) / Deuses Exteriores** — raça de deuses que criou toda a existência; antagonistas principais de **Ragnarok**. **Itarim da Dimensão-1** é o criador do Universo Exterior Dimensão-1 e detém as autoridades **Stage of the Lonely God** e **World's Predation**.
- **Apóstolos (사도들)** — servos dos Itarim; antagonistas secundários de Ragnarok:
  - **Apóstolo da Conquista** (antagonista do *Ragnarok Project Arc*),
  - **Apóstolo da Evolução** ("O Doutor") → evolui para **Apóstolo dos Pesadelos**,
  - **Apóstolo de Itarim** (invadiu o Glacier Dungeon),
  - **Apóstolo do Paraíso** (plantou Elvenwoods, ex.: Coreia do Norte),
  - **Apóstolos da Aniquilação** (criados pelo Itarim da Dimensão-1),
  - **Tiel** (benfeitor de Lee Minsung, forneceu o **Stardust**),
  - **Kraken** (invadiu o universo dos Governantes; Xavier usou sua forma).
- **Luz e Escuridão Primordiais** — forças abstratas criadas no nascimento do universo quando o Ser Absoluto dividiu a criação; origem dos dois lados da guerra. A **Abyss Authority** de Jinwoo (Ragnarok) é o poder absoluto do Nada que se opõe à Criação.
- **Guerra dos Deuses Exteriores (Outer God War)** — conflito cósmico após a morte do Ser Absoluto pela herança de sua energia; arco final de Ragnarok.

---

## 9. Bestas Mágicas / monstros

### 9.1 Regras gerais
- **Bestas Mágicas (마수)**, "moradores do Caos": monstros nativos das dimensões acessadas pelos portais. Não podem ser feridos por armas convencionais — só por quem possui mana.
- Classificadas pelo sistema **S–E**; podem ser inteligentes, forjam equipamento próprio, falam língua dos monstros (com alfabeto rúnico) e alguns falam idiomas humanos.
- Têm **Pedras de Essência (Essence Stones)** no corpo (principal fonte de renda dos caçadores; a cor varia com o rank: D branca, A vermelha, S roxa; monstros muito fortes como o Rei das Formigas e Kamish tinham pedras **negras**).
- A carne é tóxica e de sabor ruim (indigestão, estômago corroído, órgãos apodrecidos em casos graves).
- Cada masmorra tem um **chefe** (a besta mais forte), que precisa ser morto para limpar o local. Alguns monstros estão ligados a Monarcas (como o **Rei das Formigas**) e são muito superiores aos normais.
- Depois de perderem a guerra, soldados sobreviventes dos Monarcas viraram "refugiados" tentando se firmar na Terra.

### 9.2 Taxonomia por raça / família
| Família | Integrantes citados |
|---|---|
| **Insetos** | Formigas, Rei das Formigas, Rainha das Formigas, Aranha Gigante Buryura, Aranhas Sepulcrais (Arachne), Centopeias Gigantes de Presas Venenosas, Arsha, Querehsha, Vespa (Xavier/ Kwei) |
| **Feras** | Kasaka (presa venenosa azul), Razan (sombra negra), Briga (garra lâmina), Raikans (presa de aço/Lycans), Cerberus, Ursos de Gelo, Yetis, Lobisomens, Minotauros, Lagartos Espinhosos, Chacais de Masmorra, Brocky, Gray, Rakan |
| **Humanoides** | Goblins, Hobgoblins, Orcos, Orcos Altos, Crocors (crocodilos humanoides), Trolls/Shika, Kargalgan, Groctar, Golems de Pedra/Terra, Cavaleiros (Knights), Magos, Assassinos, Arqueiros, Ammut, Tarnak |
| **Espectros Demoníacos** | Harmakan, Yogumunt, Xavier, Metus |
| **Demônios** | Baran, Vulcan e suas guardas, Esil Radiru, Nukira, Demônio Intermediário Transcendido, Rei Tirano do Sangue Louco, Cerberus |
| **Dragões** | Antares, Kamish, Kaisellin, Ragnar (filho de Kamish), Nagas, Apóstolo de Itarim |
| **Povo da Neve** | Elfos de Gelo (Hyakki), Ursos de Gelo, Gigantes de Gelo, Golems de Gelo, Baruka, Sillad, Sirka |
| **Mortos-vivos (Undead)** | Cavaleiros da Morte, Arch Liches, Múmias, Ogress de Duas Cabeças, Mist Burn, Espectros |
| **Gigantes** | Gigantes (man-eaters), Legia, Titãs (gigantes de pedra/"Outsiders"), Gigante da Terra, Golems de Terra |
| **Outros** | Elfos Superiores (nascidos da árvore sagrada Elvenwood), Anões Barbados (artesãos), Soldados Celestiais (servos dos Governantes), Brotos do Pesadelo, Árvore Fantasma/Sepulcral, Nidhogg, Árvore do Mundo, Homúnculos (Crocors) |

### 9.3 Tabela de monstros (nome · rank · tipo · masmorra)
Extraída da listagem oficial da wiki (tabela "Lists of Magic Beasts"). "?" = não informado pela fonte.

| Monstro | Rank | Tipo | Masmorra |
|---|---|---|---|
| Kandiaru | S | Espectro Demoníaco | Templo de Cartenon (Double Dungeon) |
| Centopeias Gigantes de Presas Venenosas | B | Inseto | Zona de Penalidade |
| Raikan de Presas de Aço | D | Fera | Estação de metrô Hapjeong |
| Briga de Garras-Lâmina | D | Fera | Hapjeong |
| Razan da Sombra Negra | D | Fera | Hapjeong |
| Kasaka de Presas Venenosas Azuis | C | Fera | Hapjeong |
| Golem de Pedra | D | Humanoide | ? |
| Aranha Gigante Buryura | C | Inseto | Insects Dungeon |
| Cerberus | A | Fera | Castelo dos Demônios |
| Goblins | E | Humanoide | Goblins Dungeon |
| Lobisomens | C | Fera | ? |
| Cavaleiros (Hollow Knights) | C | Humanoide | Job Change Quest Dungeon |
| Magos (Hollow) | B | Humanoide | Job Change Quest Dungeon |
| Assassinos (Hollow) | C | Humanoide | Job Change Quest Dungeon |
| Arqueiros (Hollow) | C | Humanoide | Job Change Quest Dungeon |
| Comandante Vermelho-Sangue Igris | A | Humanoide | Job Change Quest Dungeon |
| Elfos de Gelo | B | Povo da Neve | Red Gate |
| Ursos de Gelo | B | Fera | Red Gate |
| Yetis | B | Fera | Red Gate |
| Baruka | S | Povo da Neve | Red Gate |
| Vulcan | S | Demônio | Castelo dos Demônios |
| Guardas de Vulcan | A | Demônio | Castelo dos Demônios |
| Metus | S | Demônio | Castelo dos Demônios |
| Esil Radiru | S | Demônio | Castelo dos Demônios |
| Kaisellin | A | Dragão | Castelo dos Demônios |
| Golems de Terra | A | Humanoide | ? |
| Gigante da Terra | S | Humanoide | ? (masmorra rank A da Hunters Guild) |
| Chacais de Masmorra | C | Fera | Hunters Guild Gate |
| Orcos Altos | A | Humanoide | Hunters Guild Gate |
| Kargalgan | S | Humanoide | Hunters Guild Gate |
| Formigas | B | Inseto | Jeju Island S-Rank Gate |
| Rainha das Formigas | S | Inseto | Jeju Island |
| Rei das Formigas | S | Inseto | Jeju Island |
| Kamish | S | Dragão | Primeiro portal rank S |
| Ogress de Duas Cabeças | A | Morto-vivo | Busan A-Rank Gate |
| Groctar | A | Humanoide | ? (ataque à escola de Jinah) |
| Cavaleiros da Morte | A (presumido) | Morto-vivo | Busan A-Rank Gate |
| Arch Lich | S | Morto-vivo | Busan A-Rank Gate |
| Nagas | A | Dragão | 1º portal rank A da guilda Ahjin |
| Gigantes | S | Gigantes | Tokyo S-Rank Gate |
| Titãs | ao menos S | Titãs | ? |
| Brocky | C | Fera | Gwanak Mountain Dungeon |
| Múmias | ao menos C | Humanoide | Pyramid Field |
| Ammut | S | Humanoide | Pyramid Field |
| Shika | A | Humanoide | Pyramid Field |
| Sirka | S | Povo da Neve | Glacier Dungeon |
| Harmakan | S | Espectro Demoníaco | Jisan Prison (Ragnarok) |
| Xavier | ? | Espectro Demoníaco | Busan Haeundae Beach Dungeon |

### 9.4 Chefes (bosses) notáveis — lista oficial
Ant King · Ant Queen · Baran · Baruka · Blue Venom-Fanged Kasaka · Brocky · Cerberus · Earth Giant · Giant Arachnid Buryura · Grave Spider Arachne · Higos · Hobgoblin · Kamish · Kandiaru · Kargalgan · Legia · Metus · Shika · Stone Golem · Vulcan

Destaques de lore:
- **Kamish** — chefe do 1º portal rank S; devastou a costa oeste dos EUA e matou todos os rank S menos cinco; considerado **a maior calamidade da humanidade**.
- **Rei das Formigas (Beru)** — chefe oculto do portal rank S de Jeju; matou 8 dos 16 rank S da 4ª incursão, incluindo Goto Ryuji.
- **Rainha das Formigas** — chefe oficial de Jeju; mãe do Rei das Formigas; 1ª geração das formigas.
- **Baruka** — líder dos Elfos de Gelo, chefe do Red Gate; falava a língua dos monstros e percebeu que Jinwoo "não era humano".
- **Kargalgan** — xamã orco alto, chefe do portal da Hunters Guild; virou a sombra **Tusk**.
- **Estátua de Deus** — obra-prima de Kandiaru e seu fantoche mais forte; quase mata Jinwoo na masmorra dupla.

---

## 10. Locais

### 10.1 Países e regiões
- **Coreia do Sul (한국)** — cenário principal; 10 rank S originais (6 vivos); a mais fraca em rank S do mundo e o único país a perder território para um portal (Jeju); recuperou Jeju 4 anos depois.
- **Coreia do Norte (북한)** — ditadura; na linha original ofereceu caçadores para ajudar Seul; na revisada está coberta pelo **North Korea Field**, com **Last Paradise** (cidade fortificada em torno do 10º Elvenwood, povoada por fugitivos e villains).
- **Japão (日本)** — 21 rank S originais; 7 mortos em Jeju; sofreu um desastre no portal rank S de Tóquio (milhões de mortos) resolvido por Jinwoo.
- **China (中国)** — militarmente forte, mais rank S da Ásia; sistema de ranking por estrelas (1–5, Liu Zhigang com 7).
- **Índia (भारत)** — fortes rank S; Siddharth Bachchan; Asura Guild; Loktak Lake Field.
- **EUA** — mais rank S do mundo; Federal Bureau of Hunters; arma secreta Norma Selner ("upgrader").
- **Rússia** — o maior país; barreiras de mana nas cidades (Yuri Orloff); projeto Unwithering Spring.
- **Canadá** — portal gigantesco do ataque final de Antares; mortes em massa.
- **Egito** — Pyramid Field. **Ilha de Nauru (Pacífico)** — Glacier Dungeon.

### 10.2 Cidades e locais urbanos
- **Seul** — centro da Coreia; *Seoul Station Field* (masmorra de campo sob a estação), distrito de Guro (sede da Associação), **Jisan Prison** (Pocheon), **Magok Field** (masmorra de campo tipo selva/jungla com monstros de planta e fantasmas), **Gwanak Mountain Dungeon** (Campo do Monte Gwanak), **Hapjeong Subway Station** (masmorra instantânea).
- **Busan** — *Busan Gate* (portal rank A alto; Cavaleiros da Morte, Arch Lich, Ogress de Duas Cabeças) e *Busan Haeundae Beach Dungeon* (Ragnarok).
- **Pyeongtaek** — masmorra de campo rank D (Demon Realm Arc).
- **Paju** — masmorra ocupada por Salamandras.
- **Yangpyeong** — **Mercado Negro** (templo subterrâneo com demônios, leilões e lutas ilegais).
- **Gimpo/Jeju** — ver 10.3.
- **Tóquio** — portal rank S (chefe oculto Legia).
- **Seul/Itaewon e Times Square** (Ragnarok) — *Times Square Field*.
- **Imphal (Índia)** — Loja/portal do vazio de Starpieces; guilda Imphal.
- **Loktak Lake (Índia)** — fusão de 5 portais num campo multidimensional.
- **Nova York / América** — Conferência Internacional de Guildas.

### 10.3 Masmorras e locais especiais
| Local | Descrição |
|---|---|
| **Templo de Cartenon / Masmorra Dupla** | Masmorra rank S oculta dentro de duas masmorras rank D; base de Kandiaru; origem do Sistema |
| **Castelo dos Demônios** | Masmorra instantânea rank S criada por Kandiaru; 100 andares; lar dos demônios; fonte da Água Sagrada da Vida |
| **Masmorra da Mudança de Classe** | Masmorra especial criada pelo Sistema; Cavaleiros/Magos/Assassinos/Arqueiros Hollow + Igris |
| **Red Gate (1º e 2º)** | Portais vermelhos: o incidente da White Tiger (Baruka) e o 2º Red Gate (Boss: Higos, centauro treefolk) |
| **Ilha de Jeju** | Transformada em deserto pelas formigas; portal rank S; 4 incursões; reconquistada por Jinwoo |
| **Pyramid Field** | Masmorra de campo no Egito; Ammut, Shika, múmias |
| **Glacier Dungeon** | Masmorra de campo em Nauru; Sirka, Apóstolo de Itarim |
| **Zona de Penalidade** | Deserto de 4h sem vento, sol, lua ou estrelas; centopeias gigantes; ajusta a dificuldade se o Player tentar caçar ali |
| **Masmorra das Sombras (Shadow Dungeon)** | Mundo de Suho, usado para treinar e como santuário |
| **Mundo do Caos (Chaos World)** | Mundo paralelo dos Monarcas e seus exércitos de bestas mágicas |
| **Mundo do Nada (World of Nothingness)** | Para onde Monarcas e Governantes vão ao morrer (Descanso Eterno) |
| **Mundo do Sono Eterno** | Onde vivem os soldados-sombra do Monarca das Sombras |
| **Mar da Vida Eterna (Sea of the Afterlife)** | Universo espiritual infinito onde flutuam as almas; raiz do **World Tree** (Árvore do Mundo) e do **Nidhogg** |
| **Elvenwood** | Cidade/árvore sagrada dos Elfos Superiores, oculta sob uma cúpula; filiais na Coreia do Norte, Rússia, China, França e EUA |
| **Torre das Provações (Tower of Trials)** | Manifestação do poder de **Ammut** após ascender a Monarca das Provações |
| **Fenda Dimensional (Dimensional Crack / Gap)** | Espaço entre dimensões; exércitos do Caos e Monarcas |
| **Coliseu** | Arena no Reino dos Demônios (execuções, combate forçado), domínio do Rei Tirano do Sangue Louco |
| **Mercado Negro** | Yangpyeong (acima) |
| **Jisan Prison** | Penitenciária de alta segurança em Pocheon (Ragnarok) |
| **Last Paradise** | Cidade fortaleza da Coreia do Norte em torno do Elvenwood corrompido |
| **Ahjin Soft / Yoojin Construction** | Empresas em Seul (ver §14) |

---

## 11. Itens, armas, equipamentos e recursos

### 11.1 Armas e equipamentos
| Item | Tipo | Detalhes |
|---|---|---|
| **Kamish's Wrath** | Par de adagas | Forjadas com a presa do dragão Kamish; uma das armas mágicas mais fortes do mundo; presente de Thomas Andre a Jinwoo |
| **Antares' Fangs** | Seis adagas | Forjadas com as presas de Antares; as **armas mágicas mais fortes do mundo** |
| **Demon King's Daggers** | Adagas/espadas curtas | Armas de Baran; usadas por Jinwoo até receber Kamish's Wrath |
| **Demon King's Longsword** | Espada | Espada de Baran; dada a **Igris**; décadas depois, arma principal de **Cha Hae-In** |
| **Baruka's Dagger** | Adaga | Drop de Baruka; arma principal de Jinwoo antes das adagas de Baran |
| **Kasaka's Venom Fang** | Adaga | Drop de Kasaka; usada até comprar a Knight Killer |
| **Knight Killer** | Adaga | Comprada na **Loja do Sistema** durante a Job Change Quest |
| **Kim Sangshik's Sword** | Espada mágica | Largada por Kim Sangshik na masmorra dupla; transferida ao inventário de Jinwoo; arma principal no Instant Dungeon Arc |
| **Grim Reaper's Bow** | Arco | Arma principal do rank S **Lim Tae-Gyu** |
| **Fang of Rakan (Rakan's Blade)** | Espada senciente | Primeira arma de **Suho**; forjada com um dente do Monarca das Feras e contém parte do ego dele |
| **The Sword that Gawns the World Tree Nidhogg** | Adagas | De Suho; combinação de Kamish's Wrath + Shadow Nidhogg |
| **Shadow of Destruction, The Flame that Gawns Gods – Ragnarok** | Espada | Arma "matadora de deuses" criada com o poder de Shadow Nidhogg + Coração do Rei Dragão |
| **Vulcan Horn** | Espada | Arma usada pelo Suho de outro mundo na quest de avanço |
| **Vulcan's Horn** | Manoplas | Manoplas feitas do chifre de Vulcan; obtidas em Caixa Aleatória Amaldiçoada |
| **Scorching Gauntlets** | Manoplas | Usadas por Suho na Quest Tutorial |
| **Ice Bear's Robe** | Manto | Usado por Suho e aliados no Glacier Dungeon Arc |

### 11.2 Artefatos e itens únicos
| Item | Efeito / papel |
|---|---|
| **Black Heart (Coração Negro)** | Objeto de **Ashborn**, herdado por Jinwoo; base do poder do Monarca das Sombras (revive/resgata o portador) |
| **Dragon King's Heart** | Objeto de **Antares**, herdado por Suho |
| **Cup of Reincarnation (Cálice da Reencarnação)** | Criado pelo Ser Absoluto; **retrocede o tempo em 10 anos**; poder finito — usado várias vezes pelos Governantes e uma última vez a pedido de Jinwoo |
| **Orb of Avarice (Esfera da Avareza)** | Item mágico dropado de Vulcan; aumenta o poder mágico do portador |
| **Bloodstone** | Poder único dos **nobres demônios** |
| **Avatar** | Produto criado por Suho a partir de itens/research |
| **Game Capsule** | Dispositivo desenvolvido pela **Ahjin Soft** (para o VR "Beautiful World") |
| **Itarim's Stone Tablet** | Tableta usada/criada pelos Apóstolos |
| **Primordial Light and Darkness** | Forças antigas personificadas na criação do universo |
| **Teleportation Stone / Hearthstone** | Item exclusivo de quests do Sistema; retorno instantâneo (Jinwoo recebeu um na Masmorra Instantânea e um na Job Change) |

### 11.3 Consumíveis, materiais e recursos
| Item | Categoria | Uso |
|---|---|---|
| **Holy Water of Life (Água Sagrada da Vida)** | Consumível | Cura-tudo criado pelo Sistema; única cura conhecida para o **Sono Eterno** (receita obtida com *Collect Demon Souls! (1)*); curou Park Kyung-Hye |
| **Essence Stones (Pedras de Essência)** | Material/renda | Nascem nos corpos das bestas mágicas; principal fonte de renda dos caçadores; valor por rank/qualidade; cor: D branca, A vermelha, S roxa, raras **negras**; usadas para forjar equipamento e manter equipamentos médicos |
| **Mana Crystals (Cristais de Mana)** | Minério | Mineral azul dentro de masmorras; renda secundária; mineração manual (eletricidade não funciona em masmorras) |
| **Rune Stones** | Item mágico | Caem de monstros e **contêm habilidades** (normalmente do monstro); muito valiosas |
| **Mana** | Energia | Energia natural radiada por caçadores, bestas e portais; sem mana não se fere uma besta mágica |
| **Seed of Evolution** | Consumível | Criada por **Beru** comprimindo os restos do Apóstolo dos Pesadelos |
| **Leaf of the World Tree** | Material | Folha da Árvore do Mundo, rica em vitalidade; ingrediente de poções e reagentes de alto grau |
| **World Tree's Fragment** | Ingrediente | Madeira da Árvore do Mundo com magia poderosa |
| **Spring Water from the Forest of Echoes** | Consumível | Água da Floresta dos Ecos, no Glacier Dungeon |
| **Purified Blood of the Demon King** | Ingrediente | Sangue de Baran purificado; ainda tóxico — precisa ser misturado a World Tree's Fragment + Spring Water para virar remédio |
| **Contaminated Elvenwood Fruits** | Consumível | Versões mutadas dos frutos sagrados de Elvenwood |
| **Stardust** | Consumível/droga | Droga que aumenta temporariamente a mana; produzida por **Lee Minsung** com **Tiel**; distribuída na comunidade de caçadores coreana |
| **Starpiece** | Consumível | Forma altamente concentrada de Stardust; fabricada em **Imphal** (Índia) |
| **Mad Blood Poison** | Veneno/consumível | Veneno usado no Coliseu do Reino dos Demônios |

---

## 12. Habilidades e poderes

### 12.1 Conceitos
- **Skills** são divididas em **Ativas** (ativação manual, custam mana/cooldown), **Passivas** (sempre ativas) e **Únicas** (raras/exclusivas de indivíduos especiais, ex.: Monarca das Sombras). Skills do Sistema sobem de nível junto com o Player e podem evoluir.
- **Authority (권능)** é a classificação das habilidades de seres superiores (deuses, Monarcas, Governantes): controle absoluto sobre um aspecto da realidade correspondente ao domínio do usuário.

### 12.2 Habilidades e poderes de Sung Jinwoo
| Habilidade | Efeito |
|---|---|
| **Will To Recover** (passiva) | Regenera qualquer dano, incluindo membros perdidos; não cobre ferimentos fatais (ex.: coração perfurado) |
| **Tenacity** (passiva) | Com HP abaixo de 30%, todo dano recebido é **reduzido em 50%** |
| **Advanced Dagger Techniques** (passiva) | Com adagas, dano causado **+33%** |
| **Bloodlust / Murderous Intent** (ativa) | Intimida o inimigo, impondo medo e **-50% nos atributos**; afeta vários alvos |
| **Mutilation / Critical Attack** (ativa) | Ataque nos pontos vitais com adagas — dano crítico |
| **Dagger Rush / Dagger Throw** (ativa) | Barragem de adagas de todas as direções |
| **Ruler's Authority / Capture** (ativa) | Telecinesia — move e controla objetos; permite voar/dodge no ar em alta velocidade |
| **Dragon's Fear** (ativa) | Grito imbuído de mana que joga qualquer um mais fraco em desespero e pânico |
| **Quicksilver / Sprint / Dash** (ativa) | Habilidade de velocidade |
| **Shadow Extraction** (job skill) | Extrai sombras de cadáveres e as adiciona ao exército (limitações em §7.1) |
| **Shadow Preservation / Shadow Storage** (job skill) | Armazena sombras e permite perceber por seus sentidos |
| **Shadow Exchange** (job skill) | Usa sombras como portais para viajar instantaneamente a grandes distâncias |
| **Monarch's Domain** (job skill) | **+50% de força** para todas as sombras ativas em batalha |
| **Shadow Authority** | Autoridade sobre a Morte: comandar os mortos |
| **Umbrakinesis** | Controle absoluto de sombras/escuridão; pode formar armadura |
| **Absolute Defense** | Barreira que anula qualquer ataque recebido |
| **Infinite Mana** | Mana ilimitada; regenera o exército de sombras indefinidamente |
| **Power Inheritance** | Usa todas as habilidades das próprias sombras |
| **Hypnosis / Illusions** | Hipnose por estalo de dedos; criação de ilusões complexas |
| **Imortalidade** | Não envelhece biologicamente; ajusta a própria aparência |
| **Bloodlust / Detection / Stealth / Taunt / Mana Shield (Iron Wall) / Strengthening / Iron Body Technique** | Habilidades clássicas por classe: intimidação, detecção (magos da Job Change), camuflagem (assassinos), provocação e escudo de mana (tankers), reforço físico |

### 12.3 Habilidades e autoridades dos seres superiores
| Habilidade | Detentor / efeito |
|---|---|
| **Authority** | Classe geral de habilidades de deuses, Monarcas e Governantes |
| **Creation (Authority of Creation)** | Seres Supremos / Itarim — criar existência a partir do nada |
| **Spiritual Body Manifestation** | Monarcas e Governantes — assumir forma e poder verdadeiros |
| **Ruler's Authority** | Governantes e seus vasos — telecinesia |
| **Monarch's Domain** | Monarcas — buff ao exército |
| **Shadow Authority** | Monarca das Sombras — domínio da Morte |
| **Abyss Authority** | Autoridade final de Jinwoo em Ragnarok; o Nada que devora a existência, oposta à Criação |
| **Transcendence Authority** | Suho (Monarca da Transcendência) — transcender limites até o máximo |
| **Shadow Creation** | Habilidade de classe de Suho ("Irregular: White Shadow") |
| **Shadow of The World Tree Authority** | Suho — papéis da Árvore do Mundo e de sua Sombra |
| **Breath of Destruction** | Antares (depois Suho) — sopro destrutivo capaz de apagar sombras permanentemente |
| **Dragon's Fear** | Antares e seus servos — debuff de pânico |
| **Stage of the Lonely God** | Itarim da Dimensão-1 |
| **World's Predation** | Itarim da Dimensão-1 |
| **Mutilation / Twin Swords / Unwithering Spring** | Habilidades registradas (Suho/Beru): Twin Swords (Suho), Unwithering Spring (projeto russo, absorvido por Beru ao consumir o corpo de Yuri Orloff) |

---

## 13. Guildas e organizações

### 13.1 Guildas
| Guilda | País | Notas |
|---|---|---|
| **Ahjin Guild** | Coreia | Criada por Jinwoo; **a mais forte do mundo** apesar de ter só três membros oficiais (um rank S); supera todas as outras por incluir o exército de sombras |
| **Hunters Guild** | Coreia | Maior e mais forte das cinco grandes coreanas; duas strike squads; única com 2 rank S (Choi Jong-In e Cha Hae-In) |
| **White Tiger Guild** | Coreia | Uma das cinco grandes; criada por Baek Yoonho após sair da Fiend; treina novatos em portais de baixo rank |
| **Fiend Guild (Ceifadores)** | Coreia | Uma das cinco grandes; já foi a mais forte da Coreia; perdeu membros para a White Tiger |
| **Knights Guild** | Coreia | Uma das cinco grandes; sem rank S, mas com o maior número de rank A do país; região de Yeongnam |
| **Fame Guild** | Coreia | Uma das cinco grandes; região de Honam; mais magos que lutadores |
| **Black Tortoise Guild** | Coreia | Guilda grande (linha revisada); rival da White Tiger; nome vem de "Hyunmoo" (Hyeonmoo Gang, o mestre) |
| **Yoojin Guild** | Coreia | Da Yoojin Construction; nunca decolou; Jinho a abandonou pela Ahjin |
| **Woojin Guild** | Coreia | Guilda nova e forte; critério: subir de nível rápido (masmorras de rank alto/muitos monstros); 3 membros oficiais (Ragnarok) |
| **Chivalry Guild / Courage Guild / Hyena Guild** | Coreia | Guildas menores (Hyena opera perto do monte Gwanak; líder: Brocky) |
| **Draw Sword Guild (Blade)** | Japão | Maior guilda do Japão e 2ª da Ásia; tinha 11 rank S, perdeu 7 em Jeju (incluindo Goto Ryuji) e caiu em desgraça |
| **Scavenger Guild** | EUA | Maior guilda dos EUA; atua em todo o país e presta serviços no exterior |
| **Asura Guild** | Índia | Mais forte da Índia; controlava guildas subsidiárias (ex.: Imphal) |
| **Imphal Guild** | Índia | Pequena; fundada por Ali Hassan (ex-mendigo) em Imphal |
| **Richter Guild** | Alemanha | Mais forte do país |
| **Gold Dragon Guild** | China | Guilda importante |

### 13.2 Organizações, empresas e instituciones
- **Korean Hunters Association (Associação Coreana de Caçadores)** — supervisiona caçadores, portais e guildas; sede em Guro, Seul; Departamento de Avaliação, Equipe de Vigilância (inspetores).
- **Japanese Hunters Association** — equivalente japonês.
- **Federal Bureau of Hunters (FBH)** — órgão do governo americano; organiza a **Conferência Internacional de Guildas** (anual, EUA); Divisão Asiática sob Adam White; Norma Selner como "upgrader".
- **World Hunter Association** — cooperação internacional (linha revisada).
- **Korean Hunters Auction (Leilão de Caçadores)** — mercado online/offline de itens e materiais mágicos; leilão privado de itens raros (onde Jinwoo buscou um artefato à prova de fogo e avaliou o Orb of Avarice).
- **Black Market (Mercado Negro)** — Yangpyeong; comércio ilegal de demônios e caçadores, leilões e apostas em lutas.
- **Yoojin Construction** — construtora de Yoo Myunghan (Lee Wong-Yu como vice-presidente).
- **Ahjin Soft** — empresa de games de Yoo Jinho; criou o VR **"Beautiful World"** (12 milhões de usuários em 4 anos).
- **Ilsin Hospital** — onde Park Kyung-Hye ficou internada com Sono Eterno.
- **Hanguk University** (Depto. de Pintura) — onde trabalha Lim Do-Gyu.

---

## 14. Glossário rápido (terminologias)

**Portais/Gates** · **Dungeons** · **Dungeon Break** · **Red Gate** · **Field-Type Dungeon** · **Masmorra Instantânea (Instant Dungeon)** · **Mana** · **Bestas Mágicas (Magic Beasts)** · **Pedras de Essência (Essence Stones)** · **Cristais de Mana** · **Runas (Rune Stones)** · **Caçadores (Hunters)** · **Awakened / Desperto** · **Rank S–E (Class Ranks)** · **National Level Hunter** · **Reawakening** · **False Ranker** · **Lizards** · **Villains** · **Guild / Guild Master** · **Strike Team / Mining Team / Collecting Team / Porter** · **Associações de Caçadores** · **Sistema (System)** · **Player** · **Quest / Quest Diária / Penalty Zone** · **Inventário** · **Loja do Sistema** · **Job Change** · **Sombras (Shadows)** · **Shadow Extraction / Preservation / Exchange** · **Graus de Sombra** · **Monarcas (Monarchs)** · **Governantes (Rulers)** · **Apóstolos (Apostles)** · **Itarim / Deuses Exteriores** · **Ser Absoluto** · **Authority** · **Spiritual Body Manifestation** · **Cálice da Reencarnação (Cup of Reincarnation)** · **Sono Eterno (Eternal Slumber)** · **Sono Eterno / Mundo do Repouso (World of Eternal Slumber)** · **Mundo do Nada** · **Mar da Vida Eterna** · **Mundo do Caos** · **Universos Exteriores** · **Fenda Dimensional** · **Dimensional Transfer** · **Árvore do Mundo (World Tree)** · **Nidhogg** · **Elvenwood** · **Torre das Provações** · **Cataclismo (Cataclysm)** · **Segundo Cataclismo** · **Conferência Internacional de Guildas** · **Incidente do Red Gate** · **Guerra dos Deuses Exteriores**

---

## 15. Ganchos para o Gatebreakers (mapa para `data/*.json`)

Estrutura atual do projeto: `data/units/*.json` (id, display_name, role, uses_hunter_xp, base_hp, base_attack, base_defense, base_speed, art, unlock), `data/gates/gates.json` (gate, boss_wave, clear_unlocks_unit; `total_gates: 10`), `data/story/story_cards.json` (id, trigger, title, text, art), `data/balance/balance_config.json`, `data/enemies/` (**ainda vazio**), `data/localization/pt_BR.json`.

Sugestões de uso deste documento:

1. **`data/units/` (aliados/sombras)** — há material para ~20 sombras nomeadas com função clara: tanque (Iron, Tank, Shadow Giants), DPS corpo a corpo (Igris, Greed, Kira), mago/suporte (Tusk, Harmakan), cura (Min Byung-Gyu), DPS à distância (Kaisel, Sita, Gordon, Jima), chefe/super-unidade (Bellion, Beru). Graus de Sombra (§7.1) dão uma **régua natural de progressão**: Normal → Elite → Knight → Elite Knight → General → Marshal → Grand Marshal, com pontos de desbloqueio ligados à autorização do Monarca.
2. **`data/enemies/`** — a tabela §9.3 já traz **nome → rank → tipo → masmorra**, o que permite montar ondas por rank (E/D/C/B/A/S) sem inventar conteúdo. Chefes de §9.4 servem como `boss_wave`.
3. **`data/gates/gates.json`** — os 10 portais podem seguir os 10 primeiros arcos / chefes em ordem de dificuldade: Goblins Dungeon (E) → Hapjeong/Kasaka (C/D) → Insects Dungeon/Buryura (C) → Job Change/Igris (A) → Red Gate/Baruka (S) → Castelo dos Demônios (Cerberus → Vulcan → Metus) → Hunters Guild Gate/Kargalgan (A/S) → Jeju (Rainha → Rei das Formigas) → Tóquio (Legia) → Antares (final). O campo `clear_unlocks_unit` casa com a ordem de aquisição das sombras: Igris (job change), Iron (Red Gate), Tank (Red Gate), Tusk (Hunters Guild Gate), Beru (Jeju), Kaisel (Baran), Bellion/Shadow Giants (final).
4. **`data/story/story_cards.json`** — a tabela §2.2 (arco → episódio → capítulo) e o resumo §2.5 dão gatilhos e textos curtos por arco; cada card pode apontar para um arco/episódio real.
5. **`data/localization/pt_BR.json`** — os nomes em português deste documento (Monarca das Sombras, Governantes, Pedras de Essência, Água Sagrada da Vida, Zona de Penalidade, Masmorra Instantânea, Portal Vermelho) estão prontos para uso como tradução consistente.
6. **Habilidades (§12.2)** — os efeitos são **numéricos no original** (-50% de atributos, +33% de dano de adaga, -50% de dano abaixo de 30% de HP, +50% de força do exército), o que dá uma base de design sem inventar fórmulas.
7. **Ranks (§5.2) e graus de sombra (§7.1)** — servem como eixos duplos de progressão: rank do caçador (E→S→National) e grau da sombra (Normal→Grand Marshal), com o **Reawakening** como evento raro de salto.

### Limites de uso (IP)
O projeto Gatebreakers é um **protótipo privado de fã, não publicável**. Padrões de sistema, arquitetura, estruturas de progressão e nomes de referência podem ser estudados; **arte, áudio, textos literais, tabelas oficiais de balanceamento e código de terceiros não devem ser redistribuídos** nem usados em publicação comercial. Se a intenção for publicar, será necessário trocar nomes/marcas por equivalentes originais.

---

## 16. Lacunas e nível de confiança

- **Fonte principal**: wiki de fandom de Solo Leveling (conteúdo mantido por fãs, ~487 páginas coletadas por API em 06/10/2026) + páginas oficiais do anime + busca web para o estado da 3ª temporada. Fatos marcados como "verificado" têm fonte oficial/secundária; o restante é conteúdo de wiki.
- **Não existem tabelas oficiais de stats** (HP, ataque, defesa, velocidade) para monstros/unidades — nem a wiki nem a obra as publicam. **Nada aqui foi estimado**: onde o rank não é informado, está marcado com "?" ou "não informado".
- Ranks individuais de vários caçadores secundários não são declarados pela obra (listados apenas nominalmente em §5.5).
- Alguns dados são exclusivos da novel, outros do webtoon ou do anime; quando a wiki indicava divergência (ex.: Kira, Kwei, Shika), isso foi anotado.
- O anime cobre até o arco da Ilha de Jeju (episódio 25). Todo o restante da história (arcos 14–22 e todo o *Ragnarok*) existe apenas em webtoon/novel — útil se o jogo quiser avançar além do que o anime mostrou.



