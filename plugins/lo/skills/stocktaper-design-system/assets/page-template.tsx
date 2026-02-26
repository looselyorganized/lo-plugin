/**
 * StockTaper Design System - Page Template
 *
 * Copy this template when creating new pages.
 * Follows the standard page layout pattern:
 *   Container > Header Section > Divider > Content Section
 */

import { Container } from "@/components/layout/Container"
import { Divider } from "@/components/ui/Divider"
import { ContentGrid } from "@/components/content/ContentGrid"
import { ArrowLink } from "@/components/ui/ArrowLink"
// import { getPosts } from "@/lib/content"

export default async function PageName() {
  // const posts = await getPosts("research") // or "thoughts"

  return (
    <Container>
      {/* ── Page Header ── */}
      <div className="py-16">
        <h1 className="text-4xl md:text-5xl font-bold tracking-tight text-ink mb-4">
          Page Title
        </h1>
        <p className="text-lg text-muted max-w-2xl">
          Brief page description that explains what this section contains.
        </p>
      </div>

      <Divider />

      {/* ── Content Section ── */}
      <section className="py-12">
        <h2 className="text-2xl font-bold tracking-tight text-ink mb-8">
          Section Heading
        </h2>

        {/*
        <ContentGrid
          posts={posts}
          basePath="/research"
          columns={3}
        />
        */}
      </section>

      {/* ── Navigation ── */}
      <div className="pb-16">
        <ArrowLink href="/">Back to home</ArrowLink>
      </div>
    </Container>
  )
}
