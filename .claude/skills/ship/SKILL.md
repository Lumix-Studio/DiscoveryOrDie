---
name: ship
description: >
  Workflow "subir sem testar" do Discovery or Die (Godot · Lumix Studio). Use
  quando o usuário digita /ship ou pede "sobe isso", "manda pra dev", "commita e
  integra sem rodar a suíte". ⚠️ Subida INCONDICIONAL — é o /test-and-ship SEM a
  fase de teste: sem tester, sem gate verde, não roda a suíte headless. Quer o
  gate verde antes de subir? use /test-and-ship. Fase 1 (paralelo): doc-checker
  (edita doc stale) + structure-checker (read-only, recomenda). Fase 2: shipper
  commita a allowlist no padrão Lumix e integra em `dev` (default) — com
  `main`/`full`, também em `main`. NÃO dispare para: rodar/validar a suíte (é
  /test-and-ship), ou começar uma tarefa (é /implement).
---

# /ship — Sobe o que a sessão fez, SEM rodar a suíte

É o `/test-and-ship` **menos a fase de teste**. Verificação de docs/estrutura
(Fase 1) + subida (commit + push + integração em `dev`) — mas **sem tester e sem
gate**: a subida é **incondicional**.

> **⚠️ Sem rede de segurança.** Diferente do `/test-and-ship`, o `/ship` **não
> roda a suíte headless** e não conserta nada. Sobe o que a sessão produziu, como
> está. Use quando você **já confia** no que foi feito (mudança de doc/config, ou
> trabalho que já validou à mão). Para o gate verde, use **`/test-and-ship`**.

> **Contexto:** repo `Lumix-Studio/DiscoveryOrDie` (Godot 4.6, default `dev`).
> Padrões em `CLAUDE.md`. **Reusa os agents do `/test-and-ship`** — mesma máquina
> de docs/estrutura/ship, só sem o tester.

## Política de autonomia

Idêntica à do `/test-and-ship`: autônomo por padrão; só pare para o humano em
**regra de jogo/design**, **gitflow** ou **compatibilidade de save**; ao
perguntar, abra com `🚨🚨🚨` (contexto + pergunta fechada + opções + recomendação).

## O que VOCÊ (orquestrador) faz

> **MODO:** contém `main`/`full`/`prod` na invocação → `MODO=full` (integra `dev`
> + `main`); senão `MODO=dev` (default, só `dev`).

### Passo 0 — Branch-guard + allowlist
`git branch --show-current`. Em `dev`/`main` → crie feature branch
(`git fetch origin dev -q && git checkout -b <slug> origin/dev`) e reporte.
Monte a **allowlist** só com os arquivos DESTA sessão. Nada editado → pare e diga.

### Passo 1 — Spawnar os 2 subagents da Fase 1 (em PARALELO)
Dispare os dois `Agent` numa única mensagem. O `prompt` de cada um = conteúdo
integral do arquivo do agent + a allowlist + resumo de 1-3 linhas da sessão.

| Subagent | `subagent_type` | `model` | prompt (arquivo) |
|---|---|---|---|
| doc-checker | `general-purpose` | sonnet | `../test-and-ship/agents/doc-checker.md` |
| structure-checker | `Explore` | sonnet | `../test-and-ship/agents/structure-checker.md` |

**Sem tester** → nada bloqueia a Fase 2. Achado **Alta** do structure-checker
auto-resolvível (arquivo fora do padrão, commit fora do formato) → **corrija e
re-suba** antes de integrar; não pergunte.

### Passo 2 — Merge da allowlist
Allowlist final = allowlist do Passo 0 + `DOCS_TOUCHED` do doc-checker.
(structure-checker é read-only — não contribui arquivos.)

### Passo 3 — Spawnar o shipper (Haiku)
`Agent` `general-purpose` · `haiku`, `prompt` = conteúdo de
`../test-and-ship/agents/shipper.md` + a allowlist final + `MODO=<dev|full>` +
a nota: "O `/ship` NÃO roda a suíte — NÃO rode testes; vá direto pro commit +
integração. Commit no padrão Lumix (`tipo: mensagem`)."

### Passo 4 — Validar + relatório
`git log --oneline -3`, `git status --short`, `git ls-remote origin dev`.
Emita o **Relatório final** (mesmo formato do `/test-and-ship`, trocando a linha
do tester por "sem testes — /ship"). TL;DR na 1ª linha (✅/⚠️/🚨).

## Loop de follow-ups
Se a Fase 1 deixou follow-ups **auto-resolvíveis** (do structure-checker), entre
num loop: resolva-os (escopo restrito) → re-rode `/ship` → repita até nenhum
follow-up novo (fixpoint). Pule só os que caem nas 3 naturezas da Política.

## Limitações
- **Sem gate:** pode subir código quebrado se a sessão não validou. Trade-off explícito. Para gate, `/test-and-ship`.
- **MODO dev vs full:** `dev` (default) vs `dev`+`main` (`full`).
- O CI remoto (Actions) ainda roda no push — se o código quebrar a suíte, o CI fica vermelho mesmo que o `/ship` não tenha testado localmente.
