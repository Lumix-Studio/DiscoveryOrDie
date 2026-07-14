# 📒 developer_doc — Discovery or Die

Documentação técnica por sistema, no padrão da Lumix Studio
(`lumix-docs/📁 Desenvolvimento/documentacao-exemplo.md`). Como mais de um dev
mexe no código do outro, **cada sistema tem um arquivo explicando o que faz,
sua API pública e como integrar** — com o nome de quem o desenvolveu.

| Sistema | Arquivo | Código | Dev |
|---|---|---|---|
| Autoload `Game` (contrato de estado) | [`game_autoload.md`](game_autoload.md) | `src/autoloads/game.gd` | Brunelli |
| Visual Novel (diálogo, cenas, escolhas) | [`vn_system.md`](vn_system.md) | `src/ui/vn/` | Darlyson (design) · porte Godot: Brunelli |
| Investigação (HUD, painéis, minigames) | [`invest_system.md`](invest_system.md) | `src/ui/invest/` | Brunelli |

> **Regra de ouro:** `Game` (autoload) é o **contrato** entre módulos. Toda
> mutação de estado passa por ele e emite sinais; as camadas de UI só reagem aos
> sinais e leem `Game.state`. VN e Investigação **não se referenciam
> diretamente** — conversam via `Game`.
