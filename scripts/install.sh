#!/usr/bin/env bash
# always-typst インストールスクリプト
# 使い方: bash scripts/install.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TEMPLATES_DST="${HOME}/.local/share/typst/packages/local/always-typst/0.1.0"
SKILLS_DST="${HOME}/.claude/skills/typst-doc.md"
CLI_DST="${HOME}/.local/bin/altyp"

echo "Installing always-typst..."

mkdir -p "${TEMPLATES_DST}"
cp -r "${REPO_ROOT}/src/templates/." "${TEMPLATES_DST}/"
echo "  templates -> ${TEMPLATES_DST}"

mkdir -p "$(dirname "${SKILLS_DST}")"
cp "${REPO_ROOT}/src/skills/typst-doc.md" "${SKILLS_DST}"
echo "  skills    -> ${SKILLS_DST}"

mkdir -p "$(dirname "${CLI_DST}")"
cp "${REPO_ROOT}/scripts/altyp" "${CLI_DST}"
chmod +x "${CLI_DST}"
echo "  cli       -> ${CLI_DST}"

echo "Done."
echo ""
if ! command -v altyp &>/dev/null; then
  echo "~/.local/bin が PATH に含まれていません。以下を shell の設定ファイルに追加してください："
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi
