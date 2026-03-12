# project.yml — Project Metadata

> From the .lo/ Convention Spec v3.0.0

The root file. One per project. Pure YAML — no frontmatter delimiters, no markdown body.

## Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Auto-generated project identifier. Format: `proj_` + lowercase UUID v4. Never manually assign or reuse. Must be the first field. |
| `title` | string | Project title, e.g. `"Loosely Organized"` |
| `description` | string | One-sentence description |
| `status` | enum | `explore` \| `build` \| `open` \| `closed` |
| `state` | enum | `public` \| `private` |

## No Optional Fields

Fields previously in PROJECT.md have moved to canonical sources:

| Removed Field | New Home |
|--------------|----------|
| `repo` | `git remote -v` / GitHub API |
| `stack` | `package.json` (or ask user during `/lo:setup`) |
| `infrastructure` | Ask user during `/lo:status` transitions |
| `agents` | Dropped — boilerplate, not displayed |
| Body sections | `CLAUDE.md` (architecture), `README.md` (public description) |

## Validation Rules

- `status` must be one of: `explore`, `build`, `open`, `closed`
- `state` must be one of: `public`, `private`
- `id` format: `proj_` + lowercase UUID v4

## Example

```yaml
id: "proj_166345da-d821-4b3a-abbc-e3a439925e85"
title: "Nexus"
description: "A coordination server for multi-agent engineering teams."
status: "build"
state: "public"
```
