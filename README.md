# Discovery or Die (DoD)

Visual novel de detetive. Você é **Bohr Holmes**, detetive particular, investigando o desaparecimento de **Lorain** numa vila da floresta — com várias rotas de vitória e derrota.

**Capítulo 1 (demo): A Floresta** — primeira versão jogável, com placeholders de arte.

> Projeto da **Lumix Studio**. Segue os padrões oficiais do estúdio
> ([`lumix-docs`](https://github.com/Lumix-Studio/lumix-docs)): estrutura de
> pastas, commits e documentação. Detalhes em [`CLAUDE.md`](CLAUDE.md).

## Sistemas do Darlyson:

Em: ```res://src/ui/main menu/main-menu.tscn``` tem o menu principal do DoD project.
Estou testando algumas coisas para a melhor experiencia de usuário

### O que estou fazendo?
	* Sistemas de animações dinâmicas:
	Esfou fazendo animações de fade in, out e etc. Para uma melhor experiencia de usuário.
	
	* Névoa dinamica:
	Estou planejando um sistema de névoa baseada em shaders, que facilitará os visuais do jogo: Com uma atmosferá nais imersiva.

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
- `docs/Discovery or Die (DoD) — GDD.docx` — GDD original (texto em `docs/gdd-extracted.txt`)
- [`CLAUDE.md`](CLAUDE.md) — guia do repositório + padrões da Lumix para IA/devs

## Equipe (do GDD)

| Quem | Área |
|---|---|
| Brunelli | Minigames de investigação + interface e diálogos |
| Darlyson | Menu principal + animação |
| Veilcrus | Suporte aos dois, sistema de save, animaçõe (exeto a do menu prinicial) |
| Nicolas | Artes do background |
| Bonie | Artes dos personagens |
| Reynaldo| Artes das UI's |
