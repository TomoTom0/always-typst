#!/usr/bin/env bash
# md2typst.sh - Markdown を always-typst テンプレート付き Typst ファイルに変換する
#
# 使い方:
#   md2typst.sh <input.md> [options]
#
# オプション:
#   --title <str>     タイトル（省略時は最初の H1 から自動抽出）
#   --subtitle <str>  サブタイトル
#   --author <str>    著者名
#   --date <str>      日付（例: 2026-03-26）
#   --toc             目次を有効化
#   --cover           表紙を独立ページにする
#   --layout <str>    print|mobile|wide（デフォルト: print）
#   --tone <str>      casual|business|stylish（デフォルト: business）
#   --color <str>     blue|green|mono|warm|purple|teal（デフォルト: blue）
#   --output <file>   出力ファイルパス（デフォルト: 入力と同じディレクトリに .typ で生成）
#   --help            このヘルプを表示

set -euo pipefail

usage() {
  sed -n '2,20p' "$0" | sed 's/^# //' | sed 's/^#//'
  exit 0
}

# 引数パース
INPUT_MD=""
TITLE=""
SUBTITLE=""
AUTHOR=""
DATE=""
TOC="false"
COVER="false"
LAYOUT="print"
TONE="business"
COLOR="blue"
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)      usage ;;
    --title)        TITLE="$2";    shift 2 ;;
    --subtitle)     SUBTITLE="$2"; shift 2 ;;
    --author)       AUTHOR="$2";   shift 2 ;;
    --date)         DATE="$2";     shift 2 ;;
    --toc)          TOC="true";    shift ;;
    --cover)        COVER="true";  shift ;;
    --layout|-l)    LAYOUT="$2";   shift 2 ;;
    --tone|-t)      TONE="$2";     shift 2 ;;
    --color|-c)     COLOR="$2";    shift 2 ;;
    --output|-o)    OUTPUT="$2";   shift 2 ;;
    -*)             echo "Unknown option: $1" >&2; exit 1 ;;
    *)
      if [[ -z "$INPUT_MD" ]]; then
        INPUT_MD="$1"
      else
        echo "Unexpected argument: $1" >&2; exit 1
      fi
      shift ;;
  esac
done

if [[ -z "$INPUT_MD" ]]; then
  echo "Error: input file is required." >&2
  echo "Usage: md2typst.sh <input.md> [options]" >&2
  exit 1
fi

if [[ ! -f "$INPUT_MD" ]]; then
  echo "Error: file not found: $INPUT_MD" >&2
  exit 1
fi

if ! command -v pandoc &>/dev/null; then
  echo "Error: pandoc is not installed." >&2
  exit 1
fi

# 出力ファイルパスを決定
if [[ -z "$OUTPUT" ]]; then
  OUTPUT="${INPUT_MD%.md}.typ"
fi

# タイトルを H1 から自動抽出
if [[ -z "$TITLE" ]]; then
  TITLE=$(grep -m1 "^# " "$INPUT_MD" | sed 's/^# //' || true)
fi

# タイトルに使用した H1 をMarkdownから除いてpandocに渡す
TMP_MD=$(mktemp --suffix=.md)
trap 'rm -f "$TMP_MD"' EXIT

if [[ -n "$TITLE" ]]; then
  # 最初の H1 行を除去
  awk 'NR==1 && /^# / {next} {print}' "$INPUT_MD" > "$TMP_MD"
else
  cp "$INPUT_MD" "$TMP_MD"
fi

# always-typst ヘッダを生成
{
  echo '#import "@local/always-typst:0.1.0": doc, note, warn, fig, blockquote'
  echo ""
  echo "#show: doc.with("
  printf '  title:    "%s",\n' "$TITLE"
  [[ -n "$SUBTITLE" ]] && printf '  subtitle: "%s",\n' "$SUBTITLE"
  [[ -n "$AUTHOR"   ]] && printf '  author:   "%s",\n' "$AUTHOR"
  [[ -n "$DATE"     ]] && printf '  date:     "%s",\n' "$DATE"
  [[ "$TOC"   == "true" ]] && echo "  toc:      true,"
  [[ "$COVER" == "true" ]] && echo "  cover:    true,"
  printf '  layout:   "%s",\n' "$LAYOUT"
  printf '  tone:     "%s",\n' "$TONE"
  printf '  color:    "%s",\n' "$COLOR"
  echo ")"
  echo ""
} > "$OUTPUT"

# pandoc で Markdown 本文を変換して追記
# pandoc が出力するテーブルの #align(center)[...] ラッパーと align 引数を除去する
pandoc "$TMP_MD" -f markdown -t typst --wrap=none \
  | awk '
    /^#align\(center\)\[#table\(/ { sub(/^#align\(center\)\[/, ""); print; next }
    /align: \(col, row\)/          { next }
    /^\]$/ && prev == ")"          { next }
    /^#horizontalrule$/            { print "#line(length: 100%, stroke: 0.5pt)"; next }
    { prev = $0; print }
  ' \
  | sed 's/#h(-1em)//g' \
  >> "$OUTPUT"

echo "Generated: $OUTPUT"
