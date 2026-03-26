// 共通コンポーネント（note / warn / fig）

// layout 参照用 state（document.typ / slide.typ の doc() 内で更新する）
#let _layout-state = state("always-typst-layout", "print")

// palette 参照用 state（document.typ / slide.typ の doc() 内で更新する）
#let _palette-state = state("always-typst-palette", none)

// 情報ボックス（accent-light 背景）
#let note(body) = context {
  let p = _palette-state.get()
  let bg = if p != none { p.at("accent-light") } else { rgb("#ebf4ff") }
  let border = if p != none { p.at("accent") } else { rgb("#2b6cb0") }
  block(
    width: 100%,
    inset: (x: 12pt, y: 8pt),
    radius: 4pt,
    fill: bg,
    stroke: (left: 3pt + border),
    body,
  )
}

// 引用ブロック
#let blockquote(body) = context {
  let p = _palette-state.get()
  let border = if p != none { p.at("rule") } else { rgb("#bee3f8") }
  block(
    width: 100%,
    inset: (left: 12pt, right: 8pt, top: 6pt, bottom: 6pt),
    stroke: (left: 3pt + border),
    text(style: "italic", fill: if p != none { p.at("muted") } else { rgb("#718096") }, body),
  )
}

// 警告ボックス（黄背景）
#let warn(body) = block(
  width: 100%,
  inset: (x: 12pt, y: 8pt),
  radius: 4pt,
  fill: rgb("#fffff0"),
  stroke: (left: 3pt + rgb("#d69e2e")),
  body,
)

// ルビ（振り仮名）
#let ruby(base, rt) = context {
  let ruby-size = 0.5em
  let base-w  = measure(base).width
  let ruby-w  = measure(text(size: ruby-size, rt)).width
  let w = calc.max(base-w, ruby-w)
  box(
    width: w,
    stack(
      spacing: 0pt,
      align(center, text(size: ruby-size, fill: rgb("#444444"), rt)),
      align(center, base),
    )
  )
}

// ファイル名付きコードブロック
#let codefile(lang: none, file: none, body) = context {
  let p = _palette-state.get()
  let bg = if p != none { p.at("code-bg") } else { rgb("#f0f7ff") }
  let accent = if p != none { p.at("accent") } else { rgb("#2b6cb0") }
  let muted = if p != none { p.at("muted") } else { rgb("#718096") }
  stack(
    spacing: 0pt,
    block(
      width: 100%,
      inset: (x: 10pt, y: 4pt),
      radius: (top: 4pt),
      fill: accent,
      {
        set text(size: 0.78em, fill: white, weight: "bold")
        if lang != none { lang }
        if lang != none and file != none { h(1em) }
        if file != none { text(weight: "regular", file) }
      }
    ),
    block(
      width: 100%,
      inset: (x: 10pt, y: 8pt),
      radius: (bottom: 4pt),
      fill: bg,
      body
    ),
  )
}

// layout-aware 画像挿入
#let fig(path, caption: none, width: auto) = context {
  let l = _layout-state.get()
  let w = if width != auto { width }
          else if l in ("slide", "mobile") { 100% }
          else { 70% }
  figure(image(path, width: w), caption: caption)
}
