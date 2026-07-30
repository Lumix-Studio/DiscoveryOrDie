# Main menu

## Animation system

Em src/autoloads/button você irá encontrar o "button_animated" irei explicar-lo como funciona:

```
func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
```

Resumidamente: Ao script ser rodado, ele conecta o evento de "_on_mouse_entered" e "_on_mouse_exited". Para quando o mouse estiver em cima do botão e quando não.

Isso serve para não precizar de varios sinais de varios botões diferentes. Ele preciza apenas de um script que pode ser acoplado em 2 ou mais botões.

```
func _on_mouse_entered():
	anim.play("hover_in")
func _on_mouse_exited():
	anim.play("hover_out")
```

Aqui, ele usa as funções de "_on_mouse_entered" e "_on_mouse_exited" que, caso algumas dessas funções forem veridicas, ele chamará o "anim" presente na linha: "@onready var anim: AnimationPlayer = $AnimationPlayer"

## Como integrar esse sistema em outros botões?

Para acoplar esse sistema em vários botões, você preciza cunprir alkguns requisitos:

* 1: O sistema deve funcionar/ser projetado para mais de 1 botão. Ou seja, o sistema deve ser pensado para rodar em mais de um botão.

Caso não queira que funcione para todos os botões, use os sinais.

* 2: Para animações: Caso o seu sistema utilize animações para todos os botões, faça uma animação para todos os "AnimationPlayar" que estão como filhos dos botões. 

### Na pratica

Na pratca, para inplementar algo para 1 ou mais botões (animações por exenplo) você:

1: Adicione um AnimationPlayar (como filho) para cada botão;

2: Adicione duas animações com o nome de "hove_in" "hover_out" (Como exenplo) para todos os AnimationPlayar (OBS: não preciza ser exatamente a mesma animação, mas preciza ter o mesmo nome)

3: Conecte os eventos com:

```
func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
```

Depois

func _on_mouse_entered():
	anim.play("hover_in")
func _on_mouse_exited():
	anim.play("hover_out")
```

Caso queira por outras animações, mude o nome da animação e a animação em si.

#### Se for adicionar apenas uma ou mais animações para apenas um botão

Utilize sinais do pórprio botão

> Pronto. Agora você entendeu como o sistema funciona 