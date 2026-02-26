# Layout Patterns Reference

Complete guide to page layouts, grid systems, and spacing patterns in the StockTaper design system.

## Page Structure

Every page follows this structural hierarchy:

```
<html>
  <body className="bg-cream text-ink font-mono antialiased">
    <Header />
    <main>
      <Container>
        <!-- Page content -->
      </Container>
    </main>
    <Footer />
  </body>
</html>
```

### Root Layout (src/app/layout.tsx)

- Body classes: `bg-cream text-ink font-mono antialiased`
- Font imports: IBM Plex Mono 400 and 700
- Global CSS: `src/app/globals.css`
- Metadata: Site title and description

## Container System

### Container Component

```tsx
<Container className="optional-overrides">
  {/* All page content */}
</Container>
```

**Constraints**:
- `max-w-[1152px]` -- maximum content width
- `mx-auto` -- horizontal centering
- `px-6` -- consistent horizontal padding (24px each side)

### When to Use Container

- ALWAYS wrap page-level content in Container
- Header and Footer use Container internally
- Nested Containers are unnecessary (one level only)
- Full-bleed backgrounds should wrap Container, not be inside it

### Full-Bleed Pattern

When a section needs a full-width background:

```tsx
<section className="bg-charcoal/5">
  <Container>
    {/* Content constrained to max-width */}
  </Container>
</section>
```

## Grid System

### ContentGrid

The primary grid component for card layouts:

```tsx
<ContentGrid posts={posts} basePath="/research" columns={3} />
```

**Column Configurations**:

| columns | Mobile (< 768px) | Tablet (768px+) | Desktop (1024px+) |
|---------|-------------------|------------------|--------------------|
| 1       | 1 column          | 1 column         | 1 column           |
| 2       | 1 column          | 2 columns        | 2 columns          |
| 3       | 1 column          | 2 columns        | 3 columns          |

**Grid Classes**:
```css
/* 1 column */
grid grid-cols-1 gap-6

/* 2 columns */
grid grid-cols-1 md:grid-cols-2 gap-6

/* 3 columns */
grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6
```

### Custom Grid Patterns

For non-card content, use Tailwind grid directly:

```tsx
{/* Two-column feature layout */}
<div className="grid grid-cols-1 md:grid-cols-2 gap-8">
  <div>{/* Left column */}</div>
  <div>{/* Right column */}</div>
</div>

{/* Sidebar layout */}
<div className="grid grid-cols-1 lg:grid-cols-[2fr_1fr] gap-8">
  <main>{/* Main content */}</main>
  <aside>{/* Sidebar */}</aside>
</div>
```

### Flexbox Patterns

Used for inline layouts:

```tsx
{/* Navigation row */}
<nav className="flex items-center gap-6">
  {links}
</nav>

{/* Metadata line */}
<div className="flex items-center gap-2 text-xs text-muted">
  <time>Jan 15, 2026</time>
  <span>&middot;</span>
  <span>8 min read</span>
</div>

{/* Topic tags */}
<div className="flex flex-wrap gap-2">
  {topics.map(t => <TopicTag key={t} topic={t} />)}
</div>

{/* Space between header items */}
<div className="flex items-center justify-between">
  <Logo />
  <Nav />
</div>
```

## Page Layout Templates

### List Page (Research, Thoughts)

```tsx
<Container>
  {/* Page header */}
  <div className="py-16">
    <h1 className="text-4xl md:text-5xl font-bold tracking-tight text-ink mb-4">
      Research
    </h1>
    <p className="text-lg text-muted max-w-2xl">
      Page description text here.
    </p>
  </div>

  <Divider />

  {/* Content grid */}
  <div className="py-12">
    <ContentGrid posts={posts} basePath="/research" columns={3} />
  </div>
</Container>
```

### Detail Page (Article/Post)

```tsx
<Container>
  <article className="py-16 max-w-3xl">
    {/* Header */}
    <header className="mb-12">
      <Badge status={post.frontmatter.status} />
      <h1 className="text-4xl md:text-5xl font-bold tracking-tight text-ink mt-4 mb-4">
        {post.frontmatter.title}
      </h1>
      <ContentMeta
        date={post.frontmatter.date}
        readingTime={post.frontmatter.readingTime}
      />
      <div className="flex flex-wrap gap-2 mt-4">
        {post.frontmatter.topics.map(t => <TopicTag key={t} topic={t} />)}
      </div>
    </header>

    {/* Prose content */}
    <div className="prose prose-quoteless max-w-none">
      {/* MDX rendered content */}
    </div>
  </article>
</Container>
```

### Homepage

```tsx
<Container>
  {/* Hero */}
  <div className="py-20">
    <h1 className="text-4xl md:text-5xl font-bold tracking-tight text-ink mb-4">
      Loosely Organized Research Facility
    </h1>
    <p className="text-lg text-muted max-w-2xl mb-8">
      Tagline / description
    </p>
    <ArrowLink href="/research">Browse research -&gt;</ArrowLink>
  </div>

  <Divider />

  {/* Featured section */}
  <section className="py-12">
    <h2 className="text-2xl font-bold tracking-tight text-ink mb-8">
      Latest Research
    </h2>
    <ContentGrid posts={featured} basePath="/research" columns={2} />
  </section>
</Container>
```

## Spacing Patterns

### Vertical Rhythm

| Context                | Spacing           | Tailwind       |
|------------------------|-------------------|----------------|
| Between page sections  | 48-80px           | `py-12` to `py-20` |
| Heading to content     | 16px              | `mb-4`         |
| Between cards          | 24px              | `gap-6`        |
| Paragraph spacing      | 16px              | `mb-4`         |
| Section heading gap    | 32px below        | `mb-8`         |
| Article header space   | 48px below        | `mb-12`        |
| List item spacing      | 8px               | `space-y-2`    |

### Horizontal Rhythm

| Context                | Spacing    | Tailwind    |
|------------------------|------------|-------------|
| Container padding      | 24px       | `px-6`      |
| Card internal padding  | 24px       | `p-6`       |
| Grid gaps              | 24px       | `gap-6`     |
| Nav link spacing       | 24px       | `gap-6`     |
| Inline metadata        | 8px        | `gap-2`     |
| Topic tag gaps         | 8px        | `gap-2`     |
| Button padding         | 16x8       | `px-4 py-2` |

## Prose Layout

MDX content renders within a constrained prose container:

```tsx
<div className="prose prose-quoteless max-w-none">
  {/* MDX content */}
</div>
```

### Prose Width

Article content uses `max-w-3xl` (768px) on the parent article element, not on the prose container. This keeps the reading line length comfortable while allowing code blocks and tables to extend if needed.

### Prose Overrides

The typography plugin is configured through `@plugin "@tailwindcss/typography"` in CSS with extensive overrides in `globals.css`:

- All prose colors overridden to use design tokens
- Link styles: dashed underline instead of default
- Code styles: custom background and border
- Table styles: dashed borders
- Heading styles: match the heading scale above

## Responsive Behavior

### Breakpoint Strategy

| Breakpoint | Changes                                    |
|------------|--------------------------------------------|
| Default    | Single column, full-width within container |
| `md` 768px | Grid expands to 2 columns                 |
| `lg` 1024px| Grid expands to 3 columns, h1 size bumps  |

### Mobile-First Rules

1. Stack everything vertically by default
2. Use `flex-col` and switch to `flex-row` at breakpoints
3. Grid starts at `grid-cols-1`, expands at `md:` and `lg:`
4. Container padding (`px-6`) is consistent across all sizes
5. Font sizes do NOT change at breakpoints (except h1)
6. No horizontal scrolling -- `overflow-x-auto` only on code/tables

### Responsive Gotchas

- Never use `hidden` to remove content on mobile -- restructure instead
- Don't change font sizes across breakpoints (except h1)
- Container max-width handles desktop constraint automatically
- Use `max-w-2xl` or `max-w-3xl` for readable prose width, not percentage
