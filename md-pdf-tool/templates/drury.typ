// Drury Roofing brand template for md-pdf
// Colors: navy (#283D75), orange (#DC5A26), gold (#D5B161)
// Available fonts: Lato, DejaVu Sans, DejaVu Sans Mono, DejaVu Serif, Libertinus Serif

#import "@preview/cmarker:0.1.8"
#import "@preview/mitex:0.2.6": mitex

// ------------------------------------------------------------------ Inputs
#let filepath        = sys.inputs.at("filepath",        default: "input.md")
#let language        = sys.inputs.at("language",        default: "en")
#let show-toc        = sys.inputs.at("toc",             default: "false") == "true"
#let has-frontmatter = sys.inputs.at("has_frontmatter", default: "false") == "true"
#let fm-title        = sys.inputs.at("fm_title",        default: none)
#let fm-subtitle     = sys.inputs.at("fm_subtitle",     default: none)
#let fm-author       = sys.inputs.at("fm_author",       default: none)
#let fm-date         = sys.inputs.at("fm_date",         default: none)
#let fm-tags         = sys.inputs.at("fm_tags",         default: none)
#let fm-version      = sys.inputs.at("fm_version",      default: none)
#let fm-logo         = sys.inputs.at("logo",            default: none)
#let fm-participants = sys.inputs.at("participants",     default: none)

#let tags-list = if fm-tags != none { fm-tags.split(",") } else { () }

#let filename = {
  let f = filepath.split("/").last()
  if f.ends-with(".temp.md") { f.slice(0, f.len() - 8) }
  else if f.ends-with(".md") { f.slice(0, f.len() - 3) }
  else { f }
}

// ---- Read the markdown and extract a leading '# Title' line if present ----
// Convention: single H1 = document title; all sections use H2+.
// If the first non-blank, non-frontmatter line is '# Foo', treat it as title.
#let raw-content = read(filepath)

#let _extract-leading-h1(text) = {
  let lines = text.split("\n")
  let i = 0
  // skip leading blank lines
  while i < lines.len() and lines.at(i).trim() == "" { i = i + 1 }
  if i < lines.len() {
    let line = lines.at(i)
    if line.starts-with("# ") and not line.starts-with("## ") {
      let title = line.slice(2).trim()
      let rest = lines.slice(i + 1).join("\n")
      return (title: title, body: rest)
    }
  }
  return (title: none, body: text)
}

#let _extracted   = _extract-leading-h1(raw-content)
#let inline-title = _extracted.title
#let body-content = _extracted.body

#let doc-author   = if fm-author   != none { fm-author   } else { none }
#let doc-title    = {
  if fm-title != none { fm-title }
  else if inline-title != none { inline-title }
  else { filename }
}
#let doc-subtitle = if fm-subtitle != none { fm-subtitle } else { none }
#let has-title-block = has-frontmatter or inline-title != none
#let doc-date = if fm-date != none {
  let p = fm-date.split("-")
  if p.len() == 3 { datetime(year: int(p.at(0)), month: int(p.at(1)), day: int(p.at(2))) }
  else { datetime.today() }
} else { datetime.today() }

// ---------------------------------------------------------------- Colors
#let navy        = rgb("#283D75")
#let mid-navy    = rgb("#3D558F")
#let bright-blue = rgb("#284EB0")
#let steel-blue  = rgb("#B4C6E8")
#let light-gray  = rgb("#F0F0F0")
#let rust-orange = rgb("#DC5A26")
#let dark-rust   = rgb("#8A3211")
#let gold        = rgb("#D5B161")
#let black       = rgb("#0A0A0A")
#let dark-gray   = rgb("#3D3D3D")
#let med-gray    = rgb("#D4D4D4")
#let white       = rgb("#FFFFFF")

// ---------------------------------------------------------------- Document
#set document(
  author:   if doc-author != none { doc-author } else { "" },
  title:    doc-title,
  keywords: (if doc-author != none { doc-author } else { "" },
             if doc-title  != none { doc-title  } else { "" },
             "md-pdf", ..tags-list),
  date: doc-date,
)

// -------------------------------------------------------------------- Page
#set page(
  margin: (top: 2.6cm, bottom: 2.6cm, left: 2.6cm, right: 2.2cm),
  header: context {
    if here().page() >= 2 [
      #set text(8pt, fill: rust-orange, weight: "bold", tracking: 1pt)
      #upper(doc-title)
      #h(1fr)
      #set text(8pt, fill: med-gray, weight: "regular", tracking: 0pt)
      #doc-date.display("[month repr:short] [year]")
      #v(-2pt)
      #line(length: 100%, stroke: 0.5pt + med-gray)
    ]
  },
  footer: context {
    if here().page() >= 2 [
      #line(length: 100%, stroke: 0.5pt + med-gray)
      #v(2pt)
      #set text(9pt, fill: dark-gray)
      #if doc-author != none { doc-author }
      #h(1fr)
      #counter(page).display("1 / 1", both: true)
    ]
  },
)

// --------------------------------------------------------------- Text defaults
#set text(
  font: "Lato",
  fallback: true,
  lang: language,
  size: 10.5pt,
  fill: dark-gray,
)

// Paragraph spacing & line height
#set par(
  leading: 0.75em,      // line-height within a paragraph
  spacing: 1.1em,       // space between paragraphs / blocks
  justify: false,
)

// ------------------------------------------------------------------- Headings
#show heading: set block(above: 1.8em, below: 0.9em)
// No auto-numbering: narrative documents read better without 1.1 / 1.2 prefixes.
#set heading(numbering: none)

// H1 — navy, bold
#show heading.where(level: 1): set text(size: 20pt, weight: "bold", fill: navy)

// H2 — mid-navy
#show heading.where(level: 2): set text(size: 14pt, weight: "bold", fill: mid-navy)

// H3 — dark gray
#show heading.where(level: 3): set text(size: 11pt, weight: "bold", fill: dark-gray)

// H4 — smaller
#show heading.where(level: 4): set text(size: 10pt, weight: "bold", fill: dark-gray)

// ------------------------------------------------------------------- Links
#show link: it => text(fill: bright-blue, it)

// ---------------------------------------------------------------- Strong/Emph
#show strong: it => text(weight: "bold", fill: rust-orange, it)
#show emph: it => text(style: "italic", fill: mid-navy, it)

// ------------------------------------------------------------------- Code
#show raw: set text(font: "DejaVu Sans Mono", fallback: true)
#show raw.where(block: false): set text(weight: "semibold", size: 9pt)
#show raw.where(block: true): set text(size: 8pt)

// ------------------------------------------------------------------ Tables
#set table(
  stroke: 0.5pt + med-gray,
  inset: (x: 6pt, y: 4pt),
)

// ------------------------------------------------------------------- Lists
#set list(spacing: 0.9em, indent: 0.6em, marker: ([•], [–], [·]))
#set enum(spacing: 0.9em, indent: 0.6em)

// -------------------------------------------------------------- Title page
// A dedicated cover page when frontmatter or a leading '#' supplied a title.
// Vertically centered, no header/footer (suppressed by `page() >= 2` rules).
#if has-title-block [
  #v(1fr)
  #align(center)[
    #text(size: 36pt, weight: "bold", fill: navy)[#doc-title]

    #v(0.6em)

    #if doc-subtitle != none [
      #text(size: 16pt, fill: mid-navy, style: "italic")[#doc-subtitle]
      #v(0.8em)
    ]

    #line(length: 30%, stroke: 2pt + gold)

    #v(1.5em)

    #if doc-author != none [
      #text(12pt, weight: "semibold", fill: dark-gray)[#doc-author]
      #v(0.4em)
    ]

    #text(10pt, fill: dark-gray)[#doc-date.display("[month repr:long] [day], [year]")]

    #if fm-version != none [
      #v(0.4em)
      #text(10pt, fill: dark-gray)[Version #fm-version]
    ]
  ]
  #v(1fr)
  #pagebreak()
]

// -------------------------------------------------------- Table of contents
#if show-toc [
  #outline(title: "Contents", indent: 1em)
  #pagebreak()
]

// --------------------------------------------------------- Render markdown
// Render the body (with any leading '# Title' already stripped into title block).
#cmarker.render(
  body-content,
  scope: (image: (path, alt: none) => image(path, alt: alt)),
  math: mitex,
)
