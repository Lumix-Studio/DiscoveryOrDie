class_name PhotoViewer
extends VBoxContainer
## Minigame de análise de foto (porte de photo.js): zoom (scroll/botões 1x–4x),
## pan (arrastar), hit-test de hotspots em coordenadas do viewBox 1200x800,
## highlights permanentes, contador de pistas e grants por pista.

const VB_W := 1200.0
const VB_H := 800.0

# ------------------------------------------------------------------ dados das fotos
const PHOTOS: Array = [
	{
		"id": "foto_clareira",
		"title": "Foto da clareira",
		"src": "res://assets/photos/foto-clareira.svg",
		"clues": [
			{
				"id": "pegadas", "x": 300.0, "y": 640.0, "r": 100.0,
				"name": "Pegadas duplas",
				"desc": "Dois pares de pegadas: um pequeno e descalço, outro grande de bota. Seguem para o norte.",
				"grants": {
					"evidence": {
						"id": "ev_pegadas", "name": "Pegadas duplas",
						"desc": "Dois pares de pegadas saindo da clareira rumo ao norte: um pequeno e descalço, outro grande de bota.",
						"source": "Foto da clareira",
					},
					"research": "trilha_norte",
				},
			},
			{
				"id": "tecido", "x": 975.0, "y": 378.0, "r": 90.0,
				"name": "Tecido rasgado",
				"desc": "Um retalho de vestido azul preso num galho, na altura de um braço erguido.",
				"grants": {
					"evidence": {
						"id": "ev_tecido", "name": "Tecido rasgado",
						"desc": "Retalho de um vestido azul preso num galho — do mesmo tom do vestido que Lorain usava.",
						"source": "Foto da clareira",
					},
				},
			},
			{
				"id": "colar", "x": 610.0, "y": 604.0, "r": 80.0,
				"name": "Colar de Lorain",
				"desc": "Um colar de pingente de madeira, a corrente arrebentada, caído perto do tronco.",
				"grants": {
					"evidence": {
						"id": "ev_colar", "name": "Colar de Lorain",
						"desc": "Colar de pingente de madeira com a corrente arrebentada, encontrado junto ao tronco caído.",
						"source": "Foto da clareira",
					},
				},
			},
		],
	},
]

static func find_photo(id: String) -> Dictionary:
	for p in PHOTOS:
		if p["id"] == id:
			return p
	return {}

static func title_for(id: String) -> String:
	var p := find_photo(id)
	return p["title"] if not p.is_empty() else id

static func is_complete(photo: Dictionary) -> bool:
	var f: Array = Game.state.get("found_clues", {}).get(photo["id"], [])
	return photo["clues"].size() > 0 and f.size() >= photo["clues"].size()

# =================================================================== GALERIA
static func render_gallery(content: VBoxContainer, invest, wrap_w: float) -> void:
	for c in content.get_children():
		content.remove_child(c)
		c.queue_free()
	var ids: Array = Game.state.get("photos", [])
	if ids.is_empty():
		var e := InvestTheme.label("Nenhuma foto disponível ainda.", InvestTheme.TEXT_DIM, 14, wrap_w)
		e.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content.add_child(e)
		return

	var grid := GridContainer.new()
	grid.columns = maxi(1, int(wrap_w / 220.0))
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	content.add_child(grid)

	for id in ids:
		var data := find_photo(id)
		if data.is_empty():
			continue
		grid.add_child(_gallery_card(data, invest))

static func _gallery_card(data: Dictionary, invest) -> Control:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", InvestTheme.photo_card_box())
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.clip_contents = true

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	card.add_child(col)

	var thumb := TextureRect.new()
	thumb.texture = load(data["src"])
	thumb.custom_minimum_size = Vector2(0, 118)
	thumb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	col.add_child(thumb)

	var meta := MarginContainer.new()
	meta.add_theme_constant_override("margin_left", 11)
	meta.add_theme_constant_override("margin_top", 9)
	meta.add_theme_constant_override("margin_right", 11)
	meta.add_theme_constant_override("margin_bottom", 9)
	col.add_child(meta)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	meta.add_child(row)

	var title := InvestTheme.label(data["title"], InvestTheme.TEXT, 13)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)

	var status: Label
	if is_complete(data):
		status = InvestTheme.label("✓ Completa", InvestTheme.SUCCESS, 12)
	else:
		var found: int = Game.state.get("found_clues", {}).get(data["id"], []).size()
		status = InvestTheme.label("Pistas: %d/%d" % [found, data["clues"].size()], InvestTheme.TEXT_DIM, 12)
	row.add_child(status)

	var pid: String = data["id"]
	card.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			invest.open_panel("photo-viewer", pid))
	return card

# =================================================================== VIEWER (instância)
var photo_id: String = ""
var avail_w: float = 900.0
var wrap_w: float = 900.0

var _data: Dictionary = {}
var _stage_w: float = 0.0
var _stage_h: float = 0.0

var _scale: float = 1.0
var _tx: float = 0.0
var _ty: float = 0.0
const MIN_SCALE := 1.0
const MAX_SCALE := 4.0

var _dragging := false
var _drag: Dictionary = {}

var _stage: Control
var _canvas: Control
var _hl: HighlightLayer
var _ripple: RippleLayer
var _counter_frame: PanelContainer
var _counter_label: Label
var _detail: PanelContainer
var _detail_content: VBoxContainer

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 12)
	_data = find_photo(photo_id)
	if _data.is_empty():
		add_child(InvestTheme.label("Foto não encontrada.", InvestTheme.TEXT_DIM, 14, wrap_w))
		return
	_build()

func _build() -> void:
	_stage_w = avail_w
	_stage_h = _stage_w / 1.5   # aspecto 3:2 == viewBox

	# --- barra: dica + contador
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 10)
	add_child(bar)
	var hint := InvestTheme.label(
		"🔍 Arraste para mover · role o mouse para dar zoom · clique para investigar",
		InvestTheme.TEXT_DIM, 12)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(hint)
	_counter_frame = PanelContainer.new()
	_counter_frame.add_theme_stylebox_override("panel", InvestTheme.counter_pill(false))
	_counter_label = InvestTheme.label("Pistas: 0/0", InvestTheme.ACCENT, 13)
	_counter_frame.add_child(_counter_label)
	bar.add_child(_counter_frame)

	# --- palco (frame com borda) + canvas transformável
	# SHRINK_CENTER: o frame fica com largura exata = _stage_w (não estica no VBox),
	# garantindo que a matemática de coordenadas (que usa _stage_w) bata com o palco real.
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", InvestTheme.stage_box())
	frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(frame)

	_stage = Control.new()
	_stage.custom_minimum_size = Vector2(_stage_w, _stage_h)
	_stage.clip_contents = true
	_stage.mouse_filter = Control.MOUSE_FILTER_STOP
	_stage.mouse_default_cursor_shape = Control.CURSOR_DRAG
	_stage.gui_input.connect(_on_stage_input)
	frame.add_child(_stage)

	_canvas = Control.new()
	_canvas.position = Vector2.ZERO
	_canvas.size = Vector2(_stage_w, _stage_h)
	_canvas.pivot_offset = Vector2.ZERO
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_canvas)

	var tex := TextureRect.new()
	tex.texture = load(_data["src"])
	tex.position = Vector2.ZERO
	tex.size = Vector2(_stage_w, _stage_h)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.add_child(tex)

	_hl = HighlightLayer.new()
	_hl.position = Vector2.ZERO
	_hl.size = Vector2(_stage_w, _stage_h)
	_hl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hl.k = _stage_w / VB_W
	_hl.clues = _data["clues"]
	_hl.found = _found_list()
	_canvas.add_child(_hl)

	_ripple = RippleLayer.new()
	_ripple.position = Vector2.ZERO
	_ripple.size = Vector2(_stage_w, _stage_h)
	_ripple.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_ripple)

	# --- controles de zoom
	var ctr := HBoxContainer.new()
	ctr.alignment = BoxContainer.ALIGNMENT_CENTER
	ctr.add_theme_constant_override("separation", 8)
	add_child(ctr)
	ctr.add_child(_zoom_button("−", func() -> void: _zoom_center(_round1(_scale - 0.5))))
	ctr.add_child(_zoom_button("⛶", func() -> void:
		_scale = 1.0; _tx = 0.0; _ty = 0.0; _apply()))
	ctr.add_child(_zoom_button("+", func() -> void: _zoom_center(_round1(_scale + 0.5))))

	# --- detalhe da última pista
	var pair := InvestTheme.bar_item_left(InvestTheme.ACCENT, InvestTheme.detail_box())
	_detail = pair[0]
	_detail_content = pair[1]
	_detail.visible = false
	add_child(_detail)

	_update_counter()
	_apply()

func _zoom_button(txt: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = txt
	b.custom_minimum_size = Vector2(44, 34)
	InvestTheme.style_button(b, InvestTheme.zoom_btn(false), InvestTheme.zoom_btn(true),
		InvestTheme.zoom_btn(true), InvestTheme.TEXT, 18)
	b.pressed.connect(cb)
	return b

# ------------------------------------------------------------------ transform / zoom / pan
func _apply() -> void:
	_canvas.position = Vector2(_tx, _ty)
	_canvas.scale = Vector2(_scale, _scale)

func _clamp_pan() -> void:
	var min_tx := _stage_w * (1.0 - _scale)
	var min_ty := _stage_h * (1.0 - _scale)
	_tx = clampf(_tx, min_tx, 0.0)
	_ty = clampf(_ty, min_ty, 0.0)

func _zoom_at(spos: Vector2, next: float) -> void:
	next = clampf(next, MIN_SCALE, MAX_SCALE)
	if is_equal_approx(next, _scale):
		return
	var cx := (spos.x - _tx) / _scale
	var cy := (spos.y - _ty) / _scale
	_scale = next
	_tx = spos.x - cx * _scale
	_ty = spos.y - cy * _scale
	_clamp_pan()
	_apply()

func _zoom_center(next: float) -> void:
	_zoom_at(Vector2(_stage_w / 2.0, _stage_h / 2.0), next)

func _round1(n: float) -> float:
	return round(n * 10.0) / 10.0

func _on_stage_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_zoom_at(event.position, _round1(_scale + 0.3))
				accept_event()
			MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_at(event.position, _round1(_scale - 0.3))
				accept_event()
			MOUSE_BUTTON_LEFT:
				_drag = {"start": event.position, "tx": _tx, "ty": _ty, "moved": false}
				_dragging = true
				accept_event()

func _input(event: InputEvent) -> void:
	if not _dragging:
		return
	if event is InputEventMouseMotion:
		var cur := _stage.get_local_mouse_position()
		var d: Vector2 = cur - _drag["start"]
		if not _drag["moved"] and d.length() > 6.0:
			_drag["moved"] = true
		if _drag["moved"]:
			_tx = _drag["tx"] + d.x
			_ty = _drag["ty"] + d.y
			_clamp_pan()
			_apply()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		var moved: bool = _drag["moved"]
		_dragging = false
		get_viewport().set_input_as_handled()
		if not moved:
			_handle_click(_stage.get_local_mouse_position())

# ------------------------------------------------------------------ hit-test
func _found_list() -> Array:
	var fc: Dictionary = Game.state["found_clues"]
	if not fc.has(photo_id):
		fc[photo_id] = []
	return fc[photo_id]

func _handle_click(pos: Vector2) -> void:
	var rw := _stage_w * _scale
	var rh := _stage_h * _scale
	var fx := (pos.x - _tx) / rw
	var fy := (pos.y - _ty) / rh
	var vx := fx * VB_W
	var vy := fy * VB_H

	var found := _found_list()
	var hit: Dictionary = {}
	for clue in _data["clues"]:
		if clue["id"] in found:
			continue
		if Vector2(vx - clue["x"], vy - clue["y"]).length() <= clue["r"]:
			hit = clue
			break

	if hit.is_empty():
		_ripple.spawn(pos)
		return

	found.append(hit["id"])
	Game.save()
	_hl.pop(hit["id"])
	_show_detail(hit)
	Invest.apply_grants(hit.get("grants", {}))
	_update_counter()

	if is_complete(_data):
		Game.set_flag(photo_id + "_completa")
		Game.complete_task("t_analisar_foto")
		Game.toast.emit("📷 Foto totalmente analisada! Todas as pistas encontradas.", "success")

func _show_detail(clue: Dictionary) -> void:
	_detail.visible = true
	for c in _detail_content.get_children():
		_detail_content.remove_child(c)
		c.queue_free()
	_detail_content.add_child(InvestTheme.label("🔍 " + clue["name"], InvestTheme.ACCENT, 15))
	var d := InvestTheme.label(clue["desc"], InvestTheme.TEXT, 13, maxf(60.0, wrap_w - 50.0))
	d.add_theme_constant_override("line_spacing", 5)
	_detail_content.add_child(d)

func _update_counter() -> void:
	var total: int = _data["clues"].size()
	var n: int = _found_list().size()
	_counter_label.text = "Pistas: %d/%d" % [n, total]
	var full := total > 0 and n >= total
	_counter_frame.add_theme_stylebox_override("panel", InvestTheme.counter_pill(full))
	_counter_label.add_theme_color_override("font_color", InvestTheme.SUCCESS if full else InvestTheme.ACCENT)

# =================================================================== camadas de desenho
class HighlightLayer extends Control:
	var clues: Array = []
	var found: Array = []
	var k: float = 1.0
	var _pop_id: String = ""
	var _pop_t: float = -1.0
	var _pulse: float = 0.0

	func pop(id: String) -> void:
		_pop_id = id
		_pop_t = Time.get_ticks_msec() / 1000.0
		queue_redraw()

	func _process(delta: float) -> void:
		_pulse += delta
		queue_redraw()

	func _draw() -> void:
		var phase := 0.5 + 0.5 * sin(_pulse * TAU / 1.7)
		var stroke_op := lerpf(0.35, 0.9, phase)
		var fill_op := lerpf(0.03, 0.1, phase)
		var now := Time.get_ticks_msec() / 1000.0
		for clue in clues:
			if not (clue["id"] in found):
				continue
			var center := Vector2(clue["x"], clue["y"]) * k
			var radius: float = clue["r"] * k
			var w := 5.0 * k
			var so := stroke_op
			if clue["id"] == _pop_id and _pop_t >= 0.0:
				var e := now - _pop_t
				if e < 0.5:
					if e < 0.3:
						w = lerpf(2.0, 11.0, e / 0.3) * k
					else:
						w = lerpf(11.0, 5.0, (e - 0.3) / 0.2) * k
					so = 0.95
			draw_circle(center, radius, InvestTheme.with_alpha(InvestTheme.ACCENT, fill_op))
			draw_arc(center, radius, 0.0, TAU, 64, InvestTheme.with_alpha(InvestTheme.ACCENT, so), w, true)

class RippleLayer extends Control:
	var _ripples: Array = []

	func _ready() -> void:
		set_process(false)

	func spawn(pos: Vector2) -> void:
		_ripples.append({"pos": pos, "t0": Time.get_ticks_msec() / 1000.0})
		set_process(true)
		queue_redraw()

	func _process(_delta: float) -> void:
		var now := Time.get_ticks_msec() / 1000.0
		var alive: Array = []
		for r in _ripples:
			if now - r["t0"] < 0.6:
				alive.append(r)
		_ripples = alive
		if _ripples.is_empty():
			set_process(false)
		queue_redraw()

	func _draw() -> void:
		var now := Time.get_ticks_msec() / 1000.0
		for r in _ripples:
			var e: float = clampf((now - r["t0"]) / 0.6, 0.0, 1.0)
			var radius := 17.0 * lerpf(0.4, 2.4, e)
			var op := lerpf(0.85, 0.0, e)
			draw_arc(r["pos"], radius, 0.0, TAU, 32, InvestTheme.with_alpha(InvestTheme.DANGER, op), 2.0, true)
