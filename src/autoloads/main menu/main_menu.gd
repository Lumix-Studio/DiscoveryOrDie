extends Node2D

@onready var animation_playar = $"Top Layar/AnimationPlayer"

# Animação de inicialização
func _ready():
	animation_playar.play("In")


# Animações do botão Play
func _on_play_mouse_entered() -> void:
	animation_playar.play("Play_animation_in")

func _on_play_mouse_exited() -> void:
	# Verifica se a animação está rodadndo, se estiver, ele espera até ela finalizar para fodar outra.
	if animation_playar.is_playing():
		await animation_playar.animation_finished
		animation_playar.play("Play_animation_out")
	else:
		animation_playar.play("Play_animation_out")


# Animações no boão Settings
func _on_settings_mouse_entered() -> void:
	animation_playar.play("Setings_animation_in")

func _on_settings_mouse_exited() -> void:
	if animation_playar.is_playing():
		await animation_playar.animation_finished
		animation_playar.play("Settings_animation_out")
	else:
		animation_playar.play("Settings_animation_out")

# Animações no boão Settings

func _on_quit_mouse_entered() -> void:
	animation_playar.play("Quit_animation_in")

func _on_quit_mouse_exited() -> void:
	if animation_playar.is_playing():
		await animation_playar.animation_finished
		animation_playar.play("Settings_animation_out")
	else:
		animation_playar.play("Quit_animation_out")


# Lógica dos botões
func _on_play_pressed():
	get_tree().change_scene_to_file("res://src/main.tscn")

func _on_settings_pressed():
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit()
