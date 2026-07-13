# Sistemas do Brunelli (Programador 1) — Especificação

> Do GDD: "responsável por cuidar dos sistemas de minigames que irão ter no jogo como parte da investigação como análise de fotos, sistemas de pesquisas, TASKs, Interface. O que será feito: Interface Funcional enquanto eu termino as UIs."

Todos os sistemas leem/escrevem `Game.state` e são acionáveis tanto pelo roteiro (`actions` dos nós) quanto pelo **modo dev** (tecla `D`), para teste isolado.

## 1. Interface funcional (`scripts/invest/` — HUD e painéis)

- **HUD** (barra superior): botões **Tarefas 📋**, **Pesquisa 🔎**, **Fotos 📷**, **Caderno 📓**, **Menu ☰**, **Dev 🛠**. Badges numéricos (tarefas abertas, fotos novas, evidências).
- **Painéis overlay**: um por sistema, abre por cima da cena, fecha com `Esc`/`✕`. Só um aberto por vez (um painel por vez; `Game.panel_open` sinaliza pro núcleo VN).
- **Caderno**: lista de evidências coletadas (`state.evidence`), com nome, descrição e origem.
- **Toasts**: notificações canto da tela ("Nova tarefa", "Evidência adicionada", "Pesquisa desbloqueada").
- **Menu**: salvar, carregar, reiniciar (confirmação antes de apagar save).
- **Modo dev**: painel com botões que populam dados de exemplo e abrem cada sistema direto — testável sem jogar a história.

## 2. Sistema de TASKs

- Modelo: `{ id, title, desc?, done }` em `Game.state.tasks`.
- API (autoload `Game`): `add_task(id, title, desc?)`, `complete_task(id)`, `is_task_done(id)`.
- UX: painel com abertas em cima e concluídas riscadas embaixo; toast em nova tarefa/conclusão; badge no HUD com contagem de abertas.
- O roteiro adiciona/conclui tarefas via `actions`; rotas podem exigir `taskDone` em condições `if`.

## 3. Sistema de pesquisa

Mecânica: o jogador **descobre termos** durante a investigação (pistas de foto, diálogos) e **digita no campo de busca** do painel de pesquisa — simulando pesquisar nos arquivos/registros.

- Base de termos: `{ id, aliases[], title, body, unlockedBy?, grants? }` — `grants` pode dar evidência, tarefa ou desbloquear outro termo.
- Termo **desbloqueado** (via `Game.unlock_research(id)`) aparece como sugestão clicável; termo ainda não descoberto só funciona se digitado exato (recompensa atenção do jogador).
- Busca sem resultado → resposta "nenhum registro encontrado".
- API: `Game.unlock_research(term_id)` desbloqueia; a busca é do painel de pesquisa (`scripts/invest/`).

## 4. Análise de fotos — minigame

- Viewer com **zoom** (scroll/botões) e **pan** (arrastar), imagem SVG da cena.
- **Hotspots invisíveis** (regiões clicáveis definidas por coordenadas relativas). Clique num hotspot → pista encontrada: highlight, descrição, e `grants` (evidência/termo/tarefa).
- Contador **"pistas 2/3"** por foto; foto completa fica marcada ✓ na galeria.
- Clique fora de hotspot → feedback sutil (nada encontrado).
- API: `Game.unlock_photo(photo_id)` desbloqueia; o viewer é aberto pela galeria ou pelo painel dev.
- Fotos definidas em dados no próprio módulo: `{ id, title, texture, clues: [{id, x, y, r, name, desc, grants}] }` (coordenadas no espaço 1200x800 da imagem).

## Checklist de teste manual

1. Abrir o projeto no Godot 4.6, rodar (F5), apertar **D** → painel dev abre.
2. **Tarefas**: "popular exemplo" → badge sobe, toast aparece, concluir risca item.
3. **Pesquisa**: termo desbloqueado aparece como sugestão; digitar termo secreto exato retorna resultado; termo inexistente retorna "nenhum registro".
4. **Fotos**: abrir foto, zoom/pan funcionam, achar as 3 pistas da foto da clareira → contador 3/3, evidências no caderno.
5. **Caderno**: evidências das etapas acima listadas com origem.
6. **História**: jogar do início até o fim de uma rota de vitória e uma de derrota, verificando que tarefas/fotos/pesquisa são acionadas pelo roteiro.
7. **Save**: fechar e reabrir o jogo → continua do mesmo ponto; menu → reiniciar zera.
