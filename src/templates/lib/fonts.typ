// フォントスタック定義
// WSL2 + Windows フォント環境を前提とする

#let font-body-default = ("Calibri", "Yu Gothic", "Noto Sans JP")
#let font-body-stylish  = ("Georgia", "Yu Gothic", "Noto Serif JP")
#let font-sans          = ("Calibri", "Yu Gothic", "Noto Sans JP")
#let font-serif         = ("Georgia", "Yu Gothic", "Noto Serif JP")
#let font-mono          = ("HackGen35 Console NF", "Consolas", "Noto Sans Mono")

// tone に応じた本文フォントを返す
#let body-font(tone) = if tone == "stylish" { font-body-stylish } else { font-body-default }

// tone に応じた見出しフォントを返す
#let heading-font(tone) = if tone == "stylish" { font-serif } else { font-sans }
