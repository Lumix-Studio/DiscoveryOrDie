class_name InvestLayer
extends Control
## Camada dos sistemas de investigação (porte de ui.js). HUD, painéis overlay,
## caderno, menu, modo dev e toasts. Reage aos sinais do autoload Game; nunca
## referencia a VNLayer. Funciona sozinha (teste isolado dos sistemas).

const HUD_BUTTONS: Array = [
	{"id": "tasks", "label": "Tarefas", "icon": "📋", "badge": "tasks"},
	{"id": "research", "label": "Pesquisa", "icon": "🔎"},
	{"id": "photos", "label": "Fotos", "icon": "📷", "badge": "photos"},
	{"id": "notebook", "label": "Caderno", "icon": "📓", "badge": "evidence"},
	{"id": "menu", "label": "Menu", "icon": "☰"},
	{"id": "dev", "label": "Dev", "icon": "🛠"},
]

const PANEL_TITLES := {
	"tasks": "Tarefas",
	"research": "Pesquisa nos arquivos",
	"photos": "Fotos",
	"notebook": "Caderno de evidências",
	"menu": "Menu",
	"dev": "Modo dev",
	"photo-viewer": "Análise de foto",
}

const HUD_H := 56.0

var _panel_host: Control
var _hud: Control
var _toast_host: VBoxContainer
var _badge_panels := {}
var _badge_labels := {}

var _current_id: String = ""
var _content_width: float = 520.0
var _active_panel: PanelContainer
var _active_header: PanelContainer
var _active_pad: MarginContainer
var _active_content: VBoxContainer
var _active_title: Label
var _active_w: float = 560.0
var _active_is_viewer := false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_panel_host = Control.new()
	_panel_host.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel_host)

	_build_hud()

	_toast_host = VBoxContainer.new()
	_toast_host.anchor_left = 1.0
	_toast_host.anchor_right = 1.0
	_toast_host.anchor_top = 0.0
	_toast_host.anchor_bottom = 1.0
	_toast_host.offset_left = -334.0
	_toast_host.offset_right = -14.0
	_toast_host.offset_top = 58.0
	_toast_host.offset_bottom = -14.0
	_toast_host.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_toast_host.alignment = BoxContainer.ALIGNMENT_BEGIN
	_toast_host.add_theme_constant_override("separation", 9)
	_toast_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toast_host)

	Game.toast.connect(_on_toast)
	Game.state_changed.connect(_on_state_changed)
	Game.research_unlocked.connect(_on_research_unlocked)

	_update_hud()

# ================================================================= HUD
func _build_hud() -> void:
	_hud = Control.new()
	_hud.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_hud.offset_left = 0.0
	_hud.offset_right = 0.0
	_hud.offset_top = 0.0
	_hud.offset_bottom = HUD_H
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hud)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.06, 0.086, 0.82)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)

	var brand := InvestTheme.label("Discovery or Die", InvestTheme.ACCENT, 18)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brand.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	brand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(brand)

	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 6)
	nav.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(nav)

	for cfg in HUD_BUTTONS:
		nav.add_child(_hud_button(cfg))

func _hud_button(cfg: Dictionary) -> Button:
	var is_dev: bool = cfg["id"] == "dev"
	var b := Button.new()
	b.text = cfg["icon"] + " " + cfg["label"]
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var col := InvestTheme.TEXT_DIM if is_dev else InvestTheme.TEXT
	InvestTheme.style_button(b, InvestTheme.hud_btn(false, is_dev), InvestTheme.hud_btn(true),
		InvestTheme.hud_btn(true), col, 13)
	var id: String = cfg["id"]
	b.pressed.connect(func() -> void: open_panel(id))

	if cfg.has("badge"):
		var badge := PanelContainer.new()
		badge.add_theme_stylebox_override("panel", InvestTheme.badge_box())
		badge.anchor_left = 1.0
		badge.anchor_top = 0.0
		badge.anchor_right = 1.0
		badge.anchor_bottom = 0.0
		badge.offset_left = -14.0
		badge.offset_top = -7.0
		badge.offset_right = 8.0
		badge.offset_bottom = 13.0
		badge.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.visible = false
		var bl := InvestTheme.label("", Color("1a1200"), 11)
		bl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		bl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_child(bl)
		b.add_child(badge)
		_badge_panels[cfg["badge"]] = badge
		_badge_labels[cfg["badge"]] = bl
	return b

func _update_hud() -> void:
	var s: Dictionary = Game.state
	var open_tasks := 0
	for t in s.get("tasks", []):
		if not t.get("done", false):
			open_tasks += 1
	_set_badge("tasks", open_tasks)
	_set_badge("evidence", s.get("evidence", []).size())
	_set_badge("photos", s.get("photos", []).size())

func _set_badge(badge_name: String, n: int) -> void:
	if not _badge_panels.has(badge_name):
		return
	var panel: PanelContainer = _badge_panels[badge_name]
	var lbl: Label = _badge_labels[badge_name]
	if n > 0:
		lbl.text = "99+" if n > 99 else str(n)
		panel.visible = true
	else:
		panel.visible = false

# ================================================================= Painéis
func open_panel(id: String, arg: String = "") -> void:
	if _current_id == id and id != "photo-viewer":
		close_panel()
		return
	close_panel()

	var vp := get_viewport_rect().size
	_active_is_viewer = id == "photo-viewer"
	var target_w := 980.0 if _active_is_viewer else 560.0
	var w: float = minf(target_w, vp.x * (0.96 if _active_is_viewer else 0.94))
	_active_w = w
	_content_width = w - 40.0

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = InvestTheme.BACKDROP
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.gui_input.connect(_on_backdrop_input)
	_panel_host.add_child(backdrop)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", InvestTheme.panel_box())
	panel.clip_contents = true
	backdrop.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 0)
	panel.add_child(vb)

	# header
	var header := PanelContainer.new()
	header.add_theme_stylebox_override("panel", InvestTheme.header_box())
	var hrow := HBoxContainer.new()
	hrow.add_theme_constant_override("separation", 12)
	header.add_child(hrow)
	var title_l := InvestTheme.label(PANEL_TITLES.get(id, "Painel"), InvestTheme.ACCENT, 19)
	title_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hrow.add_child(title_l)
	var close := Button.new()
	close.text = "✕"
	close.custom_minimum_size = Vector2(32, 32)
	close.focus_mode = Control.FOCUS_NONE
	close.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	InvestTheme.style_button(close, InvestTheme.close_btn(false), InvestTheme.close_btn(true),
		InvestTheme.close_btn(true), InvestTheme.TEXT_DIM, 15)
	close.add_theme_color_override("font_hover_color", InvestTheme.TEXT)
	close.pressed.connect(close_panel)
	hrow.add_child(close)
	vb.add_child(header)

	# body
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(scroll)
	var pad := MarginContainer.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_theme_constant_override("margin_left", 16)
	pad.add_theme_constant_override("margin_right", 16)
	pad.add_theme_constant_override("margin_top", 16)
	pad.add_theme_constant_override("margin_bottom", 16)
	scroll.add_child(pad)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	pad.add_child(content)

	_current_id = id
	_active_panel = panel
	_active_header = header
	_active_pad = pad
	_active_content = content
	_active_title = title_l
	Game.panel_open = true

	_render_body(id, content, arg)
	if _active_is_viewer:
		title_l.text = PhotoViewer.title_for(arg)

	_fit_panel(panel, header, pad, w)

func _render_body(id: String, content: VBoxContainer, arg: String) -> void:
	match id:
		"tasks":
			TasksPanel.render(content, _content_width)
		"research":
			var rp := ResearchPanel.new()
			rp.wrap_w = _content_width
			content.add_child(rp)
		"photos":
			PhotoViewer.render_gallery(content, self, _content_width)
		"notebook":
			_render_notebook(content)
		"menu":
			_render_menu(content)
		"dev":
			_render_dev(content)
		"photo-viewer":
			var pv := PhotoViewer.new()
			pv.photo_id = arg
			pv.avail_w = _content_width
			pv.wrap_w = _content_width
			content.add_child(pv)
		_:
			content.add_child(InvestTheme.label("Painel desconhecido.", InvestTheme.TEXT_DIM, 14))

func close_panel() -> void:
	for c in _panel_host.get_children():
		_panel_host.remove_child(c)
		c.queue_free()
	_current_id = ""
	_active_panel = null
	_active_header = null
	_active_pad = null
	_active_content = null
	_active_title = null
	Game.panel_open = false

func _on_backdrop_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close_panel()

func _fit_panel(panel: PanelContainer, header: Control, pad: Control, w: float) -> void:
	await get_tree().process_frame
	if not is_instance_valid(panel) or not is_instance_valid(pad):
		return
	var vp := get_viewport_rect().size
	var maxh := vp.y - 86.0
	var desired := header.get_combined_minimum_size().y + pad.get_combined_minimum_size().y + 2.0
	var h: float = clampf(desired, 140.0, maxh)
	panel.custom_minimum_size = Vector2(w, 0)
	panel.size = Vector2(w, h)
	panel.position = Vector2(round((vp.x - w) / 2.0), round(maxf(64.0, (vp.y - h) / 2.0)))

func _refit() -> void:
	if is_instance_valid(_active_panel):
		_fit_panel(_active_panel, _active_header, _active_pad, _active_w)

# ================================================================= Caderno
func _render_notebook(content: VBoxContainer) -> void:
	for c in content.get_children():
		content.remove_child(c)
		c.queue_free()
	var ev: Array = Game.state.get("evidence", [])
	if ev.is_empty():
		content.add_child(_empty("O caderno está vazio. Colete evidências investigando a cena."))
		return
	var intro := InvestTheme.label("Evidências reunidas na investigação:", InvestTheme.TEXT_DIM, 14, _content_width)
	content.add_child(intro)
	for e in ev:
		var pair := InvestTheme.bar_item_left(InvestTheme.ACCENT_2, InvestTheme.list_item_box())
		var v: VBoxContainer = pair[1]
		var tw: float = maxf(60.0, _content_width - 50.0)
		v.add_child(InvestTheme.label("📓 " + e.get("name", e.get("id", "")), InvestTheme.TEXT, 15, tw))
		if not str(e.get("desc", "")).is_empty():
			var d := InvestTheme.label(e["desc"], InvestTheme.TEXT_DIM, 13, tw)
			d.add_theme_constant_override("line_spacing", 5)
			v.add_child(d)
		if not str(e.get("source", "")).is_empty():
			v.add_child(InvestTheme.label("Origem: " + e["source"], InvestTheme.ACCENT_2, 12, tw))
		content.add_child(pair[0])

# ================================================================= Menu
func _render_menu(content: VBoxContainer) -> void:
	content.add_child(_big_btn("💾 Salvar progresso", _on_save_pressed))
	content.add_child(_big_btn("🗑 Reiniciar jogo", _on_restart_pressed, true))
	var note := InvestTheme.label("O jogo salva automaticamente a cada avanço da investigação.",
		InvestTheme.TEXT_DIM, 13, _content_width)
	content.add_child(note)

# ================================================================= Dev
func _render_dev(content: VBoxContainer) -> void:
	var intro := InvestTheme.label("Atalhos para testar os sistemas de investigação sem jogar a história.",
		InvestTheme.TEXT_DIM, 14, _content_width)
	content.add_child(intro)

	content.add_child(_big_btn("📋 Popular tarefas de exemplo", func() -> void:
		Game.add_task("t_falar_estevan", "Falar com o chefe Estevan", "Descobrir o que ele sabe sobre o desaparecimento de Lorain.")
		Game.add_task("t_analisar_foto", "Analisar a foto da clareira", "Procurar pistas na cena onde Lorain foi vista pela última vez.")
		Game.add_task("t_encontrar_cabana", "Encontrar a cabana do caçador", "Seguir a trilha norte até a cabana abandonada.")
		Game.complete_task("t_falar_estevan")
		open_panel("tasks")))

	content.add_child(_big_btn("🔎 Desbloquear termos de pesquisa", func() -> void:
		Game.unlock_research("vila")
		Game.unlock_research("lorain")
		Game.unlock_research("trilha_norte")
		open_panel("research")))

	content.add_child(_big_btn("📷 Desbloquear foto da clareira", func() -> void:
		Game.unlock_photo("foto_clareira")
		open_panel("photos")))

	content.add_child(_big_btn("📷 Abrir foto da clareira", func() -> void:
		Game.unlock_photo("foto_clareira")
		open_panel("photo-viewer", "foto_clareira")))

	content.add_child(_big_btn("📓 Adicionar evidências de exemplo", func() -> void:
		Game.add_evidence({"id": "ev_demo_bota", "name": "Marca de bota", "desc": "Marca de bota grande fincada na lama, apontando para o norte.", "source": "Modo dev"})
		Game.add_evidence({"id": "ev_demo_fogueira", "name": "Fogueira recente", "desc": "Restos de uma fogueira apagada há poucas horas na beira da clareira.", "source": "Modo dev"})
		open_panel("notebook")))

	content.add_child(_big_btn("🗑 Limpar save e recarregar", _on_wipe_pressed, true))

# ================================================================= Toasts
func _on_toast(msg: String, type: String) -> void:
	var pair := InvestTheme.bar_item_left(InvestTheme.type_color(type), InvestTheme.toast_box(type))
	var frame: PanelContainer = pair[0]
	var v: VBoxContainer = pair[1]
	frame.mouse_filter = Control.MOUSE_FILTER_STOP
	frame.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var lbl := InvestTheme.label(msg, InvestTheme.TEXT, 13, 275.0)
	lbl.add_theme_constant_override("line_spacing", 3)
	v.add_child(lbl)
	_toast_host.add_child(frame)

	frame.modulate.a = 0.0
	var tin := create_tween()
	tin.tween_property(frame, "modulate:a", 1.0, 0.28)

	frame.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed:
			_dismiss_toast(frame))
	get_tree().create_timer(3.5).timeout.connect(func() -> void: _dismiss_toast(frame))

func _dismiss_toast(frame: PanelContainer) -> void:
	if not is_instance_valid(frame):
		return
	if frame.get_meta("dying", false):
		return
	frame.set_meta("dying", true)
	var tw := create_tween()
	tw.tween_property(frame, "modulate:a", 0.0, 0.3)
	tw.tween_callback(frame.queue_free)

# ================================================================= sinais Game
func _on_state_changed() -> void:
	_update_hud()
	match _current_id:
		"tasks":
			TasksPanel.render(_active_content, _content_width)
			_refit()
		"notebook":
			_render_notebook(_active_content)
			_refit()
		"photos":
			PhotoViewer.render_gallery(_active_content, self, _content_width)
			_refit()

func _on_research_unlocked(term_id: String) -> void:
	Game.toast.emit("🔎 Novo termo de pesquisa: " + ResearchPanel.title_for(term_id), "info")

# ================================================================= entrada teclado
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _current_id != "":
			close_panel()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("dev_panel"):
		var fo := get_viewport().gui_get_focus_owner()
		if fo is LineEdit:
			return
		open_panel("dev")
		get_viewport().set_input_as_handled()

# ================================================================= helpers
func _big_btn(label: String, cb: Callable, danger: bool = false) -> Button:
	var b := Button.new()
	b.text = label
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col := Color("eba9a7") if danger else InvestTheme.TEXT
	InvestTheme.style_button(b, InvestTheme.big_btn(false, danger), InvestTheme.big_btn(true, danger),
		InvestTheme.big_btn(true, danger), col, 14)
	b.pressed.connect(cb)
	return b

func _on_save_pressed() -> void:
	Game.save()
	Game.toast.emit("💾 Progresso salvo.", "success")

func _on_restart_pressed() -> void:
	_confirm("Reiniciar o jogo? Todo o progresso salvo será apagado.", Game.reset)

func _on_wipe_pressed() -> void:
	_confirm("Limpar o save e recarregar a página?", Game.reset)

func _empty(text: String) -> Label:
	var l := InvestTheme.label(text, InvestTheme.TEXT_DIM, 14, _content_width)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_constant_override("line_spacing", 4)
	return l

func _confirm(text: String, on_ok: Callable) -> void:
	var dlg := ConfirmationDialog.new()
	dlg.dialog_text = text
	dlg.title = "Confirmar"
	dlg.ok_button_text = "Confirmar"
	dlg.get_cancel_button().text = "Cancelar"
	add_child(dlg)
	dlg.confirmed.connect(on_ok)
	dlg.confirmed.connect(dlg.queue_free)
	dlg.canceled.connect(dlg.queue_free)
	dlg.close_requested.connect(dlg.queue_free)
	dlg.popup_centered()
