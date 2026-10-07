# Referência de sistemas — vídeo de Bleach → Gatebreakers

**Natureza:** análise e propostas; não é aprovação de implementação nem alteração da especificação.
**Projeto alvo:** protótipo privado Gatebreakers, estado documentado v0.4.0.
**Fonte:** https://drive.google.com/file/d/1280DZTI00TD3JoylpALmG7MWm1L6GeiZ/view
**Arquivo:** `Screen_Recording_20261007_145818_BLEACHA Guerra dos Mil Anos.mp4`.

## 1. Como isto foi obtido

- Download real pelo Google Drive, incluindo o formulário de confirmação de arquivo grande.
- `ffprobe`: vídeo H.264, 1080 × 2340; áudio AAC; duração 246,379544 segundos; 199.172.155 bytes.
- `ffmpeg`: 62 capturas distribuídas por toda a gravação, com amostragem de uma imagem a cada quatro segundos. Oito folhas de contato e inspeção adicional de capturas individuais para ler interfaces.
- Timestamps abaixo são aproximados, relativos à gravação; servem para localizar a evidência, não para marcar exatamente o início/fim de uma ação.
- Comparação com `HANDOFF.md`, especificação do projeto incluindo adendos 14 e 15 e busca dirigida em scripts de estado/navegação. Não foram executados novos testes do jogo nesta análise.
- Não houve análise do APK, acesso ao servidor do jogo de referência, obtenção de fórmulas internas nem transcrição do áudio. A análise é visual e amostrada, não uma alegação de revisão quadro a quadro.

**Rótulos:** observado = interface/ação visível; inferência = interpretação a confirmar; proposta = adaptação original para Gatebreakers; lacuna = informação não obtida.

## 2. Síntese

O valor da referência não é a quantidade de botões. É a ligação entre **combater, identificar um bloqueio, fortalecer personagens, resgatar marcos e experimentar outro modo**. O vídeo mostra essa ligação: a campanha e outros desafios continuam enquanto o jogador navega e recebe recompensas; fichas individuais apresentam várias formas de fortalecimento.

Gatebreakers já tem o ciclo básico, auto-farm em primeiro plano, baús AFK, melhorias e formação. As próximas expansões mais úteis são **habilidades que diferenciem as unidades, objetivos claros, equipamento enxuto e um modo alternativo de desafio**. Minijogos, sorteios e sistemas pagos não devem virar pré-requisitos dessa expansão.

## 3. Arquitetura: evidência e limites

### Jogo de referência

**Observado:** cidade/hub, campanha, instâncias e ficha de heróis compartilham recursos e navegação. Há efeitos de combate, mudanças de poder, resultado com próximo combate automático, desafios por nível, menus de recompensa e funções sociais.

**Inferência:** sistemas de conteúdo e recompensa convergem para um estado de jogador compartilhado. A gravação não permite determinar engine, protocolos, autoridade do servidor, armazenamento ou fórmula de combate. Presença de guilda, ranking e correio sugere serviços online, mas não prova como estão implementados.

### Gatebreakers

**Confirmado em arquivos:** Godot/GDScript, offline-first; `GameState` concentra estado e regras econômicas; `CombatService` resolve combate determinístico; `SaveService` trabalha com schema v2; serviços de auto-farm e AFK são separados; conteúdo/localização ficam em dados.

**Direção proposta:** reutilizar esses pontos em vez de criar um segundo jogo dentro do primeiro. Campanha, torre e desafios devem consumir o mesmo motor de combate e definições de unidades. Recompensas devem ter origem identificável e idempotência. Equipamento/habilidades precisam recalcular atributos na mesma fonte central utilizada pelas telas e pelo combate.

O cabeçalho antigo da spec ainda descreve um rascunho inicial; o estado de implementação é melhor representado pelo handoff e pelos adendos aprovados. Esta referência não tenta corrigir essa documentação por conta própria.

## 4. Inventário de sistemas e tradução temática

### 4.1 Perfil e identidade — ~00:02–00:06

**Observado:** avatar, título, nível, ID, guilda, coleção exposta e opções de configuração/conta.
**Proposta:** ficha de caçador com rank, título desbloqueável e resumo de progresso. Não adicionar login, guilda ou identificação pública. Títulos podem começar cosméticos.
**Lacuna:** critérios de concessão dos títulos da referência.

### 4.2 Cidade/hub e navegação — ~00:10–00:14; ~01:18

**Observado:** cenário urbano com edifícios clicáveis, muitos ícones, indicadores vermelhos e navegação inferior; aparecem cidade, herói, mochila, instância, guilda e relíquia.
**Proposta:** uma futura base da Associação dos Caçadores, com acesso a treino, portais e arsenal. Manter os destinos compactos atuais enquanto houver pouco conteúdo; a cidade pode ser apresentação, não nova regra econômica.
**Não levar:** dezenas de atalhos permanentes e pontos vermelhos de promoção.

### 4.3 Treinamento rápido e progressão de arma/espírito — ~00:18–00:22

**Observado:** treinamento rápido com feedback de poder; ficha de Sode no Shirayuki com `Treinar`, `Presente`, `Habilidade`, `Combate` e indicação `Desativado`.
**Proposta:** evolução de habilidades/armas do caçador; não reproduzir presentes/afinidade como um sistema separado sem necessidade. Uma arma pode ter um caminho curto de domínio.
**Lacuna:** custos, requisitos de ativação e efeito exato de cada melhoria.

### 4.4 Coleção de entidades/relíquias — ~00:26

**Observado:** entidades seladas, `Baú da Fera`, `Ilustração da Fera Espada`; abas `Contrato`, `Histórias Estranhas`, `Fera Espada`, `Visão Geral`.
**Proposta:** bestiário e registros do Sistema; posteriormente relíquias obtidas em chefes. Primeiro tratar coleção como descoberta de conteúdo, não multiplicador global obrigatório.
**Lacuna:** bônus, regras de contrato e desbloqueio não demonstrados.

### 4.5 Evento com missões e coleção de pontos — ~00:30

**Observado:** `Coleção de Adesivos`, tarefas de login/desafio/fusão/recrutamento/gasto de moeda, progresso, resgate, reinício diário e tarefa de recarga cumulativa.
**Proposta:** objetivos do Sistema por marco: vencer portal, melhorar sombra, ajustar formação. Reaproveitar as ações do jogo em vez de exigir ações sem valor.
**Não levar:** tarefas de recarga, gasto premium ou reset diário obrigatório. Eventos temporários ficam para depois de existir conteúdo suficiente.

### 4.6 Recrutamento direcionado e banner com garantia — ~00:34–00:46

**Observado:** banner de Jugram, opção de personagem desejado, invocações individuais/múltiplas; outro banner exibe garantia após uma contagem de invocações. A gravação também mostra invocação e revelação de personagem em ~03:26–03:38.
**Proposta:** desbloqueio de sombras por chefes e extração após vitória. Um futuro sistema de recrutamento deve favorecer progresso previsível; não precisa ser gacha.
**Lacuna:** probabilidades, pool completo e funcionamento da garantia.
**Não levar agora:** moeda premium, banners sazonais, duplicatas obrigatórias e monetização por sorteio.

### 4.7 Desejo e recompensas de atividade — ~00:42

**Observado:** `Carpa da Sorte`, presentes, escolha visual de recompensa, condição de pontos de atividade e recarga.
**Proposta:** escolha entre recursos após uma conquista relevante: ouro, XP ou material de aprimoramento. Sem nova moeda de atividade inicialmente.
**Lacuna:** o efeito de cada opção e a distribuição de resultados.

### 4.8 Tabuleiro com dado — ~00:54–01:10

**Observado:** caminho de casas com recompensas, dado animado, quantidade de jogadas e recompensa resgatada; opção de pular animação.
**Proposta:** expedição futura por nós, com decisões entre combate, recurso e risco. O mapa deve acrescentar escolha, não apenas converter um clique em recompensa aleatória.
**Lacuna:** probabilidades do dado, regras das casas e combate associado.

### 4.9 Recursos gratuitos/roleta — ~01:14

**Observado:** `Roleta de Moedas` com ouro, pedra de ascensão, XP e botão `Grátis`.
**Proposta:** uma fonte transparente de materiais dentro de desafios reais. Não inserir uma roleta para resolver problemas de ritmo que deveriam ser resolvidos pelo balanceamento.
**Lacuna:** periodicidade, chance e eventual custo após o uso gratuito.

### 4.10 Cartas e recompensa selecionável — ~01:22–01:34

**Observado:** cartas viradas, recompensa atual, receber e atualizar gratuitamente; aparecem materiais e fragmentos.
**Proposta:** recompensa de expedição com escolha entre opções conhecidas. Baixa prioridade: o valor está na escolha, não na animação de sorteio.
**Lacuna:** mecanismo de atualização e aleatoriedade.

### 4.11 Cartões mensais e passes — ~01:38–01:42; ~03:14–03:18

**Observado:** cartões mensais com preços, calendário de recompensas e passes ligados a níveis/estágios, com resgates e compra.
**Proposta:** trilha gratuita de marcos da campanha dentro do Sistema, com recompensas por avanço real.
**Não levar:** assinatura, VIP, passe pago, obrigação de login consecutivo e preços da referência.

### 4.12 Formação e combinações de equipe — ~01:50

**Observado:** personagens posicionados em slots, espaço vazio, seleção de unidades e ícones de grupos/afinidades.
**Proposta:** Jinwoo e sombras com funções táticas: defensor, atacante, suporte/controle. Explicar como a ordem afeta o combate; recomendar opções sem escolher tudo automaticamente.
**Lacuna:** efeitos das afinidades/grupos e regra exata de posicionamento da referência.
**Estado atual:** formação existe; não confundir ícones de afinidade visíveis com prova de sinergias específicas.

### 4.13 Combate automático, habilidades e efeitos — ~01:02; ~01:54–01:58; ~02:38–02:46; ~02:58–03:06

**Observado:** equipes em lados opostos, vida por unidade, ações automáticas, dano flutuante, efeitos próprios dos personagens e destaque de golpe/habilidade. Há controle de aceleração visível em algumas batalhas.
**Proposta prioritária:** uma habilidade distintiva por unidade: dano concentrado de Jinwoo, golpe de Igris, proteção do guardião e ataque à retaguarda da sombra à distância. Começar com recarga em rodadas e regras determinísticas.
**Lacuna:** fórmulas, RNG, prioridade de alvo e tempos internos da referência. O nome de uma habilidade visualmente parcialmente legível não é necessário para adaptar o padrão.
**Regra técnica:** animação consome eventos do combate; nunca decide dano. Velocidade visual não muda resultados.

### 4.14 Catálogo de heróis e filtros — ~02:02; ~02:26

**Observado:** grade de cartas, raridades SR/SSR/SSR+, estrelas, níveis, capacidade de coleção e filtros.
**Proposta:** catálogo de sombras e caçadores com função, desbloqueio e comparação. Para o primeiro crescimento do elenco, preferir identidade de função a dezenas de raridades.
**Lacuna:** regras de capacidade, duplicatas, fusão e níveis de raridade.

### 4.15 Equipamentos e equipar rápido — ~02:06

**Observado:** slots equipados, símbolos/estrelas, botão `Equipar rápido`; abas `Desenvolver`, `Equip.`, `Despertar`, `Arte Espiritual`.
**Proposta prioritária:** começar com arma e armadura de Jinwoo, bônus simples e comparação antes de equipar. Depois expandir para sombras se fizer diferença real nas escolhas.
**Critério do equipar rápido:** regra explicitada ao jogador; não presumir que maior pontuação sempre é melhor para toda composição.
**Lacuna:** bônus de conjunto, origem dos itens e algoritmo de escolha da referência.

### 4.16 Desenvolvimento, avanço, despertar e renascimento — ~02:10–02:14; ~02:30

**Observado:** nível e limite, atributos, ícones de habilidades, `Avanço`, `Renasci...`; menu `Despertar`; posteriormente a ficha apresenta nível maior. `Arte Espiritual` mostra um slot disponível e slots bloqueados por estrelas.
**Proposta:** nível como base; promoção de rank em marcos de chefes como uma camada futura; habilidade como diferenciação. Adiar uma quarta camada de progressão até as anteriores terem propósito.
**Lacuna:** não foram demonstradas as ações nem regras completas de despertar/renascimento. O vídeo não permite afirmar que renascimento reinicia a progressão.

### 4.17 Recompensas multiplicadas e publicidade — ~02:18–02:22

**Observado:** popup com três opções de recursos, limites restantes, botão `Obter grátis` e opções com multiplicador/etiqueta de anúncio; recompensa aparece após interação.
**Proposta:** comunicar ganho e origem claramente; manter Gatebreakers sem anúncios.
**Lacuna:** não há evidência de que um anúncio tenha sido efetivamente reproduzido na gravação.

### 4.18 Campanha idle e sequência automática — ~02:34–02:50; ~03:22; ~03:30; ~03:54

**Observado:** tela de batalha com recompensa acumulada, `Escalação recomendada`, `Batalha`, `Cruzada Rápida`; resultado com MVP, recursos, `OK`, `Próximo`, opção de próxima fase automática e contagem até continuação. Batalhas da campanha aparecem concluídas entre visitas a outros menus.
**Proposta:** aperfeiçoar o auto-farm já existente, com resumo discreto e ação de parar clara. Um futuro controlador independente da tela pode permitir navegar enquanto o app permanece em primeiro plano.
**Atenção:** não equiparar execução em outros menus a execução com o aplicativo fechado. No projeto, AFK continua sendo cálculo de tempo, não batalha em background.
**Lacuna:** duração máxima AFK, taxas reais e detalhes da cruzada rápida não obtidos.

### 4.19 Torre/Provação de Agente — ~02:54–03:10

**Observado:** `Nível 50`, ranking, loja, ordem de provação, desafios disponíveis, `Iniciar desafio` e `Varredura`; batalha efetivamente exibida.
**Proposta prioritária:** Provação do Sistema: sequência separada de andares, mesmo combate, inimigos/configurações diferentes e recompensa de primeira vitória. Pode existir offline, sem ranking, loja ou quota diária.
**Regra:** portal de campanha e andar da provação têm progressos distintos. Não copiar limites numéricos da referência.

### 4.20 Loja e fragmentos — ~03:10

**Observado:** loja com bilhetes, fragmentos, descontos e moeda.
**Proposta:** somente depois de definir equipamentos e fontes de materiais, considerar troca simples por ouro ou recursos já existentes.
**Lacuna:** limites, renovação de estoque e origem da moeda.
**Não levar:** descontos artificiais e loja como obrigação para acessar o ciclo central.

### 4.21 Correio e resgate em lote — ~03:42

**Observado:** mensagens com fontes/títulos, estado lido e `Resgatar Tudo`.
**Proposta:** painel local de recompensas pendentes do Sistema, apenas se diferentes fontes justificarem sua existência. Reutilizar a lógica de crédito único.
**Não levar agora:** correio online, presentes remotos e complexidade de caixa de entrada sem necessidade.

### 4.22 Missões, conquistas e orientação — ~03:46–03:50

**Observado:** `Comando` com abas `Diário`, `Conquista`, `Experiência`, `Calendário Semanal`; resgate de recompensas por tarefas e conquista de poder; botões `Ir para` no conteúdo.
**Proposta prioritária:** painel Sistema com objetivos permanentes curtos, indicação de progresso, recompensa e botão de acesso à ação. Ex.: concluir portal, melhorar unidade, alterar formação, vencer provação.
**Regra:** objetivos devem guiar uma próxima ação útil, não exigir abrir o jogo num horário. Estado de resgate persistido; reinício não duplica prêmio.

### 4.23 Aventuras e exploração narrativa — ~03:58–04:06

**Observado:** lista de áreas com percentual, recompensa de unidade/fragmentos, estado concluído/em andamento e bloqueio por avanço na história. Abas `Capítulo do Personagem`, `Capítulo da Fera Espada`, `Capítulo do Fullbring`. Em seguida aparece um mapa com diálogo de Ashido falando em limpar obstáculos.
**Proposta:** missões de extração de sombras e episódios do Exército das Sombras: pequenos mapas por nós, encontro, texto original e recompensa de conclusão. Desbloqueio por campanha, não por pagamento.
**Lacuna:** o mapa não foi percorrido suficientemente para afirmar regras de movimento, puzzles, combate, reset ou persistência.

### 4.24 Funções só indicadas por atalhos

**Observado:** guilda, classificação/ranking, mochila, ícones sociais/chat e vários menus de evento aparecem, mas não há revisão funcional completa de cada um.
**Proposta:** nenhuma implementação com base apenas no nome/ícone. Guilda e ranking ficam fora do protótipo offline; mochila só quando houver itens; chat não é necessário.
**Lacuna:** PvP não foi comprovado nesta gravação. Não inferir PvP só porque há duas equipes no combate ou ranking na torre.

## 5. Tabela de tradução e decisão

`Fazer` significa candidato recomendado para a próxima expansão, ainda sujeito à aprovação. `Confirma` indica alinhamento com a versão atual documentada. `Pós-MVP` indica adiar/evitar, não promessa de entrega. As três colunas podem ser preenchidas quando um sistema tem partes diferentes.

| Sistema | Fazer — proposta | Confirma — já no projeto | Pós-MVP / evitar agora |
|---|---|---|---|
| Perfil/títulos | — | Resumo de caçador | Títulos cosméticos/rank visível |
| Hub/cidade | — | Navegação compacta e red dots úteis | Base visual quando houver conteúdo |
| Treino/arma/espírito | Diferenciar habilidades | Melhoria de unidades | Afinidade/presentes separados |
| Relíquias/coleção | — | Desbloqueio por avanço | Bestiário e relíquias |
| Eventos por tarefas | Objetivos permanentes | Red dots de ações reais | Calendário e evento temporário |
| Recrutamento | Extração em marco narrativo | Sombras liberadas por portal | Gacha, banners e duplicatas |
| Desejo/recompensa escolhida | — | — | Escolha de recurso em expedição |
| Tabuleiro | — | — | Expedição por nós, não dado obrigatório |
| Roleta de recursos | — | Ouro e XP existentes | Não adicionar roleta agora |
| Cartas/minijogo | — | — | Baixa prioridade |
| Cartões/passes | Marcos gratuitos no Sistema | Progressão por portais | Não implementar pagamento/VIP |
| Formação | Funções táticas claras | Jinwoo + até três sombras | Afinidades complexas |
| Combate/habilidades | Habilidade por unidade | Combate, vida, efeitos e aceleração | Status/RNG complexos depois |
| Catálogo de heróis | — | Tela Sombras | Mais elenco/filtros quando necessário |
| Equipamentos | Dois slots de Jinwoo | Atributos centralizados | Inventário, conjuntos e substats extensos |
| Avanço/despertar | — | Níveis e melhorias | Promoção de rank após playtest |
| Recompensas/anúncios | — | Feedback de recompensa | Sem anúncios/multiplicadores pagos |
| Campanha/AFK/auto | Clareza da continuidade e resumo | AFK, baús, auto-farm, varredura | Navegar com farm desacoplado exige design |
| Torre/provação | Provação offline | Reutilizar combate | Ranking, loja e quota diária |
| Loja/fragmentos | — | — | Só após economia de itens definida |
| Correio | — | Resgates já existem em baús | Painel unificado se necessário |
| Missões/conquistas | Objetivos com `Ir para` e crédito único | Aproveitar progressão existente | Calendário semanal obrigatório |
| Exploração narrativa | — | Cartões e chefes narrativos | Missões por nós e extração |
| Atalhos sociais | — | Offline-first | Guilda/chat/online fora desta rodada |

## 6. Sequência de expansão recomendada — não aprovada

### Bloco A — fazer a equipe importar

**Conteúdo:** uma habilidade própria por unidade atual, comportamento determinístico e efeitos legíveis. Não alterar de uma vez limite de equipe, raridades e equipamentos.
**Aceitação proposta:** mesma entrada gera mesmo resultado; efeito realmente distingue a unidade; morte/alvo/recarga corretos; x1/x2 não altera cálculo; auto-farm usa as mesmas regras; save existente é preservado.
**Risco:** proteção/ataque à retaguarda podem invalidar o alvo fixo do MVP. A mudança precisa ser explícita, centralizada e testada.

### Bloco B — orientar e recompensar o progresso

**Conteúdo:** pequeno painel de objetivos/conquistas do Sistema; botão para a ação, status claro e resgate único. Preferir marcos permanentes antes de missões diárias.
**Aceitação proposta:** objetivo acompanha progresso real; resgate não repete após reinício; botão leva à tela certa; não cria nova moeda; não exige horário de login.
**Risco:** somar prêmios sem recalibrar campanha/AFK acelera demais a evolução.

### Bloco C — equipamento enxuto

**Conteúdo:** arma e armadura do protagonista; origem em chefes/conquistas; comparação e troca; bônus estáticos inicialmente.
**Aceitação proposta:** item equipado altera combate e ficha de forma consistente; remover/recolocar não acumula bônus; itens persistem; save v2 migra sem apagar unidades/recursos; melhoria existente continua válida.
**Risco:** equipamento não pode virar outro requisito obrigatório de grind antes de ter escolhas interessantes.

### Bloco D — Provação do Sistema

**Conteúdo:** pequena sequência de andares independente da campanha, utilizando o mesmo motor. Combinações inimigas que valorizem habilidades e formação; prêmio de primeira vitória.
**Aceitação proposta:** progressão separada; desbloqueio válido; recompensa idempotente; derrota não avança; o modo não depende de internet; voltar à campanha preserva o estado.
**Risco:** repetir campanha apenas com outro nome. Os encontros precisam mudar a decisão de equipe.

### Depois — extração e exploração

Expandir as sombras e criar pequenas expedições narrativas quando habilidades, recompensas e equipamento estiverem testados. Coleção deve ser uma consequência de vencer/desenvolver conteúdo, não um banner obrigatório.

## 7. Cuidados de integração

- Antes de codificar, aprovar um bloco e adicionar seu contrato à especificação; esta referência não substitui essa aprovação.
- Atualizar `CombatService` para novas regras; não colocar habilidades em scripts de animação.
- Guardar definições de habilidades/itens/desafios em dados; custos, cooldowns e recompensas são parâmetros de balanceamento **a definir**, não números retirados do vídeo.
- Se novos campos forem persistidos, migrar schema e testar saves existentes. Não resetar o progresso de Filipe.
- Recompensas de missão, chefe e primeira vitória devem identificar origem/resgate; crédito e save precisam impedir duplicação.
- Não criar um backend para imitar funções sociais. Não mudar offline-first sem decisão separada.
- O handoff registra ausência de áudio/haptics reais. Isso é oportunidade de gamefeel já conhecida, não uma conclusão sobre o áudio deste vídeo.
- Não comparar o protótipo por quantidade de telas: avaliar se o jogador entende por que ficou mais forte e o que quer tentar em seguida.

## 8. O que NÃO levar

Não copiar arte, sprites, efeitos, trilha, vozes, textos, logos, código ou tabelas do Bleach. Utilizar padrões de interação e progressão para criar conteúdo próprio. O projeto continua privado; esta análise não concede direitos de publicação de Bleach nem de Solo Leveling.

Não reproduzir a arquitetura de retenção paga: VIP, banners premium, tarefas de recarga, passes pagos, excesso de moedas, múltiplas lojas, quotas artificiais, urgência e dezenas de alertas promocionais. Também não presumir que números visíveis de uma conta avançada sejam balanceamento adequado para nosso início de jogo.

## 9. Lacunas e grau de cobertura

- O vídeo mostra muitas funções, mas não demonstra todas as regras do jogo. O inventário cobre sistemas visualmente identificáveis, não é documentação completa do produto Bleach.
- Amostragem pode perder popups/ações breves. Títulos parciais não foram completados por adivinhação.
- Sem fórmulas de dano, probabilidades, loot tables, tempos de recarga, economia completa ou algoritmo de equipar rápido.
- Sem prova de PvP, funcionamento de guilda, chat, ranking, eventos não abertos ou sincronização.
- Sem prova de batalha quando o aplicativo está fechado e sem medição de limites/taxas AFK.
- Regras de despertar, renascimento, arte espiritual, coleção e exploração permanecem parciais.
- Estado atual do Gatebreakers foi lido na documentação e em pontos do código, não revalidado em Android nesta tarefa. Os resultados de testes registrados no handoff são históricos, não execuções novas.

**Conclusão:** não falta ao Gatebreakers uma cópia da cidade cheia de ícones. Falta agora aprofundar decisões do combate e oferecer metas claras; depois, diversificar progressão e desafios sem perder a simplicidade do protótipo.
