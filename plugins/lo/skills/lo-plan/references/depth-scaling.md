# Depth Scaling Guide

/lo:plan reads three signals to determine planning depth.

## Signal 1: Conversation Context

Has the user been discussing this topic in the current conversation?
- Rich context = skip brainstorming, go straight to structuring
- Look for: design decisions, approaches discussed, requirements explored

## Signal 2: Project Status (from .lo/project.yml)

- explore — lightweight (skip EARS, quick plan, no review gates)
- build — moderate (offer EARS if complex, plan mode available)
- open — full ceremony (recommend EARS, plan mode default)

## Signal 3: Feature Complexity

- Single subsystem, known pattern — lightweight
- Multiple subsystems, external APIs, state machines — full ceremony

## Depth Matrix

| Context | Status | Complexity | Depth |
|---------|--------|-----------|-------|
| Rich | any | any | Structure what was discussed. Skip brainstorming. |
| None | explore | low | Quick plan. No brainstorming needed. |
| None | explore | high | Brainstorm first, then quick plan. |
| None | build | low | Quick plan. Offer brainstorming. |
| None | build | high | Brainstorm, offer EARS, plan mode. |
| None | open | any | Brainstorm, recommend EARS, plan mode. |
