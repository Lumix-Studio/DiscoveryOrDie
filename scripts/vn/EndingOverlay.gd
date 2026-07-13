extends Control
## EndingOverlay.gd — overlay de final de jogo
## (porte de #ending-overlay / showEnding em js/vn.js).
##
## Mostrado quando o nó atual tem `ending` ("win"/"lose"): título grande
## (dourado no win, vermelho no lose), texto do nó e botão de reiniciar.

signal restart_requested

const COLOR_WIN := Color("d4a843")
const COLOR_LOSE := Color("d9534f")
const COLOR_PANEL := Color("161d27")
const COLOR_PANEL_HOVER := Color("1f2937")
const COLOR_TEXT_DIM := Color("9db1c5")

const FADE_TIME := 0.5

@onready var _card: PanelContainer = $Card
@onready var _title: Label = $Card/VBox/Title
@onready var _text: Label = $Card/VBox/Text
@onready var _restart_btn: Button = $Card/VBox/RestartButton


func _ready() -> void:
	modulate.a = 0.0
	hide()
	_text.add_theme_color_override("font_color", COLOR_TEXT_DIM)
	_restart_btn.pressed.connect(func(): restart_requested.emit())


func show_ending(node: Dictionary) -> void:
	var is_win := String(node.get("ending", "")) == "win"
	var accent := COLOR_WIN if is_win else COLOR_LOSE
	var default_title := "Vitória" if is_win else "Fim de Jogo"

	_title.text = String(node.get("title", default_title))
	_title.add_theme_color_override("font_color", accent)
	_text.text = String(node.get("text", ""))

	_card.add_theme_stylebox_override("panel", _build_card_style(accent))
	_style_restart_button(accent)

	show()
	modulate.a = 0.0
	_card.pivot_offset = _card.size / 2.0
	_card.scale = Vector2(0.96, 0.96)
	var settled_y := _card.position.y
	_card.position.y = settled_y + 16.0

	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, FADE_TIME)
	tw.tween_property(_card, "scale", Vector2.ONE, FADE_TIME)
	tw.tween_property(_card, "position:y", settled_y, FADE_TIME)


func _build_card_style(accent: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = COLOR_PANEL
	sb.set_border_width_all(1)
	sb.border_color = accent
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 54.0
	sb.content_margin_right = 54.0
	sb.content_margin_top = 44.0
	sb.content_margin_bottom = 44.0
	sb.shadow_color = Color(accent.r, accent.g, accent.b, 0.28)
	sb.shadow_size = 24
	return sb


func _style_restart_button(accent: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = COLOR_PANEL
	normal.set_border_width_all(1)
	normal.border_color = accent
	normal.set_corner_radius_all(10)
	normal.content_margin_left = 26.0
	normal.content_margin_right = 26.0
	normal.content_margin_top = 11.0
	normal.content_margin_bottom = 11.0

	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = COLOR_PANEL_HOVER

	_restart_btn.add_theme_stylebox_override("normal", normal)
	_restart_btn.add_theme_stylebox_override("hover", hover)
	_restart_btn.add_theme_stylebox_override("focus", hover)
	_restart_btn.add_theme_stylebox_override("pressed", hover)
	_restart_btn.add_theme_color_override("font_color", accent)
	_restart_btn.add_theme_color_override("font_hover_color", accent)
	_restart_btn.add_theme_color_override("font_focus_color", accent)
	_restart_btn.add_theme_font_size_override("font_size", 15)
