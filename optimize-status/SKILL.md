---
name: optimize-status
description: "Use when someone wants to see their current optimization state, check estimated savings, or verify which optimizations are active."
---

**Context:**
- Read `rewyse-ai/.optimizer/config.json` for active optimizations
- This agent is READ-ONLY — never modify any files
- Cross-references: `/optimize` to apply/rollback, `/optimize-help` for questions

## Step 1: Load Optimization State

Read `rewyse-ai/.optimizer/config.json`.

If the file doesn't exist or has an empty `optimizations` array, report:

> No optimizations applied yet. Run `/optimize` to get started.

Then stop.

## Step 2: Present Dashboard

Build and display the dashboard using data from `config.json`. Follow this exact format:

```
## Optimizer Status

Applied: {date from config.json}
Version: {version from config.json}

### Active Optimizations

**Model Routing** ({count} operations rerouted)
| File | Operation | Model | Savings |
|------|-----------|-------|---------|
| generate-content/SKILL.md | Content generation | Sonnet | ~80%/call |
| product-qa/SKILL.md | QA scanning | Sonnet | ~80%/call |
| build-database/SKILL.md | Entry seeding | Haiku | ~95%/call |
| {additional entries from config.json...} | | | |

**Batch Optimization** ({count} files)
| File | Batch Size | Status |
|------|-----------|--------|
| generate-content/SKILL.md | Dynamic | Active |
| {additional entries from config.json...} | | |

**Context Reduction** ({count} files)
- List each file with a one-line description of what was trimmed

**Skip-If-Done** ({count} files)
- List each file with the skip condition

### Quality-Critical Phases (Preserved on Opus)
- Phase 3: Expert Profile
- Phase 4: Content Blueprint
- Phase 5: Write Prompt

### Estimated Savings
- Per build (50 entries): ~$2-4 saved
- Per build (200 entries): ~$8-15 saved
- Across 10 builds: ~$50-100+
- Overall reduction: 30-50%

Rollback available: /optimize rollback
```

Populate every table dynamically from config.json. If a category has zero entries, show the header with "(0 files)" and skip the table.

## Notes

- Read-only — never modify any files
- If `config.json` is missing, guide the user to run `/optimize`
- Keep the dashboard concise and scannable
- Pull all counts and file lists from config.json — never hardcode them
