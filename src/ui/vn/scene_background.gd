extends TextureRect
## SceneBackground.gd — cenário de fundo da VN (porte de #scene-layer / applyBg em js/vn.js).
##
## Troca de `bg` com um fade curto: opacidade cai a 0, a textura é trocada,
## opacidade volta a 1. Nó que não declara `bg` simplesmente não chama
## apply_bg() (VNLayer decide isso) — o fundo atual permanece.

const FADE_TIME := 0.22  # bate com `transition: opacity .22s ease` de vn.css

var current_bg := ""

var _tween: Tween


func apply_bg(bg_name: String) -> void:
	if bg_name.is_empty() or bg_name == current_bg:
		return
	var tex_path := "res://assets/backgrounds/bg-%s.svg" % bg_name
	if not ResourceLoader.exists(tex_path):
		push_warning("SceneBackground: asset de fundo ausente -> %s" % tex_path)
		return

	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
	_tween.tween_callback(_swap_texture.bind(tex_path, bg_name))
	_tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)


func _swap_texture(tex_path: String, bg_name: String) -> void:
	texture = load(tex_path)
	current_bg = bg_name
