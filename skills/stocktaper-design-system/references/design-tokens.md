# Design Tokens Reference

Complete token inventory for the StockTaper design system. All tokens are defined as CSS custom properties in `src/app/globals.css` and mapped to Tailwind utilities via the `@theme` block (NOT `@theme inline` -- this is critical for dark mode to work).

## Color Tokens

### Core Palette (Light Mode -- Default)

```css
/* Defined via @theme in globals.css */
@theme {
  --color-cream: #FBF7EB;      /* Page backgrounds, card fills */
  --color-ink: #141414;         /* Primary text, headings, high-contrast elements */
  --color-charcoal: #393939;    /* Secondary text, borders, subtle interactive */
  --color-muted: #474747;       /* Tertiary text, metadata, timestamps */
  --color-divider: #d4c9a8;     /* Borders, separators, horizontal rules */
  --color-positive: #2F7D31;    /* Success, gains, published status */
  --color-negative: #C6392C;    /* Error, losses, critical warnings */
  --color-code-bg: #393939;
  --color-code-text: #FBF7EB;
  --color-code-inline-bg: rgba(57, 57, 57, 0.1);
}
```

### Dark Mode Palette

```css
/* Overrides via .dark {} in globals.css */
.dark {
  --color-cream:    #141414;                   /* Near-black background */
  --color-ink:      #E8E2D4;                   /* Warm off-white text */
  --color-charcoal: #C4BFAF;                   /* Light warm gray */
  --color-muted:    #9E9888;                   /* Muted warm gray */
  --color-divider:  #333333;                   /* Subtle dark borders */
  --color-positive: #4CAF50;                   /* Brighter green for contrast */
  --color-negative: #EF5350;                   /* Brighter red for contrast */
  --color-code-bg: #1e1e1e;                    /* Darker code background */
  --color-code-text: #E8E2D4;                  /* Warm code text */
  --color-code-inline-bg: rgba(255, 255, 255, 0.1); /* Light inline code bg */
}
```

### Dark Mode Architecture

- **Managed by**: next-themes (`ThemeProvider` with `attribute="class"`, `defaultTheme="system"`, `enableSystem`)
- **Toggle**: `ThemeToggle` component (moon/sun SVG icon) in the Header
- **Mechanism**: `.dark` class on `<html>` swaps CSS custom property values
- **Why `@theme` not `@theme inline`**: `@theme` makes Tailwind emit `var(--color-*)` references. `@theme inline` bakes literal hex values into utilities, preventing the `.dark` CSS variable override from working.

### Color Comparison Table

| Token       | Light            | Dark             | Design Intent                      |
|-------------|------------------|------------------|------------------------------------|
| cream       | `#FBF7EB` warm parchment | `#141414` near black | Background inverts completely |
| ink         | `#141414` near black     | `#E8E2D4` warm white | Text inverts for readability |
| charcoal    | `#393939` dark gray      | `#C4BFAF` light gray | Secondary text lightens      |
| muted       | `#474747` mid gray       | `#9E9888` warm gray  | Metadata stays subdued       |
| divider     | `#d4c9a8` tan            | `#333333` dark gray  | Borders stay subtle          |
| positive    | `#2F7D31` deep green     | `#4CAF50` bright green | Gains brighter for contrast |
| negative    | `#C6392C` deep red       | `#EF5350` bright red  | Losses brighter for contrast |
| code-bg     | `#393939`                | `#1e1e1e`            | Code blocks darken further   |
| code-text   | `#FBF7EB`                | `#E8E2D4`            | Code text stays warm         |
| code-inline-bg | `rgba(57,57,57,0.1)` | `rgba(255,255,255,0.1)` | Inline code stays subtle |

### Tailwind Utility Mapping

| CSS Variable        | Tailwind Class    | bg-* Class     | border-* Class    |
|---------------------|-------------------|----------------|-------------------|
| `--color-cream`     | `text-cream`      | `bg-cream`     | `border-cream`    |
| `--color-ink`       | `text-ink`        | `bg-ink`       | `border-ink`      |
| `--color-charcoal`  | `text-charcoal`   | `bg-charcoal`  | `border-charcoal` |
| `--color-muted`     | `text-muted`      | `bg-muted`     | `border-muted`    |
| `--color-divider`   | `text-divider`    | `bg-divider`   | `border-divider`  |
| `--color-positive`  | `text-positive`   | `bg-positive`  | `border-positive` |
| `--color-negative`  | `text-negative`   | `bg-negative`  | `border-negative` |

### Color Usage Matrix

| Context                  | Token      | Notes                                      |
|--------------------------|------------|--------------------------------------------|
| Page background          | cream      | Applied on `<body>` in globals.css         |
| Primary headings         | ink        | h1, h2, page titles                       |
| Body text                | ink        | Default paragraph text                     |
| Secondary headings       | charcoal   | h3-h6 in some contexts                    |
| Metadata text            | muted      | Dates, reading time, labels               |
| Card borders             | divider    | Always with `border-dashed`               |
| Horizontal rules         | divider    | Exception: uses solid border              |
| Links (default)          | charcoal   | With dashed underline                     |
| Links (hover)            | ink        | Solid underline on hover                  |
| Badge: PUBLISHED         | positive   | Green text with green/10 background       |
| Badge: DRAFT             | charcoal   | Default muted styling                     |
| Badge: CLASSIFIED        | negative   | Red text with red/10 background           |
| Code inline bg           | charcoal   | At 10% opacity: `bg-charcoal/10`         |
| Code block bg            | charcoal   | Full opacity: `bg-charcoal`              |
| Code block text          | cream      | Light text on dark code blocks            |

### Dark Mode Rules for Component Authors

1. **Never use `dark:` prefixed utilities** -- the CSS variable swap handles both themes automatically
2. **Never hardcode hex values** -- use `bg-cream`, `text-ink`, `border-divider`, etc.
3. **Never use `@theme inline`** -- it bakes literal values and breaks the `.dark` override
4. **Opacity modifiers work automatically** -- `bg-charcoal/10` uses the current charcoal value (light or dark)
5. **Prose styles adapt automatically** -- the `.prose` overrides in `globals.css` reference `var()` values

### Opacity Patterns

```
bg-charcoal/5     /* Extremely subtle background tint */
bg-charcoal/10    /* Inline code, subtle highlights */
bg-positive/10    /* Published badge background */
bg-negative/10    /* Classified badge background */
```

These opacity patterns work correctly in both light and dark mode because they reference the current CSS variable value.

## Border Radius Tokens

```css
/* Defined in @theme block */
@theme {
  --radius-card: 6px;        /* Cards, containers, images, code blocks */
  --radius-button: 4.8px;    /* Buttons, form inputs */
  --radius-full: 9999px;     /* Pill shapes: badges, topic tags */
}
```

### Radius Usage

| Element        | Token           | Tailwind Class                     |
|----------------|-----------------|------------------------------------|
| DossierCard    | `--radius-card` | `rounded-[var(--radius-card)]`     |
| ContentCard    | `--radius-card` | `rounded-[var(--radius-card)]`     |
| Code blocks    | `--radius-card` | `rounded-[var(--radius-card)]`     |
| Images         | `--radius-card` | `rounded-[var(--radius-card)]`     |
| Button         | `--radius-button` | `rounded-[var(--radius-button)]` |
| Badge          | `--radius-full` | `rounded-full`                     |
| TopicTag       | `--radius-full` | `rounded-full`                     |
| Inline code    | n/a             | `rounded` (Tailwind default 4px)   |

## Spacing System

The spacing system uses Tailwind's default scale (4px base unit). No custom spacing tokens are defined -- the default Tailwind scale provides sufficient granularity.

### Common Spacing Patterns

| Pattern                | Classes                          | Pixels   |
|------------------------|----------------------------------|----------|
| Section vertical gap   | `py-16` or `py-20`              | 64-80px  |
| Content section gap    | `mt-12`                          | 48px     |
| Card internal padding  | `p-6`                            | 24px     |
| Grid gap               | `gap-6`                          | 24px     |
| Heading margin-bottom  | `mb-4` (h1/h2), `mb-2` (h3-h6) | 16/8px   |
| Paragraph spacing      | `mb-4`                           | 16px     |
| Inline element gap     | `gap-2` or `gap-3`              | 8-12px   |
| Container padding      | `px-6`                           | 24px     |
| Badge padding          | `px-2 py-0.5`                    | 8/2px    |
| TopicTag padding       | `px-3 py-1`                      | 12/4px   |

### Container Constraints

```
max-w-[1152px]    /* Maximum content width */
mx-auto           /* Center alignment */
px-6              /* Horizontal gutter */
```

## Typography Tokens

### Font Family

```css
/* Defined in @theme block */
@theme {
  --font-sans: "IBM Plex Mono", monospace;
  --font-mono: "IBM Plex Mono", monospace;
}
```

Both `--font-sans` and `--font-mono` map to the same typeface. This is intentional -- the entire system uses monospace.

### Font Weights

| Weight | Import                               | Usage                      |
|--------|--------------------------------------|----------------------------|
| 400    | `@fontsource/ibm-plex-mono/400.css` | Body text, metadata, code  |
| 700    | `@fontsource/ibm-plex-mono/700.css` | Headings, bold emphasis    |

**CRITICAL**: Weight 900 does NOT exist for IBM Plex Mono. Never reference `font-black` or `font-weight: 900`.

## Border Tokens

### Border Style Rules

| Context         | Style    | Width | Color    | Tailwind Classes                       |
|-----------------|----------|-------|----------|----------------------------------------|
| Cards           | dashed   | 1px   | divider  | `border border-dashed border-divider`  |
| Code blocks     | dashed   | 1px   | divider  | `border border-dashed border-divider`  |
| Tables          | dashed   | 1px   | divider  | `border border-dashed border-divider`  |
| Table rows      | dashed   | 1px   | divider  | `divide-y divide-dashed divide-divider`|
| Horizontal rule | solid    | 1px   | divider  | `border-divider` (solid exception)     |
| Link underline  | dashed   | n/a   | current  | `decoration-dashed`                    |
| Blockquote left | solid    | 2px   | divider  | `border-l-2 border-divider`            |

## Animation Tokens

The system uses minimal animation. Only these transitions are defined:

```css
/* Link underline transition */
transition-[text-decoration-style] duration-150

/* Anchor link hover */
opacity-0 hover:opacity-100 transition-opacity

/* Badge/tag hover (if interactive) */
transition-colors duration-150
```

No bounce, slide, fade-in, or complex animations. The system is intentionally static.

## Z-Index Layers

| Layer              | z-index | Usage                          |
|--------------------|---------|--------------------------------|
| Base content       | auto    | Default stacking               |
| Anchor links       | 10      | Heading anchor hover targets   |
| Code copy button   | 10      | Overlays code block            |
| Header (if sticky) | 50      | Navigation bar                 |

## Media Query Breakpoints

Uses Tailwind v4 defaults:

| Prefix | Min-width | Usage                    |
|--------|-----------|--------------------------|
| `sm`   | 640px     | Minor adjustments        |
| `md`   | 768px     | 2-column grid, tablet    |
| `lg`   | 1024px    | 3-column grid, desktop   |
| `xl`   | 1280px    | Rarely used              |
