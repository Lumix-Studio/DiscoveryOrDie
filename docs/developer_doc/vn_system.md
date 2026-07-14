# Sistema de Visual Novel (VN)

> **Desenvolvedor:** Darlyson (design de diálogos/cenas) · porte Godot: Brunelli · **Código:** `src/ui/vn/`

*Objetivo do sistema*:

Renderizar a narrativa: cenário, personagens em cena, caixa de diálogo com
efeito máquina de escrever, escolhas e o overlay de final. Consome
`Game.script_data` (de `src/config/script.json`) e o contrato `Game.*`. É
instanciado em runtime por `src/main.gd` via `res://src/ui/vn/vn_layer.tscn`.

`VNLayer` orquestra os módulos-filho; cada um cuida só da própria apresentação:

| Nó filho | Script | Responsabilidade |
|---|---|---|
| `SceneLayer` | `scene_background.gd` | carrega o fundo de `assets/backgrounds/bg-<id>.svg` |
| `CharLayer` | `character_stage.gd` | posiciona personagens de `assets/characters/char-<id>.svg` |
| `DialogueBox` | `dialogue_box.gd` | fala + nome do falante + typewriter |
| `ChoicesBox` | `choices_box.gd` | botões de escolha (filtrados por `Game.check`) |
| `EndingOverlay` | `ending_overlay.gd` | tela de "Caso Encerrado" (win/lose) |

### Métodos (API pública de `VNLayer`):

* **start(node_id: String) -> void**
    - **Parâmetro:** `node_id` — nó inicial (usa `Game.state.node` salvo, ou `script_data.startNode`).
    * **Ação:** inicia/retoma a narrativa a partir do nó indicado.

* **goto(node_id: String) -> void**
    - **Parâmetro:** `node_id` — próximo nó do roteiro.
    * **Ação:** aplica `bg`/`chars` do nó, roda os `actions` (via `Game.run_action`), exibe `text`/`choices` e avança. É o coração do loop de narrativa.

### Funcionamento interno

`goto()` lê o nó do roteiro, delega fundo/personagens aos filhos, dispara as
`actions` no `Game` e mostra a fala com typewriter. Escolhas são renderizadas
pela `ChoicesBox`, que filtra cada opção por `Game.check(choice.if)`. Enquanto
`Game.panel_open` for `true` (algum painel de investigação aberto), o avanço de
diálogo fica bloqueado. Finais (`ending: "win"|"lose"`) sobem o `EndingOverlay`.

> **Integração:** a VN **não conhece** a camada de Investigação. Para desbloquear
> uma foto/tarefa/evidência a partir da história, use `actions` no nó do roteiro
> — o `Game` propaga por sinal para a Investigação.
