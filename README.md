# always-typst

coding agent が高品質な日本語 Typst ドキュメントを生成するためのテンプレートシステム。

## 概要

`layout` / `tone` / `color` の3軸を指定するだけで、見栄えのよい日本語 Typst ドキュメントを生成できる環境を提供する。

## セットアップ

### 事前インストール

**Typst**（0.14 以上）

```bash
cargo install typst-cli
```

**pandoc**（3.1 以上）

apt の pandoc は古い場合があるため、GitHub から最新版を取得する：

```bash
arch=$(dpkg --print-architecture)
wget -q "$(curl -s https://api.github.com/repos/jgm/pandoc/releases/latest \
  | grep -o "\"browser_download_url\": *\"[^\"]*${arch}\.deb\"" \
  | grep -o 'https://[^"]*')" -O /tmp/pandoc.deb \
  && sudo dpkg -i /tmp/pandoc.deb \
  && rm /tmp/pandoc.deb
```

### インストール

```bash
bash scripts/install.sh
```

以下がインストールされる：
- `~/.local/share/typst/packages/local/always-typst/0.1.0/` — Typst テンプレート
- `~/.claude/skills/typst-doc.md` — agent スキルファイル
- `~/.local/bin/altyp` — altyp CLI

## 使い方

### テンプレートを直接使う

```typst
#import "@local/always-typst:0.1.0": doc

#show: doc.with(
  title:  "タイトル",
  layout: "print",    // print | mobile | wide
  tone:   "business", // casual | business | stylish
  color:  "blue",     // blue | green | mono | warm | purple | teal
)

本文をここに書く。
```

### altyp CLI を使う

```bash
# Markdown を Typst に変換
altyp convert document.md

# PDF に変換
altyp convert document.md --to pdf

# オプションを指定
altyp convert document.md --layout mobile --tone casual --color green

# Typst ファイルを PDF にコンパイル
altyp build document.typ

# ファイル変更を監視して自動再コンパイル
altyp build document.typ --watch
```

詳細は `~/.claude/skills/typst-doc.md` を参照。

## ファイル構成

```
src/
├── templates/      # Typst テンプレート（パッケージ本体）
└── skills/         # agent スキルファイル
scripts/
├── install.sh      # インストールスクリプト
└── altyp           # altyp CLI（変換・ビルド）
docs/
├── requirements.md # 要件定義書
└── design.md       # 設計書
```

## 動作環境

- Typst 0.14 以上
- WSL2（Ubuntu）+ Windows フォント
- 必須フォント: Yu Gothic、Calibri、Georgia、HackGen35 Console NF
