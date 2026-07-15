# Arquivo Modelo de Save

> **Desenvolvedor:** Veilcruss   
> **Código:** [save_pattern.gd](/src/system/save/save_pattern.gd)

Arquivo base para resources `SavePattern` substitui o uso de JSON para um sistema de serialização automatica e nativa da Godot.

| Variável      | Tipo         | Descrição                                                                            |
| ------------- | ------------ | ------------------------------------------------------------------------------------ |
| `node`        | `String`     | Nó atual do roteiro. Indica a posição atual do jogador na narrativa.                 |
| `bg`          | `String`     | Último cenário aplicado. Persiste entre nós do roteiro.                              |
| `chars`       | `Array`      | Últimos personagens presentes em cena. Persiste entre nós do roteiro.                |
| `flags`       | `Dictionary` | Armazena flags de história, usadas para controlar estados e decisões narrativas.     |
| `evidence`    | `Array`      | Lista de evidências coletadas. Cada item segue o formato `{id, name, desc, source}`. |
| `tasks`       | `Array`      | Lista de tarefas ou objetivos. Cada item segue o formato `{id, title, desc, done}`.  |
| `research`    | `Array`      | IDs de termos de pesquisa desbloqueados pelo jogador.                                |
| `photos`      | `Array`      | IDs de fotos desbloqueadas pelo jogador.                                             |
| `found_clues` | `Dictionary` | Armazena pistas encontradas durante a investigação.                                  |


> **Integração**: Utilize `SavePattern.new()` para criar um objeto da classe `SavePattern`, quando criado, faça atribuições como:
>```
>var new_save:SavePattern = SavePattern.new()
>new_save.node = "Node2D"
>```
> Assim você terá um `Resource` em memória, para salvar esse resource, utilize um objeto da classe [SaveSystem](save_system.md)