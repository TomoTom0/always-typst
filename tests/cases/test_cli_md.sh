#!/usr/bin/env bash
# altyp convert .md 入力テスト
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers.sh"

FIXTURE="${SCRIPT_DIR}/../fixtures/sample.md"

test_convert_md_to_typst() {
  local outdir
  outdir=$(mktemp -d)
  trap "rm -rf '$outdir'" RETURN
  altyp convert "$FIXTURE" --output "${outdir}/out.typ" 2>&1
  [[ -f "${outdir}/out.typ" ]] && grep -q 'always-typst' "${outdir}/out.typ"
}

test_convert_md_to_pdf() {
  local outdir
  outdir=$(mktemp -d)
  trap "rm -rf '$outdir'" RETURN
  altyp convert "$FIXTURE" --to pdf --output "${outdir}/out.pdf" 2>&1
  [[ -f "${outdir}/out.pdf" ]] && [[ -s "${outdir}/out.pdf" ]]
}

test_convert_md_title_extracted() {
  local outdir
  outdir=$(mktemp -d)
  trap "rm -rf '$outdir'" RETURN
  altyp convert "$FIXTURE" --output "${outdir}/out.typ" 2>&1
  grep -q 'テストドキュメント' "${outdir}/out.typ"
}

test_convert_md_explicit_title() {
  local outdir
  outdir=$(mktemp -d)
  trap "rm -rf '$outdir'" RETURN
  altyp convert "$FIXTURE" --title "明示タイトル" --output "${outdir}/out.typ" 2>&1
  grep -q '明示タイトル' "${outdir}/out.typ"
}

test_convert_md_layout_option() {
  local outdir
  outdir=$(mktemp -d)
  trap "rm -rf '$outdir'" RETURN
  altyp convert "$FIXTURE" --layout mobile --output "${outdir}/out.typ" 2>&1
  grep -q '"mobile"' "${outdir}/out.typ"
}

test_convert_md_missing_file() {
  altyp convert /nonexistent.md 2>&1 && return 1 || return 0
}

run_tests \
  test_convert_md_to_typst \
  test_convert_md_to_pdf \
  test_convert_md_title_extracted \
  test_convert_md_explicit_title \
  test_convert_md_layout_option \
  test_convert_md_missing_file
