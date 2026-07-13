extends Panel
## DialogueBox.gd — caixa de diálogo com efeito typewriter
## (porte de #dialogue-box / startDialogue+finishTyping em js/vn.js).
##
## Puramente apresentação: não decide nada sobre o roteiro. Emite `clicked`
## a cada clique válido e `typewriter_completed` quando o texto termina de
## aparecer (natural ou por clique de "pular"); quem decide o que fazer com
## isso é o VNLayer (dono do nó atual).

signal clicked
signal typewriter_completed

const TYPE_SECONDS_PER_CHAR := 0.025  # 25ms/char, bate com TYPE_MS de vn.js

const COLOR_TEXT := Color("e6edf3")
const COLOR_TEXT_DIM := Color("9db1c5")
const COLOR_ACCENT := Color("d4a843")

const SPEAKER_COLORS := {
	"bohr": Color("d4a843"),
	"jhon": Color("4f9de0"),
	"estevan": Color("e2954a"),
	"ana": Color("7fc29b"),
	"rurik": Color("d9534f"),
	"lorain": Color("c893e0"),
}

@onready var _chip: Control = $SpeakerChip
@onready var _speaker_label: Label = $SpeakerChip/SpeakerName
@onready var _text_label: Label = $DialogueText
@onready var _hint: Label = $DialogueHint

var _typing := false
var _type_tween: Tween
var _hint_tween: Tween
var _hint_base_y: float
var _italic_font: FontVariation


func _ready() -> void:
	_hint_base_y = _hint.position.y
	_italic_font = FontVariation.new()
	_italic_font.base_font = ThemeDB.fallback_font
	_italic_font.variation_transform = Transform2D(Vector2(1, 0), Vector2(0.22, 1), Vector2(0, 0))
	_hint.hide()
	gui_input.connect(_on_gui_input)


func start_node(speaker: String, text: String) -> void:
	_hide_hint_instant()
	_apply_speaker_style(speaker)
	_begin_typewriter(text)


func _apply_speaker_style(speaker: String) -> void:
	var is_narrator := speaker.is_empty()
	_chip.visible = not is_narrator
	if is_narrator:
		_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_text_label.add_theme_color_override("font_color", COLOR_TEXT_DIM)
		_text_label.add_theme_font_override("font", _italic_font)
	else:
		var speaker_id := speaker.to_lower()
		_speaker_label.text = speaker
		_speaker_label.add_theme_color_override("font_color", SPEAKER_COLORS.get(speaker_id, COLOR_ACCENT))
		_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_text_label.add_theme_color_override("font_color", COLOR_TEXT)
		_text_label.remove_theme_font_override("font")


func _begin_typewriter(text: String) -> void:
	if _type_tween and _type_tween.is_valid():
		_type_tween.kill()

	_text_label.text = text
	var total := text.length()
	_typing = true

	if total <= 0:
		_finish_typing()
		return

	_text_label.visible_characters = 0
	_type_tween = create_tween()
	_type_tween.tween_property(_text_label, "visible_characters", total, total * TYPE_SECONDS_PER_CHAR)
	_type_tween.tween_callback(_finish_typing)


func is_typing() -> bool:
	return _typing


## Chamado de fora (clique) para pular direto ao fim do typewriter.
func finish_typing() -> void:
	if not _typing:
		return
	_finish_typing()


func _finish_typing() -> void:
	if _type_tween and _type_tween.is_valid():
		_type_tween.kill()
	_typing = false
	_text_label.visible_characters = -1
	typewriter_completed.emit()


func show_hint() -> void:
	_hint.show()
	_hint.modulate.a = 0.25
	_hint.position.y = _hint_base_y
	if _hint_tween and _hint_tween.is_valid():
		_hint_tween.kill()
	_hint_tween = create_tween()
	_hint_tween.set_loops()
	_hint_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_hint_tween.tween_property(_hint, "modulate:a", 1.0, 0.7)
	_hint_tween.parallel().tween_property(_hint, "position:y", _hint_base_y + 3.0, 0.7)
	_hint_tween.tween_property(_hint, "modulate:a", 0.25, 0.7)
	_hint_tween.parallel().tween_property(_hint, "position:y", _hint_base_y, 0.7)


func hide_hint() -> void:
	_hide_hint_instant()


func _hide_hint_instant() -> void:
	if _hint_tween and _hint_tween.is_valid():
		_hint_tween.kill()
	_hint.hide()


func show_box() -> void:
	show()


func hide_box() -> void:
	hide_hint()
	hide()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit()
