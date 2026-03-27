#!/usr/bin/env bash
# テストランナー
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TOTAL_PASS=0
TOTAL_FAIL=0
FAILED_TESTS=()

_green() { printf '\033[32m%s\033[0m' "$*"; }
_red()   { printf '\033[31m%s\033[0m' "$*"; }

# 実行するテストファイルを決定（引数があればそれのみ、なければ全件）
if [[ $# -gt 0 ]]; then
  CASES=("$@")
else
  CASES=("${SCRIPT_DIR}"/cases/test_*.sh)
fi

for case_file in "${CASES[@]}"; do
  output=$(bash "$case_file" 2>&1) || true
  echo "$output"

  stripped=$(echo "$output" | sed 's/\x1b\[[0-9;]*m//g')
  pass=$(echo "$stripped" | grep -c '^ *PASS ' || true)
  fail=$(echo "$stripped" | grep -c '^ *FAIL ' || true)
  (( TOTAL_PASS += pass )) || true
  (( TOTAL_FAIL += fail )) || true
  if (( fail > 0 )); then
    FAILED_TESTS+=("${case_file##*/}")
  fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ ${#FAILED_TESTS[@]} -eq 0 ]]; then
  echo "$(_green "All ${TOTAL_PASS} tests passed.")"
  exit 0
else
  echo "$(_red "${TOTAL_FAIL} test(s) failed") / $((TOTAL_PASS + TOTAL_FAIL)) total"
  for f in "${FAILED_TESTS[@]}"; do echo "  - ${f}"; done
  exit 1
fi
