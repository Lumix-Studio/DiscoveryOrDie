extends Node2D

# notas: tenho que ajeitar a lógica, pois se eu passar o mouse muito rápido pelos boões, ele fica travado em uma animações
# Pelo visto, tenho que adicionar um animation playar para cada objeto mesmo, desgra-s

# Variáveis 
@onready var anim = $"Top Layar/AnimationPlayer"

func _ready() -> void:
	anim.play("In")

# Lógica de botões:
func _on_play_pressed() -> void:
	anim.play("Out")
	await anim.animation_finished
	get_tree().change_scene_to_file("res://src/main.tscn")

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	anim.play("Out")
	await anim.animation_finished
	get_tree().quit(0)
