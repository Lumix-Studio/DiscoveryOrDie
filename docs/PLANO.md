# Discovery or Die (DoD) — Plano de Desenvolvimento

> Fonte: `Discovery or Die (DoD) — GDD.docx` (original nesta pasta; texto extraído em `gdd-extracted.txt`).

## Visão

Visual novel de detetive. O jogador controla **Bohr Holmes**, detetive particular famoso. O Capítulo 1 (demonstrativo) se passa numa floresta: Bohr e o companheiro **Jhon Poly** investigam o sequestro de **Lorain**. O jogo terá **várias rotas** (formas de ganhar e de perder). Foco atual: sistemas principais funcionando com aparência boa o suficiente para o público.

## Personagens

| Personagem | Papel |
|---|---|
| Bohr Holmes | Protagonista (jogador) |
| Jhon Poly | Amigo/companheiro de investigação |
| Estevan | Chefe da vila |
| Lorain | Garota sequestrada |

O GDD cita 8 personagens no capítulo; 4 estão definidos. Para o demo funcionar com rotas, foram adicionados provisoriamente: **Rurik** (caçador, culpado do demo) e **Ana** (moradora/testemunha). Trocar/expandir quando o roteiro oficial chegar.

## Decisões técnicas

- **Stack: Godot 4.6 (GDScript), renderer GL Compatibility.** A primeira versão foi feita em web vanilla pra validar os sistemas rapidamente; portada pra Godot por decisão do time (histórico no git, commit `2132f40`).
- **Dados dirigem o jogo**: roteiro é um grafo de nós em `data/script.json`; sistemas (tarefas, pesquisa, fotos) são acionados por `actions` nos nós.
- **Save**: JSON em `user://dod-save.json`, 1 slot.
- **Arte**: placeholders SVG (importados como textura pelo Godot) até as UIs/artes finais do GDD chegarem.

## Arquitetura

```
project.godot            — projeto (1920x1080, autoload Game, inputs D/Esc)
data/script.json         — roteiro do Capítulo 1 (grafo de 59 nós)
scripts/Game.gd          — autoload: estado, save/load, run_action, check, sinais (CONTRATO)
scripts/Main.gd          — boot: instancia as camadas e inicia o roteiro
scenes/Main.tscn         — cena principal
scenes/VNLayer.tscn      — núcleo VN: diálogo, cenas, personagens, escolhas, finais
scripts/vn/              — scripts do núcleo VN
scenes/InvestLayer.tscn  — sistemas de investigação (Brunelli)
scripts/invest/          — HUD, painéis, TASKs, pesquisa, minigame de fotos, dev
assets/                  — SVGs placeholder (fundos, personagens, fotos)
```

Contrato entre módulos: autoload `Game` (documentado em `scripts/Game.gd`) — toda mutação de estado passa por ele e emite sinais; as camadas só reagem a sinais e leem `Game.state`. Roteiro chama sistemas via `actions`; rotas são bloqueadas/liberadas por condições (`if`) sobre evidências, flags e tarefas.

## Divisão de trabalho (do GDD)

| Quem | Responsabilidade | Módulos |
|---|---|---|
| **Brunelli (Prog. 1)** | Minigames de investigação (análise de fotos, pesquisa, TASKs) e interface funcional | `ui.js`, `tasks.js`, `research.js`, `photo.js`, `invest.css` |
| **Darlyson (Prog. 2)** | Diálogos, troca de personagens, ambientação, resposta/leitura | `vn.js`, `script-data.js`, `vn.css` |
| **Veilcrus** | Auxilia os dois | — |

Detalhe dos sistemas do Brunelli: ver `BRUNELLI-SISTEMAS.md`.

## Caso do Capítulo 1 (esboço para o demo)

Lorain desapareceu na vila da floresta. Estevan chama Bohr. Investigação:

1. Chegada à vila → conversa com Estevan → **tarefas** iniciais.
2. Clareira: **foto da cena** → minigame de análise (pegadas duplas, tecido rasgado, colar de Lorain).
3. **Pesquisa**: termos descobertos nas pistas ("cabana abandonada", "Rurik", "trilha norte") desbloqueiam leads.
4. Conversas com Ana/moradores abrem ramificações.
5. Confronto final:
   - **Vitória**: com evidências suficientes, acusar Rurik e escolher a abordagem certa → resgata Lorain.
   - **Derrotas**: acusar inocente (Estevan), ir à cabana sem provas/preparo, ou esgotar caminhos errados → game over ("or Die").

## Etapas

| Etapa | Escopo | Status |
|---|---|---|
| **0 — Fundação** | Repo, stack, esqueleto/contrato, docs | ✅ feita |
| **1 — Núcleo VN** | Diálogo, personagens, cenas, escolhas, finais, roteiro demo | ✅ 1ª versão |
| **2 — Sistemas de investigação** | Interface, TASKs, pesquisa, análise de fotos, modo dev | ✅ 1ª versão (foco do Brunelli) |
| **3 — Conteúdo do Capítulo 1** | Roteiro completo com as 8 personagens, rotas oficiais do GDD | ⬜ aguarda lista de TASKs/roteiro do GDD |
| **4 — Arte & som** | Substituir placeholders pelas UIs/artes finais, música/SFX | ⬜ |
| **5 — Polimento & distribuição** | Ajustes de UX, save múltiplo, build desktop/web pública | ⬜ |

## Como rodar / testar

Abrir a pasta do projeto no **Godot 4.6** e rodar (F5), ou pela linha de comando:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path DiscoveryOrDie
```

Modo dev (testar sistemas do Brunelli sem jogar a história): tecla **D** ou botão 🛠 no HUD — abre painel com atalhos para cada sistema já populado com dados de exemplo. Checklist de teste em `BRUNELLI-SISTEMAS.md`.
