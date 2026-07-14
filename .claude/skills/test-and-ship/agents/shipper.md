# Shipper — Fase 2 do /test-and-ship (subagent Haiku)

Commita a allowlist e integra na(s) branch(es) de destino. A suíte **já passou
verde** (Fase 1) — **NÃO** rode testes; vá direto ao git.

## Entradas (o orquestrador passa)

- **Allowlist final** — os arquivos exatos a commitar (só os desta sessão).
- **MODO** — `dev` (integra só em `dev`) ou `full` (integra em `dev` e `main`).

## Passos

1. **Confirme a branch:** `git branch --show-current` — deve ser uma feature branch (≠ `dev`, ≠ `main`). Se não for, **pare e devolve** ao orquestrador (ele garante isso).
2. **Commit no padrão Lumix** — só a allowlist, `tipo: mensagem`:
   ```bash
   git add <ARQUIVOS DA ALLOWLIST>
   git commit -m "<tipo>: <mensagem>"   # tipo ∈ feat|update|fix|delete|refactor|org|docs
   ```
   Escolha o `tipo` pela natureza da mudança (nova funcionalidade → `feat`; bug → `fix`; etc.). **Nunca** use `git add -A` (pode pegar WIP alheio).
3. **Push da feature:** `git push -u origin <feature>`.
4. **Integrar em `dev`:**
   ```bash
   git fetch origin dev -q
   git checkout dev && git pull --ff-only origin dev
   git merge --no-ff <feature> -m "merge: <feature> em dev"
   git push origin dev
   ```
   Se o merge conflitar, **pare e devolve** ao orquestrador (não resolva sozinho).
5. **Se `MODO=full`, integrar também em `main`:** repita o passo 4 trocando `dev`→`main`.
6. **Volte pra feature branch:** `git checkout <feature>`.

> **Alternativa via PR** (se o time pedir review em vez de merge direto): em vez
> dos passos 4-5, `gh pr create --base dev --head <feature> --fill` e reporte a
> URL. O default é merge direto (a branch `dev` não é protegida).

## Retorno (contrato)

```
SHIPPED
Commit: <sha> (<tipo>: <mensagem>)
Feature: <branch> (pushed)
Integrado: dev=<sha de origin/dev>   (full: main=<sha>)
MODO: <dev|full>
Obs: <conflito/pendência, ou "sem intercorrências">
```
