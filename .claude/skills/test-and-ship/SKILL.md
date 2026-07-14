---
name: test-and-ship
description: >
  Workflow "testar e depois subir" do Discovery or Die (Godot · Lumix Studio).
  Use SEMPRE que o usuário quiser validar E subir de uma vez — /test-and-ship,
  "testa tudo e sobe", "roda a suíte e manda pra dev", "deixa verde e integra".
  Duas fases via subagents. Fase 1 (paralelo): tester — roda a suíte headless
  (res://test/test_suite.tscn: smoke de integração + validação do padrão Lumix),
  CONSERTANDO cada falha até ficar verde — é o GATE; + doc-checker (developer_doc/
  README) e structure-checker (padrão Lumix, read-only). Fase 2 (só com tester
  100% verde): shipper commita a allowlist numa feature branch no padrão Lumix
  (tipo: mensagem) e integra em `dev` (default) — com `main`/`full`, também em
  `main`. Se a suíte não ficar verde, NÃO sobe — para e reporta. NÃO dispare
  para: só rodar a suíte sem subir, subir sem testar (é /ship), ou começar uma
  tarefa (é /implement).
---

# /test-and-ship — Testa rigorosamente, conserta, e só então sobe

Junta suíte-verde + verificação de docs/estrutura + subida (commit + push) num
fluxo único com **gate de qualidade**: a subida só acontece se a suíte passar.
Tudo via subagents — sua sessão principal não muda de estado.

> **Contexto:** repo `Lumix-Studio/DiscoveryOrDie` (Godot 4.6, default `dev`).
> Toolchain: Godot headless. Sem Linear/pnpm. Padrões em `CLAUDE.md`. Agents em
> `agents/` (self-contained).

| Fase | Subagent | tipo · modelo | O que faz |
|---|---|---|---|
| 1 | tester | `general-purpose` · sonnet | roda `test_suite.tscn` headless + **conserta tudo** até verde. É o GATE. |
| 1 | doc-checker | `general-purpose` · sonnet | decide se `docs/developer_doc`/README/CLAUDE.md ficou stale e **edita se preciso** |
| 1 | structure-checker | `Explore` · sonnet (read-only) | roda a validação de padrão + confere estrutura/nomes/commits — **recomenda** |
| 2 | shipper | `general-purpose` · haiku | commit no padrão Lumix + push + integra em `dev` (e `main` no full) |

> **Por que `Explore` no structure-checker:** roda AO MESMO TEMPO que o tester
> (que edita código). `Explore` é read-only por construção — não briga com o
> tester. Paralelismo seguro por design.

> **Gate inegociável:** a Fase 2 só roda se o **tester** retornar **100% verde**
> (suíte com exit 0). Tester vermelho → o fluxo **para** (sem commit) e você
> reporta as falhas. doc-checker/structure-checker **não são gate** — recomendam.

## Política de autonomia e perguntas

Fluxo **autônomo por padrão**. Falha da suíte **é pra consertar, não perguntar**.
**Só marque para o humano** quando a dúvida for de: **regra de jogo/design**
(comportamento que não está no GDD/código), **gitflow** (branch protegida,
reescrever histórico), ou **compatibilidade de save** (mudança no formato de
`Game.state` que quebra saves existentes). Nunca pergunte sobre decisão pequena
de implementação. **Testes: sempre completos** — rode a suíte inteira, sempre.
Ao perguntar, abra com `🚨🚨🚨`: contexto (1-2 frases) + pergunta fechada +
opções com trade-off + a sua recomendação.

## O que VOCÊ (orquestrador) faz

> **Parâmetro `main`/`full`/`prod`:** se a mensagem que invocou a skill contém
> `main`, `full` ou `prod`, **`MODO = full`** — integra em `dev` **e** `main`.
> Caso contrário, **`MODO = dev`** (default) — integra só em `dev`. Passe o MODO
> ao shipper no Passo 4.

### Passo 0 — Branch-guard + allowlist

**Branch-guard:** `git branch --show-current`.
- Feature branch (≠ `dev`, ≠ `main`) → ok.
- Em `dev`/`main` → crie a feature branch antes: `git fetch origin dev -q && git checkout -b <slug> origin/dev`. **Reporte**.

**Allowlist:** reflita sobre **o que ESTA sessão editou/criou** e monte a lista explícita. Se nada foi editado, **pare e diga**.

### Passo 1 — Spawnar os 3 subagents da Fase 1 (em PARALELO)

Numa única mensagem, dispare os três `Agent`. O `prompt` de cada um = conteúdo
integral de `agents/<arquivo>.md` + a allowlist + um resumo de 1-3 linhas do que
a sessão fez.

| Subagent | `subagent_type` | `model` | prompt |
|---|---|---|---|
| tester | `general-purpose` | sonnet | `agents/tester.md` |
| doc-checker | `general-purpose` | sonnet | `agents/doc-checker.md` |
| structure-checker | `Explore` | sonnet | `agents/structure-checker.md` |

Contratos de retorno:
- **tester** → `STATUS` 🟢/🔴 · o que quebrou/consertou · `FILES_TOUCHED`.
- **doc-checker** → `DOC-CHECK` 📝/✅ · `DOCS_TOUCHED`.
- **structure-checker** → `STRUCT-CHECK` 🏗️/✅ · achados · `FOLLOWUPS`.

### Passo 2 — O GATE (sobre o tester)

- **tester 🔴** → **NÃO** spawne o shipper. A causa de implementação é pra consertar (o tester conserta); só pare se restar um bloqueio das 3 naturezas da Política. Reporte as falhas.
- **tester 🟢** → siga.
- Achados do structure-checker auto-resolvíveis (ex.: arquivo fora do padrão, commit fora do formato) → **corrija e re-rode** antes de subir; não pergunte.

### Passo 3 — Merge da allowlist

Allowlist final = allowlist do Passo 0 + `FILES_TOUCHED` do tester + `DOCS_TOUCHED` do doc-checker. Se um fix do tester não entrar no commit, o remoto sobe quebrado.

### Passo 4 — Spawnar o shipper (Haiku)

`Agent` `general-purpose` · `haiku`, `prompt` = `agents/shipper.md` + a allowlist
final + `MODO=<dev|full>` + a nota: "A suíte já passou 100% verde — NÃO re-rode;
vá direto pro commit + integração. A branch atual é feature ≠ dev/main (o
orquestrador garantiu). Commit no padrão Lumix (`tipo: mensagem`). Integre em
`dev`; se `MODO=full`, também em `main`." Ele devolve o commit SHA, a(s)
branch(es) atualizada(s) e os SHAs de `dev`/`main`.

### Passo 5 — Validar + relatório

Valide o reporte: `git log --oneline -3` (SHA novo existe), `git status --short`
(allowlist saiu do `M`), `git ls-remote origin dev` bate com o local. Confirme
que o **CI remoto** (Actions) ficou verde no push (`gh run list --limit 1`) —
se vermelho num diff que não pode causá-lo, investigue antes de dar por fechado.

Emita SEMPRE o **Relatório final** (formato abaixo). Nunca encerre sem ele.

## Relatório final (OBRIGATÓRIO)

1ª linha = **TL;DR** começando com ✅/⚠️/🚨. Ex.:

```
✅ Verde e subido — suíte 27/27, integrado em dev (SHA abcd123). CI verde.

Testado & subido 🚀 (/test-and-ship · MODO: dev · branch: fix-typewriter)

── Fase 1 ──
tester (sonnet): 🟢 27/27 asserts — consertou <resumo> · FILES_TOUCHED: src/…
doc-check (sonnet): 📝 developer_doc/vn_system.md atualizado — ou ✅ sem mudança
struct-check (Explore): 🏗️ 0 achados — ou lista

── Fase 2 (MODO: dev) ──
Commit `abcd123` (feat: …) na feature `fix-typewriter`.
Integrado: dev → push origin dev ok.   (full: + main)
CI (Actions): 🟢 verde.

⚠️ Exit? — ✅ pode dar exit: suíte verde, integrado, CI verde, sem pergunta pendente.
```

- **✅** subiu tudo, suíte + CI verdes. **⚠️** subiu mas há follow-up/pendência. **🚨** travou (suíte vermelha, CI vermelho, pergunta ao humano aguardando).

## Limitações

- **Gate = suíte headless** (`test_suite.tscn`): smoke de integração + validação de estrutura. Não cobre tudo do jogo — cobre regressão de carregamento, roteiro e padrão. Cobertura nova de teste é bem-vinda como follow-up.
- **MODO dev vs full:** `dev` (default) integra na branch de trabalho; `full`/`main` promove pra produção. `dev` não é protegida → integra por push direto.
- **Sem Linear:** rastreamento é opcional (GitHub Issues do repo). Não falhe a subida por causa de tracker.

## Relação com outras skills

- **`/ship`** — o irmão **sem** a fase de teste (sobe incondicional). Use quando já confiar no que fez.
- **`/implement`** — abre a tarefa (branch + plano) antes desta.
