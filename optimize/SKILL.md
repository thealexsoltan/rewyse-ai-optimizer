---
name: optimize
description: "Use when someone wants to reduce their AI costs, optimize token usage, route tasks to cheaper models, or make their Rewyse AI pipeline more efficient."
argument-hint: [rollback]
---

## Context

Before doing anything, read the full routing rules, operation catalog, batch configs, and
optimization patterns in [reference.md](reference.md).

This agent modifies SKILL.md files in the main Rewyse AI pipeline (`rewyse-ai/`) to:
- Route subagent calls to the cheapest model that maintains quality
- Optimize batch sizes to reduce orchestration overhead
- Reduce context passed to subagents (send only what they need)
- Add skip-if-done logic to avoid reprocessing completed work

**Optimizer data directory:** `rewyse-ai/.optimizer/`
- `config.json` — Tracks all applied optimizations, timestamps, and estimated savings
- `savings-log.json` — Per-build savings data (populated by `/optimize-status`)
- `backups/` — Original SKILL.md files before modification

**Cross-reference:**
- `/optimize-status` — Savings dashboard after builds
- `/optimize-help` — Questions about optimization decisions

---

## Step 0: Handle Rollback

If `$ARGUMENTS` is "rollback":

1. Read `rewyse-ai/.optimizer/config.json`
2. Extract the list of modified files from the `optimizations` array
3. For each unique file in the optimizations:
   a. Determine the backup path: `rewyse-ai/.optimizer/backups/{dirname}-SKILL-original.md`
      where `{dirname}` is the directory name of the modified file (e.g., `generate-content`)
   b. Read the backup file
   c. Write it back to the original location (e.g., `rewyse-ai/generate-content/SKILL.md`)
4. Clear the `optimizations` array in `config.json` and set `version` to 0
5. Present to the user:

> Rolled back {N} optimizations across {M} files. All SKILL.md files restored to their
> original state from backups.
>
> Backup files preserved in `rewyse-ai/.optimizer/backups/` in case you need them.

6. **Exit.** Do not continue to subsequent steps.

If `$ARGUMENTS` is NOT "rollback" (or no arguments provided), proceed to Step 1.

---

## Step 1: Check Prerequisites

### Verify Pipeline Exists

Check that the `rewyse-ai/` directory exists and contains the expected SKILL.md files.
If not found, stop and tell the user:

> "Can't find `rewyse-ai/` directory. Is this the correct project root?"

### Check for Previous Optimization

Read `rewyse-ai/.optimizer/config.json` if it exists.

If the file exists AND has a non-empty `optimizations` array:

> "Pipeline was last optimized on {applied_at}.
>
> **Current optimizations:**
> - {N} model routing changes
> - {N} batch optimizations
> - {N} context reductions
> - {N} skip-if-done enhancements
>
> **Options:**
> - **Re-optimize** — Scan again and update to the latest routing rules (backs up current state first)
> - **Rollback** — Restore all files to their pre-optimization state
> - **Cancel** — Keep the current optimizations as-is
>
> What would you like to do?"

Wait for the user's response:
- If **Re-optimize**: Create new backups of the current state, then continue to Step 2
- If **Rollback**: Execute Step 0 logic and exit
- If **Cancel**: Exit

### Create Optimizer Directory

If `rewyse-ai/.optimizer/` does not exist, create it:
- `rewyse-ai/.optimizer/`
- `rewyse-ai/.optimizer/backups/`
- Initialize `rewyse-ai/.optimizer/config.json` with:

```json
{
  "version": 0,
  "applied_at": null,
  "optimizations": [],
  "estimated_total_savings": null,
  "quality_preserved": []
}
```

---

## Step 2: Scan Pipeline

Read ALL SKILL.md files in the Rewyse AI pipeline. For each file, identify and document:

1. **Subagent calls** — Any instruction that uses the Agent tool or launches a subagent.
   Look for these patterns:
   - "Use a subagent"
   - "Launch a subagent"
   - "Agent tool"
   - "model: sonnet"
   - "model: haiku"
   - "run_in_background"
   - "parallel agents"
   - "parallel subagents"

2. **Current model specification** — Does the subagent call specify a model?
   - If `model: sonnet` or `model: haiku` is present, record it
   - If no model is specified, record as "Opus (default)" — subagents without explicit
     model routing inherit the parent model

3. **Batch configurations** — Any batch size instructions:
   - "batches of 5-10"
   - "batch size: 5"
   - "5-10 entries per agent"
   - "Maximum 10 parallel agents per wave"

4. **Context passing** — What files or data are passed to subagents:
   - Full file paths (e.g., "Read expert-profile.md")
   - Specific sections (e.g., "Pass only the Voice & Tone section")
   - Entire JSON objects vs. filtered subsets

5. **Resume logic** — Does the skill check for completed work before re-processing:
   - Reads a log file (content-log.json, qa-report.md)
   - Checks status fields
   - Skips already-processed entries

**Files to scan (read each one in full):**
- `rewyse-ai/product-idea/SKILL.md`
- `rewyse-ai/build-database/SKILL.md`
- `rewyse-ai/expert-profile/SKILL.md`
- `rewyse-ai/content-blueprint/SKILL.md`
- `rewyse-ai/write-prompt/SKILL.md`
- `rewyse-ai/test-content/SKILL.md`
- `rewyse-ai/generate-content/SKILL.md`
- `rewyse-ai/design-product/SKILL.md`
- `rewyse-ai/product-qa/SKILL.md`
- `rewyse-ai/product-expand/SKILL.md`

Record your findings for each file before proceeding to classification.

---

## Step 3: Classify Operations

For each subagent call found in Step 2, classify it using the three-tier complexity model
from reference.md (Section 1):

### Route to Haiku (complexity < 0.3)

Mechanical operations that follow exact templates with no creative judgment:
- Node.js script generation for database creation
- Icon assignment scripts
- Entry seeding from user-provided lists (Option A in build-database)
- Simple data formatting and API call scripts
- Distribution counting scripts

Look for: operations that generate or run boilerplate Node.js scripts, assign emojis,
or populate structured data from a known list.

### Route to Sonnet (complexity 0.3-0.7)

Template-following operations that need language quality but not deep reasoning:
- Content generation from a parameterized prompt
- QA scanning against a defined checklist
- Domain research (web search + summarize findings)
- Homepage structure creation and view configuration
- Batch entry population with AI-generated data (Option B in build-database)
- Market research for product expansion

Look for: operations where the subagent follows an explicit prompt template and produces
structured output, but the output quality depends on language ability.

### Keep on Opus (complexity > 0.7)

Operations requiring creative reasoning, architectural decisions, or nuanced judgment:
- Expert profile persona design (voice, tone, vocabulary, perspective)
- Content blueprint section architecture (structure, flow, word count balancing)
- Prompt assembly and optimization (combining profile + blueprint + variables)
- User-facing orchestrator interactions (build-product)
- Test content review and root cause diagnosis

Look for: operations where the main agent (not a subagent) does the creative work,
or where the quality bar is "this must be as good as a senior human expert."

**Important distinctions:**
- Domain RESEARCH subagents (in product-idea and expert-profile) are Sonnet-tier
  because they search + summarize. The PERSONA DESIGN that uses the research is
  Opus-tier, but that's the main agent's work, not a subagent.
- Entry seeding from a USER-PROVIDED list (mechanical mapping) is Haiku-tier.
  Entry seeding with AI GENERATION (creating realistic entry data) is Sonnet-tier.
- The filtered view creation agents in design-product are Sonnet-tier (they follow
  a clear filter DSL pattern).

---

## Step 4: Generate Optimization Plan

Compile all findings into a structured report. Cross-reference each finding against
the operation catalog in reference.md (Section 2) to validate your classifications.

Present this report to the user:

```
## Claude Code Optimization Plan

### 1. Model Routing ({N} changes across {M} files)

| File | Operation | Current | Optimized | Est. Savings |
|------|-----------|---------|-----------|-------------|
| {path} | {operation description} | {current model} | {recommended model} | {estimated % savings per call} |
| ... | ... | ... | ... | ... |

{For operations already correctly routed, note them separately:}

**Already optimized (no change needed):**
- {file}: {operation} — already on {model}
- ...

### 2. Batch Optimization ({N} changes)

| File | Operation | Current | Optimized | Why |
|------|-----------|---------|-----------|-----|
| {path} | {operation} | {current batch size} | {new batch size} | {reasoning} |
| ... | ... | ... | ... | ... |

### 3. Context Reduction ({N} changes)

| File | Operation | Current | Optimized | Est. Token Savings |
|------|-----------|---------|-----------|-------------------|
| {path} | {operation} | {what's currently passed} | {what should be passed} | {estimated % reduction} |
| ... | ... | ... | ... | ... |

### 4. Skip-If-Done Logic ({N} enhancements)

| File | Enhancement |
|------|-------------|
| {path} | {what check to add and what it skips} |
| ... | ... |

### Summary

- Model routing: {N} operations analyzed, {N} changes recommended
- Batch optimization: {N} changes
- Context reduction: {N} changes
- Skip-if-done: {N} enhancements
- Quality-critical phases preserved on Opus: {list phases}
- **Estimated total cost reduction: 30-50% per build**

Apply all optimizations? (Yes / Selective / No)
```

**Wait for the user's response:**
- **Yes**: Apply all recommended optimizations in Step 5
- **Selective**: Ask which categories or specific changes to apply
- **No**: Exit without changes

---

## Step 5: Apply Optimizations

For each approved change, apply it surgically to the target SKILL.md file.

### Backup First

Before modifying any file, check if a backup already exists at
`rewyse-ai/.optimizer/backups/{dirname}-SKILL-original.md`. If not, create one:

1. Read the current file
2. Write a copy to `rewyse-ai/.optimizer/backups/{dirname}-SKILL-original.md`

Only create one backup per file, even if multiple optimizations target the same file.

### Apply Model Routing Changes

For each model routing change:

1. Read the target SKILL.md file
2. Find the subagent instruction paragraph — the text that describes launching the subagent
3. Apply the edit:

   **If the current text has no model specification (defaults to Opus):**
   - Find: `Agent tool)` or `a subagent)` or similar closing pattern
   - Add the model parameter: `Agent tool, model: {haiku|sonnet})`
   - Example: `"Use a subagent (Agent tool) to generate entries"`
     becomes `"Use a subagent (Agent tool, model: haiku) to generate entries"`

   **If the current text already specifies a model that should change:**
   - Find: `model: {current_model}`
   - Replace with: `model: {new_model}`
   - Example: `"model: sonnet"` becomes `"model: haiku"`

4. Verify the edit was applied correctly by reading the file again

### Apply Batch Optimization Changes

For each batch size change:

1. Find the batch size instruction in the SKILL.md
2. Update the number or range
3. If adding dynamic sizing logic, add a brief instruction block:

```
**Dynamic batch sizing:**
- 10-30 entries: batch size 10-15
- 30-50 entries: batch size 15
- 50-100 entries: batch size 15-20
- 100+ entries: batch size 20
```

### Apply Context Reduction Changes

For each context reduction:

1. Find where the subagent is told to read a file
2. Add a specific instruction to pass only the relevant section:

```
Pass only the Voice & Tone section and Vocabulary section from expert-profile.md,
not the entire file. The QA subagent does not need the full expert background,
credentials, or knowledge boundaries.
```

### Apply Skip-If-Done Logic

For each skip-if-done enhancement:

1. Find the appropriate step in the SKILL.md (usually before a processing loop)
2. Add a check instruction:

```
**Before processing, check {file} for already-completed entries.**
- Read {file} if it exists
- Extract entries with status "{completed_status}"
- Remove them from the processing queue
- Report: "Skipping {N} already-completed entries. Processing {M} remaining."
```

### Track All Changes

After applying all changes, write the complete optimization record to
`rewyse-ai/.optimizer/config.json`:

```json
{
  "version": 1,
  "applied_at": "{YYYY-MM-DD}",
  "optimizations": [
    {
      "file": "generate-content/SKILL.md",
      "type": "model_routing",
      "operation": "content generation subagents",
      "from": "sonnet",
      "to": "sonnet (confirmed)",
      "estimated_savings": "0% (already optimal)"
    },
    {
      "file": "design-product/SKILL.md",
      "type": "model_routing",
      "operation": "filtered view creation agents",
      "from": "opus (default)",
      "to": "sonnet",
      "estimated_savings": "80%"
    },
    {
      "file": "build-database/SKILL.md",
      "type": "model_routing",
      "operation": "entry seeding from list (Option A)",
      "from": "sonnet",
      "to": "haiku",
      "estimated_savings": "93%"
    },
    ...
  ],
  "estimated_total_savings": "30-50%",
  "quality_preserved": [
    "expert-profile (persona design)",
    "content-blueprint (section architecture)",
    "write-prompt (prompt engineering)",
    "build-product (orchestrator)"
  ]
}
```

---

## Step 6: Present Summary

After all optimizations are applied and tracked:

```
## Optimization Complete

### Applied Changes

- **Model routing:** {N} changes across {M} files
  - {N} operations confirmed already optimal
  - {N} operations downgraded to cheaper models
  - {N} operations kept on current model (quality-critical)

- **Batch optimization:** {N} changes
  - Dynamic batch sizing added to {files}

- **Context reduction:** {N} changes
  - Subagent context trimmed in {files}

- **Skip-if-done:** {N} enhancements
  - Resume logic added/verified in {files}

### Quality-Critical Phases Preserved on Opus

These phases are NOT touched for model routing — they require deep creative reasoning:
- **Phase 3:** Expert Profile — persona design, voice calibration, vocabulary selection
- **Phase 4:** Content Blueprint — section architecture, word count balancing, flow design
- **Phase 5:** Write Prompt — prompt engineering, constraint design, test validation
- **Phase 0:** Build Product — orchestrator, all user-facing interactions

### Estimated Savings

- **Per-build cost reduction:** 30-50% (depends on product size and entry count)
- **Largest savings:** Phase 7 (generate-content) and Phase 9 (product-qa) — these run
  the most subagent calls and benefit most from model routing + batch optimization

### File Locations

- Optimization config: `rewyse-ai/.optimizer/config.json`
- Backups: `rewyse-ai/.optimizer/backups/`

### Next Steps

- Run `/optimize-status` after your next build to see actual savings
- To undo all changes: `/optimize rollback`
```

---

## Notes

- **NEVER modify `build-product/SKILL.md`.** The orchestrator handles user interactions
  and must always run on the parent model (Opus). It does not launch cost-relevant subagents.
- **NEVER modify `expert-profile/SKILL.md` for persona design model routing.** The main
  agent work in Phase 3 (building the persona) is quality-critical. However, the domain
  RESEARCH subagent within expert-profile CAN be routed — it already is (to Sonnet).
- **NEVER modify `content-blueprint/SKILL.md` or `write-prompt/SKILL.md` for model routing.**
  These are creative-reasoning phases with no subagents to route.
- **Changes are surgical.** Add model parameters and brief instructions. Never restructure
  the file, reorder steps, or rewrite existing prose. The optimizer adds to files; it does
  not rewrite them.
- **If a subagent already has the correct model specified, log it as "confirmed already
  optimal" in the config.** Do not modify the file — just document the finding.
- **Always back up before modifying.** One backup per file, stored in
  `rewyse-ai/.optimizer/backups/`. If a backup already exists for a file (from a previous
  optimization run), overwrite it with the current state before applying new changes.
- **The operation catalog in reference.md is the source of truth.** If your scan finds
  a subagent call not listed in the catalog, classify it using the three-tier rules and
  add a note in the optimization plan.
- **Batch size increases have diminishing returns.** Going from 5 to 15 cuts waves by ~66%.
  Going from 15 to 20 cuts waves by ~25%. The Notion API rate limit (350ms between calls,
  5 concurrent) is the practical constraint — batch sizes above 20 rarely help.
- **Context reduction should never remove information the subagent actually needs.** When
  in doubt, keep the full context. A subagent that fails due to missing context costs more
  than the tokens saved by trimming.
