# typst-doc スキル

coding agent が高品質な日本語 Typst ドキュメントを生成するためのガイドライン。

## テンプレートの場所

Typst ローカルパッケージとして `~/.local/share/typst/packages/local/always-typst/0.1.0/` にインストールされている。

## 基本的な使い方

### ドキュメント（print / mobile / wide）

```typst
#import "@local/always-typst:0.1.0": doc

#show: doc.with(
  title:    "タイトル",
  subtitle: "サブタイトル",   // 省略可
  author:   "著者名",         // 省略可
  date:     "2026-03-25",    // 省略可
  abstract: "概要",           // 省略可
  toc:          false,        // 目次の有無
  cover:        false,        // true: 独立表紙ページ / false: インラインタイトル
  line-numbers: false,        // コードブロックの行番号表示
  layout:       "print",     // print | mobile | wide
  tone:     "business",      // casual | business | stylish
  color:    "blue",          // blue | green | mono | warm | purple | teal
)

本文をここに書く。
```

### スライド

```typst
#import "@local/always-typst:0.1.0": slide-doc

#show: slide-doc.with(
  title:  "プレゼンタイトル",
  author: "著者名",           // 省略可
  date:   "2026-03-25",      // 省略可
  tone:   "business",
  color:  "blue",
)

= スライド1のタイトル

スライドの内容。

#pagebreak()

= スライド2のタイトル

次のスライドの内容。
```

## コンポーネントの使い方

```typst
#import "@local/always-typst:0.1.0": note, warn, fig, blockquote, ruby, codefile

// 情報ボックス（accent-light 背景 + 左ボーダー）
#note[これは情報ボックスです。]

// 警告ボックス（黄背景 + 左ボーダー）
#warn[これは警告ボックスです。]

// 引用ブロック（イタリック + 左ボーダー）
#blockquote[引用文をここに書く。]

// 画像 (width は省略可。layout に応じて自動調整)
#fig("./images/chart.png", caption: "グラフのキャプション")

// ルビ（振り仮名）
#ruby[自然言語処理][しぜんげんごしょり]

// ファイル名付きコードブロック
#codefile(lang: "python", file: "main.py")[
```python
print("hello")
```
]
```

## 画像の参照

- 画像パスは **Typst ファイルからの相対パス** で指定する
- 例: `fig("./images/chart.png")` → Typst ファイルと同じディレクトリの `images/` 内

## パラメータ自動選択ガイドライン

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

## Markdown からの変換

既存の Markdown ファイルを always-typst テンプレート付き Typst ファイルに変換できる。

```bash
bash ~/path/to/always-typst/scripts/md2typst.sh input.md [options]
```

オプション:

| オプション | 説明 | デフォルト |
|---|---|---|
| `--title <str>` | タイトル（省略時は最初の H1 から自動抽出） | 自動抽出 |
| `--subtitle <str>` | サブタイトル | なし |
| `--author <str>` | 著者名 | なし |
| `--date <str>` | 日付 | なし |
| `--toc` | 目次を有効化 | 無効 |
| `--cover` | 独立表紙ページを有効化 | 無効 |
| `--layout <str>` | print / mobile / wide | print |
| `--tone <str>` | casual / business / stylish | business |
| `--color <str>` | blue / green / mono / warm / purple / teal | blue |
| `--output <file>` | 出力ファイルパス | 入力と同じディレクトリに `.typ` |

変換後は `typst compile output.typ` でPDFを生成する。

## インストール

```bash
bash ~/path/to/always-typst/scripts/install.sh
```

## コンパイル

```bash
typst compile document.typ
# または PDF ウォッチ
typst watch document.typ
```
