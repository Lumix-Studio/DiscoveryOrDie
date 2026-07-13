extends Node
## Game.gd — autoload singleton (CONTRATO entre módulos).
##
## Toda mutação de estado passa por aqui e emite sinais; as camadas de UI
## (VNLayer, InvestLayer) apenas reagem aos sinais e leem `state`.
##
## Roteiro: `script_data` = data/script.json → { "startNode": String, "nodes": {...} }
## Nó: { id, bg?, chars?: [{id, pos}], speaker?, text?, next?,
##       choices?: [{text, next, if?}], actions?: [[tipo, ...args]],
##       ending?: "win"|"lose", title? }
##
## Ações (run_action): ["task", id, title, desc?] ["taskDone", id]
##   ["evidence", {id, name, desc, source?}] ["research", termId]
##   ["photo", photoId] ["flag", nome, valor?]
##
## Condições (check): { "flag": x } { "notFlag": x } { "taskDone": id }
##   { "evidence": id ou [ids] }

signal toast(msg: String, type: String)          # type: "info" | "success" | "warn"
signal state_changed                              # badges/HUD devem re-renderizar
signal task_added(task: Dictionary)
signal task_completed(task: Dictionary)
signal evidence_added(ev: Dictionary)
signal research_unlocked(term_id: String)
signal photo_unlocked(photo_id: String)

const SAVE_PATH := "user://dod-save.json"
const SCRIPT_PATH := "res://data/script.json"

var state: Dictionary = {}
var script_data: Dictionary = {}
## true enquanto um painel overlay (tarefas/pesquisa/foto/...) está aberto.
## InvestLayer seta; VNLayer não avança diálogo enquanto true.
var panel_open := false

func _ready() -> void:
	script_data = _load_json(SCRIPT_PATH)
	load_save()

func default_state() -> Dictionary:
	return {
		"node": "",           # nó atual do roteiro
		"bg": "",             # último cenário aplicado (persiste entre nós)
		"chars": [],          # últimos personagens em cena (persistem entre nós)
		"flags": {},          # flags de história
		"evidence": [],       # [{id, name, desc, source}]
		"tasks": [],          # [{id, title, desc, done}]
		"research": [],       # ids de termos desbloqueados
		"photos": [],         # ids de fotos desbloqueadas
		"found_clues": {},    # photo_id -> [clue_ids]
	}

# ------------------------------------------------------------------ save/load

func save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(state))

func load_save() -> bool:
	state = default_state()
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return false
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		state.merge(parsed, true)
		return true
	return false

func reset() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	state = default_state()
	panel_open = false
	get_tree().reload_current_scene()

# ------------------------------------------------------------------ mutações

func add_task(id: String, title: String, desc := "") -> void:
	for t in state.tasks:
		if t.id == id:
			return
	var task := {"id": id, "title": title, "desc": desc, "done": false}
	state.tasks.append(task)
	toast.emit("📋 Nova tarefa: %s" % title, "info")
	task_added.emit(task)
	_changed()

func complete_task(id: String) -> void:
	for t in state.tasks:
		if t.id == id and not t.done:
			t.done = true
			toast.emit("✔ Tarefa concluída: %s" % t.title, "success")
			task_completed.emit(t)
			_changed()
			return

func is_task_done(id: String) -> bool:
	for t in state.tasks:
		if t.id == id:
			return t.done
	return false

func add_evidence(ev: Dictionary) -> void:
	for e in state.evidence:
		if e.id == ev.id:
			return
	state.evidence.append(ev)
	toast.emit("📓 Evidência: %s" % ev.get("name", ev.id), "success")
	evidence_added.emit(ev)
	_changed()

func has_evidence(id: String) -> bool:
	for e in state.evidence:
		if e.id == id:
			return true
	return false

func set_flag(flag_name: String, value: bool = true) -> void:
	state.flags[flag_name] = value
	save()

func has_flag(flag_name: String) -> bool:
	return state.flags.get(flag_name, false)

func unlock_research(term_id: String) -> void:
	if term_id in state.research:
		return
	state.research.append(term_id)
	research_unlocked.emit(term_id)
	_changed()

func unlock_photo(photo_id: String) -> void:
	if photo_id in state.photos:
		return
	state.photos.append(photo_id)
	toast.emit("📷 Nova foto disponível", "info")
	photo_unlocked.emit(photo_id)
	_changed()

# ------------------------------------------------------------------ roteiro

func run_action(action: Array) -> void:
	if action.is_empty():
		return
	var args := action.slice(1)
	match String(action[0]):
		"task":
			add_task(args[0], args[1], args[2] if args.size() > 2 else "")
		"taskDone":
			complete_task(args[0])
		"evidence":
			add_evidence(args[0])
		"research":
			unlock_research(args[0])
		"photo":
			unlock_photo(args[0])
		"flag":
			set_flag(args[0], args[1] if args.size() > 1 else true)
		_:
			push_warning("Ação desconhecida: %s" % str(action))

func check(cond: Variant) -> bool:
	if cond == null or not (cond is Dictionary):
		return true
	if cond.has("flag") and not has_flag(cond.flag):
		return false
	if cond.has("notFlag") and has_flag(cond.notFlag):
		return false
	if cond.has("taskDone") and not is_task_done(cond.taskDone):
		return false
	if cond.has("evidence"):
		var ids: Array = cond.evidence if cond.evidence is Array else [cond.evidence]
		for id in ids:
			if not has_evidence(id):
				return false
	return true

# ------------------------------------------------------------------ interno

func _changed() -> void:
	state_changed.emit()
	save()

func _load_json(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Não foi possível abrir %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	return parsed if parsed is Dictionary else {}
