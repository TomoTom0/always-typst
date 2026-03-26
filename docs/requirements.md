# always-typst 要件定義書

## 1. 背景・目的

### 1.1 背景

coding agent にドキュメント・レポートの作成を依頼する際、Markdown ではなく
Typst で出力させることで見栄えを向上させたい。しかし現状、単に「Typst で出力せよ」
と指示するだけでは以下の問題が生じる：

- デザインが貧弱・読みにくい
- 日本語フォントが適切に設定されない
- 用途に合わないレイアウトが生成される
- 毎回ゼロからスタイルを書かせると品質にばらつきが出る

### 1.2 目的

任意のプロジェクトで、coding agent が `layout` / `tone` / `color` を指定するだけで
高品質な日本語 Typst ドキュメントを生成できる環境を整備する。

---

## 2. ステークホルダー

| 役割 | 説明 |
|---|---|
| ユーザー（人間） | ドキュメント生成を指示する。パラメータを明示することも、agent に委ねることもある |
| coding agent | テンプレートを使用して Typst ファイルを生成する |
| テンプレート管理者 | テンプレートの改善・追加を行う（現時点では同一人物） |

---

## 3. 機能要件

### 3.1 テンプレートパラメータ

テンプレートは以下の3軸のパラメータを受け付けること。

#### layout（レイアウト）

| 値 | 説明 | ページサイズ |
|---|---|---|
| `print` | 印刷前提 | A4縦 |
| `mobile` | スマホ閲覧前提 | A5縦相当 |
| `wide` | 横長形式 | A4横 |
| `slide` | スライド形式 | 16:9 |

#### tone（雰囲気）

| 値 | 説明 | 本文フォント |
|---|---|---|
| `casual` | カジュアル | Calibri + Yu Gothic |
| `business` | ビジネス（デフォルト） | Calibri + Yu Gothic |
| `stylish` | スタイリッシュ | Georgia + Yu Gothic |

#### color（テーマカラー）

| 値 | イメージ | デフォルト |
|---|---|---|
| `blue` | 汎用 | はい |
| `green` | 環境・自然系 | |
| `mono` | モノクロ・シンプル | |
| `warm` | マーケ・クリエイティブ系 | |
| `purple` | テック・AI系 | |
| `teal` | データ・分析系 | |

### 3.2 テンプレート API

```typst
#import "@local/always-typst:0.1.0": doc

#show: doc.with(
  title:        "タイトル",
  subtitle:     "サブタイトル",  // 省略可
  author:       "著者名",        // 省略可
  date:         "2026-03-25",   // 省略可
  abstract:     "概要",          // 省略可
  toc:          false,           // 目次の有無
  cover:        false,           // true: 独立表紙ページ
  line-numbers: false,           // コードブロック行番号
  layout:       "print",
  tone:         "business",
  color:        "blue",
)
```

### 3.3 コンポーネント

テンプレートは以下のコンポーネントを提供すること。

| コンポーネント | 説明 |
|---|---|
| `note(body)` | 情報ボックス（accent-light 背景 + 左ボーダー） |
| `warn(body)` | 警告ボックス（黄背景 + 左ボーダー） |
| `blockquote(body)` | 引用ブロック（イタリック + 左ボーダー） |
| `fig(path, caption, width)` | layout-aware な画像挿入 |
| `ruby(base, rt)` | ルビ（振り仮名） |
| `codefile(lang, file, body)` | ファイル名付きコードブロック |

### 3.4 自動スタイル適用

以下の要素はテンプレートが自動でスタイルを適用すること。

- 見出し（level 1〜4）、tone に応じたデザイン
- コードブロック（インライン・ブロック）。言語ラベルをサブトルに右上表示
- テーブル（ヘッダ背景・交互行色）
- 箇条書き・番号リスト
- イタリック（`emph`）: accent カラー + 合成斜体
- ページフッター（ページ番号）
- タイトルブロック（`title` 指定時）
- 目次（`toc: true` 時）

### 3.5 日本語対応

- 日英混植を自動処理すること（欧文→和文フォントフォールバック）
- `lang: "ja"` で禁則処理を有効にすること
- コードブロック内の日本語コメントも適切に表示されること
- ルビ（振り仮名）コンポーネントを提供すること

### 3.6 Markdown 変換

- `scripts/md2typst.sh` により Markdown を always-typst テンプレート付き Typst ファイルに変換できること
- pandoc を内部で使用し、テーブル・水平線・引用ブロックを適切に変換すること

---

## 4. 非機能要件

### 4.1 再利用性

- Typst ローカルパッケージ（`~/.local/share/typst/packages/local/always-typst/0.1.0/`）として配置し、任意のプロジェクトから `@local/always-typst:0.1.0` で import できること
- パッケージ名は agent スキルに記載し、agent が自律的に利用できること

### 4.2 保守性

- カラーテーマの追加・変更は `lib/colors.typ` のみの修正で完結すること
- フォントの変更は `lib/fonts.typ` のみの修正で完結すること

### 4.3 拡張性

- 新しい `layout` / `tone` / `color` を追加できる構造とすること

### 4.4 動作環境

- Typst 0.14 以上
- WSL2（Ubuntu）+ Windows フォント（`/mnt/c/Windows/Fonts/`）
- 必須フォント：Yu Gothic、Calibri、Georgia、HackGen35 Console NF

---

## 5. ファイル構成

```
~/.local/share/typst/packages/local/always-typst/0.1.0/
├── typst.toml
├── lib.typ             # エントリポイント
├── lib/
│   ├── fonts.typ       # フォントスタック定義
│   ├── colors.typ      # テーマカラーパレット
│   └── components.typ  # 共通コンポーネント
├── document.typ        # print / mobile / wide 用テンプレート
└── slide.typ           # slide 用テンプレート

~/.claude/
├── CLAUDE.md               # Typst 使用時ルール追記
└── skills/
    └── typst-doc.md        # agent への指示スキル
```

---

## 6. エージェントスキル要件

`~/.claude/skills/typst-doc.md` は以下を含むこと：

- テンプレートのパスと import 方法
- パラメータの選び方（自動選択ガイドライン）
- コンポーネントの使用例
- `md2typst.sh` の使い方
- 画像の参照方法（Typst ファイルからの相対パス）

---

## 7. 制約・前提

- テンプレートは人間が直接使うことも想定するが、主目的は agent による利用
- Typst のコンパイルは `typst compile <file.typ>` で実行する（agent はソースファイル生成のみ）
- バリアブルフォント（Noto Serif/Sans JP VF）は Typst 0.14 で非対応のため使用しない
