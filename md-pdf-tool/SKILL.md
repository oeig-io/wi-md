---
name: md-pdf
description: Convert markdown files to PDF using md-pdf (typst engine) with built-in and custom brand templates
compatibility: opencode
metadata:
  type: tool
  original_file: md-pdf-tool/SKILL.md
  category: publishing
  scope: md
---

# MD-PDF Tool

The purpose of this document is to provide a reliable, repeatable process for converting markdown files to PDF using typst as the rendering engine.

This is important because the pandoc+weasyprint pipeline breaks on anchor links and CSS edge cases, while md-pdf compiles cleanly on first try with no intermediate HTML step.

## Overview

**Tool:** `md-pdf` (Rust crate, installed via `cargo install md-pdf`)
**Engine:** typst (via the `cmarker` package for markdown parsing)
**Pipeline:** Markdown → cmarker (typst package) → typst template → PDF

> 💡 **Tip** — This skill ships with a sample brand template at [`templates/drury.typ`](templates/drury.typ). Install it to `~/.config/md-pdf/templates/drury.typ` to use `--template drury`. See [Custom Templates](#custom-templates) for details.

## Default Workflow

For any "convert this markdown to PDF" task:

```bash
md-pdf input.md -o output.pdf --template simple
```

That's it. No CSS, no intermediate HTML, no anchor-link problems.

### Common patterns

```bash
# Same directory, same name, .pdf extension (default behavior)
md-pdf docs/report.md

# Explicit output path
md-pdf docs/report.md -o /tmp/report.pdf

# Choose a template
md-pdf docs/report.md --template brutalist

# Use a custom brand template (must be installed first)
md-pdf docs/report.md --template drury

# Watch mode — rebuild on save
md-pdf docs/report.md --watch

# Check links in the markdown
md-pdf docs/report.md --check-links
```

### Output defaults

When `-o` is omitted, the output PDF is written to the same directory as the input with a `.pdf` extension:
- `docs/report.md` → `docs/report.pdf`

## Installation

```bash
cargo install md-pdf
```

This installs the binary to `~/.cargo/bin/md-pdf`. Ensure `~/.cargo/bin` is on your `PATH`.

On first run, `md-pdf` creates:
- `~/.config/md-pdf/config.ron` — configuration file
- `~/.config/md-pdf/templates/` — built-in template directory

### Dependencies

- `cargo` (Rust toolchain) — for installation
- `typst` — bundled inside `md-pdf`; no separate typst install needed at runtime
- No LaTeX, Chrome, Puppeteer, WeasyPrint, or wkhtmltopdf required

## Built-in Templates

| Template | Description | Best for |
|----------|-------------|----------|
| `simple` | Professional with headers/footers | Business documents, reports |
| `brutalist` | Raw, bold, high contrast | Technical specs, readability |
| `darko` | Dark theme | Screen reading |
| `none` | Minimal styling | Raw content, debugging |
| `playful` | Colorful, Dieter Rams inspired | Presentations, creative docs |

List available templates:

```bash
md-pdf --list-templates
```

## Configuration

Configuration lives at `~/.config/md-pdf/config.ron`:

```ron
(
    templates_dir: Some("/home/debian/.config/md-pdf/templates"),
    default_template: Some("simple"),
    default_language: Some("en"),
    default_toc: Some(true),
    default_author: Some("md-pdf"),
)
```

Key settings:
- `default_template` — template used when `--template` is omitted
- `default_toc` — whether to generate a table of contents by default
- `default_author` — author metadata embedded in the PDF

## YAML Front Matter

Markdown files can include YAML front matter for metadata that flows into the PDF:

```yaml
---
title: Bid Portals
subtitle: Texas Commercial Roofing
author: OEIG
date: 2026-05-05
version: 2.0
tags: roofing, texas, procurement
---
```

Supported fields: `title`, `subtitle`, `author`, `date`, `version`, `tags`, `logo`, `participants`.

When front matter is present, the template renders a title block on the first page. When absent, the filename is used as the document title.

## Custom Templates

Custom templates are typst `.typ` files placed in `~/.config/md-pdf/templates/`. They become available via `--template <name>` (without the `.typ` extension).

### Installing a custom template

```bash
cp templates/drury.typ ~/.config/md-pdf/templates/drury.typ
md-pdf input.md --template drury
```

### Writing custom templates

Templates must follow the md-pdf contract:

1. Import `cmarker` and `mitex`
2. Read `sys.inputs` for filepath, language, toc, and front matter fields
3. Call `cmarker.render(read(filepath), ...)` at the end to render the markdown

Key constraints when authoring typst templates:

| Pattern | Works | Breaks |
|---------|-------|--------|
| `#show heading.where(level: 1): set text(...)` | ✓ | |
| `#show strong: it => text(weight: 700, it)` | ✓ | |
| `#show heading.where(level: 1): { text(..., it) }` | | ✗ `it` not in scope |
| `#show raw.where(block: true): { block(..., it) }` | | ✗ `it` not in scope |
| `font: "Work Sans"` (not installed) | | ✗ unknown font warning |

**Rules for show rules:**

- Use `set` rules (no `it` needed): `#show heading: set text(size: 20pt, fill: navy)`
- Use arrow syntax when accessing element: `#show strong: it => text(fill: red, it)`
- Do NOT use `{ ... it ... }` block syntax — `it` is only available with the arrow form
- Wrap context-dependent code in `context { ... }` when using `here()` or `counter()`

**Available fonts** (check with `typst fonts`):

```
Lato, Libertinus Serif, DejaVu Sans, DejaVu Sans Mono, DejaVu Serif
```

Other common fonts (Work Sans, Inter, Arial, Helvetica) are NOT available unless installed separately. Always use available fonts in templates to avoid warnings.

### Template anatomy (minimal working example)

```typ
#import "@preview/cmarker:0.1.8"
#import "@preview/mitex:0.2.6": mitex

#let filepath = sys.inputs.at("filepath", default: "input.md")
#let language = sys.inputs.at("language", default: "en")
#let show-toc = sys.inputs.at("toc", default: "false") == "true"

#set page(margin: 2.5cm)
#set text(font: "Lato", size: 10pt)
#show heading: set text(fill: rgb("#283D75"))
#show link: it => text(fill: blue, it)

#if show-toc [
  #outline(title: "Contents")
  #pagebreak()
]

#cmarker.render(
  read(filepath),
  scope: (image: (path, alt: none) => image(path, alt: alt)),
  math: mitex,
)
```

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| `unknown font family` warning | Font not installed on system | Use only fonts from `typst fonts` output |
| `unknown variable: it` error | Using `it` inside `{ }` block show rule | Switch to arrow syntax: `it => ...` |
| `#` is not valid in code | Using `#v()` or `#text()` inside a code block | Remove the `#` prefix inside code blocks (functions are called directly) |
| PDF renders but no TOC | `default_toc` is false in config | Add `--template` flag or set `default_toc: Some(true)` in config.ron |
| Images not found | Relative path resolution | `md-pdf` sets `--root` to the input file's directory; use paths relative to the markdown file |

## Wrapper Script

A convenience wrapper lives at `bin/md2pdf` in this repository:

```bash
./bin/md2pdf input.md                     # output: input.pdf (same dir)
./bin/md2pdf input.md --template drury    # use custom brand template
./bin/md2pdf input.md -o /tmp/out.pdf     # explicit output
```

## Reference

- md-pdf source: https://github.com/tschinz/md-pdf
- md-pdf crate: https://crates.io/crates/md-pdf
- typst documentation: https://typst.app/docs
- cmarker (markdown parser): https://typst.app/universe/package/cmarker
- Available templates: `md-pdf --list-templates`
- Template directory: `~/.config/md-pdf/templates/`
- Configuration: `~/.config/md-pdf/config.ron`

Tags: #tool #pdf #markdown #typst #publishing
