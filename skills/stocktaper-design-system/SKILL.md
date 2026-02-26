---
name: stocktaper-design-system
description: Implements the StockTaper / Loosely Organized Research Facility design system for building UI components, pages, and layouts. Use when the user asks to "build a component", "create a page", "add a section", "style this", "design a layout", "update the UI", "add a card", "create a form", "add dark mode", "fix dark mode", "theme toggle", mentions design tokens, or references the StockTaper visual language. Covers color tokens, typography (IBM Plex Mono), dark mode (CSS variable swap via next-themes), dashed-border aesthetic, component patterns, responsive grids, and MDX prose styling.
license: MIT
metadata:
  author: Loosely Organized
  version: 1.1.0
  category: design-system
  tags: [tailwind-v4, next-js-16, mdx, monospace, design-tokens, dark-mode, next-themes]
---

# StockTaper Design System

## Critical: Read Before Building

This design system defines the visual language for the Loosely Organized Research Facility. Every component, page, and layout MUST adhere to these constraints. The aesthetic is **monochromatic, monospace, minimal** -- inspired by vintage research documents and financial tickers.

**IMPORTANT: Never introduce these anti-patterns:**
- Gradients, shadows, or blur effects
- Sans-serif or serif fonts (IBM Plex Mono is the ONLY typeface)
- Solid borders where dashed borders are specified
- Colors outside the defined palette
- Font weight 900 (does not exist for IBM Plex Mono)
- `@import` for Tailwind plugins (use `@plugin` in Tailwind v4)
- `@theme inline` (breaks dark mode -- use `@theme` so utilities emit CSS variable references)
- `dark:` prefixed Tailwind utilities (dark mode is handled by CSS variable swap, not utility prefixes)
- Hardcoded hex color values (will not respond to dark mode toggle)

## Design Philosophy

1. **Monochromatic palette** -- cream, ink, charcoal, muted with functional red/green only
2. **Single typeface** -- IBM Plex Mono at weights 400 (regular) and 700 (bold) only
3. **Dashed borders** -- the signature visual element across cards, code blocks, tables
4. **Minimal decoration** -- no gradients, no shadows, no rounded-full on containers
5. **Content-first** -- typography and spacing do the heavy lifting, not ornamentation
6. **Responsive restraint** -- max-width 1152px, 1/2/3-column grids
7. **Dark mode native** -- all colors use CSS variables that swap via `.dark` class, so both themes maintain the same vintage monochrome aesthetic

## Color System

All colors are CSS custom properties defined in `src/app/globals.css` and exposed as Tailwind utilities via `@theme` (NOT `@theme inline` -- this is critical for dark mode to work, see Dark Mode section).

| Token            | Hex       | Usage                                    |
|------------------|-----------|------------------------------------------|
| `--color-cream`  | `#FBF7EB` | Page background, card backgrounds        |
| `--color-ink`    | `#141414` | Primary text, headings, high-contrast    |
| `--color-charcoal` | `#393939` | Secondary text, borders, subtle UI     |
| `--color-muted`  | `#474747` | Tertiary text, metadata, placeholders    |
| `--color-divider`| `#d4c9a8` | Borders, separators, horizontal rules    |
| `--color-positive` | `#2F7D31` | Success states, gains, published badge |
| `--color-negative` | `#C6392C` | Error states, losses, warnings         |

### Usage Rules

- Background: ALWAYS `bg-cream`
- Primary text: `text-ink`
- Secondary/supporting text: `text-charcoal` or `text-muted`
- Borders and dividers: `border-divider` with `border-dashed`
- Never use raw hex values -- always reference the CSS variable or Tailwind class
- Functional colors (positive/negative) are ONLY for semantic meaning, never decoration
- All color tokens automatically swap in dark mode -- no manual dark: prefixes needed

## Dark Mode

Dark mode is built into the system and requires NO special handling from component authors. It works automatically through CSS custom property overrides.

### Architecture

1. **next-themes** manages the `.dark` class on `<html>` (class strategy, system-aware)
2. `@theme` in `globals.css` defines light-mode CSS variables as Tailwind utilities
3. `.dark {}` in `globals.css` overrides those same variables with dark-mode values
4. Because `@theme` (not `@theme inline`) is used, Tailwind utilities emit `var(--color-*)` references that respond to the `.dark` override

**CRITICAL**: Using `@theme inline` would bake literal hex values into utilities, breaking dark mode. Always use `@theme`.

### Dark Mode Color Mapping

| Token            | Light (default)      | Dark (.dark class)   |
|------------------|----------------------|----------------------|
| `--color-cream`  | `#FBF7EB` (warm parchment) | `#141414` (near black) |
| `--color-ink`    | `#141414` (near black)     | `#E8E2D4` (warm white) |
| `--color-charcoal` | `#393939` (dark gray)    | `#C4BFAF` (light gray) |
| `--color-muted`  | `#474747` (mid gray)       | `#9E9888` (muted warm) |
| `--color-divider`| `#d4c9a8` (tan)            | `#333333` (dark gray)  |
| `--color-positive` | `#2F7D31` (deep green)   | `#4CAF50` (bright green) |
| `--color-negative` | `#C6392C` (deep red)     | `#EF5350` (bright red) |
| `--color-code-bg`    | `#393939`            | `#1e1e1e`            |
| `--color-code-text`  | `#FBF7EB`            | `#E8E2D4`            |
| `--color-code-inline-bg` | `rgba(57,57,57,0.1)` | `rgba(255,255,255,0.1)` |

### Components

| Component      | Location                          | Purpose                         |
|----------------|-----------------------------------|---------------------------------|
| ThemeProvider   | `src/components/ThemeProvider.tsx` | Wraps app in next-themes provider (class strategy, system default) |
| ThemeToggle     | `src/components/ui/ThemeToggle.tsx`| Moon/sun SVG icon button for manual toggle |

ThemeToggle lives in the Header alongside navigation links.

### Rules for Component Authors

1. **Never use `dark:` prefixed utilities** -- the variable-swap approach handles everything
2. **Never hardcode hex values** -- always use design token classes (`bg-cream`, `text-ink`, etc.)
3. **Never use `@theme inline`** -- this bakes literal values and breaks the `.dark` override
4. **Opacity modifiers work automatically** -- `bg-charcoal/10` will use the correct charcoal value in both themes
5. **Prose styles adapt automatically** -- the `.prose` overrides in `globals.css` reference `var()` values

For the full dark mode color table and usage patterns, consult `references/design-tokens.md`.

## Typography

For detailed scale and patterns, consult `references/typography-scale.md`.

### Quick Reference

- **Font**: `font-mono` everywhere (maps to IBM Plex Mono)
- **Weights**: 400 (normal body) and 700 (bold headings) ONLY
- **Base size**: `text-base` (16px) with `leading-relaxed`
- **H1**: `text-4xl md:text-5xl font-bold tracking-tight`
- **H2**: `text-2xl font-bold tracking-tight`
- **H3**: `text-xl font-bold uppercase`
- **Small/meta**: `text-xs uppercase tracking-[0.5px]`

## Border System

Dashed borders are the defining visual element. Use them consistently.

| Context          | Classes                                         |
|------------------|-------------------------------------------------|
| Cards            | `border border-dashed border-divider rounded-[var(--radius-card)]` |
| Code blocks      | `border border-dashed border-divider`           |
| Tables           | `border border-dashed border-divider divide-y divide-dashed divide-divider` |
| Horizontal rules | `border-divider` (solid, exception to dashed)   |
| Links            | `underline decoration-dashed underline-offset-4` |
| Link hover       | `decoration-solid` (dashed -> solid transition)  |

### Border Radius Tokens

```
--radius-card: 6px       /* Cards, containers */
--radius-button: 4.8px   /* Buttons, inputs */
--radius-full: 9999px    /* Pill shapes: badges, topic tags */
```

## Layout System

For full grid and spacing patterns, consult `references/layout-patterns.md`.

### Container

All page content wraps in `Container`:
- Max width: `max-w-[1152px]`
- Horizontal padding: `px-6`
- Centered: `mx-auto`

### Responsive Grid (ContentGrid)

```
grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6
```

Adjusts column count by passing `columns` prop (1, 2, or 3).

## Component Library

For the full component catalog with props and examples, consult `references/component-catalog.md`.

### Component Index

| Component       | Location                         | Purpose                              |
|-----------------|----------------------------------|--------------------------------------|
| Container       | `src/components/layout/`         | Max-width page wrapper               |
| Header          | `src/components/layout/`         | Site navigation                      |
| Footer          | `src/components/layout/`         | Copyright bar                        |
| Button          | `src/components/ui/`             | Primary/secondary actions            |
| Badge           | `src/components/ui/`             | Status indicators                    |
| DossierCard     | `src/components/ui/`             | Bordered content card with badge     |
| Divider         | `src/components/ui/`             | Horizontal separator                 |
| ArrowLink       | `src/components/ui/`             | Text link with `->` glyph           |
| TopicTag        | `src/components/ui/`             | Pill-style topic label               |
| ContentCard     | `src/components/content/`        | Post preview card                    |
| ContentGrid     | `src/components/content/`        | Responsive card grid                 |
| ContentMeta     | `src/components/content/`        | Date, reading time, status           |
| CopyButton      | `src/components/mdx/`            | Clipboard copy for code blocks       |
| ExperimentEmbed | `src/components/mdx/`            | Lazy-loaded interactive experiments  |
| ThemeProvider   | `src/components/`                | next-themes wrapper (class strategy) |
| ThemeToggle     | `src/components/ui/`             | Dark/light mode toggle button        |

## Building New Components

### Step 1: Determine Component Category

- **Layout** (`src/components/layout/`): Structural wrappers, navigation
- **UI** (`src/components/ui/`): Reusable atomic elements
- **Content** (`src/components/content/`): Content-specific compositions
- **MDX** (`src/components/mdx/`): Components used inside MDX rendering

### Step 2: Follow the Pattern

Every component in this system follows these conventions:

```tsx
// 1. Import cn utility for conditional classes
import { cn } from "@/lib/utils"

// 2. Define props interface
interface ComponentNameProps {
  className?: string  // ALWAYS accept className for composition
  children?: React.ReactNode
  // ... specific props
}

// 3. Export named function component
export function ComponentName({ className, children, ...props }: ComponentNameProps) {
  return (
    <div className={cn(
      // Base classes first
      "font-mono text-ink",
      // Then structural classes
      "border border-dashed border-divider rounded-[var(--radius-card)]",
      // Then allow override
      className
    )}>
      {children}
    </div>
  )
}
```

### Step 3: Validate Against Checklist

Before finalizing any component:

- [ ] Uses ONLY `font-mono` (no sans/serif)
- [ ] Colors reference design tokens (no raw hex)
- [ ] Borders are `dashed` where applicable
- [ ] Accepts `className` prop for composition
- [ ] Responsive at mobile/tablet/desktop
- [ ] Uses `cn()` from `@/lib/utils` for class merging
- [ ] No shadows, gradients, or blur effects
- [ ] Font weights are 400 or 700 only
- [ ] No `dark:` prefixed utilities (dark mode uses CSS variable swap)
- [ ] No hardcoded hex values (breaks dark mode)

## MDX Content Styling

For full MDX prose configuration, consult `references/mdx-content-guide.md`.

All MDX rendering is handled through `mdx-components.tsx` at the project root. Custom components override every HTML element to enforce the design system within prose content.

### Key MDX Overrides

- **Headings**: Size scale from `text-4xl` (h1) to `text-base` (h6), with h3/h6 `uppercase`
- **Links**: `text-charcoal decoration-dashed` with `decoration-solid` on hover
- **Code inline**: `bg-charcoal/10 rounded px-1.5 py-0.5 text-sm`
- **Code blocks**: `bg-charcoal text-cream border-dashed` with language badge + copy button
- **Tables**: Full dashed borders, `divide-dashed`
- **Blockquotes**: `border-l-2 border-divider pl-4 italic text-muted`
- **Images**: `rounded-[var(--radius-card)]` with optional figcaption

## Content System

### Frontmatter Schema

```yaml
title: string           # Required
date: YYYY-MM-DD        # Required
description: string     # Required, used in cards and meta
topics: string[]         # Required, displayed as TopicTags
status: enum             # Required: draft | field-notes | published | experiment | classified
readingTime: string      # Optional, e.g. "8 min read"
```

### Content Types

| Type         | Directory              | URL Pattern          |
|--------------|------------------------|----------------------|
| Research     | `content/research/`    | `/research/[slug]`   |
| Thoughts     | `content/thoughts/`    | `/thoughts/[slug]`   |
| Experiments  | `src/experiments/`     | `/experiments/[slug]` |

## Tech Stack Constraints

- **Next.js 16** with Turbopack -- MDX plugins MUST be strings, not imports
- **Tailwind v4** -- use `@plugin` not `@import` for plugins in CSS
- **React 19** -- server components by default, `"use client"` only when needed
- **Path aliases**: `@/*` = `./src/*`, `@content/*` = `./content/*`

## Examples

### Example 1: Creating a New UI Component

User says: "Add a callout box component"

Actions:
1. Create `src/components/ui/Callout.tsx`
2. Use dashed border with `border-divider`
3. Apply `font-mono text-sm` for body text
4. Accept `variant` prop for info/warning/success using design tokens
5. Accept `className` for composition
6. Export as named export

### Example 2: Building a New Page Section

User says: "Add a featured research section to the homepage"

Actions:
1. Use `Container` for max-width constraint
2. Add section heading with `text-2xl font-bold tracking-tight text-ink`
3. Use `ContentGrid` with `columns={2}` for cards
4. Add `Divider` above/below section
5. Ensure responsive: stacks to 1 column on mobile

### Example 3: Adding a New MDX Element

User says: "I need a custom aside element for MDX"

Actions:
1. Create component in `src/components/mdx/`
2. Register in `mdx-components.tsx`
3. Use `border-l-2 border-divider` left accent
4. Apply `bg-cream` background (or `bg-charcoal/5` for subtle contrast)
5. Use `text-muted` for supporting text
6. Ensure it works within prose context

## Troubleshooting

### Component looks wrong after adding

**Cause**: Missing design tokens or wrong border style
**Solution**: Verify all borders use `border-dashed border-divider`. Check no solid borders crept in. Confirm `rounded-[var(--radius-card)]` not arbitrary radius values.

### Font rendering inconsistent

**Cause**: Missing font import or wrong weight
**Solution**: Ensure `@fontsource/ibm-plex-mono` is imported for weight 400 and 700 only. Never reference weight 900 (does not exist). All text should use `font-mono`.

### Tailwind classes not applying

**Cause**: Tailwind v4 configuration issue
**Solution**: Check that `src/app/globals.css` has `@theme` block (NOT `@theme inline`) with CSS variables mapped to Tailwind utilities. Typography plugin must use `@plugin "@tailwindcss/typography"` not `@import`.

### Dark mode not working

**Cause**: `@theme inline` used instead of `@theme`, or hardcoded hex values
**Solution**: The `@theme` directive (without `inline`) makes Tailwind emit `var(--color-*)` references. The `.dark {}` block in `globals.css` overrides those variables. If `@theme inline` is used, literal hex values get baked in and CSS variable overrides won't apply. Also check that no components use hardcoded hex values or `dark:` utility prefixes.

### Dark mode flash on page load

**Cause**: Theme not detected before first paint
**Solution**: The ThemeProvider uses next-themes with `attribute="class"` and `enableSystem`. next-themes injects a blocking script to prevent flash. Ensure ThemeProvider wraps the app in `layout.tsx`.

### MDX content not styled correctly

**Cause**: Component not registered in `mdx-components.tsx`
**Solution**: Verify the element override exists in the `useMDXComponents` export. All MDX elements (h1-h6, p, a, ul, ol, code, pre, table, img, blockquote, hr) must have custom mappings.
