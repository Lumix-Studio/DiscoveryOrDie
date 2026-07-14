class_name InvestTheme
extends RefCounted
## Paleta e construtores de estilo (StyleBoxFlat/Labels) do tema noir detetive.
## Porte das variáveis de css/main.css + estilos de css/invest.css.
## Sem instância: só helpers estáticos.

# ------------------------------------------------------------------ paleta
const BG := Color("0d1117")
const PANEL := Color("161d27")
const PANEL_TOP := Color("18212d")      # topo do gradiente do painel
const PANEL_BORDER := Color("2b3a4d")
const TEXT := Color("e6edf3")
const TEXT_DIM := Color("9db1c5")
const ACCENT := Color("d4a843")         # dourado detetive
const ACCENT_2 := Color("4f9de0")       # azul pistas
const DANGER := Color("d9534f")
const SUCCESS := Color("5cb85c")

const RADIUS := 10
const BACKDROP := Color(0.016, 0.027, 0.043, 0.62)   # rgba(4,7,11,.62)

# ------------------------------------------------------------------ util cor
static func with_alpha(c: Color, a: float) -> Color:
	return Color(c.r, c.g, c.b, a)

# ------------------------------------------------------------------ styleboxes
static func flat(bg: Color, corner: int = 8, border_w: int = 0, border_col: Color = Color(0, 0, 0, 0)) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(corner)
	if border_w > 0:
		sb.set_border_width_all(border_w)
		sb.border_color = border_col
	sb.anti_aliasing = true
	return sb

static func _pad(sb: StyleBoxFlat, l: float, t: float, r: float, b: float) -> StyleBoxFlat:
	sb.content_margin_left = l
	sb.content_margin_top = t
	sb.content_margin_right = r
	sb.content_margin_bottom = b
	return sb

static func panel_box() -> StyleBoxFlat:
	var sb := flat(PANEL_TOP, RADIUS, 1, PANEL_BORDER)
	return _pad(sb, 0, 0, 0, 0)

static func header_box() -> StyleBoxFlat:
	var sb := flat(Color(0, 0, 0, 0.22), 0)
	sb.corner_radius_top_left = RADIUS
	sb.corner_radius_top_right = RADIUS
	sb.set_border_width(SIDE_BOTTOM, 1)
	sb.border_color = PANEL_BORDER
	return _pad(sb, 16, 13, 16, 13)

static func hud_btn(hover: bool = false, dev: bool = false) -> StyleBoxFlat:
	var bg := with_alpha(Color("1f2937"), 0.95) if hover else with_alpha(PANEL, 0.82)
	var border := ACCENT if hover else PANEL_BORDER
	var sb := flat(bg, 16, 1, border)
	if dev and not hover:
		sb.border_color = with_alpha(PANEL_BORDER, 0.9)
	return _pad(sb, 12, 6, 12, 6)

static func badge_box() -> StyleBoxFlat:
	var sb := flat(ACCENT, 9)
	return _pad(sb, 5, 1, 5, 1)

static func big_btn(hover: bool = false, danger: bool = false) -> StyleBoxFlat:
	var bg := Color(0, 0, 0, 0.18)
	var border := PANEL_BORDER
	if danger:
		border = with_alpha(DANGER, 0.55)
		if hover:
			bg = with_alpha(DANGER, 0.16)
			border = DANGER
	elif hover:
		bg = with_alpha(ACCENT, 0.12)
		border = ACCENT
	var sb := flat(bg, 8, 1, border)
	return _pad(sb, 14, 12, 14, 12)

static func chip_box(hover: bool = false) -> StyleBoxFlat:
	var bg := with_alpha(ACCENT_2, 0.24) if hover else with_alpha(ACCENT_2, 0.12)
	var border := ACCENT_2 if hover else with_alpha(ACCENT_2, 0.4)
	var sb := flat(bg, 14, 1, border)
	return _pad(sb, 12, 6, 12, 6)

static func search_btn(hover: bool = false) -> StyleBoxFlat:
	var bg := with_alpha(ACCENT, 0.14) if hover else with_alpha(PANEL, 0.82)
	var sb := flat(bg, 8, 1, ACCENT)
	return _pad(sb, 14, 10, 14, 10)

static func list_item_box() -> StyleBoxFlat:
	return flat(Color(0, 0, 0, 0.18), 8, 1, PANEL_BORDER)

static func result_card_box() -> StyleBoxFlat:
	return flat(Color(0, 0, 0, 0.22), 8, 1, PANEL_BORDER)

static func no_result_box() -> StyleBoxFlat:
	var sb := flat(with_alpha(DANGER, 0.08), 8, 1, with_alpha(DANGER, 0.4))
	return _pad(sb, 16, 14, 16, 14)

static func input_box(focus: bool = false) -> StyleBoxFlat:
	var border := ACCENT if focus else PANEL_BORDER
	var sb := flat(Color(0, 0, 0, 0.3), 8, 1, border)
	return _pad(sb, 13, 10, 13, 10)

static func counter_pill(full: bool = false) -> StyleBoxFlat:
	var base := SUCCESS if full else ACCENT
	var sb := flat(with_alpha(base, 0.14), 14, 1, with_alpha(base, 0.5))
	return _pad(sb, 11, 4, 11, 4)

static func detail_box() -> StyleBoxFlat:
	return flat(Color(0, 0, 0, 0.28), 8, 1, PANEL_BORDER)

static func toast_box(type: String) -> StyleBoxFlat:
	var sb := flat(with_alpha(PANEL, 0.97), 8, 1, PANEL_BORDER)
	return _pad(sb, 0, 0, 0, 0)

static func stage_box() -> StyleBoxFlat:
	return _pad(flat(Color("05080b"), 8, 1, PANEL_BORDER), 0, 0, 0, 0)

static func photo_card_box() -> StyleBoxFlat:
	return _pad(flat(Color(0, 0, 0, 0.25), RADIUS, 1, PANEL_BORDER), 0, 0, 0, 0)

static func zoom_btn(hover: bool = false) -> StyleBoxFlat:
	var border := ACCENT if hover else PANEL_BORDER
	var sb := flat(with_alpha(PANEL, 0.9), 8, 1, border)
	return _pad(sb, 0, 6, 0, 6)

static func close_btn(hover: bool = false) -> StyleBoxFlat:
	if hover:
		return _pad(flat(with_alpha(DANGER, 0.12), 8, 1, DANGER), 0, 0, 0, 0)
	return _pad(flat(Color(0, 0, 0, 0), 8), 0, 0, 0, 0)

static func type_color(type: String) -> Color:
	match type:
		"success":
			return SUCCESS
		"warn":
			return DANGER
		_:
			return ACCENT

# ------------------------------------------------------------------ controles
static func style_button(b: Button, normal: StyleBoxFlat, hover: StyleBoxFlat, pressed: StyleBoxFlat, font_col: Color, font_size: int) -> void:
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", normal)
	b.add_theme_color_override("font_color", font_col)
	b.add_theme_color_override("font_hover_color", font_col)
	b.add_theme_color_override("font_pressed_color", font_col)
	b.add_theme_color_override("font_focus_color", font_col)
	b.add_theme_font_size_override("font_size", font_size)

static func style_line_edit(le: LineEdit) -> void:
	le.add_theme_stylebox_override("normal", input_box(false))
	le.add_theme_stylebox_override("focus", input_box(true))
	le.add_theme_color_override("font_color", TEXT)
	le.add_theme_color_override("font_placeholder_color", TEXT_DIM)
	le.add_theme_color_override("caret_color", ACCENT)
	le.add_theme_color_override("selection_color", with_alpha(ACCENT, 0.3))
	le.add_theme_font_size_override("font_size", 14)

# ------------------------------------------------------------------ labels
static func label(text: String, color: Color, font_size: int, wrap_w: float = 0.0) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", font_size)
	if wrap_w > 0.0:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = wrap_w
	return l

static func rich(bbcode: String, color: Color, font_size: int, wrap_w: float) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	r.custom_minimum_size.x = wrap_w
	r.add_theme_color_override("default_color", color)
	r.add_theme_font_size_override("normal_font_size", font_size)
	r.text = bbcode
	return r

# ------------------------------------------------------------------ itens com barra lateral/superior
## Cartão com barra colorida à esquerda (tarefas, evidências, detalhe de pista).
## Retorna [PanelContainer, VBoxContainer_conteudo].
static func bar_item_left(bar_color: Color, box: StyleBoxFlat) -> Array:
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", box)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 0)
	pc.add_child(h)
	var bar := ColorRect.new()
	bar.color = bar_color
	bar.custom_minimum_size = Vector2(3, 0)
	bar.size_flags_vertical = Control.SIZE_FILL
	h.add_child(bar)
	var m := MarginContainer.new()
	m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	m.add_theme_constant_override("margin_left", 11)
	m.add_theme_constant_override("margin_top", 11)
	m.add_theme_constant_override("margin_right", 13)
	m.add_theme_constant_override("margin_bottom", 11)
	h.add_child(m)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 3)
	m.add_child(v)
	return [pc, v]

## Cartão com barra colorida no topo (resultado de pesquisa).
static func bar_item_top(bar_color: Color, box: StyleBoxFlat) -> Array:
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", box)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	pc.add_child(col)
	var bar := ColorRect.new()
	bar.color = bar_color
	bar.custom_minimum_size = Vector2(0, 3)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(bar)
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", 16)
	m.add_theme_constant_override("margin_top", 14)
	m.add_theme_constant_override("margin_right", 16)
	m.add_theme_constant_override("margin_bottom", 14)
	col.add_child(m)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	m.add_child(v)
	return [pc, v]
