extends VBoxContainer
## ChoicesBox.gd — botões de escolha (porte de #choices / renderChoices em js/vn.js).
##
## Filtra `choices` do nó por `Game.check(choice.get("if"))` e emite
## `choice_selected(next_id)` ao clicar; quem decide se o clique é válido
## (ex.: painel aberto) é o VNLayer.

signal choice_selected(next_id: String)

const FONT_SIZE := 17

const STYLE_NORMAL_BG := Color(22.0 / 255.0, 29.0 / 255.0, 39.0 / 255.0, 0.88)
const STYLE_HOVER_BG := Color("1f2937")
const STYLE_BORDER_LEFT := Color("4f9de0")
const STYLE_ACCENT := Color("d4a843")
const STYLE_TEXT := Color("e6edf3")


func show_choices(choices: Array) -> void:
	_clear()
	var any_visible := false
	for choice in choices:
		var c: Dictionary = choice
		if not Game.check(c.get("if")):
			continue
		any_visible = true
		add_child(_build_button(c))
	visible = any_visible


func hide_box() -> void:
	_clear()
	visible = false


func _clear() -> void:
	for child in get_children():
		child.queue_free()


func _build_button(choice: Dictionary) -> Button:
	var btn := Button.new()
	btn.text = String(choice.get("text", ""))
	btn.focus_mode = Control.FOCUS_NONE
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.add_theme_font_size_override("font_size", FONT_SIZE)
	btn.add_theme_color_override("font_color", STYLE_TEXT)
	btn.add_theme_color_override("font_hover_color", STYLE_TEXT)
	btn.add_theme_color_override("font_focus_color", STYLE_TEXT)

	var normal := _make_style(STYLE_NORMAL_BG, STYLE_BORDER_LEFT, 22.0)
	var hover := _make_style(STYLE_HOVER_BG, STYLE_ACCENT, 30.0)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("focus", hover)
	btn.add_theme_stylebox_override("pressed", hover)

	var next_id := String(choice.get("next", ""))
	btn.pressed.connect(func(): choice_selected.emit(next_id))
	return btn


## StyleBoxFlat só suporta uma cor de borda (não uma por lado); o "acento"
## esquerdo de vn.css (3px azul, 1px cinza nos outros lados) é simplificado
## aqui para uma cor única (mais forte) com a borda esquerda mais grossa,
## o que preserva a leitura de "faixa de destaque à esquerda".
func _make_style(bg: Color, border_color: Color, left_margin: float) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(10)
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_width_left = 3
	sb.border_color = border_color
	sb.content_margin_left = left_margin
	sb.content_margin_right = 22.0
	sb.content_margin_top = 15.0
	sb.content_margin_bottom = 15.0
	return sb
