# Custom Templates

Custom typst templates for `md-pdf`. Drop any `.typ` file into `~/.config/md-pdf/templates/` to make it available as `--template <name>`.

## Install

**Recommended — symlink so edits stay versioned in the repo:**

```bash
ln -s "$(pwd)/drury.typ" ~/.config/md-pdf/templates/drury.typ
```

**Simple copy (one-way; edits won't flow back to the repo):**

```bash
cp drury.typ ~/.config/md-pdf/templates/drury.typ
```

See [`../SKILL.md`](../SKILL.md#installing-a-custom-template) for details on the trade-offs.

## Available

| Template | Brand | Description |
|----------|-------|-------------|
| `drury.typ` | Drury Roofing | Navy / rust-orange / gold palette. Lato body. Generates a dedicated title page from a leading `#` heading and its preamble. |

## `drury.typ` — behaviors

The drury template implements opinionated formatting suited to formal business documents (agreements, briefs, plans):

### Title page
- Triggered when the markdown has either:
  - YAML front matter with `title:`, **or**
  - A leading `# Title` line at the top of the body
- Renders a centered title page with title, optional subtitle, gold rule, and either:
  - The **inline preamble** (everything between `# Title` and the first `## Section`), rendered as markdown via cmarker, **or**
  - Author / date / version metadata from front matter (if no preamble exists)
- Followed by a `pagebreak()` so the cover stands alone

### Body
- Page header (from page 2 onward): document title in rust-orange tracked caps, date right-aligned
- Page footer: author (if set) on the left, `n / total` page counter on the right
- Heading auto-numbering is **off** — narrative documents read more naturally without `1.1 / 1.2` prefixes
- The H1 heading and preamble are stripped from the body so `## Section` headings are the visual top level

### Spacing
Tuned for readability rather than density:

| Setting | Value |
|---------|-------|
| Body text | 10.5pt Lato |
| Paragraph leading (line-height) | 0.75em |
| Paragraph spacing | 1.1em |
| Heading above / below | 1.8em / 0.9em |
| List / enum spacing | 0.9em |
| Page margins | 2.6cm top/bottom/left, 2.2cm right |

### Markdown inline styling
- `**bold**` renders in **rust-orange bold** (used as a lead-in accent for list items)
- `*italic*` renders in *mid-navy italic*
- Links render in bright-blue
- Code (inline and block) uses DejaVu Sans Mono

### Authoring tip
Where you place the first `##` is the dial for what appears on the cover:

```markdown
# My Document          ← title

**Byline**             ← preamble (on cover)

A short paragraph...   ← preamble (on cover)

## First Section       ← body starts here
```

To keep the cover tight, move the first `##` up immediately after the byline. To include an executive-summary paragraph on the cover, leave a paragraph between the byline and the first `##`.

## Creating new brand templates

Start from `drury.typ` as a working reference. Key things to change:

1. **Colors** — Replace the color block (`navy`, `rust-orange`, `gold`, etc.) with your brand hex values
2. **Fonts** — Confirm the font is installed (`typst fonts`); change `Lato` to your brand font if available
3. **Heading styles** — Adjust the `set text(fill: ...)` colors in heading show rules
4. **Strong / Emph accents** — Set the accent color for `**bold**` and `*italic*`
5. **Header / Footer** — Update the text color, tracking, and content in the page header
6. **Title-page extraction logic** — The `_extract-leading-h1` function and the title-page `#if has-title-block` block can be reused as-is; only the visual styling needs to change

See the [Custom Templates](../SKILL.md#custom-templates) section of `SKILL.md` for typst show-rule patterns that work reliably (and the ones that break).
