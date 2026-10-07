# Gatebreakers — Product Specification and Development Plan

**Status:** Draft v0.1 — revisão do proprietário pendente antes da execução por agentes  
**Destino deste build:** protótipo privado de fã/estudo, sem publicação ou monetização  
**Fonte de verdade:** este documento  
**Título:** Gatebreakers é um nome de trabalho; disponibilidade de marca não foi verificada.

> **Instrução para agentes de codificação:** implementar apenas o escopo MVP e os critérios deste documento. Não ampliar o produto com recursos “óbvios” sem aprovação de Filipe. A stack Godot é a recomendação técnica para este rascunho, ainda sujeita à confirmação do proprietário. Não iniciar implementação pública, publicação ou distribuição.

## 1. Resumo executivo

Gatebreakers é um RPG idle single-player para Android, em orientação vertical, inspirado no ciclo de progressão de jogos idle/RPG e ambientado, neste protótipo privado, no universo de *Solo Leveling*. O jogador acompanha Sung Jinwoo, fortalece suas unidades e progride por portais. O combate é automático; as decisões principais do jogador são melhorar a equipe, escolher a formação e decidir quando tentar o próximo portal.

A experiência combina duas referências observadas nos vídeos enviados:

- De *Pocket Monster League*: recompensas AFK apresentadas claramente ao retornar, combate automático/rápido e progressão contínua.
- Do jogo de Bleach: portais/instâncias, chefes, resultados de combate e potencial para varredura de conteúdo já concluído.

A proposta deliberadamente começa menor que os jogos de referência. O MVP valida um único ciclo: **abrir o jogo → receber relatório AFK → melhorar a equipe → combater um portal → desbloquear o próximo**.

### Decisões e pressupostos desta versão

- Android primeiro; orientação vertical.
- Godot 4.x + GDScript como stack recomendada.
- Single-player, offline-first e sem conta/servidor no MVP.
- Protótipo pessoal e privado. Não publicar, monetizar ou distribuir a terceiros.
- Usar arte temporária original ou formas simples. Não extrair arte, áudio, modelos ou outros recursos dos animes ou dos jogos de referência.
- Uma fatia curta do universo de *Solo Leveling*, não uma adaptação completa do anime.

## 2. Problema, público e proposta de valor

### Público inicial — hipótese

Fãs de fantasia de caçadores/portais e jogadores que gostam de RPGs idle de sessões curtas, coleta de recursos, evolução de equipe e batalhas automáticas.

### Necessidade atendida

O jogador quer sentir progresso mesmo em sessões breves: deixar a equipe avançando, voltar depois, entender o que ganhou e tomar uma decisão interessante de evolução ou de avanço.

### Promessa do produto

> “Seus caçadores continuam progredindo entre sessões; cada retorno mostra o resultado e oferece uma escolha clara para fortalecer a equipe ou enfrentar um portal mais difícil.”

### Diferenciação pretendida

- A fantasia de evolução do protagonista e de construção de uma tropa de sombras.
- Recompensas offline transparentes, ligadas ao melhor portal concluído.
- Uma interface enxuta, sem reproduzir a quantidade de menus e moedas dos jogos de referência.

## 3. Objetivos, não objetivos e sucesso

### Objetivos do MVP

1. Entregar uma build Android instalável para teste pessoal.
2. Implementar um combate automático compreensível e reproduzível.
3. Salvar o progresso localmente e recuperá-lo após fechar/reabrir o app.
4. Conceder recompensas AFK limitadas e explicadas ao retornar.
5. Permitir gastar recursos em melhorias que afetem o resultado de combate.
6. Permitir avançar por uma sequência pequena de portais com um chefe de marco.

### Não objetivos do MVP

- Publicação na Play Store ou distribuição pública.
- Monetização, anúncios, compras no app ou moeda premium.
- Login, multiplayer, PvP, guildas, leilão, chat, leaderboard ou sincronização na nuvem.
- Gacha, banners de convocação ou probabilidades pagas.
- Reprodução completa de temporadas/arcos do anime.
- Gráficos 3D, mundo explorável ou cutscenes animadas.
- Equilibrar dezenas de personagens, equipamentos, raridades ou eventos.

### Critérios de sucesso do protótipo

- Um usuário novo consegue iniciar, entender o objetivo, lutar e concluir o primeiro portal sem tutorial externo.
- O progresso permanece após encerrar e reabrir o app.
- Uma ausência simulada de duas horas gera um relatório e uma quantidade consistente de recompensas; a ausência maior que o limite não excede o teto definido.
- Melhorar uma unidade altera de forma observável o resultado de combate.
- O MVP roda em aparelho Android real, sem conexão de rede, sem travamentos bloqueadores e sem manter processo de batalha ativo em segundo plano.

## 4. Escopo funcional do MVP

### Conteúdo jogável

- Protagonista: Sung Jinwoo.
- Equipe inicial: Jinwoo nível 1 e um Shadow Soldier genérico nível 1. Vencer o portal 2 desbloqueia um Shadow Soldier de longo alcance; vencer o portal 4 desbloqueia um Shadow Soldier guardião; vencer o chefe do portal 5 desbloqueia Igris. Jinwoo mais no máximo três sombras podem entrar na formação.
- Dez portais de teste, cada um com três ondas; o portal 5 e o portal 10 encerram com um chefe. A duração e os valores de balanceamento ficam configuráveis, não codificados nas telas.
- Três cartões narrativos curtos: introdução ao Sistema; primeiro avanço importante; aquisição/desbloqueio da tropa de sombras. O texto deve ser original e resumido, sem copiar falas do anime.

### Ciclo principal

1. Na abertura, calcular e creditar o relatório AFK pendente.
2. Mostrar o portal atual e o estado da equipe.
3. O jogador melhora níveis/unidades ou ajusta a formação.
4. O jogador inicia o combate automático do portal.
5. Vitória concede recursos e desbloqueia o próximo portal; derrota permite melhorar e tentar de novo.
6. O jogador fecha o app. O jogo registra o horário e calcula a próxima ausência na abertura seguinte.

### Combate

- Combate automático por turnos, sem comandos necessários durante a batalha.
- Equipe do jogador: Jinwoo mais até três sombras. A formação e a ordem das unidades devem ser exibidas antes do início.
- Cada unidade tem, no mínimo: `id`, nome exibido, função, nível, HP, ataque, defesa, velocidade e estado de desbloqueio.
- A ordem de ação é da maior para a menor velocidade; empates são desfeitos pela posição na formação.
- Para a primeira versão, usar ataques determinísticos, sem acerto crítico, esquiva, efeitos aleatórios ou cálculo online.
- Dano básico: `max(1, ataque_atacante - floor(defesa_alvo / 2))`.
- Alvo inicial: primeiro inimigo vivo na ordem da formação. Essa regra deve ser documentada e testável.
- Cada unidade faz um ataque básico por rodada. Habilidades especiais, energia, efeitos de status e seleção manual de alvo ficam fora do MVP.
- Condição de vitória: todos os inimigos derrotados. Condição de derrota: todas as unidades aliadas derrotadas.
- Cada portal contém três ondas. A tela exibe onda atual, barras de vida, velocidade `x1`/`x2`, pausa e opção de sair. Não permitir saída que conceda recompensa de vitória.
- A aceleração altera apenas a apresentação/tempo da batalha, nunca os resultados determinísticos.
- Batalhas são simuladas somente enquanto o app está em primeiro plano; o sistema AFK é calculado separadamente.

### Progressão e recursos

- `hunter_xp`: experiência recebida em batalhas e no relatório AFK; aumenta o nível de Jinwoo.
- `gold`: recurso comum para melhorias de nível.
- `shadow_essence`: recurso ganho em marcos/chefes, usado para desbloquear ou melhorar sombras.
- Não existe moeda paga no MVP.
- Estado inicial de teste: Jinwoo nível 1, um Shadow Soldier genérico nível 1, Gate 1 disponível, `gold = 100`, `hunter_xp = 0` e `shadow_essence = 0`.
- Limite de nível do protótipo: 20. XP necessário para o próximo nível de Jinwoo: `100 * nível_atual`. Custo em gold para subir um nível: `25 * nível_atual`.
- Ao subir de nível, recalcular atributos a partir da definição base: HP `base_hp * (1 + 0.10 * (nível - 1))`, ataque `base_attack * (1 + 0.08 * (nível - 1))` e defesa `base_defense * (1 + 0.05 * (nível - 1))`, arredondando para baixo.
- As sombras usam as mesmas fórmulas de atributos, mas não consomem `hunter_xp`; cada nível exige `gold = 25 * nível_atual` e `shadow_essence = 5 * nível_atual`. Se algum recurso for insuficiente, bloquear a melhoria e mostrar a quantidade faltante.
- Valores iniciais de balanceamento — sementes de teste, centralizadas em `BalanceConfig` e ajustáveis após playtest: Jinwoo nível 1 `HP=100, ATK=20, DEF=6, SPD=10`; Shadow Soldier nível 1 `HP=80, ATK=15, DEF=8, SPD=8`.
- Para portal `n` (1 a 10), inimigo comum: `HP=60+20*(n-1)`, `ATK=10+2*(n-1)`, `DEF=2+n`, `SPD=7+floor((n-1)/3)`. Cada onda comum contém dois inimigos. O último combate dos portais 5 e 10 é um chefe único com `HP=4x`, `ATK=1.5x` e `DEF=1.2x` do inimigo comum do portal.
- Recompensa ao concluir um portal: `gold=10*n` e `hunter_xp=5*n` por inimigo derrotado naquele portal; derrota não concede essas recompensas. O chefe dos portais 5 e 10 também concede `50 shadow_essence`; vencer o chefe do portal 5 desbloqueia Igris automaticamente, sem custo adicional.
- Taxas AFK iniciais: `gold_per_hour=10*n` e `hunter_xp_per_hour=5*n`, usando o maior portal concluído. Shadow essence não é concedida AFK.
- Esses números são valores funcionais de partida, não balanceamento final. Nenhuma tela ou script pode duplicá-los: editar apenas `BalanceConfig`/dados de portal.
- Fórmulas de custo e crescimento ficam em um recurso/configuração de balanceamento central. Evitar valores duplicados em scripts de UI.
- A tela de melhoria mostra nível atual, custo, nível/atributos previstos e botão de confirmação.
- Equipamentos, raridades, conjuntos e inventário complexo ficam fora do MVP. Estruturar dados para permitir expansão posterior, mas não criar telas vazias desses sistemas.

### Recompensas AFK

- Não executar uma simulação contínua quando o app estiver fechado. Calcular a diferença de tempo ao abrir.
- Limite inicial do protótipo: **8 horas** acumuláveis. Tratar este número como parâmetro de balanceamento central.
- Fórmula: `elapsed = clamp(now_unix - last_background_unix, 0, 28800)`.
- Taxas de gold e XP são definidas pelo melhor portal concluído e armazenadas em dados de portal/configuração.
- Recompensa: `floor(rate_per_hour * elapsed / 3600)` para cada recurso aplicável.
- Primeiro início: inicializar `last_background_unix` sem conceder recompensa retroativa.
- Ao abrir/retomar o app, calcular `elapsed = clamp(now_unix - last_background_unix, 0, 28800)`, creditar uma única vez, salvar o estado e então mostrar o relatório. Se `last_background_unix` estiver ausente, inicializá-lo com o horário atual e conceder zero.
- Ao enviar o app para segundo plano, salvar `last_background_unix = now_unix`. Nenhuma simulação ou timer de batalha continua rodando enquanto o app está em segundo plano.
- Se o processo for encerrado abruptamente sem receber o evento de segundo plano, a próxima abertura pode contar tempo ativo desde o último horário salvo; isso é uma limitação aceita do protótipo local e continua sujeito ao teto de oito horas.
- Se o relógio do aparelho estiver atrasado em relação ao último registro, conceder zero, atualizar o horário salvo para o atual e não produzir valores negativos.
- Sem opção de dobrar recompensa por anúncio, pagamento ou moeda premium.
- Fraude pelo ajuste manual do relógio é um risco aceito no protótipo privado offline; não adicionar soluções de servidor nesta fase.

### Varredura

- Disponível somente para portais já concluídos.
- Resolve instantaneamente uma repetição e concede a recompensa normal de conclusão definida para aquele portal.
- Não concede desbloqueio novo nem recompensa de chefe que ainda não foi vencido.
- Uma repetição não pode ser usada para contornar requisitos de progressão.

## 5. Jornada e telas

### Navegação principal

Manter no máximo quatro destinos principais: **Portais**, **Caçador**, **Sombras** e **Sistema/Configurações**. Mochila completa, guilda, loja, PvP e eventos ficam fora do MVP.

### Telas obrigatórias

1. **Portais / início:** perfil resumido, nível, recursos, melhor portal, caminho visual com portais bloqueados/desbloqueados e botão para enfrentar o portal atual.
2. **Relatório AFK:** tempo computado, limite aplicado se necessário, recompensas detalhadas e botão “Continuar”.
3. **Preparação do portal:** inimigos/chefe, equipe atual, formação, recompensas de primeira vitória e botão para começar.
4. **Combate:** onda, unidades, vida, ordem/feedback de ações, velocidade, pausa e saída sem vitória.
5. **Resultado:** vitória/derrota, recursos ganhos, portal desbloqueado ou botão para tentar novamente.
6. **Caçador:** nível/XP/atributos de Jinwoo e melhoria disponível.
7. **Sombras:** unidades desbloqueadas, níveis, formação e melhoria usando shadow essence.
8. **Configurações:** som, vibração, versão do jogo e reset local somente em build de desenvolvimento com confirmação explícita.

### Direção visual e UX

- Retrato; base de composição 9:16, adaptável a proporções mais altas e áreas seguras/notch.
- Estética escura de portal, com alto contraste e acentos roxo/ciano. Essa é uma direção proposta, não cópia de telas de *Solo Leveling* ou dos jogos analisados.
- Usar placeholders originais simples para arte durante o MVP; todas as imagens devem caber nos slots e ser trocáveis sem mexer na lógica.
- Botões grandes para uso com uma mão; texto legível em telas pequenas; estados de bloqueio, carregamento, vitória, derrota, ausência de recompensas e relógio inválido claramente comunicados.
- Idioma inicial: português do Brasil. Manter textos em recursos de localização, sem strings de interface espalhadas pelo código.

## 6. Arquitetura e especificações técnicas

### Stack proposta

- Godot 4.x, versão estável fixada quando o repositório for criado.
- GDScript tipado quando útil, com funções curtas e responsabilidades separadas.
- Projeto Android portrait, renderização 2D.
- Sem plugins externos no MVP, salvo aprovação do proprietário e justificativa técnica.
- Sem backend ou APIs externas.

### Separação de responsabilidades

- **UI/Scenes:** desenhar estado e encaminhar ações do usuário; não calcular recompensas nem regras de combate.
- **GameState:** estado principal da sessão, unidades, recursos, formação e progresso.
- **CombatService:** resolução determinística de ondas/combates, sem depender de nós visuais.
- **IdleRewardService:** cálculo puro das recompensas a partir do horário, limite e taxas.
- **SaveService:** carregar, validar, migrar e persistir estado local.
- **Content resources:** unidades, inimigos, portais, taxas e custos em dados editáveis separados do código.

### Estrutura de projeto recomendada

```text
res://
  scenes/
    app/main.tscn
    ui/portal_map.tscn
    ui/afk_report.tscn
    ui/gate_prep.tscn
    battle/battle.tscn
    battle/battle_result.tscn
    hunter/hunter_screen.tscn
    shadows/shadows_screen.tscn
    settings/settings.tscn
  scripts/
    autoload/game_state.gd
    systems/combat_service.gd
    systems/idle_reward_service.gd
    systems/save_service.gd
    ui/navigation_controller.gd
  data/
    units/
    enemies/
    gates/
    balance/
    localization/
  assets/
    placeholders/
  tests/
    runner.tscn
    test_idle_rewards.gd
    test_combat_service.gd
    test_save_service.gd
```

A estrutura é proposta; agentes podem ajustar nomes internos se preservarem a separação e os contratos descritos.

### Persistência local

- Estado em `user://save_v1.json`, não dentro da pasta do projeto.
- Incluir `schema_version`, `hunter_xp`, `gold`, `shadow_essence`, roster com níveis/desbloqueios, formação, `highest_gate_cleared` e `last_background_unix`. O nível de Jinwoo é derivado do total de XP.
- Validar tipos, valores negativos, campos ausentes e versões desconhecidas ao carregar.
- Gravar em arquivo temporário e substituir o save anterior somente após serialização válida.
- Save corrompido: não travar; preservar/copiá-lo como backup de diagnóstico, inicializar save novo e mostrar aviso compreensível.
- Não salvar credenciais, identificadores de conta, dados pessoais ou tokens.

### Requisitos de dispositivo e desempenho

- Meta inicial de teste: Android 10 ou superior, aparelho de referência com aproximadamente 4 GB de RAM. Rever após testar nos aparelhos disponíveis.
- Meta de desempenho: 30 FPS estáveis durante combate e navegação no aparelho de referência; animações podem chegar a 60 FPS quando disponíveis.
- Carregamento rápido; texturas comprimidas; limitar partículas e efeitos simultâneos.
- Não manter serviço, timer de combate ou loop de renderização ativo em segundo plano para calcular AFK.
- APK de debug instalável por sideload para os testes privados. Não configurar Play Store/AAB de publicação nesta fase.

## 7. Dados, regras e casos extremos

### Entidades mínimas

- `PlayerState`: `hunter_xp`, `gold`, `shadow_essence`, roster, formation, `last_background_unix` e `highest_gate_cleared`. O nível de Jinwoo é calculado a partir do `hunter_xp`.
- `UnitDefinition`: atributos base, função e referência a placeholder de arte.
- `UnitState`: id da definição, nível e estado de desbloqueio.
- `GateDefinition`: inimigos por onda, taxa de AFK, recompensas de vitória, condição de chefe.
- `BattleResult`: estado, portal/onda, recursos concedidos e unidades sobreviventes.
- `BalanceConfig`: limite AFK, taxas, custos e constantes de combate.

### Casos que precisam ser tratados

- Primeira execução sem arquivo de save.
- Save incompleto, inválido ou de versão anterior.
- Hora atual igual, anterior ou muito posterior ao último horário gravado.
- Mais de oito horas offline.
- App fechado durante ou logo após uma batalha.
- Toque duplo em “Começar”, “Melhorar” ou “Continuar”.
- Tentativa de varrer portal não concluído.
- Unidade derrotada, equipe inteira derrotada e inimigo derrotado na mesma atualização.
- Tela em aparelhos com proporções diferentes, recorte/notch e tamanho de fonte ampliado.

## 8. Segurança, IP e privacidade

- Este build é privado e não comercial. Não enviar para lojas, redes sociais ou grupos públicos.
- Não baixar nem embutir arte, música, voz, vídeo, sprites ou modelos extraídos do anime ou dos jogos de referência.
- Placeholders e texto de interface devem ser originais. Nomes/personagens de *Solo Leveling* podem servir à experiência privada conforme a decisão atual, mas qualquer distribuição pública exige obter autorização/licença ou substituir integralmente o conteúdo por propriedade intelectual original.
- Não copiar código, assets, layouts pixel a pixel, textos ou tabelas de balanceamento dos jogos analisados; usar somente princípios gerais de design.
- Sem telemetria, analytics, anúncios, permissões desnecessárias ou coleta de dados no MVP.

## 9. Plano de desenvolvimento por fases

### Fase 0 — Base técnica e build Android

**Resultado:** projeto Godot abre, executa uma cena vazia em retrato e exporta um APK de debug para aparelho de teste.  
**Conclusão:** importação limpa, orientação correta, safe areas verificadas e instalação confirmada.

### Fase 1 — Modelo de estado, save e navegação

**Resultado:** telas vazias funcionais e estado local com perfil, recursos e portal.  
**Conclusão:** criar save, fechar/reabrir e recuperar estado sem regressão; navegação não duplica telas.

### Fase 2 — Combate e progressão de portais

**Resultado:** combate determinístico de três ondas, resultado e desbloqueio do próximo portal.  
**Conclusão:** testes de vitória, derrota, empate de velocidade, alvo, dano e bloqueio de progressão passam.

### Fase 3 — Recompensas AFK

**Resultado:** cálculo ao reabrir, crédito único e relatório visual.  
**Conclusão:** testes para zero tempo, duas horas, limite de oito horas, relógio retrocedido e reinício após crédito passam.

### Fase 4 — Melhorias e sombras

**Resultado:** melhorias alteram atributos e combate; equipe editável dentro do limite.  
**Conclusão:** custo é descontado uma vez, atributos atualizados persistem e unidades bloqueadas não entram na formação.

### Fase 5 — Arte temporária, acessibilidade e validação Android

**Resultado:** fluxo completo navegável e legível em um aparelho real.  
**Conclusão:** sessão curta de teste identifica o próximo bloqueio sem crash; desempenho dentro da meta; app funcional em modo avião.

### Fora das fases do MVP

Conta, nuvem, multiplayer, PvP, guilda, gacha, publicidade, compras, temporadas, leilões, eventos diários e publicação ficam em backlog, sem implementação até decisão separada.

## 10. Critérios de aceitação do MVP

1. O app instala e abre em Android 10+ no aparelho de teste, em orientação vertical.
2. Um save novo cria estado válido e apresenta Jinwoo, recursos iniciais e primeiro portal.
3. Uma vitória conclui uma onda/portal, credita recompensa uma única vez e desbloqueia progressão conforme regra.
4. Uma derrota não concede recompensa de vitória nem desbloqueia o próximo portal.
5. O combate usa a mesma entrada e estado inicial para produzir o mesmo resultado; a velocidade visual não altera cálculos.
6. Melhorias consomem o custo uma única vez, atualizam atributos e persistem após reinício.
7. Ao reabrir, ausência de duas horas concede a recompensa calculada; ausência acima de oito horas fica limitada ao teto.
8. Reabrir repetidamente sem passagem adicional de tempo não concede recompensa duplicada.
9. Relatório AFK informa tempo contado, limite aplicado quando houver, quantidades e portal/taxa utilizados.
10. Relógio retrocedido não gera XP/ouro negativo nem recompensa adicional; o app se recupera sem crash.
11. A varredura não pode ser usada em portal ainda não concluído.
12. Nenhuma função principal depende de internet; funcionamento confirmado em modo avião.
13. O save não contém dados pessoais nem credenciais; não há permissões de rede/localização não justificadas.
14. As telas principais permanecem utilizáveis em proporções 9:16 e 20:9, incluindo áreas seguras.
15. O agente entrega instruções para abrir/exportar o projeto, testes executados e limitações conhecidas; não declara fase concluída sem saída real dos testes.

## 11. Riscos, pressupostos e validação

### Pressupostos

- O primeiro objetivo é ter uma demonstração privada, não um produto comercial.
- O aspecto mais importante a provar é a satisfação do ciclo idle, não a quantidade de conteúdo.
- Uma interface 2D vertical é suficiente para avaliar a experiência inicial.
- Godot 4.x é a stack proposta, ainda esperando confirmação expressa.

### Riscos

- O escopo pode crescer para dezenas de personagens, telas, moedas e eventos antes de o combate ser divertido.
- Recompensas offline podem parecer irrelevantes ou excessivas; as taxas precisam de teste.
- A hora local é manipulável; aceitável para protótipo, inadequada para competição/economia monetizada.
- A propriedade intelectual de *Solo Leveling* impede presumir publicação livre.
- Assets temporários podem não representar o apelo visual final; a fatia valida loop e usabilidade, não qualidade de arte.

### Experimentos de validação

1. Testar se o jogador entende o relatório AFK sem explicação.
2. Comparar o desejo de voltar ao jogo após recompensas de 30 min, 2 h e 8 h simuladas.
3. Verificar se melhorar uma unidade produz diferença perceptível sem planilha de balanceamento externa.
4. Observar se o jogador consegue escolher o próximo portal e entender por que venceu/perdeu.

## 12. Handoff para agentes de codificação

- Tratar este documento como a única fonte de requisitos do MVP; quando houver conflito entre uma sugestão de agente e este documento, prevalece este documento até Filipe aprovar mudança.
- Antes de codificar, verificar a instalação/exportação do Godot e relatar qualquer dependência ausente; não instalar plugins ou SDKs não aprovados.
- Trabalhar em fases, com mudanças pequenas, testes e evidência real de execução.
- Separar regras de combate, cálculo AFK, estado/save e interface; não colocar lógica econômica em scripts de tela.
- Usar dados de teste/placeholders; não buscar assets protegidos em sites ou repositórios.
- Não implementar monetização, networking, autenticação, publicação ou funcionalidades fora do MVP.
- Cada entrega ao proprietário deve conter: resumo da mudança, arquivos tocados, comando/testes executados, resultado real, limitações e próximo passo.
- Nenhum agente pode marcar tarefa concluída apenas por gerar código; precisa executar e verificar os critérios de aceitação relevantes.

## 13. Aprovação necessária antes da implementação

O proprietário confirmou que este primeiro build é um protótipo privado de fã/estudo, sem publicação por enquanto. Ainda é necessário aprovar explicitamente, antes do handoff final, a direção técnica **Godot 4.x + GDScript** e o escopo proposto: Android vertical, 2D, offline-first, sem serviços online ou monetização no MVP.
