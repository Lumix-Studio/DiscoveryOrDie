# Discovery or Die (DoD)

Visual novel de detetive. Você é **Bohr Holmes**, detetive particular, investigando o desaparecimento de **Lorain** numa vila da floresta — com várias rotas de vitória e derrota.

**Capítulo 1 (demo): A Floresta** — primeira versão jogável, com placeholders de arte.

> Projeto da **Lumix Studio**. Segue os padrões oficiais do estúdio
> ([`lumix-docs`](https://github.com/Lumix-Studio/lumix-docs)): estrutura de
> pastas, commits e documentação. Detalhes em [`CLAUDE.md`](CLAUDE.md).

## Rodar

Abrir a pasta do projeto no **Godot 4.6** e apertar F5, ou:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

## Testar os sistemas de investigação (parte do Brunelli)

Aperte **D** dentro do jogo (ou o botão 🛠 no topo) → painel dev com atalhos para testar cada sistema sem jogar a história:

- **TASKs** 📋 — lista de tarefas com notificações e badge
- **Pesquisa** 🔎 — busca por termos descobertos na investigação
- **Análise de fotos** 📷 — minigame de zoom/pan e pistas escondidas
- **Caderno** 📓 — evidências coletadas

Checklist de teste completo: [`docs/BRUNELLI-SISTEMAS.md`](docs/BRUNELLI-SISTEMAS.md).

## Testes automatizados

Rodam no Godot **headless** (mesma suíte que o CI executa a cada push/PR):

```bash
# suíte completa (smoke de integração + validação do padrão Lumix)
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . res://test/test_suite.tscn

# só o smoke de integração
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . res://test/smoke.tscn
```

Saída com `exit code 0` = tudo verde; `≠ 0` = falha (o CI barra o merge).

## Estrutura (padrão Lumix Studio)

```
res://
├── docs/
│   ├── developer_doc/     # doc técnica por sistema (1 arquivo/sistema)
│   └── *.md, *.docx       # GDD, plano, specs
├── assets/                # arte geral, segmentada por tipo
│   ├── characters/        # sprites de personagem (char-*.svg)
│   ├── backgrounds/       # cenários (bg-*.svg)
│   └── photos/            # fotos da investigação
├── src/                   # todo o código-fonte do jogo
│   ├── autoloads/         # singletons (game.gd = contrato de estado)
│   ├── config/            # dados estáticos (script.json = roteiro)
│   ├── main.{gd,tscn}     # boot: instancia as camadas
│   └── ui/
│       ├── vn/            # camada de Visual Novel
│       └── invest/        # camada de Investigação
├── test/                  # suíte automatizada (headless / CI)
├── .editorconfig
├── project.godot
└── README.md
```

## Docs

- [`docs/developer_doc/`](docs/developer_doc/) — **doc técnica por sistema** (padrão Lumix)
- [`docs/PLANO.md`](docs/PLANO.md) — plano de desenvolvimento, arquitetura, etapas
- [`docs/BRUNELLI-SISTEMAS.md`](docs/BRUNELLI-SISTEMAS.md) — spec dos sistemas de investigação
- `docs/Discovery or Die (DoD) — GDD.docx` — GDD original (texto em `docs/gdd-extracted.txt`)
- [`CLAUDE.md`](CLAUDE.md) — guia do repositório + padrões da Lumix para IA/devs

## Equipe (do GDD)

| Quem | Área |
|---|---|
| Brunelli | Minigames de investigação + interface e diálogos |
| Darlyson | Menu principal + animação |
| Veilcrus | Suporte aos dois, sistema de save, animaçõe (exeto a do menu ainicial) |
| Nicolas | Artes do background |
| Bonie | Artes dos personagens |
| Reynaldo| Artes das UI's |
