#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TEMPLATES_SRC="${REPO_ROOT}/src/templates"
TEMPLATES_DST="${HOME}/.local/share/typst/packages/local/always-typst/0.1.0"

SKILLS_SRC="${REPO_ROOT}/src/skills/typst-doc.md"
SKILLS_DST="${HOME}/.claude/skills/typst-doc.md"

echo "Installing always-typst templates..."

# テンプレートをコピー
mkdir -p "${TEMPLATES_DST}"
cp -r "${TEMPLATES_SRC}/." "${TEMPLATES_DST}/"
echo "  templates -> ${TEMPLATES_DST}"

# スキルファイルをコピー
mkdir -p "$(dirname "${SKILLS_DST}")"
cp "${SKILLS_SRC}" "${SKILLS_DST}"
echo "  skills    -> ${SKILLS_DST}"

echo "Done."
echo ""
echo "Add the following to ~/.claude/CLAUDE.md if not already present:"
echo "  ## Typst ドキュメント生成"
echo "  Typst でドキュメントを生成する場合は ~/.claude/skills/typst-doc.md を参照すること。"
