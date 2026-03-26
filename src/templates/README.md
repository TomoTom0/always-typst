# always-typst テンプレート

## import

```typst
// ドキュメント
#import "@local/always-typst:0.1.0": doc

// スライド
#import "@local/always-typst:0.1.0": slide-doc

// コンポーネント（必要なものだけ列挙）
#import "@local/always-typst:0.1.0": note, warn, fig, blockquote, ruby, codefile
```

## パラメータ

### doc（ドキュメント）

| パラメータ | 型 | デフォルト | 説明 |
|---|---|---|---|
| `title` | string | `""` | タイトル |
| `subtitle` | string/none | `none` | サブタイトル |
| `author` | string/none | `none` | 著者名 |
| `date` | string/none | `none` | 日付 |
| `abstract` | content/none | `none` | 概要 |
| `toc` | bool | `false` | 目次を表示する |
| `cover` | bool | `false` | true: 独立表紙ページ / false: インラインタイトル |
| `line-numbers` | bool | `false` | コードブロックに行番号を表示する |
| `layout` | string | `"print"` | print / mobile / wide |
| `tone` | string | `"business"` | casual / business / stylish |
| `color` | string | `"blue"` | blue / green / mono / warm / purple / teal |

### slide-doc（スライド）

| パラメータ | 型 | デフォルト | 説明 |
|---|---|---|---|
| `title` | string | `""` | タイトル |
| `author` | string/none | `none` | 著者名 |
| `date` | string/none | `none` | 日付 |
| `tone` | string | `"business"` | casual / business / stylish |
| `color` | string | `"blue"` | blue / green / mono / warm / purple / teal |

## コンポーネント

| 名前 | シグネチャ | 説明 |
|---|---|---|
| `note` | `note(body)` | 情報ボックス（accent-light 背景 + 左ボーダー） |
| `warn` | `warn(body)` | 警告ボックス（黄背景 + 左ボーダー） |
| `blockquote` | `blockquote(body)` | 引用ブロック（イタリック + 左ボーダー） |
| `fig` | `fig(path, caption: none, width: auto)` | layout-aware 画像挿入 |
| `ruby` | `ruby(base, rt)` | ルビ（振り仮名） |
| `codefile` | `codefile(lang: none, file: none, body)` | ファイル名付きコードブロック |

## ファイル構成

```
lib/
├── fonts.typ       # フォントスタック定義
├── colors.typ      # テーマカラーパレット（6テーマ）
└── components.typ  # 共通コンポーネント
document.typ        # print / mobile / wide 用テンプレート
slide.typ           # slide 用テンプレート
lib.typ             # パッケージエントリポイント
typst.toml          # パッケージ定義
```
