// document.typ - print / mobile / wide 用テンプレート
// layout: "print" | "mobile" | "wide"
// tone:   "casual" | "business" | "stylish"
// color:  "blue" | "green" | "mono" | "warm" | "purple" | "teal"

#import "lib/fonts.typ": body-font, heading-font, font-mono
#import "lib/colors.typ": get-palette
#import "lib/components.typ": _layout-state, _palette-state

#let doc(
  title:    "",
  subtitle: none,
  author:   none,
  date:     none,
  abstract: none,
  toc:          false,
  cover:        false,   // true: 独立表紙ページ / false: インラインタイトル
  line-numbers: false,   // コードブロックの行番号表示
  layout:       "print",
  tone:     "business",
  color:    "blue",
  body,
) = {
  let p = get-palette(color)

  // state を更新してコンポーネントから参照できるようにする
  _layout-state.update(layout)
  _palette-state.update(p)

  // ページ設定
  let (paper, margin, font-size) = if layout == "mobile" {
    ("a5", 16mm, 11pt)
  } else if layout == "wide" {
    ("a4", (x: 20mm, y: 20mm), 10pt)
  } else {
    // print
    ("a4", 25mm, 10.5pt)
  }

  let flipped = layout == "wide"

  set page(
    paper: paper,
    flipped: flipped,
    margin: margin,
    footer: context [
      #set text(size: 8pt, fill: p.at("muted"))
      #h(1fr)
      #counter(page).display("1 / 1", both: true)
    ],
  )

  // 基本テキスト設定
  set text(
    font: body-font(tone),
    size: font-size,
    fill: p.at("text"),
    lang: "ja",
  )

  set par(justify: true, leading: 1.1em)
  set list(spacing: 0.75em, indent: 1em, body-indent: 0.5em)
  set enum(spacing: 0.75em, indent: 1em, body-indent: 0.5em)
  show list: it => block(above: 0.8em, below: 0.8em, it)
  show enum: it => block(above: 0.8em, below: 0.8em, it)

  // イタリック:
  //   欧文 → 各 tone のイタリック体（Calibri Italic / Georgia Italic）
  //   和文 → 合成斜体 + アクセントカラーで区別（明朝体への切り替えはしない）
  show emph: it => text(
    style: "italic",
    fill: p.at("accent"),
    it.body,
  )

  // コードブロック設定
  let code-radius = if tone == "casual" { 8pt }
                    else if tone == "stylish" { 0pt }
                    else { 4pt }

  show raw.where(block: true): it => {
    block(
      width: 100%,
      inset: (x: 10pt, y: 8pt),
      radius: code-radius,
      fill: p.at("code-bg"),
      {
        // 言語ラベル（右上にサブトルに表示）
        if it.lang != none {
          place(top + right, dx: 0pt, dy: 0pt,
            text(font: font-mono, size: 0.72em, fill: p.at("muted"), it.lang)
          )
        }
        // コード本体（行番号あり/なし）
        let lines = it.lines
        if line-numbers {
          grid(
            columns: (auto, 1fr),
            column-gutter: 10pt,
            row-gutter: 0.45em,
            ..lines.map(line => (
              text(font: font-mono, size: 0.88em, fill: p.at("muted"), str(line.number)),
              text(font: font-mono, size: 0.88em, line.body),
            )).flatten()
          )
        } else {
          for line in lines {
            text(font: font-mono, size: 0.88em, line.body)
            linebreak()
          }
        }
      }
    )
  }

  show raw.where(block: false): it => box(
    inset: (x: 3pt, y: 1pt),
    radius: code-radius / 2,
    fill: p.at("code-bg"),
    text(font: font-mono, size: 0.88em, it),
  )

  // テーブルスタイル
  set table(
    stroke: (x, y) => if y == 0 { none } else { (top: 0.5pt + p.at("rule")) },
    fill: (x, y) => if y == 0 { p.at("table-head") }
                    else if calc.odd(y) { p.at("table-odd") }
                    else { white },
  )
  show table.cell.where(y: 0): set text(fill: white, weight: "bold")

  // 見出し内の英数字サイズ補正（欧文フォントのキャップハイトを和文全角に揃える）
  show heading: it => {
    show regex("[A-Za-z0-9]"): set text(size: 1.18em)
    it
  }

  // 見出しスタイル（tone 別）
  show heading.where(level: 1): it => {
    set text(font: heading-font(tone), fill: p.at("primary"), size: font-size * 2.1)
    set par(leading: 0.7em)
    if tone == "casual" {
      block(
        width: 100%,
        inset: (x: 10pt, y: 6pt),
        radius: 6pt,
        fill: p.at("accent-light"),
        above: 2.2em,
        below: 1.6em,
        it.body,
      )
    } else if tone == "stylish" {
      block(
        width: 100%,
        inset: (x: 10pt, y: 8pt),
        fill: p.at("primary"),
        above: 2.2em,
        below: 1.6em,
        text(fill: white, it.body),
      )
    } else {
      // business
      stack(
        spacing: 4pt,
        block(above: 2.2em, below: 0pt, it.body),
        line(length: 100%, stroke: 1.5pt + p.at("accent")),
        block(above: 0pt, below: 1.6em, []),
      )
    }
  }

  show heading.where(level: 2): it => {
    set text(font: heading-font(tone), fill: p.at("primary"), size: font-size * 1.6)
    set par(leading: 0.7em)
    if tone == "casual" {
      block(
        above: 2.0em,
        below: 1.4em,
        stack(
          spacing: 3pt,
          it.body,
          line(length: 60%, stroke: (dash: "dashed", paint: p.at("accent"), thickness: 1pt)),
        ),
      )
    } else if tone == "stylish" {
      block(
        above: 2.0em,
        below: 1.4em,
        stack(
          dir: ltr,
          spacing: 8pt,
          line(length: 0pt, angle: 90deg, stroke: 3pt + p.at("accent")),
          it.body,
        ),
      )
    } else {
      // business
      block(
        above: 2.0em,
        below: 1.4em,
        stack(
          dir: ltr,
          spacing: 8pt,
          rect(width: 4pt, height: 1em, fill: p.at("accent")),
          it.body,
        ),
      )
    }
  }

  show heading.where(level: 3): it => {
    set text(font: heading-font(tone), fill: p.at("accent"), size: font-size * 1.3)
    set par(leading: 0.7em)
    block(above: 1.8em, below: 1.4em, it.body)
  }

  show heading.where(level: 4): it => {
    set text(font: heading-font(tone), fill: p.at("muted"), size: font-size * 1.1)
    block(above: 1.6em, below: 1.4em, it.body)
  }

  // タイトル・目次
  let title-meta = {
    if author != none or date != none {
      set text(size: font-size * 0.85, fill: p.at("muted"))
      align(right, {
        if author != none { author }
        if author != none and date != none { h(1em) }
        if date != none { date }
      })
    }
  }

  if title != "" and cover {
    // 独立表紙ページ（縦中央配置）
    page(
      margin: 0pt,
      header: none,
      footer: none,
      {
        place(bottom, rect(width: 100%, height: 8pt, fill: p.at("accent")))
        place(center + horizon,
          block(width: 72%, {
            text(
              font: heading-font(tone),
              size: font-size * 2.6,
              fill: p.at("primary"),
              weight: "bold",
              title,
            )
            if subtitle != none {
              parbreak()
              v(4pt)
              text(
                font: heading-font(tone),
                size: font-size * 1.4,
                fill: p.at("accent"),
                subtitle,
              )
            }
            v(8pt)
            title-meta
            if abstract != none {
              v(1em)
              block(
                inset: (x: 12pt, y: 8pt),
                fill: p.at("accent-light"),
                radius: 4pt,
                width: 100%,
                abstract,
              )
            }
          })
        )
      }
    )
    if toc {
      outline(
        title: block(
          above: 0pt, below: 1em,
          text(font: heading-font(tone), size: font-size * 1.5, fill: p.at("primary"), weight: "bold", "目次"),
        ),
        depth: 3,
      )
      pagebreak()
    }
  } else {
    // インラインタイトルブロック
    if title != "" {
      block(
        width: 100%,
        below: 1.5em,
        {
          text(
            font: heading-font(tone),
            size: font-size * 2.2,
            fill: p.at("primary"),
            weight: "bold",
            title,
          )
          if subtitle != none {
            parbreak()
            text(
              font: heading-font(tone),
              size: font-size * 1.4,
              fill: p.at("accent"),
              subtitle,
            )
          }
          v(8pt)
          title-meta
          if abstract != none {
            v(0.8em)
            block(
              inset: (x: 10pt, y: 6pt),
              fill: p.at("accent-light"),
              radius: 4pt,
              width: 100%,
              abstract,
            )
          }
        }
      )
    }
    if toc {
      v(1.5em)
      outline(
        title: block(
          above: 0pt, below: 1em,
          text(font: heading-font(tone), size: font-size * 1.5, fill: p.at("primary"), weight: "bold", "目次"),
        ),
        depth: 3,
      )
      v(2em)
    }
  }

  body
}
