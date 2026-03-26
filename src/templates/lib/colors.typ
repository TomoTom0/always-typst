// テーマカラーパレット定義（6テーマ）
// 各テーマは以下のキーを持つ辞書として定義する:
//   primary      - 見出し・強調テキスト
//   accent       - 装飾・ライン・マーカー
//   accent-light - note ボックス背景等
//   text         - 本文テキスト
//   muted        - 補足・キャプション・フッター
//   rule         - 罫線
//   code-bg      - コードブロック背景
//   table-head   - テーブルヘッダ背景
//   table-odd    - テーブル奇数行背景

#let palettes = (
  blue: (
    primary:      rgb("#1a365d"),
    accent:       rgb("#2b6cb0"),
    accent-light: rgb("#ebf4ff"),
    text:         rgb("#1a202c"),
    muted:        rgb("#718096"),
    rule:         rgb("#bee3f8"),
    code-bg:      rgb("#f0f7ff"),
    table-head:   rgb("#2b6cb0"),
    table-odd:    rgb("#ebf8ff"),
  ),
  green: (
    primary:      rgb("#1a4731"),
    accent:       rgb("#276749"),
    accent-light: rgb("#f0fff4"),
    text:         rgb("#1a202c"),
    muted:        rgb("#718096"),
    rule:         rgb("#9ae6b4"),
    code-bg:      rgb("#f0fff4"),
    table-head:   rgb("#276749"),
    table-odd:    rgb("#f0fff4"),
  ),
  mono: (
    primary:      rgb("#1a1a1a"),
    accent:       rgb("#4a4a4a"),
    accent-light: rgb("#f5f5f5"),
    text:         rgb("#1a1a1a"),
    muted:        rgb("#888888"),
    rule:         rgb("#cccccc"),
    code-bg:      rgb("#f5f5f5"),
    table-head:   rgb("#4a4a4a"),
    table-odd:    rgb("#f5f5f5"),
  ),
  warm: (
    primary:      rgb("#7b341e"),
    accent:       rgb("#c05621"),
    accent-light: rgb("#fffaf0"),
    text:         rgb("#1a202c"),
    muted:        rgb("#718096"),
    rule:         rgb("#fbd38d"),
    code-bg:      rgb("#fffaf0"),
    table-head:   rgb("#c05621"),
    table-odd:    rgb("#fffaf0"),
  ),
  purple: (
    primary:      rgb("#2d1b69"),
    accent:       rgb("#6b46c1"),
    accent-light: rgb("#faf5ff"),
    text:         rgb("#1a202c"),
    muted:        rgb("#718096"),
    rule:         rgb("#d6bcfa"),
    code-bg:      rgb("#faf5ff"),
    table-head:   rgb("#6b46c1"),
    table-odd:    rgb("#faf5ff"),
  ),
  teal: (
    primary:      rgb("#1d4044"),
    accent:       rgb("#2c7a7b"),
    accent-light: rgb("#e6fffa"),
    text:         rgb("#1a202c"),
    muted:        rgb("#718096"),
    rule:         rgb("#81e6d9"),
    code-bg:      rgb("#e6fffa"),
    table-head:   rgb("#2c7a7b"),
    table-odd:    rgb("#e6fffa"),
  ),
)

// color 名からパレットを返す（不明な場合は blue を返す）
#let get-palette(color) = {
  if color in palettes { palettes.at(color) } else { palettes.at("blue") }
}
