class_name Invest
extends RefCounted
## Utilitários compartilhados dos sistemas de investigação.

## Aplica os `grants` de uma pista/termo via mutações do Game.
## Ordem idêntica à web: evidence → research → task → taskDone → flag.
## NÃO faz o controle de "uma vez só" — quem chama garante (ex.: flag granted_<id>).
static func apply_grants(g: Dictionary) -> void:
	if g.is_empty():
		return
	if g.has("evidence"):
		Game.add_evidence(g["evidence"])
	if g.has("research"):
		Game.unlock_research(g["research"])
	if g.has("task"):
		var t: Dictionary = g["task"]
		Game.add_task(t.get("id", ""), t.get("title", ""), t.get("desc", ""))
	if g.has("taskDone"):
		Game.complete_task(g["taskDone"])
	if g.has("flag"):
		Game.set_flag(g["flag"])
