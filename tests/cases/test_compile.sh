#!/usr/bin/env bash
# テンプレート全パラメータ組み合わせコンパイルテスト
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../helpers.sh"

LAYOUTS=(print mobile wide)
TONES=(casual business stylish)
COLORS=(blue green mono warm purple teal)

_compile_doc() {
  local layout="$1" tone="$2" color="$3"
  local tmpdir
  tmpdir=$(mktemp -d)
  trap "rm -rf '$tmpdir'" RETURN

  cat > "${tmpdir}/test.typ" <<EOF
#import "@local/always-typst:0.1.0": doc
#show: doc.with(
  title: "test",
  layout: "${layout}",
  tone: "${tone}",
  color: "${color}",
)
= 見出し
本文テキスト。
#table(columns: 2, [A], [B], [1], [2])
EOF

  typst compile "${tmpdir}/test.typ" "${tmpdir}/test.pdf" 2>&1
  [[ -f "${tmpdir}/test.pdf" ]] && [[ -s "${tmpdir}/test.pdf" ]]
}

_compile_slide() {
  local tone="$1" color="$2"
  local tmpdir
  tmpdir=$(mktemp -d)
  trap "rm -rf '$tmpdir'" RETURN

  cat > "${tmpdir}/test.typ" <<EOF
#import "@local/always-typst:0.1.0": slide-doc
#show: slide-doc.with(
  title: "test",
  tone: "${tone}",
  color: "${color}",
)
= スライド1
本文テキスト。
#table(columns: 2, [A], [B], [1], [2])
EOF

  typst compile "${tmpdir}/test.typ" "${tmpdir}/test.pdf" 2>&1
  [[ -f "${tmpdir}/test.pdf" ]] && [[ -s "${tmpdir}/test.pdf" ]]
}

# document: layout × tone × color の全組み合わせ
for layout in "${LAYOUTS[@]}"; do
  for tone in "${TONES[@]}"; do
    for color in "${COLORS[@]}"; do
      name="doc_${layout}_${tone}_${color}"
      eval "test_${name}() { _compile_doc '${layout}' '${tone}' '${color}'; }"
      TESTS+=("test_${name}")
    done
  done
done

# slide: tone × color の全組み合わせ
for tone in "${TONES[@]}"; do
  for color in "${COLORS[@]}"; do
    name="slide_${tone}_${color}"
    eval "test_${name}() { _compile_slide '${tone}' '${color}'; }"
    TESTS+=("test_${name}")
  done
done

run_tests "${TESTS[@]}"
