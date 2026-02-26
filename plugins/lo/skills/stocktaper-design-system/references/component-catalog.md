# Component Catalog

Complete reference for every component in the StockTaper design system. Each entry includes the component's location, props, visual structure, and usage examples.

## Layout Components

### Container

**Location**: `src/components/layout/Container.tsx`

**Purpose**: Constrains content to maximum width with consistent horizontal padding.

**Props**:
```typescript
interface ContainerProps {
  children: React.ReactNode
  className?: string
}
```

**Structure**:
```tsx
<div className={cn("mx-auto max-w-[1152px] px-6", className)}>
  {children}
</div>
```

**Usage**: Wrap every page section. Never render content directly without Container.

---

### Header

**Location**: `src/components/layout/Header.tsx`

**Purpose**: Site-wide navigation bar with logo and page links.

**Structure**:
- Wraps in `Container`
- Flex row with `justify-between items-center`
- Left side: Site name link (`text-lg font-bold text-ink`)
- Right side: Navigation links in flex row with `gap-6`
- Links use `text-sm text-charcoal hover:text-ink`
- Bottom border: `border-b border-divider`

**Nav Links**: Research, Thoughts, About

---

### Footer

**Location**: `src/components/layout/Footer.tsx`

**Purpose**: Minimal copyright bar at page bottom.

**Structure**:
- Wraps in `Container`
- Top border: `border-t border-divider`
- Centered text: `text-xs text-muted`
- Padding: `py-8`

---

## UI Components

### Button

**Location**: `src/components/ui/Button.tsx`

**Purpose**: Primary action trigger.

**Props**:
```typescript
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary"
  className?: string
  children: React.ReactNode
}
```

**Variants**:

| Variant   | Background  | Text       | Border                              |
|-----------|-------------|------------|-------------------------------------|
| primary   | `bg-ink`    | `text-cream` | none                              |
| secondary | `bg-cream`  | `text-ink` | `border border-dashed border-divider` |

**Common Classes**:
```
font-mono text-sm font-bold uppercase tracking-wider
px-4 py-2 rounded-[var(--radius-button)]
transition-colors duration-150
```

---

### Badge

**Location**: `src/components/ui/Badge.tsx`

**Purpose**: Status indicator for content items.

**Props**:
```typescript
interface BadgeProps {
  status: "draft" | "field-notes" | "published" | "experiment" | "classified"
  className?: string
}
```

**Status Styles**:

| Status       | Text Color     | Background         | Label         |
|--------------|----------------|--------------------|---------------|
| draft        | `text-muted`   | `bg-charcoal/10`   | DRAFT         |
| field-notes  | `text-charcoal`| `bg-charcoal/10`   | FIELD NOTES   |
| published    | `text-positive`| `bg-positive/10`   | PUBLISHED     |
| experiment   | `text-charcoal`| `bg-charcoal/10`   | EXPERIMENT    |
| classified   | `text-negative`| `bg-negative/10`   | CLASSIFIED    |

**Common Classes**:
```
inline-flex items-center
px-2 py-0.5 rounded-full
text-xs font-bold uppercase tracking-[0.5px]
font-mono
```

---

### DossierCard

**Location**: `src/components/ui/DossierCard.tsx`

**Purpose**: Primary content card with dashed border and optional status badge.

**Props**:
```typescript
interface DossierCardProps {
  children: React.ReactNode
  badge?: React.ReactNode
  className?: string
}
```

**Structure**:
```tsx
<div className={cn(
  "border border-dashed border-divider rounded-[var(--radius-card)]",
  "p-6 bg-cream",
  className
)}>
  {badge && <div className="mb-3">{badge}</div>}
  {children}
</div>
```

**Usage Pattern**: Often wraps title, description, metadata, and topic tags together.

---

### Divider

**Location**: `src/components/ui/Divider.tsx`

**Purpose**: Horizontal separator between sections.

**Props**:
```typescript
interface DividerProps {
  className?: string
}
```

**Structure**:
```tsx
<hr className={cn("border-divider", className)} />
```

**Note**: Divider is the ONE exception that uses solid border, not dashed.

---

### ArrowLink

**Location**: `src/components/ui/ArrowLink.tsx`

**Purpose**: Navigation link with trailing arrow glyph.

**Props**:
```typescript
interface ArrowLinkProps {
  href: string
  children: React.ReactNode
  className?: string
}
```

**Structure**:
```tsx
<Link href={href} className={cn(
  "inline-flex items-center gap-1",
  "text-sm font-bold text-charcoal hover:text-ink",
  "underline decoration-dashed underline-offset-4 hover:decoration-solid",
  className
)}>
  {children}
  <span aria-hidden>-&gt;</span>
</Link>
```

**Arrow glyph**: Uses `->` text (not an SVG icon). This is intentional for the monospace aesthetic.

---

### TopicTag

**Location**: `src/components/ui/TopicTag.tsx`

**Purpose**: Pill-shaped label for content topics/categories.

**Props**:
```typescript
interface TopicTagProps {
  topic: string
  className?: string
}
```

**Structure**:
```tsx
<span className={cn(
  "inline-flex items-center",
  "px-3 py-1 rounded-full",
  "text-xs font-mono text-muted",
  "border border-dashed border-divider",
  className
)}>
  {topic}
</span>
```

**Usage**: Rendered in a flex-wrap row with `gap-2` for multiple topics.

---

## Content Components

### ContentCard

**Location**: `src/components/content/ContentCard.tsx`

**Purpose**: Post preview card displayed in grids and lists.

**Props**:
```typescript
interface ContentCardProps {
  post: Post
  basePath: string   // e.g., "/research" or "/thoughts"
  className?: string
}
```

**Structure**:
```
DossierCard
  Badge (status)
  Link > h3 (title: text-lg font-bold text-ink hover:text-charcoal)
  ContentMeta (date, readingTime, status)
  p (description: text-sm text-muted, line-clamp-3)
  div (topics: flex flex-wrap gap-2)
    TopicTag (for each topic)
```

**Interaction**: The title is a link to the full post. No card-level click handler.

---

### ContentGrid

**Location**: `src/components/content/ContentGrid.tsx`

**Purpose**: Responsive grid layout for ContentCards.

**Props**:
```typescript
interface ContentGridProps {
  posts: Post[]
  basePath: string
  columns?: 1 | 2 | 3
  className?: string
}
```

**Grid Classes**:
```
columns=1: "grid grid-cols-1 gap-6"
columns=2: "grid grid-cols-1 md:grid-cols-2 gap-6"
columns=3: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
```

---

### ContentMeta

**Location**: `src/components/content/ContentMeta.tsx`

**Purpose**: Metadata line showing date, reading time, and optionally status.

**Props**:
```typescript
interface ContentMetaProps {
  date: string
  readingTime?: string
  status?: string
  className?: string
}
```

**Structure**:
```tsx
<div className={cn("flex items-center gap-2 text-xs text-muted", className)}>
  <time>{formatDate(date)}</time>
  {readingTime && (
    <>
      <span aria-hidden>&middot;</span>
      <span>{readingTime}</span>
    </>
  )}
</div>
```

**Date format**: Uses `formatDate()` from `@/lib/utils` which outputs "Month DD, YYYY" format.

---

## Theme Components

### ThemeProvider

**Location**: `src/components/ThemeProvider.tsx`

**Directive**: `"use client"` (requires next-themes context)

**Purpose**: Wraps the application in next-themes provider, enabling dark mode via class strategy on `<html>`.

**Configuration**:
- `attribute="class"` -- toggles `.dark` class on `<html>`
- `defaultTheme="system"` -- respects OS preference on first visit
- `enableSystem` -- tracks OS dark mode changes

**Usage**: Wraps `{children}` in root `layout.tsx`. Only instantiated once.

---

### ThemeToggle

**Location**: `src/components/ui/ThemeToggle.tsx`

**Directive**: `"use client"` (requires useTheme hook + useState)

**Purpose**: Toggle button for switching between light and dark mode.

**Structure**:
- Uses `useTheme()` from next-themes
- Hydration-safe: renders `null` until mounted
- Shows moon SVG in light mode, sun SVG in dark mode
- `aria-label` updates with current state

**Styles**:
```
text-charcoal hover:text-ink transition-colors
```

**Placement**: Lives in the Header component alongside navigation links.

---

## MDX Components

### CopyButton

**Location**: `src/components/mdx/CopyButton.tsx`

**Purpose**: Copy-to-clipboard button overlaid on code blocks.

**Directive**: `"use client"` (requires browser clipboard API)

**Props**:
```typescript
interface CopyButtonProps {
  text: string
}
```

**Visual States**:
- Default: "Copy" text, `text-xs text-cream/60 hover:text-cream`
- Copied: "Copied!" text, briefly shown then reverts
- Position: `absolute top-3 right-3`

---

### ExperimentEmbed

**Location**: `src/components/mdx/ExperimentEmbed.tsx`

**Purpose**: Renders interactive experiment components inside MDX content with lazy loading.

**Directive**: `"use client"` (dynamic import + interactivity)

**Props**:
```typescript
interface ExperimentEmbedProps {
  id: string   // Matches experiment registry key
}
```

**Structure**:
- Wraps in `DossierCard` with experiment `Badge`
- Shows experiment title and description
- Lazy-loads the React component from `src/experiments/registry.ts`
- Displays loading skeleton while component loads

---

## Creating New Components

### Template: New UI Component

```tsx
import { cn } from "@/lib/utils"

interface NewComponentProps {
  children: React.ReactNode
  variant?: "default" | "accent"
  className?: string
}

export function NewComponent({
  children,
  variant = "default",
  className,
}: NewComponentProps) {
  return (
    <div
      className={cn(
        // Base
        "font-mono",
        // Border (dashed is default for cards/containers)
        "border border-dashed border-divider rounded-[var(--radius-card)]",
        // Spacing
        "p-6",
        // Variants
        variant === "default" && "bg-cream text-ink",
        variant === "accent" && "bg-charcoal/5 text-ink",
        // Allow override
        className
      )}
    >
      {children}
    </div>
  )
}
```

### Template: New Content Component

```tsx
import { cn } from "@/lib/utils"
import type { Post } from "@/lib/types"

interface NewContentComponentProps {
  post: Post
  className?: string
}

export function NewContentComponent({ post, className }: NewContentComponentProps) {
  return (
    <article className={cn("space-y-3", className)}>
      <h3 className="text-lg font-bold text-ink">{post.frontmatter.title}</h3>
      <p className="text-sm text-muted leading-relaxed">
        {post.frontmatter.description}
      </p>
    </article>
  )
}
```

### Template: New MDX Component

```tsx
"use client"

import { cn } from "@/lib/utils"

interface NewMdxComponentProps {
  children: React.ReactNode
  className?: string
}

export function NewMdxComponent({ children, className }: NewMdxComponentProps) {
  return (
    <aside
      className={cn(
        "my-6 border-l-2 border-divider pl-4",
        "font-mono text-sm text-muted",
        className
      )}
    >
      {children}
    </aside>
  )
}
```

After creating any MDX component, register it in `mdx-components.tsx` at the project root.
