---
name: optimize-help
description: "Use when someone has questions about the Claude Code Optimizer, wants to understand how model routing works, or needs help troubleshooting optimization issues."
argument-hint: [question]
---

**Context:**
- Read [reference.md](reference.md) for FAQ and troubleshooting
- Check `rewyse-ai/.optimizer/config.json` for current state
- READ-ONLY agent — never modify any files
- Cross-references: `/optimize` to apply, `/optimize-status` for dashboard

## Step 1: Detect Context

1. If `$ARGUMENTS` provided, infer the mode from the question and answer directly — skip the mode menu
2. Check if the optimizer is installed (`rewyse-ai/.optimizer/` directory exists)
3. Check if optimizations are active (`config.json` has entries in the `optimizations` array)

## Step 2: Determine Mode

If no arguments were provided, present the menu:

> How can I help?
> 1. **Guide** — How the optimizer works and what it does
> 2. **Status** — Show current optimization state
> 3. **Troubleshoot** — Something seems wrong after optimizing

### Mode 1: Guide

Explain conversationally, walking through each concept in order:

1. **What it does** — "Every time your AI agents run a task, they use Claude's most powerful (and most expensive) model by default. But 70% of those tasks don't NEED the most powerful model. The optimizer identifies which tasks can run on cheaper models and makes the switch automatically."

2. **Three-tier routing** — Haiku for mechanical tasks (entry seeding, script generation), Sonnet for template-following tasks (content generation, QA scanning, domain research), Opus for creative reasoning (expert profile, content blueprint, prompt engineering). Give concrete examples from the Rewyse AI pipeline for each tier.

3. **What stays on Opus** — "The brain work stays on the expensive model: designing your expert persona, architecting your content structure, and engineering the generation prompt. These directly affect quality."

4. **Batch optimization** — "Larger, smarter batches mean fewer API round-trips. The optimizer tunes your batch sizes based on your product size."

5. **Context reduction** — "Your agents were sending full files when they only needed specific sections. The optimizer trims the fat."

6. **How to apply** — "Just run `/optimize` once. It scans everything, shows you the plan, and applies on your approval. That's it — every future build benefits automatically."

7. **Safety** — Explain the three safety nets: automatic backups before any change, approval gate so nothing happens without your say-so, and instant rollback with `/optimize rollback`.

### Mode 2: Status

Run the same logic as `/optimize-status`:
- Read `rewyse-ai/.optimizer/config.json`
- Present the full dashboard (see `/optimize-status` SKILL.md for format)
- If config.json is missing, report that no optimizations are applied

### Mode 3: Troubleshoot

Reference `reference.md` for detailed fixes. Address these common issues:

| Problem | Cause | Fix |
|---------|-------|-----|
| "Content quality dropped after optimizing" | A quality-critical operation may have been routed incorrectly | Run `/optimize rollback` to restore originals. Report which phase had quality issues so the routing rules can be updated. |
| "Build seems slower" | Batch sizes may be too large for your API tier | Run `/optimize rollback` then re-run `/optimize` — it will re-calibrate batch sizes |
| "optimize says already optimized" | Previous optimization is still active | Choose "Re-optimize" to update with latest rules, or "Rollback" to start fresh |
| "/optimize-status shows no data" | Optimizer hasn't been run yet | Run `/optimize` first to apply optimizations |
| "Can I optimize selectively?" | Yes | When `/optimize` shows the plan, choose "Selective" and pick which categories to apply |
| "Will this affect my existing products?" | No | Optimization only changes how FUTURE builds run. Existing Notion content is untouched. |
| "How do I know it's saving money?" | Check your Claude usage dashboard | Compare token usage before/after optimization across similar builds |

For any issue not in the table, check `reference.md` for expanded troubleshooting steps.

## Notes

- Read-only agent — never modify any files
- If content quality concerns arise, ALWAYS recommend rollback first, investigate second
- Quality > cost savings — if in doubt, keep on Opus
- Redirect pipeline questions (how to build products, Notion setup, etc.) to `/rewyse-help`
