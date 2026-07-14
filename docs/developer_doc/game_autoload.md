# Autoload `Game`

> **Desenvolvedor:** Brunelli · **Código:** `src/autoloads/game.gd` · **Tipo:** singleton (autoload `Game`)

*Objetivo do sistema*:

Ser o **contrato único de estado** entre todos os módulos. Toda mutação de
estado do jogo (tarefas, evidências, flags, pesquisa, fotos, roteiro) passa por
aqui, que persiste em `user://dod-save.json` e **emite sinais**. As camadas de
UI (VN e Investigação) apenas reagem aos sinais e leem `Game.state` — nunca
mutam estado diretamente nem se conhecem entre si.

Carrega o roteiro de `src/config/script.json` para `Game.script_data` no `_ready()`.

### Sinais

- `toast(msg: String, type: String)` — `type`: `"info" | "success" | "warn"`.
- `state_changed` — badges/HUD devem re-renderizar.
- `task_added(task: Dictionary)` · `task_completed(task: Dictionary)`
- `evidence_added(ev: Dictionary)`
- `research_unlocked(term_id: String)` · `photo_unlocked(photo_id: String)`

### Métodos:

* **default_state() -> Dictionary**
    * **Ação:** monta o dicionário de estado zerado (node, bg, chars, flags, evidence, tasks, research, photos, found_clues).
    * **Retorno:** `Dictionary` com o estado inicial.

* **save() -> void** / **load_save() -> bool** / **reset() -> void**
    * **Ação:** persistem/recarregam/apagam o save em `user://dod-save.json`. `reset()` recomeça o jogo (`reload_current_scene`).
    * **Retorno:** `load_save` devolve `true` se havia save válido.

* **add_task(id: String, title: String, desc := "") -> void**
    - **Parâmetro:** `id` único da tarefa; `title` exibido; `desc` opcional.
    * **Ação:** adiciona a tarefa (ignora duplicata por `id`), emite `toast` + `task_added` + `state_changed`.

* **complete_task(id: String) -> void** / **is_task_done(id: String) -> bool**
    * **Ação:** marca concluída (emite `task_completed`) / consulta se concluída.

* **add_evidence(ev: Dictionary) -> void** / **has_evidence(id: String) -> bool**
    - **Parâmetro:** `ev` = `{id, name, desc, source?}`.
    * **Ação:** adiciona ao caderno (ignora duplicata), emite `evidence_added`. `has_evidence` consulta.

* **set_flag(name: String, value := true) -> void** / **has_flag(name: String) -> bool**
    * **Ação:** grava/lê flag de história. `set_flag` persiste imediatamente.

* **unlock_research(term_id: String) -> void** / **unlock_photo(photo_id: String) -> void**
    * **Ação:** libera termo de pesquisa / foto para análise; emite o sinal correspondente.

* **run_action(action: Array) -> void**
    - **Parâmetro:** `action` no formato `[tipo, ...args]`.
    * **Ação:** despacha uma ação de nó do roteiro. Tipos: `["task", id, title, desc?]`, `["taskDone", id]`, `["evidence", {…}]`, `["research", termId]`, `["photo", photoId]`, `["flag", nome, valor?]`.

* **check(cond: Variant) -> bool**
    - **Parâmetro:** `cond` = `Dictionary` de condição (ou `null` = sempre verdadeiro).
    * **Ação:** avalia gates de escolha. Chaves: `{flag}`, `{notFlag}`, `{taskDone}`, `{evidence: id | [ids]}`.
    * **Retorno:** `true` se a condição passa.

### Funcionamento interno

O estado vive em `var state: Dictionary`. Toda mutação chama o helper privado
`_changed()`, que emite `state_changed` e salva. O roteiro (`script_data`) é um
JSON com `{ "startNode": String, "nodes": { id: nó } }`, onde cada nó pode ter
`bg`, `chars`, `speaker`, `text`, `next`, `choices` (com `if` para gate) e
`actions`. `run_action`/`check` são o elo entre o roteiro (dados) e o estado.

> **Integração:** para reagir a mudanças, conecte-se aos sinais no `_ready()` do
> seu módulo. Para mutar estado, **chame os métodos do `Game`** — nunca edite
> `Game.state` na mão (quebra os sinais e o save).
