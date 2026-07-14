# CLAUDE.md — Discovery or Die (Lumix Studio)

Guia do repositório para IA e devs. **Leia antes de mexer no código.** Este
projeto segue os **padrões oficiais da Lumix Studio**
([`lumix-docs`](https://github.com/Lumix-Studio/lumix-docs)) — respeitá-los é
obrigatório e é o que o CI valida a cada push/PR.

## O que é

**Discovery or Die (DoD)** — visual novel de detetive em **Godot 4.6**
(GL Compatibility). Você é Bohr Holmes investigando o desaparecimento de Lorain.
Duas camadas: **Visual Novel** (diálogo/cenas/escolhas) e **Investigação**
(HUD, tarefas, pesquisa, análise de fotos, caderno). Capítulo 1 é a demo jogável.

Repositório oficial: **`Lumix-Studio/DiscoveryOrDie`** (default branch: `dev`).

## Arquitetura (o contrato importa)

`Game` (autoload, `src/autoloads/game.gd`) é o **contrato de estado** entre
módulos. **Toda** mutação de estado passa por ele e emite sinais; as camadas de
UI só reagem aos sinais e leem `Game.state`. **VN e Investigação nunca se
referenciam diretamente** — conversam via `Game`. Detalhes por sistema em
[`docs/developer_doc/`](docs/developer_doc/) (um arquivo por sistema — leia o do
sistema antes de editá-lo).

## Estrutura (padrão Lumix — o CI barra quem violar)

```
src/          código-fonte do jogo
  autoloads/  singletons (game.gd)
  config/     dados estáticos (script.json = roteiro)
  main.{gd,tscn}  boot
  ui/vn/      camada de Visual Novel
  ui/invest/  camada de Investigação
assets/       arte geral por tipo: characters/ backgrounds/ photos/
docs/         GDD, plano, specs + developer_doc/ (doc técnica por sistema)
test/         suíte headless (roda no CI)
```

Regras (validadas por `test/lumix_standard_test.gd`):
- **Arquivos `.gd` em `snake_case`** (`vn_layer.gd`, não `VNLayer.gd`). `class_name` continua em PascalCase.
- **Nada de `scripts/`, `scenes/`, `data/`** na raiz (layout legado) — tudo vive em `src/`.
- Assets de personagem/cenário segmentados por tipo em `assets/`.
- Cada sistema novo ganha um doc em `docs/developer_doc/`.

## Commits (padrão Lumix — validado no CI)

Formato **`tipo: mensagem`**. Tipos: `feat` (nova funcionalidade), `update`
(melhora existente), `fix` (bug), `delete` (remove), `refactor` (sem mudar
comportamento), `org` (organização de arquivos), `docs` (documentação).
Ex.: `feat: minigame de zoom na análise de fotos`.

## Gitflow

- **`dev`** — branch de integração (default). O trabalho é integrado aqui.
- **`main`** — produção/releases.
- Trabalhe em **feature branch** a partir de `origin/dev`; integre via `/ship`
  ou `/test-and-ship`. Nunca commite direto em `dev`/`main` sem necessidade.

## Rodar e testar

```bash
# rodar o jogo
/Applications/Godot.app/Contents/MacOS/Godot --path .

# suíte completa headless (o mesmo que o CI roda) — 0 = verde
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . res://test/test_suite.tscn
```

**Regra de ouro:** todo trabalho com código passa pela **suíte verde** antes de
subir. É o gate do `/test-and-ship` e do CI. Painel dev in-game: tecla **D**.

## Skills (`.claude/skills/`)

Fluxo de trabalho adaptado ao Godot/Lumix (portado do maria-hub):

| Skill | Quando usar |
|---|---|
| **`/implement`** | Começar uma tarefa: cria feature branch de `origin/dev`, confere docs/GDD, faz plano curto. Não testa nem sobe. |
| **`/ship`** | Subir o que a sessão fez **sem** rodar a suíte (mudança de doc/config/trabalho já validado à mão). Commit no padrão Lumix + push/PR pra `dev`. |
| **`/test-and-ship`** | Rodar a suíte headless (GATE — conserta até verde) e **só então** subir. É o caminho padrão para mudança de código. |

Encadeamento típico: `/implement` → código → `/test-and-ship`.

## Referências

- Padrões da Lumix: <https://github.com/Lumix-Studio/lumix-docs/tree/dev/%F0%9F%93%81%20Desenvolvimento>
- Doc técnica por sistema: [`docs/developer_doc/`](docs/developer_doc/)
- Specs do jogo: [`docs/PLANO.md`](docs/PLANO.md), [`docs/BRUNELLI-SISTEMAS.md`](docs/BRUNELLI-SISTEMAS.md)
