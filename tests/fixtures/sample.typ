#import "@local/always-typst:0.1.0": doc

#show: doc.with(
  title: "テストドキュメント",
  layout: "print",
  tone: "business",
  color: "blue",
)

= セクション1

本文テキストです。

#table(
  columns: (1fr, 1fr),
  [ヘッダA], [ヘッダB],
  [データ1], [データ2],
)
