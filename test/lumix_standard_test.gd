extends Node
## Validação automatizada do PADRÃO LUMIX STUDIO (estrutura de pastas, nomes de
## arquivo, arquivos obrigatórios, ausência de layout legado). Roda headless e
## falha (exit ≠ 0) se o projeto divergir do padrão descrito em
## lumix-docs/📁 Desenvolvimento/Estrutura-Interna-Padrao.md.
##   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . res://test/lumix_standard_test.tscn
## Também roda dentro de test_suite.tscn (com autorun=false → sem quit próprio).

@export var autorun := true
var fails := 0
var checks := 0

# Pastas do layout pré-padrão (que a reorganização eliminou). Construídas como
# nomes soltos de propósito: assim o literal "res://<nome>/" não existe neste
# arquivo e a auto-varredura da checagem 5 não gera falso positivo sobre ele.
const LEGACY_DIRS := ["scripts", "scenes", "data"]

func ok(cond: bool, msg: String) -> void:
	checks += 1
	if cond:
		print("  ✓ ", msg)
	else:
		fails += 1
		printerr("  ✗ FAIL: ", msg)

func _ready() -> void:
	if not autorun:
		return
	await run()
	print("\n%d/%d checagens de padrão OK" % [checks - fails, checks])
	get_tree().quit(1 if fails > 0 else 0)

func run() -> void:
	await get_tree().process_frame

	# 1. Pastas obrigatórias do padrão
	for d in ["res://src", "res://src/autoloads", "res://src/config", "res://src/ui",
			"res://docs", "res://docs/developer_doc", "res://assets"]:
		ok(DirAccess.dir_exists_absolute(d), "existe a pasta obrigatória %s" % d)

	# 2. Arquivos obrigatórios na raiz
	for f in ["res://project.godot", "res://README.md", "res://.editorconfig"]:
		ok(FileAccess.file_exists(f), "existe o arquivo obrigatório %s" % f)
	ok(FileAccess.file_exists("res://icon.svg") or FileAccess.file_exists("res://icon.png"),
			"existe um ícone na raiz (icon.svg ou icon.png)")

	# 3. Layout legado ausente
	for d in LEGACY_DIRS:
		ok(not DirAccess.dir_exists_absolute("res://" + d), "NÃO existe a pasta legada res://%s/" % d)

	# 4. Autoload apontando para src/autoloads/
	var cfg := FileAccess.get_file_as_string("res://project.godot")
	ok("res://src/autoloads/" in cfg, "autoload(s) do project.godot apontam para src/autoloads/")

	# 5. + 6. Varredura de código: sem refs legadas + nomes .gd em snake_case
	var files := _walk("res://src")
	files.append_array(_walk("res://test"))
	var old_refs: Array[String] = []
	var bad_names: Array[String] = []
	for path in files:
		var ext := path.get_extension()
		if ext in ["gd", "tscn", "godot", "import", "tres"]:
			var text := FileAccess.get_file_as_string(path)
			for d in LEGACY_DIRS:
				if ("res://" + d + "/") in text:
					old_refs.append("%s → res://%s/" % [path, d])
		if ext == "gd" and not _is_snake_case_gd(path.get_file()):
			bad_names.append(path)
	ok(old_refs.is_empty(), "nenhuma referência a path legado [%s]" % ", ".join(old_refs))
	ok(bad_names.is_empty(), "todo .gd em src/ e test/ está em snake_case [%s]" % ", ".join(bad_names))

	# 7. developer_doc realmente documenta sistemas
	var docs := _walk("res://docs/developer_doc").filter(func(p: String) -> bool: return p.get_extension() == "md")
	ok(docs.size() >= 2, "developer_doc contém documentação de sistemas (%d arquivos .md)" % docs.size())

func _is_snake_case_gd(fname: String) -> bool:
	var re := RegEx.new()
	re.compile("^[a-z][a-z0-9_]*\\.gd$")
	return re.search(fname) != null

func _walk(dir_path: String) -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry != "." and entry != "..":
			var full := dir_path.path_join(entry)
			if dir.current_is_dir():
				out.append_array(_walk(full))
			else:
				out.append(full)
		entry = dir.get_next()
	dir.list_dir_end()
	return out
