class_name ResearchPanel
extends VBoxContainer
## Sistema de pesquisa nos arquivos da vila (porte de research.js).
## Termo desbloqueado vira chip clicável; termo secreto digitado exato também
## funciona. Grants aplicados UMA vez, no momento da busca (flag granted_<id>).

# ------------------------------------------------------------------ base de termos
const TERMS: Array = [
	{
		"id": "vila",
		"aliases": ["vila", "vila da floresta"],
		"title": "Vila da Floresta",
		"body": "Povoado isolado às margens da mata, com pouco mais de cinquenta famílias que vivem da caça e da coleta. A comunidade é fechada e vê forasteiros com desconfiança. Toda decisão importante passa pelo chefe Estevan, que governa o lugar há quase vinte anos com mão firme.",
	},
	{
		"id": "lorain",
		"aliases": ["lorain"],
		"title": "Lorain — Registro de Desaparecimento",
		"body": "Lorain, 17 anos, filha de um dos coletores da vila. Descrita como quieta e de hábitos regulares, jamais passava a noite fora de casa. Foi vista pela última vez na clareira ao norte do povoado, ao entardecer de três dias atrás. Não retornou e ninguém relatou sinais de luta no local.",
	},
	{
		"id": "trilha_norte",
		"aliases": ["trilha norte", "trilha"],
		"title": "Trilha Norte",
		"body": "Antiga trilha de caça que corta a mata rumo ao norte, hoje evitada pelos moradores. Registros da vila mencionam armadilhas montadas ao longo do caminho, algumas nunca recolhidas. Dizem por aqui que ninguém em sã consciência se embrenha por ali depois do anoitecer.",
		"grants": {
			"evidence": {
				"id": "ev_armadilha",
				"name": "Armadilha de caça",
				"desc": "Armadilha recente perto da trilha norte — alguém ainda caça por lá.",
				"source": "Pesquisa: trilha norte",
			},
		},
	},
	{
		"id": "rurik",
		"aliases": ["rurik", "caçador", "cacador"],
		"title": "Rurik — O Caçador",
		"body": "Rurik foi o melhor caçador que a vila já teve, até se indispor com o chefe Estevan há dois anos. Depois de uma discussão violenta a respeito das terras de caça, foi expulso do povoado e proibido de voltar. Consta que passou a viver sozinho numa cabana abandonada, mata adentro. Desde então, ninguém mais teve notícias dele.",
		"grants": {
			"research": "cabana",
		},
	},
	{
		"id": "cabana",
		"aliases": ["cabana", "cabana abandonada"],
		"title": "Cabana Abandonada",
		"body": "Velha cabana de madeira erguida ao fim da trilha norte, meio engolida pelo mato. Serviu de posto de caça por décadas antes de ser abandonada. Nas últimas semanas, moradores juram ter visto fumaça saindo de sua chaminé — estranho, para um lugar que deveria estar vazio.",
		"unlocked_by": "rurik",
		"grants": {
			"evidence": {
				"id": "ev_cabana",
				"name": "Localização da cabana",
				"desc": "Cabana de caçador abandonada ao fim da trilha norte.",
				"source": "Pesquisa: cabana abandonada",
			},
			"taskDone": "t_encontrar_cabana",
		},
	},
]

const _ACCENT_MAP := {
	"á": "a", "à": "a", "â": "a", "ã": "a", "ä": "a",
	"é": "e", "è": "e", "ê": "e", "ë": "e",
	"í": "i", "ì": "i", "î": "i", "ï": "i",
	"ó": "o", "ò": "o", "ô": "o", "õ": "o", "ö": "o",
	"ú": "u", "ù": "u", "û": "u", "ü": "u",
	"ç": "c", "ñ": "n",
}

# ------------------------------------------------------------------ dados (estático)
static func find_term(id: String) -> Dictionary:
	for t in TERMS:
		if t["id"] == id:
			return t
	return {}

static func title_for(id: String) -> String:
	var t := find_term(id)
	return t["title"] if not t.is_empty() else id

static func strip_accents(s: String) -> String:
	var out := ""
	for ch in s:
		out += _ACCENT_MAP.get(ch, ch)
	return out

## Normaliza: minúsculas, sem acentos, espaços colapsados (porte de research.js::norm).
static func norm(s: String) -> String:
	var t := strip_accents(s.to_lower().strip_edges())
	return " ".join(t.split(" ", false))

static func match_query(q: String) -> Dictionary:
	var nq := norm(q)
	if nq.is_empty():
		return {}
	for t in TERMS:
		for a in t["aliases"]:
			if norm(a) == nq:
				return t
	return {}

# ------------------------------------------------------------------ instância / UI
var wrap_w: float = 480.0
var _chips: HFlowContainer
var _search_input: LineEdit
var _result: VBoxContainer

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 12)
	_build()
	if not Game.research_unlocked.is_connected(_on_research_unlocked):
		Game.research_unlocked.connect(_on_research_unlocked)

func _build() -> void:
	var intro := InvestTheme.label(
		"Consulte os arquivos e registros da vila. Clique num termo conhecido ou digite o que quer investigar.",
		InvestTheme.TEXT_DIM, 14, wrap_w)
	intro.add_theme_constant_override("line_spacing", 5)
	add_child(intro)

	_chips = HFlowContainer.new()
	_chips.add_theme_constant_override("h_separation", 7)
	_chips.add_theme_constant_override("v_separation", 7)
	add_child(_chips)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	add_child(row)

	_search_input = LineEdit.new()
	_search_input.placeholder_text = "Digite um termo… (ex.: Lorain)"
	_search_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	InvestTheme.style_line_edit(_search_input)
	_search_input.text_submitted.connect(_on_submit)
	row.add_child(_search_input)

	var btn := Button.new()
	btn.text = "Pesquisar"
	InvestTheme.style_button(btn, InvestTheme.search_btn(false), InvestTheme.search_btn(true),
		InvestTheme.search_btn(true), InvestTheme.ACCENT, 14)
	btn.pressed.connect(_do_search_from_input)
	row.add_child(btn)

	_result = VBoxContainer.new()
	_result.add_theme_constant_override("separation", 8)
	add_child(_result)
	_show_placeholder()

	_refresh_chips()
	_search_input.call_deferred("grab_focus")

func _refresh_chips() -> void:
	if _chips == null or not is_instance_valid(_chips):
		return
	for c in _chips.get_children():
		_chips.remove_child(c)
		c.queue_free()
	var ids: Array = Game.state.get("research", [])
	if ids.is_empty():
		var hint := InvestTheme.label(
			"Nenhum termo conhecido ainda — investigue a cena para descobrir pistas.",
			InvestTheme.TEXT_DIM, 13)
		_chips.add_child(hint)
		return
	for id in ids:
		var term := find_term(id)
		if term.is_empty():
			continue
		var chip := Button.new()
		chip.text = "🔎 " + term["title"]
		InvestTheme.style_button(chip, InvestTheme.chip_box(false), InvestTheme.chip_box(true),
			InvestTheme.chip_box(true), InvestTheme.TEXT, 13)
		var alias0: String = term["aliases"][0]
		var title: String = term["title"]
		chip.pressed.connect(func() -> void:
			_search_input.text = title
			search(alias0))
		_chips.add_child(chip)

func _on_submit(_t: String) -> void:
	_do_search_from_input()

func _do_search_from_input() -> void:
	if _search_input.text.strip_edges().is_empty():
		return
	search(_search_input.text)

## Pesquisa um texto livre. Desbloqueia termo secreto digitado exato (silencioso,
## como a web) e aplica grants uma única vez.
func search(text: String) -> void:
	var term := match_query(text)
	if term.is_empty():
		_show_no_result(text)
		return
	if not (term["id"] in Game.state.research):
		Game.state.research.append(term["id"])
		Game.save()
		_refresh_chips()
	_apply_grants_once(term)
	_show_result(term)

func _apply_grants_once(term: Dictionary) -> void:
	var key := "granted_" + str(term["id"])
	if Game.has_flag(key):
		return
	Game.set_flag(key)
	if term.has("grants"):
		Invest.apply_grants(term["grants"])

func _clear_result() -> void:
	for c in _result.get_children():
		_result.remove_child(c)
		c.queue_free()

func _show_placeholder() -> void:
	_clear_result()
	var l := InvestTheme.label("Nenhuma consulta ainda.", InvestTheme.TEXT_DIM, 14)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result.add_child(l)

func _show_result(term: Dictionary) -> void:
	_clear_result()
	var pair := InvestTheme.bar_item_top(InvestTheme.ACCENT, InvestTheme.result_card_box())
	var pc: PanelContainer = pair[0]
	var v: VBoxContainer = pair[1]
	v.add_child(InvestTheme.label(term["title"], InvestTheme.ACCENT, 17, wrap_w - 40.0))
	var body := InvestTheme.label(term["body"], InvestTheme.TEXT, 14, wrap_w - 40.0)
	body.add_theme_constant_override("line_spacing", 6)
	v.add_child(body)
	_result.add_child(pc)

func _show_no_result(text: String) -> void:
	_clear_result()
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", InvestTheme.no_result_box())
	var msg := "Nenhum registro encontrado para “%s”." % text.strip_edges()
	var l := InvestTheme.label(msg, InvestTheme.TEXT_DIM, 14, wrap_w - 40.0)
	pc.add_child(l)
	_result.add_child(pc)

func _on_research_unlocked(_term_id: String) -> void:
	_refresh_chips()
