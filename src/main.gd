extends Control
## Main.gd — boot: instancia as camadas em runtime (evita conflito de .tscn
## entre módulos) e inicia o roteiro do ponto salvo ou do começo.

const VN_LAYER := "res://src/ui/vn/vn_layer.tscn"
const INVEST_LAYER := "res://src/ui/invest/invest_layer.tscn"

func _ready() -> void:
	var vn: Node = null
	if ResourceLoader.exists(VN_LAYER):
		vn = load(VN_LAYER).instantiate()
		add_child(vn)
	if ResourceLoader.exists(INVEST_LAYER):
		add_child(load(INVEST_LAYER).instantiate())

	if vn != null and vn.has_method("start"):
		var start_node: String = Game.state.get("node", "")
		if start_node.is_empty():
			start_node = Game.script_data.get("startNode", "")
		vn.start(start_node)
