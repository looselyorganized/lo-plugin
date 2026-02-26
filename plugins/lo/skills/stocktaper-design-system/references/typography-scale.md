# Typography Scale Reference

Complete typography reference for the StockTaper design system. The entire system uses a single typeface -- IBM Plex Mono -- at two weights.

## Typeface

**Font**: IBM Plex Mono
**Source**: `@fontsource/ibm-plex-mono`
**Weights Available**: 400 (regular), 700 (bold)
**Weight 900 does NOT exist** -- never use `font-black` or `font-weight: 900`

### Font Imports (in layout.tsx)

```typescript
import "@fontsource/ibm-plex-mono/400.css"
import "@fontsource/ibm-plex-mono/700.css"
```

### CSS Variables

```css
--font-sans: "IBM Plex Mono", monospace;
--font-mono: "IBM Plex Mono", monospace;
```

Both aliases point to the same font. This ensures that `font-sans` and `font-mono` Tailwind utilities produce identical results. Everything is monospace.

## Heading Scale

| Element | Size                    | Weight | Tracking      | Transform | Bottom Margin | Top Margin |
|---------|-------------------------|--------|---------------|-----------|---------------|------------|
| h1      | `text-4xl md:text-5xl`  | `font-bold` | `tracking-tight` | none      | `mb-4`        | none       |
| h2      | `text-2xl`              | `font-bold` | `tracking-tight` | none      | `mb-4`        | `mt-12`    |
| h3      | `text-xl`               | `font-bold` | none          | `uppercase` | `mb-2`        | `mt-8`     |
| h4      | `text-lg`               | `font-bold` | none          | none      | `mb-2`        | `mt-6`     |
| h5      | `text-base`             | `font-bold` | none          | none      | `mb-2`        | `mt-4`     |
| h6      | `text-base`             | `font-bold` | none          | `uppercase` | `mb-2`        | `mt-4`     |

### Heading Color

All headings use `text-ink` (#141414).

### Heading Examples

```html
<!-- H1: Page titles -->
<h1 class="text-4xl md:text-5xl font-bold tracking-tight text-ink mb-4">
  Distributed Locking for Agents
</h1>

<!-- H2: Major sections -->
<h2 class="text-2xl font-bold tracking-tight text-ink mt-12 mb-4">
  Architecture Overview
</h2>

<!-- H3: Subsections (UPPERCASE) -->
<h3 class="text-xl font-bold uppercase text-ink mt-8 mb-2">
  Implementation Details
</h3>

<!-- H4: Minor subsections -->
<h4 class="text-lg font-bold text-ink mt-6 mb-2">
  Configuration Options
</h4>
```

## Body Text

| Context        | Size        | Weight      | Line Height     | Color        |
|----------------|-------------|-------------|-----------------|--------------|
| Paragraph      | `text-base` | normal (400)| `leading-relaxed` | `text-ink`   |
| Card description | `text-sm` | normal (400)| `leading-relaxed` | `text-muted` |
| Blockquote     | `text-base` | normal (400)| `leading-relaxed` | `text-muted` |
| List items     | `text-base` | normal (400)| `leading-relaxed` | `text-ink`   |

### Body Spacing

All paragraphs use `mb-4` (16px) bottom margin. This creates consistent vertical rhythm in prose content.

## Small Text / Metadata

| Context            | Size       | Weight      | Transform   | Tracking           | Color        |
|--------------------|------------|-------------|-------------|--------------------|--------------|
| Badge label        | `text-xs`  | `font-bold` | `uppercase` | `tracking-[0.5px]` | varies       |
| TopicTag           | `text-xs`  | normal      | none        | none               | `text-muted` |
| ContentMeta (date) | `text-xs`  | normal      | none        | none               | `text-muted` |
| Footer             | `text-xs`  | normal      | none        | none               | `text-muted` |
| Button text        | `text-sm`  | `font-bold` | `uppercase` | `tracking-wider`   | varies       |
| Nav links          | `text-sm`  | normal      | none        | none               | `text-charcoal` |
| Code language badge| `text-xs`  | `font-bold` | `uppercase` | `tracking-wider`   | `text-cream/60` |

## Code Typography

### Inline Code

```
text-sm font-mono
bg-charcoal/10 rounded px-1.5 py-0.5
```

Color inherits from parent context.

### Code Blocks

```
text-sm font-mono
bg-charcoal text-cream
p-4 overflow-x-auto
border border-dashed border-divider rounded-[var(--radius-card)]
```

### Code Block Header

When a language is specified, a header bar appears:
```
flex items-center justify-between
px-4 py-2
text-xs font-bold uppercase tracking-wider text-cream/60
border-b border-dashed border-cream/20
```

## Link Typography

### Default Links (in prose)

```
text-charcoal
underline decoration-dashed underline-offset-4
hover:text-ink hover:decoration-solid
transition-[text-decoration-style] duration-150
```

### ArrowLink

```
text-sm font-bold text-charcoal
underline decoration-dashed underline-offset-4
hover:text-ink hover:decoration-solid
```

Plus trailing `->` glyph.

### Navigation Links

```
text-sm text-charcoal
hover:text-ink
```

No underline in navigation.

## Table Typography

| Cell Type   | Size        | Weight      | Color        | Alignment |
|-------------|-------------|-------------|--------------|-----------|
| Header (th) | `text-sm`   | `font-bold` | `text-ink`   | left      |
| Body (td)   | `text-sm`   | normal      | `text-ink`   | left      |

Tables use `font-mono` throughout (inherited).

## Emphasis Patterns

| Style       | Tailwind               | Usage                           |
|-------------|------------------------|---------------------------------|
| Bold        | `font-bold` (700)      | Headings, emphasis, labels      |
| Italic      | `italic`               | Blockquotes, secondary emphasis |
| Uppercase   | `uppercase`            | h3, h6, badges, buttons         |
| Tight track | `tracking-tight`       | h1, h2 (large headings)         |
| Wide track  | `tracking-wider`       | Buttons, code badges            |
| Half-px     | `tracking-[0.5px]`     | Badge labels                    |

## Line Clamping

Used for card descriptions to prevent overflow:

```
line-clamp-3    /* Truncate at 3 lines with ellipsis */
```

Applied on ContentCard description paragraph.

## Responsive Typography

Only h1 changes size responsively:

```
text-4xl md:text-5xl
```

All other typography sizes remain fixed across breakpoints. The monospace aesthetic benefits from consistent sizing.
