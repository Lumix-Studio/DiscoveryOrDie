extends Resource
class_name SavePattern

@export var node:String           # nó atual do roteiro
@export var bg:String			  # último cenário aplicado (persiste entre nós)
@export var chars:Array			  # últimos personagens em cena (persistem entre nós)
@export var flags:Dictionary      # flags de história
@export var evidence:Array		  # [{id, name, desc, source}]
@export var tasks:Array           # [{id, title, desc, done}]
@export var research:Array        # ids de termos desbloqueados
@export var photos:Array          # ids de fotos desbloqueadas
@export var found_clues:Dictionary
