# Sistema de Investigação

> **Desenvolvedor:** Brunelli · **Código:** `src/ui/invest/`

*Objetivo do sistema*:

A camada de investigação: HUD do topo, painéis overlay (tarefas, pesquisa,
análise de fotos, caderno), menu, modo dev e toasts. Reage aos sinais do
autoload `Game` e **nunca referencia a VNLayer** — por isso funciona sozinha
(dá para testar cada sistema isolado, via o painel dev com a tecla **D**).

| Peça | Script / `class_name` | Responsabilidade |
|---|---|---|
| Camada raiz | `invest_layer.gd` / `InvestLayer` | HUD, toasts, abre/fecha painéis |
| Tarefas | `tasks_panel.gd` / `TasksPanel` | lista de TASKs + badge |
| Pesquisa | `research_panel.gd` / `ResearchPanel` | busca por termos desbloqueados |
| Fotos | `photo_viewer.gd` / `PhotoViewer` | minigame de zoom/pan + pistas escondidas |
| Utilitário | `invest_util.gd` / `Invest` | aplica os `grants` de uma pista/termo |
| Tema | `invest_theme.gd` / `InvestTheme` | paleta e estilos do tema noir |

### Métodos (API pública de `InvestLayer`):

* **open_panel(id: String, arg: String = "") -> void**
    - **Parâmetro:** `id` — `"tasks" | "research" | "photo" | "notebook"`; `arg` opcional (ex.: id da foto a abrir).
    * **Ação:** abre o painel overlay indicado e seta `Game.panel_open = true` (bloqueia o avanço da VN).

* **close_panel() -> void**
    * **Ação:** fecha o painel aberto e libera `Game.panel_open = false`.

### `Invest.apply_grants(...)` (util)

Aplica os `grants` de uma pista/termo via mutações do `Game`, **na ordem fixa**
`evidence → research → task → taskDone → flag` (idêntica à versão web). Não faz
controle de "uma vez só" — quem chama garante (ex.: `flag granted_<id>`).

### `InvestTheme` (tema)

Só helpers estáticos (sem instância): paleta noir e construtores de
`StyleBoxFlat`/`Label`. Porte das variáveis de `css/main.css` + `css/invest.css`.

### Funcionamento interno

`InvestLayer` conecta-se aos sinais do `Game` no `_ready()` (novos toasts,
`state_changed` para atualizar badges, `photo_unlocked` etc.). Os painéis são
instanciados sob demanda em `open_panel`. O HUD reflete o `Game.state`
(contagem de tarefas, evidências, fotos disponíveis).

> **Integração:** para reagir a algo da história, escute o sinal do `Game`
> correspondente. Para conceder itens ao jogador a partir de uma pista, use
> `Invest.apply_grants` (não mute o `Game.state` direto).
