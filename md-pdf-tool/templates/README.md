# Custom Templates

Custom typst templates for md-pdf. Copy any `.typ` file to `~/.config/md-pdf/templates/` to make it available.

## Install

```bash
cp templates/drury.typ ~/.config/md-pdf/templates/
```

## Available

| Template | Brand | Description |
|----------|-------|-------------|
| `drury.typ` | Drury | Navy/orange/gold palette. Uses Lato font. |

## Creating New Brand Templates

Start from `drury.typ` as a working reference. Key things to change:

1. **Colors** — Replace the color block (lines ~45-55) with your brand hex values
2. **Headings** — Adjust the `set text(fill: ...)` colors in heading show rules
3. **Strong/Emph** — Set the accent color for bold and italic text
4. **Header/Footer** — Update the text color and tracking in the page header

See the "Custom Templates" section of `SKILL.md` for typst show-rule patterns that work reliably.
