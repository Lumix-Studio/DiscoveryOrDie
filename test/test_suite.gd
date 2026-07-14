extends Node
## Suíte completa headless — é o que o CI roda a cada push/PR:
##   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . res://test/test_suite.tscn
## Roda cada teste com autorun=false e agrega tudo num único exit code
## (0 = verde; ≠ 0 = alguma falha → o CI barra o merge).

const SUITES := {
	"Padrão Lumix Studio": "res://test/lumix_standard_test.gd",
	"Smoke de integração": "res://test/smoke.gd",
}

func _ready() -> void:
	var total_checks := 0
	var total_fails := 0
	for suite_name in SUITES:
		print("\n── %s ──" % suite_name)
		var t: Node = load(SUITES[suite_name]).new()
		t.autorun = false
		add_child(t)
		await t.run()
		total_checks += t.checks
		total_fails += t.fails
		t.queue_free()
	var verdict := "🟢 VERDE" if total_fails == 0 else "🔴 %d FALHA(S)" % total_fails
	print("\n══════════════════════════════════════")
	print("TOTAL: %d/%d asserts OK — %s" % [total_checks - total_fails, total_checks, verdict])
	get_tree().quit(1 if total_fails > 0 else 0)
