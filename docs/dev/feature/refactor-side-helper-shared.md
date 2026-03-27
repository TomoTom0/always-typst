# _sideヘルパーロジックの共通化

## 現状

`components.typ` の `wide-table` 関数内に `_side` ヘルパー関数がローカル定義されている。
`document.typ` や `slide.typ` のフッター部分にも、ページ余白を取得する同様のロジックが存在する。

## 問題点

- 同じロジックが複数箇所に重複している
- 余白取得ロジックを変更する場合、複数ファイルを修正する必要がある
- 将来的なメンテナンスコストが増加する

## 改善案

`_side` ヘルパー関数を `components.typ` からエクスポートし、
`document.typ` / `slide.typ` で import して再利用する。

## 優先度

medium

## 関連

- PR: #2
- Thread ID: PRRT_kwDORxLCNs53MAI1
- タスク: TASK-12
- 関連ファイル: src/templates/lib/components.typ, src/templates/document.typ, src/templates/slide.typ
