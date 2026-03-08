---
feature: f004
phase: 001
title: Add emoji visual anchors across all skills
status: pending
---

# Add Emoji Visual Anchors

Strategic emoji placement at critical decision points to improve agent instruction-following. Emojis are single tokens with strong semantic weight — they break text monotony and the model's attention mechanism latches onto them more reliably than bold text or caps.

## Emoji Vocabulary

| Emoji | Meaning | Use at |
|-------|---------|--------|
| 🛑 | **Stop** — do not proceed, halt pipeline | Gate failures, "stop and report", "do not continue" |
| ⚠️ | **Warning** — ask user, caution | "ask the user", destructive actions, "warn user" |
| 🔒 | **Hard constraint** — MUST/NEVER | "MUST exist", "never force-push", "never reuse" |
| ✅ | **Pass** | Gate passed, test passed, check succeeded |
| ❌ | **Fail** | Gate failed, test failed, check failed |
| 🚫 | **Anti-pattern** — never do this | Anti-pattern lists, "do NOT", redirect warnings |
| ⏸️ | **Wait** — do not proceed until user answers | "Do not proceed until the user answers" |

## Rules

- Only add emojis at **critical decision points** — constraints, stops, warnings, gates
- Do NOT add emojis to: step headers, mode descriptions, examples, general prose
- One emoji per line max — multiple emojis become noise
- Emoji goes at the **start** of the line/bullet, before the text
- Backlog view output gets status emojis (🟢 done, 🔵 active, ⚪ backlog) for scanability

## Tasks

- [ ] 1. **ship** — Critical Rules (🛑 gate fail, 🔒 run every gate), Gate 3 fail (🛑), Gate 5 fail (🛑), Gate 7 push fail (🛑), Gate 8 Build/Open constraint (🚫), wrap-up pass/fail markers (✅/❌)
- [ ] 2. **release** — Critical Rules (🔒 MUST exist, 🔒 never force-push), Gate 1 fail (🛑), Gate 2 changelog (⚠️ user review), Gate 3 conflict (🛑), progress tracking fail (❌)
- [ ] 3. **work** — Critical Rules (🔒 must exist, 🚫 do not ship), isolation wait (⏸️), EARS ambiguity (🛑 stop and ask), error handling stops (🛑), phase boundary (🚫 do NOT auto-ship)
- [ ] 4. **plan** — Critical Rules (🔒 must exist, 🔒 plans always go in), brainstorm gate (⏸️), EARS gate (⏸️), planning approach gate (⏸️)
- [ ] 5. **backlog** — View output status emojis (🟢/🔵/⚪), Critical Rules (🔒 must exist), redirect warnings (🚫)
- [ ] 6. **new** — Critical Rules (🛑 never overwrite, 🚫 never fabricate), proj_id constraint (🔒)
- [ ] 7. **status** — Critical Rules (🔒 MUST exist), backward transition (⚠️)
- [ ] 8. **stream** — Critical Rules (🔒 MUST exist, 🔒 never create duplicates, 🔒 MUST include commits)
- [ ] 9. **solution** — Critical Rules (🔒 MUST exist, 🔒 never reuse ID, 🔒 MUST have id)
- [ ] 10. **publish** — Stop condition (🛑), platform repo constraint (🔒), do NOT commit warning (🚫)
- [ ] 11. **stocktaper** — Anti-patterns list (🚫 each item), hard constraints (🔒 never use dark:, 🔒 never hardcode hex)
- [ ] 12. **backlog-format-contract.md** — No emojis (data format spec, not instructions)
