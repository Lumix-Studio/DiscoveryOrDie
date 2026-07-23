# Sistema de Save

> **Desenvolvedor:** Veilcruss   
> **Código:** [save_system.gd](/src/system/save/save_system.gd)

Separa a responsabilidade do sistema de save do [game.gd](/src/autoloads/game.gd).

### Métodos:

* **save_resource(resource: SavePattern, path:String) -> void**
    - **Parâmetros:**
        1. `resource` — recebe um `Resource` do tipo `SavePattern`
        2. `path` — recebe o caminho que o resource será salvo
    
    * **Ação:** Salva o `Resource` em um arquivo de extensão `.tres`/`.res`

* **load_resource(path:String) -> SavePattern**
    - **Parâmetro:** `path` recebe o caminho onde o save está
    * **Ação:** Retorna o Resource `SavePattern` carregado se existir, caso contrário retorna um novo

<br>

>**Integração:** Crie um objeto do tipo `SaveSystem` para ter acesso aos métodos, diferente de um script herdado de Node/2D/3D, um script herdado de `RefCounted` não necessita de métodos instanciamento como `add_child()`, com o class_name, todo o projeto tem acesso a esse script como objeto. Ex:
> ## Criando
> ```gdscript
>
> const FILE_PATH = "res://src/config/script.tres"
> var new_resource:SavePattern = SavePattern.new()
> new_resource.node = "Node2D"
>
> var save: SaveSystem = SaveSystem.new()
> save.save_resource(new_resource, FILE_PATH) 
>```
>
> ## Carregando
>```gdscript
> const FILE_PATH = "res://src/config/script.tres"
>
> var loaded_resource:SavePattern
> var save: SaveSystem = SaveSystem.new()
>
> # carrega o save se existir, caso contraio cria um save limpo
> loaded_resource = save.load_resource(FILE_PATH)
>```
