extends Control
## VNLayer.gd — raiz do núcleo de Visual Novel (porte de js/vn.js).
##
## Consome Game.script_data (data/script.json, mesmo formato de
## js/script-data.js) e o contrato Game.* (scripts/Game.gd — NÃO MODIFICADO).
## Main.gd instancia esta cena em runtime e chama start(node_id).
##
## Orquestra os módulos-filho (cada um só cuida da própria apresentação):
##   SceneLayer   (SceneBackground.gd) — cenário/fundo
##   CharLayer    (CharacterStage.gd)  — personagens em cena
##   DialogueBox  (DialogueBox.gd)     — caixa de diálogo + typewriter
##   ChoicesBox   (ChoicesBox.gd)      — botões de escolha
##   EndingOverlay(EndingOverlay.gd)   — overlay de final

@onready var _background: TextureRect = $SceneLayer
@onready var _char_stage: Control = $CharLayer
@onready var _dialogue: Panel = $DialogueBox
@onready var _choices: VBoxContainer = $ChoicesBox
@onready var _ending: Control = $EndingOverlay

var _current_node: Dictionary = {}


func _ready() -> void:
	_dialogue.clicked.connect(_on_dialogue_clicked)
	_dialogue.typewriter_completed.connect(_on_typewriter_completed)
	_choices.choice_selected.connect(_on_choice_selected)
	_ending.restart_requested.connect(_on_restart_requested)


## API pública — chamada pelo Main.gd. `node_id` é o nó salvo (retomada de
## save) ou o startNode do roteiro.
func start(node_id: String) -> void:
	var node := _get_node_data(node_id)
	if not node.is_empty():
		# Retomando um save no meio de uma cena: o nó atual pode não
		# declarar bg/chars (herdados de nós anteriores) — restaura do
		# estado salvo, senão a retomada aparece com a tela vazia.
		var saved_bg := String(Game.state.get("bg", ""))
		if not node.has("bg") and not saved_bg.is_empty():
			_background.apply_bg(saved_bg)
		var saved_chars: Array = Game.state.get("chars", [])
		if not node.has("chars") and not saved_chars.is_empty():
			_char_stage.apply_chars({"chars": saved_chars}, String(node.get("speaker", "")))
	_enter_node(node_id)


func goto(node_id: String) -> void:
	_enter_node(node_id)


func _enter_node(id: String) -> void:
	var node := _get_node_data(id)
	if node.is_empty():
		push_error("VNLayer: nó inexistente no roteiro -> %s" % id)
		return

	Game.state.node = id
	# Persiste cenário/personagens correntes: valem até o próximo nó que os
	# declarar, então precisam sobreviver a um reload no meio da cena.
	if node.has("bg"):
		Game.state.bg = node.bg
	if node.has("chars"):
		Game.state.chars = node.chars
	Game.save()

	_current_node = node
	_background.apply_bg(String(node.get("bg", "")))
	_char_stage.apply_chars(node, String(node.get("speaker", "")))
	_run_actions_once(node, id)

	if node.has("ending"):
		_dialogue.hide_box()
		_choices.hide_box()
		_ending.show_ending(node)
		return

	_choices.hide_box()
	_dialogue.show_box()
	_dialogue.start_node(String(node.get("speaker", "")), String(node.get("text", "")))


## Executa as actions do nó uma única vez por visita (guarda em flags).
func _run_actions_once(node: Dictionary, id: String) -> void:
	var visited_flag := "visited_%s" % id
	if Game.has_flag(visited_flag):
		return
	for action in node.get("actions", []):
		Game.run_action(action)
	Game.set_flag(visited_flag)


func _get_node_data(id: String) -> Dictionary:
	var nodes: Dictionary = Game.script_data.get("nodes", {})
	return nodes.get(id, {})


func _on_typewriter_completed() -> void:
	if _current_node.has("choices"):
		_choices.show_choices(_current_node.choices)
	else:
		_dialogue.show_hint()


## Clique na caixa de diálogo: durante o typewriter, completa o texto; com
## o texto completo, avança pro `next` — exceto se houver escolhas (avança
## só pelos botões) ou um painel overlay aberto (outra camada).
func _on_dialogue_clicked() -> void:
	if Game.panel_open:
		return
	if _dialogue.is_typing():
		_dialogue.finish_typing()
		return
	if _current_node.is_empty() or _current_node.has("ending") or _current_node.has("choices"):
		return
	if _current_node.has("next"):
		goto(String(_current_node.next))


func _on_choice_selected(next_id: String) -> void:
	if Game.panel_open:
		return
	goto(next_id)


func _on_restart_requested() -> void:
	Game.reset()
