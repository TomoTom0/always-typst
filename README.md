# always-typst

coding agent が高品質な日本語 Typst ドキュメントを生成するためのテンプレートシステム。

## 概要

`layout` / `tone` / `color` の3軸を指定するだけで、見栄えのよい日本語 Typst ドキュメントを生成できる環境を提供する。

## インストール

```bash
bash scripts/install.sh
```

Typst ローカルパッケージとして `~/.local/share/typst/packages/local/always-typst/0.1.0/` にインストールされる。

## 使い方

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

詳細は `~/.claude/skills/typst-doc.md` を参照。

## ファイル構成

```
src/
├── templates/      # Typst テンプレート（パッケージ本体）
└── skills/         # agent スキルファイル
scripts/
└── install.sh      # インストールスクリプト
docs/
├── requirements.md # 要件定義書
└── design.md       # 設計書
```

## 動作環境

- Typst 0.14 以上
- WSL2（Ubuntu）+ Windows フォント
- 必須フォント: Yu Gothic、Calibri、Georgia、HackGen35 Console NF
