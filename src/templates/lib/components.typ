// 共通コンポーネント（note / warn / fig / wide-table）

// layout 参照用 state（document.typ / slide.typ の doc() 内で更新する）
#let _layout-state = state("always-typst-layout", "print")

// palette 参照用 state（document.typ / slide.typ の doc() 内で更新する）
#let _palette-state = state("always-typst-palette", none)

// テーブル開始ページ記録用 state（繰り返しヘッダの色切り替えに使用）
#let _tbl-start-page = state("always-typst-tbl-start", 0)

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

// 横長テーブルの自動レイアウト調整
//
// 優先順位（mode: auto のとき）:
//   1. フォント縮小（0.85em → 0.75em）
//   2. 余白はみ出し（左右マージン分まで中央配置で拡張）
//   3. 90度回転（ページを横向きに使う）
//   4. フォールバック（0.75em + はみ出し + ページまたぎ許容）
//
// mode 引数:
//   auto      → 優先度順に自動選択（デフォルト）
//   "normal"  → 調整なし
//   "small"   → フォント縮小のみ（overflow・rotate は行わない）
//   "overflow"→ フォント縮小 + 余白はみ出し（rotate は行わない）
//   "rotate"  → フォント縮小 + 余白はみ出し + 回転
//
// 使用例:
//   #wide-table[#table(...)]                   // 自動（推奨）
//   #wide-table(mode: "rotate")[#table(...)]   // 回転を優先
//   #wide-table(mode: "small")[#table(...)]    // フォント縮小のみ
#let wide-table(mode: auto, caption: none, body) = context {
  let p = _palette-state.get()

  // body がテーブルの場合: ヘッダ再構築 + 開始ページ記録
  // show table ルール経由でも直接呼び出しでも同じ処理が適用される
  let processed = if body.func() == table {
    let children = body.children
    let cols = body.columns
    let num-cols = if type(cols) == int { cols }
                   else if type(cols) == array { cols.len() }
                   else { 1 }
    let first-is-header = children.len() > 0 and children.at(0).func() == table.header
    _tbl-start-page.update(counter(page).get().first())
    if (not first-is-header) and children.len() > num-cols and p != none {
      let base = body.fields().keys()
        .filter(k => k != "children")
        .fold((:), (acc, k) => acc + ((k): body.fields().at(k)))
      table(
        ..base,
        table.header(repeat: true, ..children.slice(0, num-cols)),
        ..children.slice(num-cols),
      )
    } else { body }
  } else { body }

  // show table: it => it で再帰的な show table 適用を封じる
  let guarded = {
    show table: it => it
    processed
  }

  // caption が指定されている場合は figure で包む（非回転用）
  let wrap(content) = if caption != none {
    figure(content, kind: table, caption: caption)
  } else { content }

  // 回転ケース用: キャプションを回転ブロック内に含める（caption も一緒に回転）
  let make-rotated(b, width) = {
    let inner = if caption != none {
      counter(figure.where(kind: table)).step()
      stack(spacing: 6pt,
        align(center, {
          set text(size: 0.88em)
          text(weight: "bold", fill: p.at("primary"),
            context [表 #counter(figure.where(kind: table)).display()]
          )
          text(fill: p.at("muted"), [: ])
          caption
        }),
        b,
      )
    } else { b }
    align(center, rotate(-90deg, reflow: true, block(width: width, align(center, inner))))
  }

  // 後方互換: 非回転ケース用 wrap（未使用になった wrap-rotated は削除）
  let wrap-rotated(rotated-content) = rotated-content

  // page.margin は単一値(25mm)またはdict((x:20mm,y:20mm)など)の両方がありうる
  let _m = page.margin
  let _side(key, cross) = if type(_m) == dictionary {
    if key   in _m { _m.at(key)   }
    else if cross in _m { _m.at(cross) }
    else { 0pt }
  } else { _m }
  let ml = _side("left",   "x")
  let mr = _side("right",  "x")
  let cw = page.width  - ml - mr
  let lw = page.height - _side("top", "y") - _side("bottom", "y")

  // block(width: auto) で自然幅（コンテナ幅に依存しない固有幅）を取得
  let w0 = measure(block(width: auto, guarded)).width

  // 調整不要: 幅 100% に拡張して返す（auto 列テーブルが狭くならないように）
  if mode == "normal" { return wrap(block(width: 100%, guarded)) }

  // mode: "rotate" → フォント縮小をスキップして直接回転
  if mode == "rotate" {
    let b2 = { set text(size: 0.75em); guarded }
    let w2 = measure(block(width: auto, b2)).width
    let use-lw = if w2 <= lw { lw } else { w2 }
    return make-rotated(b2, use-lw)
  }

  // mode: auto / "small" / "overflow" → 優先順に試みる

  // 収まる場合: 100% 幅に拡張（auto 列の狭いテーブルを本文幅に揃える）
  if w0 <= cw {
    return wrap(block(width: 100%, guarded))
  }

  // Step 1: フォント縮小
  let b1 = { set text(size: 0.85em); guarded }
  let w1 = measure(block(width: auto, b1)).width
  if w1 <= cw { return wrap(block(width: 100%, b1)) }

  let b2 = { set text(size: 0.75em); guarded }
  let w2 = measure(block(width: auto, b2)).width
  if w2 <= cw { return wrap(block(width: 100%, b2)) }

  // Step 2: 余白はみ出し（small モード以外）
  // 左右マージン合計分まで中央配置で均等にはみ出す（行方向ページまたぎも許容）
  if mode != "small" and w2 <= cw + ml + mr {
    return wrap(align(center, block(width: w2, b2)))
  }

  // Step 3: 90度回転（auto のみ）- portrait に収まらない場合は常に回転
  if mode == auto {
    let use-lw = calc.max(lw, w2)
    return make-rotated(b2, use-lw)
  }

  // フォールバック: 0.75em + はみ出し許容（行方向ページまたぎも許容）
  wrap(align(center, block(width: w2, b2)))
}

// layout-aware 画像挿入
#let fig(path, caption: none, width: auto) = context {
  let l = _layout-state.get()
  let w = if width != auto { width }
          else if l in ("slide", "mobile") { 100% }
          else { 70% }
  figure(image(path, width: w), caption: caption)
}
