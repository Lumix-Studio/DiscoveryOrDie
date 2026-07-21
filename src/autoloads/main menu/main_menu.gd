extends Node2D

@onready var animation_playar = $"Top Layar/AnimationPlayer"

func _ready():
	animation_playar.play("In")


func _on_play_focus_exited() -> void:
	print("botão acionado")


func _on_settings_focus_entered() -> void:
	print("botão acionado")
