// slide.typ - スライドテンプレート（16:9固定）
// tone:  "casual" | "business" | "stylish"
// color: "blue" | "green" | "mono" | "warm" | "purple" | "teal"

#import "lib/fonts.typ": body-font, heading-font, font-mono
#import "lib/colors.typ": get-palette
#import "lib/components.typ": _layout-state, _palette-state, _tbl-start-page, wide-table

// スライドのページサイズ（16:9）
#let _slide-width  = 254mm
#let _slide-height = 142.875mm

#let slide-doc(
  title:  "",
  author: none,
  date:   none,
  tone:   "business",
  color:  "blue",
  body,
) = {
  let p = get-palette(color)

  _layout-state.update("slide")
  _palette-state.update(p)
  _tbl-start-page.update(1)  // ページ1の初回ヘッダが濃色になるよう初期値を1に設定

  set page(
    width:  _slide-width,
    height: _slide-height,
    margin: (x: 16mm, top: 14mm, bottom: 12mm),
    header: context {
      // タイトルスライド以外はヘッダを表示
      if counter(page).get().first() > 1 {
        set text(size: 7pt, fill: p.at("muted"))
        title
        h(1fr)
        if author != none { author }
      }
    },
    footer: context {
      let cur   = str(counter(page).get().first())
      let total = str(counter(page).final().first())
      let _m = page.margin
      let mr = if type(_m) == dictionary {
        if "right" in _m { _m.right } else if "x" in _m { _m.x } else { 16mm }
      } else { _m }
      // 右マージンに近い位置まで拡張して右端揃え
      block(
        width: 100% + mr - 5mm,
        align(right, {
          text(size: 9pt, weight: "bold", fill: p.at("primary"), cur)
          text(size: 6.5pt, fill: p.at("muted"), " / " + total)
        })
      )
    },
  )

  set text(
    font: body-font(tone),
    size: 11pt,
    fill: p.at("text"),
    lang: "ja",
  )

  set par(leading: 0.7em)

  // コードブロック
  let code-radius = if tone == "casual" { 6pt }
                    else if tone == "stylish" { 0pt }
                    else { 3pt }

  show raw.where(block: true): it => block(
    width: 100%,
    inset: (x: 8pt, y: 6pt),
    radius: code-radius,
    fill: p.at("code-bg"),
    text(font: font-mono, size: 0.82em, it),
  )

  show raw.where(block: false): it => box(
    inset: (x: 3pt, y: 1pt),
    radius: code-radius / 2,
    fill: p.at("code-bg"),
    text(font: font-mono, size: 0.82em, it),
  )

  // テーブルスタイル
  set table(
    stroke: (x, y) => if y == 0 { none } else { (top: 0.4pt + p.at("rule")) },
    fill: (x, y) => if y == 0 { p.at("table-head") }
                    else if calc.odd(y) { p.at("table-odd") }
                    else { white },
  )
  // ヘッダ行（y==0）を白太字で表示
  show table.cell: it => {
    if it.y == 0 {
      set text(fill: white, weight: "bold")
      it
    } else {
      it
    }
  }

  show table: it => wide-table(it)
  show figure.where(kind: table): set block(breakable: true)
  show figure.where(kind: table): set figure(supplement: [表])
  show figure.where(kind: image): set figure(supplement: [図])
  show figure.caption: it => {
    set text(size: 0.82em)
    text(fill: p.at("primary"), weight: "bold", [#it.supplement #it.counter.display(it.numbering)])
    text(fill: p.at("muted"), it.separator)
    it.body
  }

  // 見出し（スライド内セクションタイトル）
  show heading.where(level: 1): it => {
    set text(font: heading-font(tone), fill: p.at("primary"), size: 18pt, weight: "bold")
    if tone == "stylish" {
      block(
        width: 100%,
        inset: (x: 8pt, y: 6pt),
        fill: p.at("primary"),
        above: 0.6em,
        below: 0.5em,
        text(fill: white, it.body),
      )
    } else {
      stack(
        spacing: 3pt,
        block(above: 0.6em, below: 0pt, it.body),
        line(length: 100%, stroke: 1.5pt + p.at("accent")),
        block(above: 0pt, below: 0.5em, []),
      )
    }
  }

  show heading.where(level: 2): it => {
    set text(font: heading-font(tone), fill: p.at("accent"), size: 13pt)
    block(above: 0.8em, below: 0.4em, it.body)
  }

  // タイトルスライド
  if title != "" {
    page(
      margin: 0pt,
      header: none,
      footer: none,
      {
        // 背景
        rect(
          width: 100%,
          height: 100%,
          fill: p.at("primary"),
        )
        place(
          center + horizon,
          dx: 0pt,
          dy: -6mm,
          {
            set text(fill: white)
            align(center, {
              text(
                font: heading-font(tone),
                size: 28pt,
                weight: "bold",
                title,
              )
              if author != none or date != none {
                v(8mm)
                set text(size: 11pt, fill: luma(200))
                if author != none { author }
                if author != none and date != none { h(1em) }
                if date != none { date }
              }
            })
          },
        )
        // アクセントライン
        place(
          bottom,
          rect(width: 100%, height: 6pt, fill: p.at("accent")),
        )
      },
    )
  }

  body
}
