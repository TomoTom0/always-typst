#!/usr/bin/env bash
# テスト共通ヘルパー

PASS=0
FAIL=0
ERRORS=()

_green()  { printf '\033[32m%s\033[0m' "$*"; }
_red()    { printf '\033[31m%s\033[0m' "$*"; }

run_tests() {
  local test_file="${BASH_SOURCE[1]##*/}"
  echo "=== ${test_file} ==="

  for name in "$@"; do
    if "$name" > /dev/null 2>&1; then
      echo "  $(_green PASS) ${name}"
      (( PASS++ )) || true
    else
      echo "  $(_red FAIL) ${name}"
      (( FAIL++ )) || true
      ERRORS+=("${test_file}::${name}")
    fi
  done

  echo ""
}

# テストファイル単体実行時の終了処理
_summarize() {
  if [[ ${#ERRORS[@]} -eq 0 ]]; then
    echo "$(_green "All ${PASS} tests passed.")"
    exit 0
  else
    echo "$(_red "${FAIL} test(s) failed:")"
    for e in "${ERRORS[@]}"; do echo "  - ${e}"; done
    exit 1
  fi
}

trap _summarize EXIT
