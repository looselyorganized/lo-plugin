# MDX Content & Prose Styling Guide

Complete reference for MDX content rendering, component overrides, and content authoring in the StockTaper design system.

## MDX Configuration

### Next.js Config (next.config.ts)

MDX plugins MUST be specified as **strings** (package names), NOT imported function references. This is a requirement for Next.js 16 + Turbopack compatibility.

```typescript
// CORRECT
remarkPlugins: ["remark-gfm", "remark-frontmatter"]
rehypePlugins: [
  "rehype-slug",
  ["rehype-autolink-headings", { behavior: "prepend", className: "anchor-link" }],
  ["rehype-pretty-code", { theme: "github-dark", keepBackground: false }]
]

// WRONG - will break with Turbopack
remarkPlugins: [remarkGfm, remarkFrontmatter]
```

### Plugin Stack

| Plugin                    | Purpose                                    |
|---------------------------|--------------------------------------------|
| remark-gfm               | GitHub Flavored Markdown (tables, etc.)    |
| remark-frontmatter        | Parse YAML frontmatter in MDX              |
| rehype-slug               | Add IDs to headings for anchor links       |
| rehype-autolink-headings  | Prepend anchor links to headings           |
| rehype-pretty-code        | Syntax highlighting via Shiki              |
| shiki (theme: github-dark)| Code block syntax highlighting theme       |

## Component Registry (mdx-components.tsx)

Located at project root. All MDX elements are overridden with custom components.

### Heading Overrides

```tsx
h1: ({ children }) => (
  <h1 className="text-4xl md:text-5xl font-bold tracking-tight text-ink mb-4">
    {children}
  </h1>
)

h2: ({ children }) => (
  <h2 className="text-2xl font-bold tracking-tight text-ink mt-12 mb-4">
    {children}
  </h2>
)

h3: ({ children }) => (
  <h3 className="text-xl font-bold uppercase text-ink mt-8 mb-2">
    {children}
  </h3>
)

h4: ({ children }) => (
  <h4 className="text-lg font-bold text-ink mt-6 mb-2">
    {children}
  </h4>
)

h5: ({ children }) => (
  <h5 className="text-base font-bold text-ink mt-4 mb-2">
    {children}
  </h5>
)

h6: ({ children }) => (
  <h6 className="text-base font-bold uppercase text-muted mt-4 mb-2">
    {children}
  </h6>
)
```

### Paragraph

```tsx
p: ({ children }) => (
  <p className="text-base leading-relaxed mb-4 text-ink">
    {children}
  </p>
)
```

### Links

```tsx
a: ({ href, children }) => (
  <a
    href={href}
    className="text-charcoal underline decoration-dashed underline-offset-4 hover:text-ink hover:decoration-solid"
  >
    {children}
  </a>
)
```

External links get `target="_blank" rel="noopener noreferrer"`.

### Lists

```tsx
// Unordered
ul: ({ children }) => (
  <ul className="list-disc list-outside pl-6 mb-4 space-y-1 text-ink marker:text-muted">
    {children}
  </ul>
)

// Ordered
ol: ({ children }) => (
  <ol className="list-decimal list-outside pl-6 mb-4 space-y-1 text-ink marker:text-muted">
    {children}
  </ol>
)

// List item
li: ({ children }) => (
  <li className="text-base leading-relaxed">
    {children}
  </li>
)
```

**Note**: Markers (bullets/numbers) use `text-muted` while content uses `text-ink`.

### Code

#### Inline Code

```tsx
code: ({ children }) => (
  <code className="bg-charcoal/10 rounded px-1.5 py-0.5 text-sm font-mono">
    {children}
  </code>
)
```

#### Code Blocks (pre)

```tsx
pre: ({ children, ...props }) => {
  // Extract raw text for copy button
  const codeString = extractText(children)
  // Get language from data attribute (set by rehype-pretty-code)
  const lang = props["data-language"]

  return (
    <div className="relative my-6 rounded-[var(--radius-card)] border border-dashed border-divider overflow-hidden">
      {/* Language header bar */}
      {lang && (
        <div className="flex items-center justify-between px-4 py-2 border-b border-dashed border-cream/20 bg-charcoal">
          <span className="text-xs font-bold uppercase tracking-wider text-cream/60">
            {lang}
          </span>
          <CopyButton text={codeString} />
        </div>
      )}
      {/* Code content */}
      <pre className="p-4 overflow-x-auto bg-charcoal text-cream text-sm">
        {children}
      </pre>
    </div>
  )
}
```

### Tables

```tsx
table: ({ children }) => (
  <div className="my-6 overflow-x-auto">
    <table className="w-full border border-dashed border-divider text-sm">
      {children}
    </table>
  </div>
)

thead: ({ children }) => (
  <thead className="border-b border-dashed border-divider bg-charcoal/5">
    {children}
  </thead>
)

tr: ({ children }) => (
  <tr className="border-b border-dashed border-divider">
    {children}
  </tr>
)

th: ({ children }) => (
  <th className="px-4 py-2 text-left font-bold text-ink">
    {children}
  </th>
)

td: ({ children }) => (
  <td className="px-4 py-2 text-ink">
    {children}
  </td>
)
```

### Blockquotes

```tsx
blockquote: ({ children }) => (
  <blockquote className="border-l-2 border-divider pl-4 my-6 italic text-muted">
    {children}
  </blockquote>
)
```

### Images

```tsx
img: ({ src, alt }) => (
  <figure className="my-6">
    <img
      src={src}
      alt={alt}
      className="rounded-[var(--radius-card)] w-full"
    />
    {alt && (
      <figcaption className="mt-2 text-center text-xs text-muted">
        {alt}
      </figcaption>
    )}
  </figure>
)
```

### Horizontal Rule

```tsx
hr: () => (
  <hr className="my-8 border-divider" />
)
```

**Note**: Horizontal rules use SOLID border (not dashed). This is an intentional exception.

## Prose CSS Overrides

The `@tailwindcss/typography` plugin is loaded in `globals.css` via:

```css
@plugin "@tailwindcss/typography";
```

Additional prose overrides in globals.css:

```css
.prose {
  --tw-prose-body: var(--color-ink);
  --tw-prose-headings: var(--color-ink);
  --tw-prose-links: var(--color-charcoal);
  --tw-prose-bold: var(--color-ink);
  --tw-prose-counters: var(--color-muted);
  --tw-prose-bullets: var(--color-muted);
  --tw-prose-hr: var(--color-divider);
  --tw-prose-quotes: var(--color-muted);
  --tw-prose-quote-borders: var(--color-divider);
  --tw-prose-captions: var(--color-muted);
  --tw-prose-code: var(--color-ink);
  --tw-prose-pre-code: var(--color-cream);
  --tw-prose-pre-bg: var(--color-charcoal);
  --tw-prose-th-borders: var(--color-divider);
  --tw-prose-td-borders: var(--color-divider);
}
```

## Anchor Links

Headings get automatic anchor links via rehype-slug + rehype-autolink-headings:

```css
.anchor-link {
  position: absolute;
  left: -1.5rem;
  opacity: 0;
  transition: opacity 150ms;
  text-decoration: none;
}

*:hover > .anchor-link {
  opacity: 1;
}
```

The anchor character is `#` prepended to the heading. It appears on hover with a fade transition.

## Content Frontmatter

### Schema

```yaml
---
title: "Article Title"
date: "2026-01-15"
description: "Brief description for cards and meta tags"
topics:
  - "Agent Coordination"
  - "Distributed Systems"
status: "published"
readingTime: "8 min read"
---
```

### Status Values

| Value        | Display     | Badge Color   |
|--------------|-------------|---------------|
| draft        | DRAFT       | muted/gray    |
| field-notes  | FIELD NOTES | charcoal/gray |
| published    | PUBLISHED   | positive/green|
| experiment   | EXPERIMENT  | charcoal/gray |
| classified   | CLASSIFIED  | negative/red  |

### Content Parsing

Content is parsed in `src/lib/content.ts`:

1. `gray-matter` extracts frontmatter from MDX files
2. `normalizeFrontmatter()` ensures all required fields exist
3. Posts are sorted by date (newest first)
4. Slug is derived from filename (e.g., `my-post.mdx` -> `my-post`)

## Adding Custom MDX Components

### Step 1: Create the Component

```tsx
// src/components/mdx/Callout.tsx
"use client"
import { cn } from "@/lib/utils"

interface CalloutProps {
  children: React.ReactNode
  type?: "info" | "warning" | "success"
}

export function Callout({ children, type = "info" }: CalloutProps) {
  return (
    <aside className={cn(
      "my-6 p-4 rounded-[var(--radius-card)]",
      "border border-dashed border-divider",
      "font-mono text-sm",
      type === "info" && "bg-charcoal/5 text-ink",
      type === "warning" && "bg-negative/5 text-ink border-negative/30",
      type === "success" && "bg-positive/5 text-ink border-positive/30",
    )}>
      {children}
    </aside>
  )
}
```

### Step 2: Register in mdx-components.tsx

```tsx
import { Callout } from "@/components/mdx/Callout"

export function useMDXComponents(components) {
  return {
    ...components,
    Callout,  // Now available in MDX as <Callout type="info">...</Callout>
    // ... existing overrides
  }
}
```

### Step 3: Use in MDX Content

```mdx
<Callout type="warning">
  This approach has known limitations with concurrent writes.
</Callout>
```

## Experiments System

Interactive experiments are registered in `src/experiments/registry.ts` and embedded via:

```mdx
<ExperimentEmbed id="file-claim-flow" />
```

Each experiment needs:
1. A React component in `src/experiments/`
2. A registry entry with: id, title, description, topics, status, component (lazy import)
3. The component renders inside a DossierCard with an EXPERIMENT badge
