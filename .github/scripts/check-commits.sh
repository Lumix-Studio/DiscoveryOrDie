#!/usr/bin/env bash
# Valida que as mensagens de commit seguem o padrão da Lumix Studio:
#   "tipo: mensagem"  (ref: lumix-docs/📁 Desenvolvimento/Commits-Padrao.md)
# Só valida os commits NOVOS (delta do push, ou do PR contra a base) —
# nunca o histórico anterior. Merges são ignorados.
set -uo pipefail

PATTERN='^(feat|update|fix|delete|refactor|org|docs)(\([a-z0-9._/-]+\))?: .+'
TYPES="feat, update, fix, delete, refactor, org, docs"
ZERO="0000000000000000000000000000000000000000"

EVENT_NAME="${EVENT_NAME:-}"
BEFORE_SHA="${BEFORE_SHA:-}"
BASE_REF="${BASE_REF:-}"

if [ "$EVENT_NAME" = "pull_request" ] && [ -n "$BASE_REF" ]; then
	git fetch origin "$BASE_REF" --quiet 2>/dev/null || true
	RANGE="origin/${BASE_REF}..HEAD"
elif [ -n "$BEFORE_SHA" ] && [ "$BEFORE_SHA" != "$ZERO" ] && git cat-file -e "${BEFORE_SHA}^{commit}" 2>/dev/null; then
	RANGE="${BEFORE_SHA}..HEAD"
else
	RANGE=""   # branch nova / sem base conhecida → valida só o HEAD
fi

if [ -z "$RANGE" ]; then
	COMMITS="$(git rev-list -n 1 HEAD)"
else
	COMMITS="$(git rev-list --no-merges "$RANGE")"
fi

if [ -z "$COMMITS" ]; then
	echo "Nenhum commit novo para validar."
	exit 0
fi

fail=0
while IFS= read -r sha; do
	[ -z "$sha" ] && continue
	subject="$(git log -1 --format=%s "$sha")"
	if printf '%s' "$subject" | grep -qE "$PATTERN"; then
		echo "  ✓ ${sha:0:8} ${subject}"
	else
		echo "  ✗ ${sha:0:8} ${subject}"
		fail=1
	fi
done <<< "$COMMITS"

if [ "$fail" -ne 0 ]; then
	echo ""
	echo "❌ Há commits fora do padrão da Lumix Studio."
	echo "   Formato: 'tipo: mensagem'  ·  tipos válidos: ${TYPES}"
	exit 1
fi

echo ""
echo "✅ Todos os commits novos seguem o padrão de commits da Lumix."
