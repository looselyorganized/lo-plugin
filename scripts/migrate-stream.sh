#!/bin/bash
# Migrate .lo/stream/*.md files to a single .lo/STREAM.md file
# For each project: read all stream files, convert to new format, write STREAM.md, delete stream/

set -euo pipefail

BASE="/Users/bigviking/Documents/github/projects/lo"

PROJECTS=(
  "agent-development-brief"
  "claude-dashboard"
  "content-webhook"
  "cr-agent"
  "nexus"
  "platform"
  "telemetry-exporter"
  "yellowages-for-agents"
  "lo-concierge"
)

migrate_project() {
  local project="$1"
  local project_dir="$BASE/$project"
  local stream_dir="$project_dir/.lo/stream"
  local stream_file="$project_dir/.lo/STREAM.md"

  if [ ! -d "$stream_dir" ]; then
    echo "  $project: no stream/ dir, skipping"
    return
  fi

  # Collect all .md files sorted by filename (reverse for newest-first)
  local files
  files=$(ls "$stream_dir"/*.md 2>/dev/null | sort -r || true)

  if [ -z "$files" ]; then
    echo "  $project: stream/ empty, removing dir"
    rm -rf "$stream_dir"
    # Create empty STREAM.md if it doesn't exist
    if [ ! -f "$stream_file" ]; then
      printf -- '---\ntype: stream\n---\n' > "$stream_file"
    fi
    return
  fi

  # Start building STREAM.md
  local output
  output="---
type: stream
---"

  while IFS= read -r file; do
    [ -z "$file" ] && continue

    # Parse the file: extract frontmatter and body
    local in_frontmatter=0
    local frontmatter_done=0
    local fm_lines=""
    local body=""

    while IFS= read -r line; do
      if [ "$frontmatter_done" -eq 0 ]; then
        if [ "$line" = "---" ]; then
          if [ "$in_frontmatter" -eq 0 ]; then
            in_frontmatter=1
            continue
          else
            frontmatter_done=1
            continue
          fi
        fi
        if [ "$in_frontmatter" -eq 1 ]; then
          fm_lines="$fm_lines
$line"
        fi
      else
        body="$body
$line"
      fi
    done < "$file"

    # Trim leading newline from body
    body=$(echo "$body" | sed '/./,$!d')

    # Parse frontmatter fields we care about
    local date_val title_val version_val feature_id_val commits_val research_val type_val
    date_val=$(echo "$fm_lines" | grep -E '^date:' | head -1 | sed 's/^date:[[:space:]]*//' | tr -d '"' || true)
    title_val=$(echo "$fm_lines" | grep -E '^title:' | head -1 | sed 's/^title:[[:space:]]*//' || true)
    version_val=$(echo "$fm_lines" | grep -E '^version:' | head -1 | sed 's/^version:[[:space:]]*//' | tr -d '"' || true)
    feature_id_val=$(echo "$fm_lines" | grep -E '^feature_id:' | head -1 | sed 's/^feature_id:[[:space:]]*//' | tr -d '"' || true)
    commits_val=$(echo "$fm_lines" | grep -E '^commits:' | head -1 | sed 's/^commits:[[:space:]]*//' || true)

    # Build entry block
    local entry_block="
<!-- entry -->
date: $date_val
title: $title_val"

    [ -n "$version_val" ] && entry_block="$entry_block
version: \"$version_val\""
    [ -n "$feature_id_val" ] && entry_block="$entry_block
feature_id: \"$feature_id_val\""
    [ -n "$commits_val" ] && entry_block="$entry_block
commits: $commits_val"

    entry_block="$entry_block

$body"

    output="$output
$entry_block"
  done <<< "$files"

  # Write STREAM.md
  echo "$output" > "$stream_file"

  # Count entries
  local count
  count=$(echo "$files" | wc -l | tr -d ' ')

  # Remove stream directory
  rm -rf "$stream_dir"

  echo "  $project: migrated $count entries to STREAM.md, deleted stream/"
}

echo "Migrating stream files to STREAM.md..."
echo ""

for project in "${PROJECTS[@]}"; do
  migrate_project "$project"
done

echo ""
echo "Migration complete."
