/**
 * StockTaper Design System - Component Template
 *
 * Copy this template when creating new components.
 * Replace placeholders with your component-specific implementation.
 *
 * RULES:
 * - Only use font-mono (IBM Plex Mono)
 * - Only use design token colors (cream, ink, charcoal, muted, divider, positive, negative)
 * - Use dashed borders for cards/containers: border border-dashed border-divider
 * - Use rounded-[var(--radius-card)] for containers, rounded-[var(--radius-button)] for inputs
 * - Always accept className prop for composition
 * - Use cn() utility for class merging
 * - Font weights: 400 (normal) or 700 (bold) only
 * - No shadows, gradients, or blur effects
 */

import { cn } from "@/lib/utils"

// -------------------------------------------------------------------
// 1. PROPS INTERFACE
// -------------------------------------------------------------------
interface ComponentNameProps {
  children: React.ReactNode
  variant?: "default" | "accent"
  size?: "sm" | "md" | "lg"
  className?: string
}

// -------------------------------------------------------------------
// 2. COMPONENT
// -------------------------------------------------------------------
export function ComponentName({
  children,
  variant = "default",
  size = "md",
  className,
}: ComponentNameProps) {
  return (
    <div
      className={cn(
        // Base styles
        "font-mono",

        // Border (dashed is the default for card-like elements)
        "border border-dashed border-divider",
        "rounded-[var(--radius-card)]",

        // Size variants
        size === "sm" && "p-3 text-sm",
        size === "md" && "p-6 text-base",
        size === "lg" && "p-8 text-lg",

        // Color variants
        variant === "default" && "bg-cream text-ink",
        variant === "accent" && "bg-charcoal/5 text-ink",

        // Allow consumer overrides
        className
      )}
    >
      {children}
    </div>
  )
}
