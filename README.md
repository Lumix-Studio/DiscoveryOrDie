# Discovery or Die (DoD)

Visual novel de detetive. Você é **Bohr Holmes**, detetive particular, investigando o desaparecimento de **Lorain** numa vila da floresta — com várias rotas de vitória e derrota.

**Capítulo 1 (demo): A Floresta** — primeira versão jogável, com placeholders de arte.

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

## Docs

- [`docs/PLANO.md`](docs/PLANO.md) — plano de desenvolvimento, arquitetura, etapas
- [`docs/BRUNELLI-SISTEMAS.md`](docs/BRUNELLI-SISTEMAS.md) — spec dos sistemas de investigação
- `docs/Discovery or Die (DoD) — GDD.docx` — GDD original (texto em `docs/gdd-extracted.txt`)

## Equipe (do GDD)

| Quem | Área |
|---|---|
| Brunelli | Minigames de investigação + interface |
| Darlyson | Diálogos, personagens, ambientação, animação |
| Veilcrus | Suporte aos dois |
| Nicolas | Algumas artes de ui |
| Bonie | Artes gerais |
