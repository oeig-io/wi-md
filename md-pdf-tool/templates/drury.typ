// Drury brand template for md-pdf
// Navy/orange/gold palette: navy (#283D75), orange (#DC5A26), gold (#D5B161)
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

#let doc-author   = if fm-author   != none { fm-author   } else { none }
#let doc-title    = if fm-title    != none { fm-title    } else { filename }
#let doc-subtitle = if fm-subtitle != none { fm-subtitle } else { none }
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
  size: 10pt,
  fill: dark-gray,
)

// ------------------------------------------------------------------- Headings
#show heading: set block(above: 1.4em, below: 0.6em)
#set heading(numbering: "1.1")

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
#set list(spacing: 0.5em)
#set enum(spacing: 0.5em)

// -------------------------------------------------------------- Front matter
#if has-frontmatter [
  #if fm-title != none [
    #v(1cm)
    #text(size: 24pt, weight: "bold", fill: navy)[#fm-title]
    #v(0.3em)
  ]
  #if fm-subtitle != none [
    #text(size: 14pt, fill: mid-navy)[#fm-subtitle]
    #v(0.3em)
  ]
  #if doc-author != none or fm-version != none [
    #set text(10pt, fill: dark-gray)
    #if doc-author != none [#doc-author]
    #if doc-author != none and fm-version != none [ · ]
    #if fm-version != none [v#fm-version]
    #v(0.3em)
  ]
  #line(length: 100%, stroke: 2pt + gold)
  #v(1cm)
]

// -------------------------------------------------------- Table of contents
#if show-toc [
  #outline(title: "Contents", indent: 1em)
  #pagebreak()
]

// --------------------------------------------------------- Render markdown
#cmarker.render(
  read(filepath),
  scope: (image: (path, alt: none) => image(path, alt: alt)),
  math: mitex,
)
