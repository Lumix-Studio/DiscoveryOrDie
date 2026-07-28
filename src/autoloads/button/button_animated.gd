extends Button

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	anim.play("hover_in")
func _on_mouse_exited():
	anim.play("hover_out")
