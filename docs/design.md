# always-typst 設計書

## 1. 概要

要件定義書（`docs/requirements.md`）に基づく実装設計。

---

## 2. ファイル構成

### リポジトリ構成

```
llm-typst/
├── src/
│   ├── templates/
│   │   ├── lib/
│   │   │   ├── fonts.typ       # フォントスタック定義
│   │   │   ├── colors.typ      # テーマカラーパレット（6テーマ）
│   │   │   └── components.typ  # 共通コンポーネント
│   │   ├── document.typ        # print / mobile / wide 用
│   │   ├── slide.typ           # slide 用
│   │   ├── lib.typ             # パッケージエントリポイント
│   │   ├── typst.toml          # パッケージ定義
│   │   └── README.md
│   └── skills/
│       └── typst-doc.md        # agent 向け指示スキル
├── scripts/
│   ├── install.sh              # インストールスクリプト
│   └── md2typst.sh             # Markdown → Typst 変換スクリプト
└── docs/
```

### インストール後の配置先

```
~/.local/share/typst/packages/local/always-typst/0.1.0/   # src/templates/ からコピー

~/.claude/
├── CLAUDE.md               # Typst 使用時ルール追記（手動）
└── skills/
    └── typst-doc.md        # src/skills/ からコピー
```

### テンプレートの import

Typst ローカルパッケージとしてインストールされるため、以下のように import できる：

```typst
#import "@local/always-typst:0.1.0": doc, note, warn, fig, blockquote, ruby, codefile
#import "@local/always-typst:0.1.0": slide-doc
```

---

## 3. フォント設計

### 3.1 日英混植の仕組み

Typst はフォントリストの順番で Unicode カバレッジによるフォールバックを行う。
欧文フォントを先頭に置くことで、ASCII 文字は欧文フォント、和文文字は Yu Gothic が担当する。

```typst
// 例: "Hello 世界" → "Hello" は Calibri、"世界" は Yu Gothic
#set text(font: ("Calibri", "Yu Gothic"))
```

### 3.2 tone 別フォント構成

| tone | 本文 | 見出し | コード |
|---|---|---|---|
| `casual` | Calibri → Yu Gothic | Calibri → Yu Gothic | HackGen35 Console NF → Consolas |
| `business` | Calibri → Yu Gothic | Calibri → Yu Gothic | HackGen35 Console NF → Consolas |
| `stylish` | Georgia → Yu Gothic | Georgia → Yu Gothic | HackGen35 Console NF → Consolas |

### 3.3 フォントスタック定義（lib/fonts.typ）

```typst
#let font-body-default = ("Calibri", "Yu Gothic", "Noto Sans JP")
#let font-body-stylish  = ("Georgia", "Yu Gothic", "Noto Serif JP")
#let font-sans          = ("Calibri", "Yu Gothic", "Noto Sans JP")
#let font-serif         = ("Georgia", "Yu Gothic", "Noto Serif JP")
#let font-mono          = ("HackGen35 Console NF", "Consolas", "Noto Sans Mono")
```

### 3.4 見出し内英数字サイズ補正

欧文フォント（Calibri）のキャップハイトは Yu Gothic の全角枠より小さいため、
見出し内の英数字に +18% のサイズ補正を適用する。

```typst
show heading: it => {
  show regex("[A-Za-z0-9]"): set text(size: 1.18em)
  it
}
```

---

## 4. カラーパレット設計（lib/colors.typ）

各テーマは以下の変数セットを持つ辞書として定義する。

```typst
#let palette = (
  primary:       ...,  // 見出し・強調テキスト
  accent:        ...,  // 装飾・ライン・マーカー
  accent-light:  ...,  // note ボックス背景等
  text:          ...,  // 本文テキスト
  muted:         ...,  // 補足・キャプション・フッター
  rule:          ...,  // 罫線
  code-bg:       ...,  // コードブロック背景
  table-head:    ...,  // テーブルヘッダ背景
  table-odd:     ...,  // テーブル奇数行背景
)
```

### テーマ別カラー値

| テーマ | primary | accent | 用途 |
|---|---|---|---|
| `blue` | `#1a365d` | `#2b6cb0` | 汎用（デフォルト） |
| `green` | `#1a4731` | `#276749` | 環境・自然系 |
| `mono` | `#1a1a1a` | `#4a4a4a` | モノクロ・シンプル |
| `warm` | `#7b341e` | `#c05621` | マーケ・クリエイティブ |
| `purple` | `#2d1b69` | `#6b46c1` | テック・AI |
| `teal` | `#1d4044` | `#2c7a7b` | データ・分析 |

---

## 5. コンポーネント設計（lib/components.typ）

### state による layout / palette 参照

`fig()` 等のコンポーネントが layout・palette を参照できるよう、
`document.typ` / `slide.typ` の `doc()` 関数内で state を更新する。

```typst
#let _layout-state = state("always-typst-layout", "print")
#let _palette-state = state("always-typst-palette", none)

// document.typ の doc() 内で更新
_layout-state.update(layout)
_palette-state.update(p)
```

### コンポーネント一覧

| 名前 | シグネチャ | 説明 |
|---|---|---|
| `note` | `note(body)` | 情報ボックス（accent-light 背景 + 左ボーダー） |
| `warn` | `warn(body)` | 警告ボックス（黄背景 + 左ボーダー） |
| `blockquote` | `blockquote(body)` | 引用ブロック（イタリック + muted 色 + 左ボーダー） |
| `fig` | `fig(path, caption: none, width: auto)` | layout-aware 画像挿入 |
| `ruby` | `ruby(base, rt)` | ルビ（振り仮名）。`context` + `measure()` で幅を計算 |
| `codefile` | `codefile(lang: none, file: none, body)` | ファイル名付きコードブロック（accent 色ヘッダ） |
| `wide-table` | `wide-table(mode: auto, body)` | 横長テーブルの自動レイアウト調整（後述） |

### wide-table の設計

`document.typ` / `slide.typ` の `show table: it => wide-table(it)` により、全テーブルが自動的に `wide-table` を経由する。直接呼び出し `#wide-table(mode: "rotate")[#table(...)]` も可。

#### mode 引数

| mode | 動作 |
|---|---|
| `auto`（デフォルト） | フォント縮小 → 余白はみ出し → 90度回転の順に自動選択 |
| `"normal"` | 調整なし（100% 幅に拡張のみ） |
| `"small"` | フォント縮小のみ（overflow・rotate は行わない） |
| `"overflow"` | フォント縮小 + 余白はみ出し |
| `"rotate"` | フォント縮小 + 回転（`reflow: true` で後続コンテンツとの重なりなし） |

#### ヘッダ再構築

テーブルの先頭行を `table.header(repeat: true, ...)` に変換することで、ページをまたいだ際のヘッダ繰り返しを実現する。

- 既に `table.header` が先頭にある場合は再構築しない
- `p != none`（パレット設定済み）の場合のみ実行

#### テーブルスタイルの分担

| 役割 | 担当 |
|---|---|
| ヘッダ背景色 | `set table(fill: (x, y) => if y == 0 { p.at("table-head") } ...)` |
| ヘッダ文字（白太字） | `show table.cell: it => { if it.y == 0 { set text(fill: white, weight: "bold"); it } else { it } }` |
| データ行背景（交互） | `set table(fill: ...)` の奇数行判定 |
| ページをまたぐ figure | `show figure.where(kind: table): set block(breakable: true)` |

> **Typst 0.14.2 の制約:** `show table.header: it => { set text(fill: white); it }` はヘッダのテキスト色に効かない。`show table.cell` + `it.y == 0` による判定が唯一の有効手段。

#### 幅測定と縮小の優先順位（auto モード）

```
1. 幅が収まる場合: block(width: 100%) で拡張して返す
2. フォント 0.85em 縮小で収まる: そのまま返す
3. フォント 0.75em 縮小で収まる: そのまま返す
4. 余白はみ出し（左右マージン合計まで）で収まる: 中央寄せで返す
5. 90度回転（auto のみ）: rotate(-90deg, reflow: true) で返す
6. フォールバック: 0.75em + はみ出し許容
```

---

## 6. テンプレート設計

### 6.1 document.typ（print / mobile / wide）

パラメータ:

```typst
#let doc(
  title:        "",
  subtitle:     none,
  author:       none,
  date:         none,
  abstract:     none,
  toc:          false,
  cover:        false,   // true: 独立表紙ページ / false: インラインタイトル
  line-numbers: false,   // コードブロックの行番号表示
  layout:       "print", // print | mobile | wide
  tone:         "business",
  color:        "blue",
  body,
) = { ... }
```

#### layout 別ページ設定

| layout | paper | margin | 本文サイズ |
|---|---|---|---|
| `print` | a4 | 25mm | 10.5pt |
| `mobile` | a5 | 16mm | 11pt |
| `wide` | a4横 | 20mm | 10pt |

#### tone 別スタイル

| tone | H1 | H2 | コード角丸 |
|---|---|---|---|
| `casual` | 丸み背景ブロック | 破線アンダーライン | 8pt |
| `business` | アンダーライン | 左矩形バー | 4pt |
| `stylish` | 全幅塗りブロック（白文字） | 縦バー | 0pt |

#### 見出しフォントサイズ（print: 10.5pt 基準）

| レベル | 倍率 | サイズ |
|---|---|---|
| H1 | ×2.1 | 約22pt |
| H2 | ×1.6 | 約17pt |
| H3 | ×1.3 | 約14pt |
| H4 | ×1.1 | 約12pt |

#### テキストスタイル

- 本文行間: `leading: 1.1em`
- イタリック（`emph`）: `style: "italic"` + accent カラー。日本語は合成斜体
- 見出し英数字: +18% サイズ補正（Calibri と Yu Gothic のキャップハイト差を吸収）

#### コードブロック

- 言語ラベル: 右上に muted 色でサブトルに表示（`place(top + right, ...)`）
- 行番号: `line-numbers: true` で有効化（デフォルト: off）
- インラインコード: 背景色 + 等幅フォント

#### テーブル

- `show table: it => wide-table(it)` で全テーブルを `wide-table` に委譲
- `show table.cell: it => { if it.y == 0 { set text(fill: white, weight: "bold"); it } else { it } }` でヘッダ行を白太字
- `show figure.where(kind: table): set block(breakable: true)` でページまたぎを許可
- `figure(table(...), caption: [...])` で自動的に「表 N」番号付き（キャプション位置: top）
- `figure(image(...), caption: [...])` は「図 N」番号付き（キャプション位置: bottom）

### 6.2 slide.typ（slide）

パラメータ:

```typst
#let slide-doc(
  title:  "",
  author: none,
  date:   none,
  tone:   "business",
  color:  "blue",
  body,
) = { ... }
```

スライドは layout 引数を持たない（常に 16:9）。
各スライドは `#pagebreak()` で区切る。

テーブルの設定は `document.typ` と同じ（`show table.cell` によるヘッダ白太字、`wide-table` 委譲、`breakable: true`）。
スライドのヘッダセルフォントサイズは `0.9em`（通常の `1em` より小さい）で自動調整される。

---

## 7. CLI（scripts/altyp）

### コマンド一覧

| コマンド | 説明 |
|---|---|
| `altyp install` | テンプレート・スキル・CLI を所定ディレクトリにインストール |
| `altyp convert <input>` | `.md` または `.typ` を PDF に変換 |

### altyp convert

入力ファイルの拡張子で動作が切り替わる。

#### .typ 入力（Typst → PDF）

```bash
altyp convert input.typ
altyp convert input.typ --output out.pdf
altyp convert input.typ --watch        # ファイル変更を監視して自動再コンパイル
```

#### .md 入力（Markdown → Typst → PDF）

```bash
altyp convert input.md                         # .typ を生成
altyp convert input.md --to pdf                # PDF まで一括変換
altyp convert input.md --author "著者" --toc   # オプション指定
```

| オプション | デフォルト | .md のみ |
|---|---|---|
| `--to typst\|pdf` | `typst` | ✓ |
| `--output, -o` | 入力と同じディレクトリ | |
| `--title` | 最初の H1 から自動抽出 | ✓ |
| `--subtitle`, `--author`, `--date` | なし | ✓ |
| `--toc`, `--cover` | false | ✓ |
| `--layout, -l` | `print` | ✓ |
| `--tone, -t` | `business` | ✓ |
| `--color, -c` | `blue` | ✓ |
| `--watch, -w` | false | .typ のみ |

pandoc 出力の後処理（.md 入力時）:
- `#align(center)[#table(...)]` → `#table(...)` に変換（align/table 競合回避）
- `#horizontalrule` → `#line(length: 100%, stroke: 0.5pt)`
- `#h(-1em)` を除去（LaTeX `\!` 変換の重複スペース対策）

---

## 8. エージェント自動選択ガイドライン

### layout

| キーワード | 選択値 |
|---|---|
| レポート・仕様書・議事録・報告書 | `print` |
| スライド・発表・プレゼン | `slide` |
| 横長・比較表・ダッシュボード | `wide` |
| スマホ・モバイル閲覧 | `mobile` |
| （その他） | `print` |

### tone

| キーワード | 選択値 |
|---|---|
| 社内メモ・ブレスト・カジュアル | `casual` |
| 提案書・報告書・対外向け | `business` |
| 発表・ポートフォリオ・スタイリッシュ | `stylish` |
| （その他） | `business` |

### color

| キーワード | 選択値 |
|---|---|
| （明示なし） | `blue` |
| 分析・データ系 | `teal` |
| AI・テック系 | `purple` |
| モノクロ印刷 | `mono` |
| 環境・自然系 | `green` |
| マーケ・クリエイティブ | `warm` |

---

## 9. 確定済み事項

- 本文フォント: **Calibri + Yu Gothic**（casual/business）、**Georgia + Yu Gothic**（stylish）
- コードフォント: **HackGen35 Console NF**（日英統一、コメント日本語対応）
- Noto JP VF は Typst 0.14 非対応のためフォールバックにのみ使用
- slide は document とは構造が根本的に異なるため別ファイルとする
- テンプレートは Typst ローカルパッケージ（`@local/always-typst:0.1.0`）として配布する
- `ruby` コンポーネントは `context` + `measure()` を使用（`style()` は Typst 0.14 で非推奨）
- イタリックの日本語は明朝体への切り替えをしない（合成斜体 + アクセントカラーのみ）
- テーブルヘッダの白テキストは `show table.cell` + `it.y == 0` で実現（`show table.header` は Typst 0.14.2 でテキスト色に効かない）
- `figure(table(...))` のページまたぎは `show figure.where(kind: table): set block(breakable: true)` が必須
- `wide-table` 内の `table.header` 再構築は先頭行を `table.header(repeat: true, ...)` に変換するのみ（セルへの直接スタイル付与はしない）
