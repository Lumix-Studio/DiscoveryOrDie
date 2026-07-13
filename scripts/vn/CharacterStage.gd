extends Control
## CharacterStage.gd — camada de personagens em cena
## (porte de #char-layer / applyChars+applyHighlight em js/vn.js).
##
## Cada personagem em cena é um TextureRect (assets/char-<id>.svg), alinhado
## na base, nas posições left/center/right. Entrada e saída usam fade; quem
## fala fica em destaque (modulate normal), os demais escurecidos; se o
## speaker não está em cena, todos ficam num tom neutro.

const CHAR_ASPECT := 500.0 / 900.0  # viewBox das artes de personagem (w/h)
const HEIGHT_RATIO := 0.92          # altura do personagem = 92% do palco

const TRANSITION_TIME := 0.3   # bate com `opacity .3s` / `filter .3s` de vn.css
const REPOSITION_TIME := 0.35  # bate com `left .35s` de vn.css

const POS_RATIO := {
	"left": 0.20,
	"center": 0.50,
	"right": 0.80,
}

const COLOR_ACTIVE := Color(1, 1, 1, 1)        # filter: none
const COLOR_DIM := Color(0.55, 0.55, 0.6, 1)   # filter: brightness(.5) saturate(.7)
const COLOR_NEUTRAL := Color(0.82, 0.82, 0.85, 1)  # filter: brightness(.82)

## char_id (String) -> { "node": TextureRect, "pos": String, "tween": Tween }
var _on_screen: Dictionary = {}


## Aplica o campo `chars` do nó (se presente) e sempre reaplica o destaque
## de acordo com o `speaker` atual — mesmo quando `chars` não foi declarado,
## pois o speaker pode mudar sem trocar quem está em cena.
func apply_chars(node_data: Dictionary, speaker: String) -> void:
	if node_data.has("chars"):
		_sync_chars(node_data["chars"])
	_apply_highlight(speaker)


func _sync_chars(chars: Array) -> void:
	var wanted := {}
	for c in chars:
		var cd: Dictionary = c
		wanted[String(cd.id)] = String(cd.pos)

	# Remove quem saiu de cena.
	for id in _on_screen.keys().duplicate():
		if not wanted.has(id):
			_remove_char(id)

	# Adiciona quem entrou / reposiciona quem já estava.
	for id in wanted.keys():
		var pos: String = wanted[id]
		if _on_screen.has(id):
			var entry: Dictionary = _on_screen[id]
			if entry.pos != pos:
				entry.pos = pos
				_reposition(entry.node, pos)
		else:
			_add_char(id, pos)


func _add_char(id: String, pos: String) -> void:
	var tex_path := "res://assets/char-%s.svg" % id
	if not ResourceLoader.exists(tex_path):
		push_warning("CharacterStage: asset de personagem ausente -> %s" % tex_path)
		return

	var rect := TextureRect.new()
	rect.texture = load(tex_path)
	rect.name = "Char_%s" % id
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.modulate = Color(1, 1, 1, 0)  # começa invisível; _apply_highlight cuida do fade-in
	add_child(rect)

	_on_screen[id] = {"node": rect, "pos": pos, "tween": null}
	_layout_char(rect, pos)


## Redimensiona/posiciona instantaneamente (usado na criação e em qualquer
## necessidade de recálculo; a transição lateral de reposicionamento usa
## `_reposition`, que anima só o X).
func _layout_char(rect: TextureRect, pos: String) -> void:
	var stage_size := size
	var target_height := stage_size.y * HEIGHT_RATIO
	var target_width := target_height * CHAR_ASPECT
	rect.size = Vector2(target_width, target_height)
	rect.position = Vector2(_center_x(pos, target_width), stage_size.y - target_height)


func _center_x(pos: String, width: float) -> float:
	var ratio: float = POS_RATIO.get(pos, 0.5)
	return size.x * ratio - width / 2.0


func _reposition(rect: TextureRect, pos: String) -> void:
	var target_x := _center_x(pos, rect.size.x)
	var tw := create_tween()
	tw.tween_property(rect, "position:x", target_x, REPOSITION_TIME)


func _remove_char(id: String) -> void:
	var entry: Dictionary = _on_screen[id]
	_on_screen.erase(id)
	var rect: TextureRect = entry.node
	if entry.tween and entry.tween.is_valid():
		entry.tween.kill()
	var tw := create_tween()
	tw.tween_property(rect, "modulate:a", 0.0, TRANSITION_TIME)
	tw.tween_callback(rect.queue_free)


## Personagem que fala fica em destaque (COLOR_ACTIVE); os demais, escurecidos
## (COLOR_DIM). Se o speaker não está em cena, todos ficam neutros (COLOR_NEUTRAL).
func _apply_highlight(speaker: String) -> void:
	var speaker_id := speaker.to_lower()
	var someone_matches := _on_screen.has(speaker_id)
	for id in _on_screen.keys():
		var entry: Dictionary = _on_screen[id]
		var tint: Color
		if not someone_matches:
			tint = COLOR_NEUTRAL
		elif id == speaker_id:
			tint = COLOR_ACTIVE
		else:
			tint = COLOR_DIM
		_animate_modulate(entry, tint)


func _animate_modulate(entry: Dictionary, tint: Color) -> void:
	if entry.tween and entry.tween.is_valid():
		entry.tween.kill()
	var target := Color(tint.r, tint.g, tint.b, 1.0)
	var tw := create_tween()
	tw.tween_property(entry.node, "modulate", target, TRANSITION_TIME)
	entry.tween = tw
