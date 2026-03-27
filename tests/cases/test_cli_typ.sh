#!/usr/bin/env bash
# altyp convert .typ 入力テスト
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers.sh"

FIXTURE="${SCRIPT_DIR}/../fixtures/sample.typ"

test_convert_typ_default() {
  local out
  out=$(mktemp --suffix=.pdf)
  trap "rm -f '$out'" RETURN
  altyp convert "$FIXTURE" --output "$out" 2>&1
  [[ -f "$out" ]] && [[ -s "$out" ]]
}

test_convert_typ_output_option() {
  local out
  out=$(mktemp --suffix=.pdf)
  trap "rm -f '$out'" RETURN
  altyp convert "$FIXTURE" -o "$out" 2>&1
  [[ -f "$out" ]] && [[ -s "$out" ]]
}

test_convert_typ_missing_file() {
  altyp convert /nonexistent.typ 2>&1 && return 1 || return 0
}

run_tests \
  test_convert_typ_default \
  test_convert_typ_output_option \
  test_convert_typ_missing_file
