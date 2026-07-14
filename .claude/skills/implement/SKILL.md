---
name: implement
description: >
  Porta de entrada do fluxo de trabalho do Discovery or Die (Godot · Lumix Studio).
  Recebe uma descrição livre de tarefa OU um link/número de issue do GitHub
  (Lumix-Studio/DiscoveryOrDie), isola a sessão numa feature branch a partir de
  origin/dev, confere a documentação (developer_doc, GDD, CLAUDE.md), rascunha um
  plano curto e entrega para o trabalho. Use SEMPRE que o usuário disser
  "implementa X", "começa essa task", "vou mexer em <feature/bug>", colar uma
  issue do GitHub, ou descrever algo a construir no jogo — mesmo sem dizer
  "implement". Encadeia com /test-and-ship (roda a suíte e sobe) no fim. NÃO
  dispare para rodar testes/subir (isso é test-and-ship/ship).
---

# /implement — porta de entrada do fluxo do DoD

Transforma "uma ideia ou uma issue" em "sessão pronta pra trabalhar: isolada
numa branch, com a documentação conferida e um plano". É a cola entre o início
da tarefa e a fase de subida (`/test-and-ship`).

> **Contexto do repo:** projeto Godot 4.6 da **Lumix Studio**
> (`Lumix-Studio/DiscoveryOrDie`, default `dev`). Padrões em `CLAUDE.md` e no
> [`lumix-docs`](https://github.com/Lumix-Studio/lumix-docs). Sem Linear, sem
> pnpm — o "teste" é a suíte headless (`res://test/test_suite.tscn`).

## Política de autonomia (leia antes)

Fluxo **autônomo por padrão**: implemente e decida sozinho. Antes de fechar uma
decisão, investigue o impacto no resto do sistema (quem consome, quebra algum
contrato do `Game`, faz algo parar). **Só pare para perguntar** quando a dúvida
for de **regra do jogo/design** (comportamento que não está no GDD nem no
código), **gitflow** (reescrever histórico, mexer em branch protegida) ou risco
de **quebrar o save do jogador** (formato de `Game.state`). Decisão pequena de
implementação (nome, onde pôr helper, formato) você resolve e registra em 1 linha.

## Passo 1 — Entender o input

- **Descrição livre** ("bug no typewriter", "novo minigame de X") → siga.
- **Issue do GitHub** (número/URL) → `gh issue view <n> --repo Lumix-Studio/DiscoveryOrDie`, resuma (título + corpo + estado) em PT-BR e confirme que é a tarefa certa. Se o repo usar labels/estados, mova/assine conforme o combinado (opcional — não falhe se não houver tracker).

## Passo 2 — Isolar a sessão numa feature branch (a partir de `origin/dev`)

O trabalho vai integrar em `dev`, então **baseie a branch na `dev` mais recente**:

```bash
git fetch origin dev -q
git checkout -b <slug> origin/dev   # slug: verbo-curto, ex.: fix-typewriter, feat-foto-zoom
```

- Já numa feature branch própria com trabalho em andamento → siga nela (não recrie).
- Em `dev`/`main` → crie a feature branch antes de qualquer commit. **Reporte** a branch criada.
- Nome pela natureza da tarefa (`fix-…`, `feat-…`, `refactor-…`, `org-…`) — casa com o tipo do commit Lumix que virá.

## Passo 3 — Conferir a documentação

Antes de planejar, cheque se o pedido bate com a doc do projeto (nesta ordem):
`docs/developer_doc/` (o do sistema que você vai tocar), `docs/PLANO.md`,
`docs/BRUNELLI-SISTEMAS.md`, o GDD (`docs/gdd-extracted.txt`), `CLAUDE.md`.

- **Suporta** → cite a doc e ancore o plano nela.
- **Contradiz** → PARE e avise, citando o trecho × o pedido. Doc pode estar velha vs. código: se briga com o **código**, vale o código; se briga com o **design/GDD**, é decisão de jogo → pergunte antes de codar.
- **Ausência** → nada cobre. Siga se for trivial/bugfix (registre a decisão); se for sistema novo, sinalize que vai precisar de um doc em `developer_doc/` (o `/test-and-ship` cobra isso).

## Passo 4 — Plano curto

- **Valide a premissa contra o código ATUAL** (rode, grepe, leia) — descrições envelhecem. Reporte o delta se o estado real diferir.
- Leia o código relevante (o `Game` é o contrato — veja `docs/developer_doc/game_autoload.md`).
- Rascunhe um plano enxuto (3-6 passos) citando arquivos prováveis (em `src/…`), respeitando o padrão Lumix (estrutura, snake_case, comunicação por sinais do `Game`).
- Confirme escopo antes de mudança grande; trivial → siga direto.

## Passo 5 — Trabalhar e fechar

Implemente respeitando o padrão (arquivos em `src/`, `snake_case`, sistema novo
→ doc em `developer_doc/`, assets no tipo certo de `assets/`). Ao terminar,
lembre o handoff (você **não** testa/sobe aqui):

- **`/test-and-ship`** → roda a suíte headless (conserta até verde) + commit no padrão Lumix + push/PR pra `dev`. É o caminho padrão.
- **`/ship`** → sobe sem rodar a suíte (só para doc/config ou trabalho já validado à mão).

## Não fazer

- ❌ Rodar a suíte / subir (é `test-and-ship`/`ship`).
- ❌ Commitar direto em `dev`/`main` (crie a feature branch no Passo 2).
- ❌ Referenciar a VN a partir da Investigação (ou vice-versa) — passe pelo `Game`.
