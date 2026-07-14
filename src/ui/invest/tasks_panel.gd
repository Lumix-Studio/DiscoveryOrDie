class_name TasksPanel
extends RefCounted
## Renderização do painel de Tarefas (porte de tasks.js::renderPanel).
## Abertas primeiro, concluídas riscadas embaixo. Sem estado próprio: lê Game.state.

static func render(content: VBoxContainer, wrap_w: float) -> void:
	for c in content.get_children():
		content.remove_child(c)
		c.queue_free()
	content.add_theme_constant_override("separation", 9)

	var all: Array = Game.state.get("tasks", [])
	if all.is_empty():
		content.add_child(_empty("Nenhuma tarefa no momento. A investigação vai gerar novas tarefas.", wrap_w))
		return

	var open_tasks: Array = []
	var done_tasks: Array = []
	for t in all:
		if t.get("done", false):
			done_tasks.append(t)
		else:
			open_tasks.append(t)

	var intro_txt := "Todas as tarefas foram concluídas."
	if open_tasks.size() > 0:
		intro_txt = "Você tem %d tarefa(s) em aberto." % open_tasks.size()
	var intro := InvestTheme.label(intro_txt, InvestTheme.TEXT_DIM, 14, wrap_w)
	intro.add_theme_constant_override("line_spacing", 4)
	content.add_child(intro)

	for t in open_tasks:
		content.add_child(_item(t, wrap_w))
	for t in done_tasks:
		content.add_child(_item(t, wrap_w))

static func _item(t: Dictionary, wrap_w: float) -> Control:
	var done: bool = t.get("done", false)
	var bar := InvestTheme.SUCCESS if done else InvestTheme.ACCENT
	var pair := InvestTheme.bar_item_left(bar, InvestTheme.list_item_box())
	var pc: PanelContainer = pair[0]
	var v: VBoxContainer = pair[1]
	if done:
		pc.modulate.a = 0.6

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 11)
	v.add_child(row)

	var mark := InvestTheme.label("✔" if done else "○", bar, 15)
	mark.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_child(mark)

	var textcol := VBoxContainer.new()
	textcol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textcol.add_theme_constant_override("separation", 3)
	row.add_child(textcol)

	var title: String = t.get("title", t.get("id", ""))
	var tw: float = maxf(60.0, wrap_w - 50.0)
	if done:
		textcol.add_child(InvestTheme.rich("[s]%s[/s]" % title, InvestTheme.TEXT_DIM, 15, tw))
	else:
		textcol.add_child(InvestTheme.label(title, InvestTheme.TEXT, 15, tw))

	var desc: String = t.get("desc", "")
	if not desc.is_empty():
		textcol.add_child(InvestTheme.label(desc, InvestTheme.TEXT_DIM, 13, tw))

	return pc

static func _empty(text: String, wrap_w: float) -> Label:
	var l := InvestTheme.label(text, InvestTheme.TEXT_DIM, 14, wrap_w)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_constant_override("line_spacing", 4)
	return l
