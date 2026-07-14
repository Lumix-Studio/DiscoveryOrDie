extends Node
## Smoke de integração headless:
##   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . res://test/smoke.tscn
## Instancia as duas camadas de verdade e dirige o roteiro pelo VN.
## Também roda dentro de test_suite.tscn (com autorun=false → sem quit próprio).

@export var autorun := true
var fails := 0
var checks := 0

func ok(cond: bool, msg: String) -> void:
	checks += 1
	if cond:
		print("  ✓ ", msg)
	else:
		fails += 1
		printerr("  ✗ FAIL: ", msg)

func _ready() -> void:
	if not autorun:
		return
	await run()
	print("\n%d/%d asserts OK" % [checks - fails, checks])
	get_tree().quit(1 if fails > 0 else 0)

func run() -> void:
	await get_tree().process_frame
	Game.state = Game.default_state()

	var vn: Node = load("res://src/ui/vn/vn_layer.tscn").instantiate()
	var invest: Node = load("res://src/ui/invest/invest_layer.tscn").instantiate()
	add_child(vn)
	add_child(invest)
	await get_tree().process_frame
	ok(true, "VNLayer + InvestLayer coexistem sem erro")

	vn.start("title")
	await get_tree().process_frame
	ok(Game.state.node == "title", "start() posiciona no nó 'title' (obtido: %s)" % Game.state.node)

	vn.goto("clareira_01")
	await get_tree().process_frame
	ok(Game.state.bg == "clareira", "nó com bg persiste em state.bg (obtido: %s)" % Game.state.bg)
	ok(Game.state.chars.size() > 0, "nó com chars persiste em state.chars (%d em cena)" % Game.state.chars.size())

	vn.goto("clareira_03")
	await get_tree().process_frame
	ok(Game.state.photos.has("foto_clareira"), "action do nó desbloqueou foto_clareira")
	ok(_has_task("t_analisar_foto"), "actions de tarefa do nó executaram")

	# hub: choices aparecem depois do typewriter — espera até 8s
	vn.goto("hub")
	var buttons: Array = []
	for i in range(80):
		await get_tree().create_timer(0.1).timeout
		buttons = vn.find_children("*", "Button", true, false).filter(func(b: Node) -> bool: return b.is_visible_in_tree())
		if buttons.size() > 0:
			break
	ok(buttons.size() >= 2, "hub renderiza escolhas visíveis após typewriter (%d botões)" % buttons.size())

	# gate: com ev_cabana a escolha da cabana aparece
	Game.add_evidence({"id": "ev_cabana", "name": "Localização da cabana", "desc": "x", "source": "teste"})
	vn.goto("hub")
	var texts: Array = []
	for i in range(80):
		await get_tree().create_timer(0.1).timeout
		buttons = vn.find_children("*", "Button", true, false).filter(func(b: Node) -> bool: return b.is_visible_in_tree())
		if buttons.size() > 0:
			break
	for b in buttons:
		texts.append(b.text)
	ok(texts.any(func(t: String) -> bool: return "cabana" in t.to_lower()), "gate por evidência libera escolha da cabana (%s)" % [texts])

	# final de vitória
	vn.goto("ending_win")
	await get_tree().create_timer(1.0).timeout
	var labels: Array = vn.find_children("*", "Label", true, false) + vn.find_children("*", "RichTextLabel", true, false)
	var has_title := labels.any(func(l: Node) -> bool: return l.is_visible_in_tree() and "Caso Encerrado" in str(l.get("text")))
	ok(has_title, "overlay de final exibe o título 'Caso Encerrado'")

	# limpa o save gerado pelo teste
	if FileAccess.file_exists(Game.SAVE_PATH):
		DirAccess.remove_absolute(Game.SAVE_PATH)

func _has_task(id: String) -> bool:
	for t in Game.state.tasks:
		if t.id == id:
			return true
	return false
