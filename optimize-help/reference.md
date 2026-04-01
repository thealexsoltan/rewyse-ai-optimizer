# Claude Code Optimizer — Reference

## How the Optimizer Works

Your AI agents have a "brain" they use for every task. The most powerful brain (Opus) costs the most. But most tasks — like generating content from a template, scanning pages for issues, or searching the web — work perfectly fine with a faster, cheaper brain (Sonnet).

The optimizer figures out which tasks need the expensive brain and which don't. Then it makes the switch. You run it once, and every future build benefits.

### Three-Tier Model Routing

| Tier | Model | Cost | Best for | Examples |
|------|-------|------|----------|----------|
| Tier 1 | Haiku | Lowest | Mechanical, repetitive tasks with no creative judgment | Entry seeding, script generation, simple data extraction |
| Tier 2 | Sonnet | Mid | Template-following tasks that need good output but follow clear patterns | Content generation, QA scanning, domain research, homepage structure |
| Tier 3 | Opus | Highest | Creative reasoning, strategy, and quality-critical decisions | Expert profile design, content blueprint architecture, prompt engineering |

The optimizer analyzes every subagent call in the pipeline, classifies it into one of these tiers, and adds a model routing parameter. The orchestrator and all user-facing interactions always stay on Opus.

### Other Optimizations

- **Batch size tuning** — Adjusts how many pages are generated per API call based on product size. Larger batches mean fewer round-trips and lower overhead.
- **Context reduction** — Trims instruction payloads so agents only receive the sections they need instead of entire files.
- **Skip-if-done** — Adds guards so agents skip work that was already completed in a previous run (useful for resumed builds).

---

## FAQ

### 1. Will my content quality drop?
No. Quality-critical phases (expert profile, content blueprint, prompt engineering) stay on Opus. Only mechanical and template-following tasks get routed to cheaper models. These tasks follow clear instructions and don't require creative reasoning, so the output quality remains the same.

### 2. How much will I save?
Estimated 30-50% per build. The exact amount depends on your product size. A 50-entry product saves roughly $2-4 per build. A 200-entry product saves $8-15. Across multiple builds, savings compound quickly.

### 3. Can I undo it?
Yes. Run `/optimize rollback` to instantly restore all original files from backups. Every file modified by the optimizer is backed up before any change is made.

### 4. Do I need to run it after every build?
No. Run `/optimize` once, and it works for every future build. Only re-run if you want to update to newer optimization rules or re-calibrate after a rollback.

### 5. What exactly changes?
The SKILL.md instruction files for specific pipeline phases get a model routing parameter added to their subagent calls. Nothing structural changes — the pipeline flow, phase order, and output format all stay identical.

### 6. Is it safe?
Yes. Three safety nets protect you:
- **Automatic backups** — Every file is copied to `rewyse-ai/.optimizer/backups/` before modification
- **Approval gate** — The optimizer shows you exactly what it plans to change and waits for your confirmation
- **Instant rollback** — `/optimize rollback` restores everything in seconds

### 7. What if I also have the Self-Improvement Agent?
They work together without conflicts. The self-improvement agent modifies content quality rules (what gets generated). The optimizer modifies cost routing (which model generates it). Different concerns, no overlap.

### 8. Which phases stay on Opus?
- Phase 3: Expert Profile — designing the voice and persona
- Phase 4: Content Blueprint — architecting page structure
- Phase 5: Write Prompt — engineering the generation prompt
- All user-facing conversations and approval gates
- The build-product orchestrator itself

### 9. Can I pick which optimizations to apply?
Yes. When `/optimize` shows the plan, choose "Selective" instead of "Apply All." You can pick individual categories (model routing, batch optimization, context reduction, skip-if-done) or even individual files.

### 10. Does it affect existing Notion products?
No. Optimization only changes how future builds run. Your existing Notion pages, databases, and content are completely untouched.

### 11. What's the difference between Haiku, Sonnet, and Opus?
- **Haiku** is the fastest and cheapest — great for simple, repetitive tasks that don't need judgment
- **Sonnet** is the sweet spot — good quality output at a fraction of Opus pricing, ideal for tasks that follow templates
- **Opus** is the most powerful — best for complex reasoning, creative decisions, and quality-critical work

The optimizer puts the right brain on the right job.

### 12. How do I check if it's working?
Run `/optimize-status` to see all active optimizations at a glance. For cost verification, check your Claude usage dashboard and compare token consumption before and after optimization across similar-sized builds.

---

## Troubleshooting

### Content quality dropped after optimizing
**Cause:** A quality-critical operation may have been routed to a cheaper model incorrectly.
**Fix:**
1. Run `/optimize rollback` immediately to restore original files
2. Note which phase produced lower-quality output (e.g., "Phase 7 content was repetitive")
3. Report the issue so the routing rules can be updated to keep that operation on Opus
4. Re-run `/optimize` after the fix — it will preserve that operation on Opus

### Build seems slower than before
**Cause:** Batch sizes may be too large for your current API tier or rate limits.
**Fix:**
1. Run `/optimize rollback` to restore defaults
2. Re-run `/optimize` — it will re-calibrate batch sizes based on current conditions
3. If the issue persists, choose "Selective" and skip batch optimization

### Optimizer says "already optimized"
**Cause:** A previous optimization is still active in `config.json`.
**Fix:** You have two options:
- **Re-optimize** — Updates existing optimizations with the latest rules (keeps backups from the original pre-optimization state)
- **Rollback first** — Run `/optimize rollback`, then run `/optimize` fresh

### /optimize-status shows no data
**Cause:** The optimizer hasn't been run yet — there's no `config.json` to read.
**Fix:** Run `/optimize` to apply optimizations. After that, `/optimize-status` will show the full dashboard.

### Rollback didn't fully restore files
**Cause:** Backup files may have been manually moved or deleted.
**Fix:**
1. Check `rewyse-ai/.optimizer/backups/` for your backup files
2. If backups exist, manually copy them back to their original locations
3. If backups are missing, the original skill files can be restored from git history

### Optimizer conflicts with manual SKILL.md edits
**Cause:** You edited a SKILL.md file after optimization, and the optimizer's markers may be inconsistent.
**Fix:**
1. Run `/optimize rollback` to get back to the pre-optimization baseline
2. Make your manual edits on the clean files
3. Re-run `/optimize` — it will layer optimizations on top of your edits

---

## Template Cache (ReasoningBank)

The template cache saves proven build artifacts so you can reuse them on future builds of the same product type. Instead of designing an expert profile, blueprint, and generation prompt from scratch every time, you start from a proven template and customize.

### FAQ

#### 13. What is the template cache?
A storage system for proven build artifacts — expert profiles, content blueprints, and generation prompts — organized by product type. When you complete a build that produces good results, you cache those artifacts. Next time you build the same product type, you can start from those templates instead of from scratch, potentially skipping Phases 3-5.

#### 14. How do I cache a build?
Run `/cache-build` after completing a build (at least Phase 7). It reads the build's output files, extracts the reusable artifacts, and saves them to `rewyse-ai/.optimizer/template-cache/{product-type}/`. You can also pass the project slug directly: `/cache-build hyrox-recipes`.

#### 15. How do I use cached templates?
Run `/use-cache` before starting a new build (or at the start of one). It checks if a template cache exists for your product type and offers to copy the templates as starting points. You can reuse all three templates, pick selectively, or review each one before deciding.

#### 16. Does it auto-apply templates?
No. Templates are always presented for review. You must confirm or customize each template before it is used. The cache provides starting points, not final outputs. This is especially important when building for a different niche — the structural elements transfer, but niche-specific details need adjustment.

#### 17. Can I cache multiple builds of the same type?
Only one cache per product type. If you cache a second build of the same type, it replaces the previous cache (after asking for confirmation). This keeps the cache simple and ensures it always reflects your latest proven build.

#### 18. What if my new niche is different from the cached one?
Templates are structural, not content-specific. A recipe expert profile template has the right voice dimensions, vocabulary categories, and perspective framework whether the recipes are for athletes or vegans. You customize the niche-specific terms during the review step. The page structure, prompt architecture, and voice patterns are the reusable parts.

#### 19. What gets cached exactly?
Three required artifacts and two optional ones:
- **Expert profile** — voice, tone, vocabulary, perspective (required)
- **Content blueprint** — sections, word counts, formatting rules (required)
- **Generation prompt** — the assembled prompt that passed testing (required)
- **QA baseline** — issue counts from the last QA scan (optional, informational)
- **Cache metadata** — product type, source build, date, usage count (auto-generated)

#### 20. Where are cached templates stored?
In `rewyse-ai/.optimizer/template-cache/{product-type}/`. Each product type gets its own subdirectory with the template files and a `cache-meta.json` metadata file.

### Troubleshooting

#### /cache-build says "build is incomplete"
**Cause:** The build has not reached Phase 7 (content generation). The cache requires proof that the artifacts actually work together.
**Fix:** Complete at least Phase 7 (generate content), then re-run `/cache-build`.

#### /use-cache says "no cached templates"
**Cause:** No build of this product type has been cached yet.
**Fix:** Complete a build of this product type first, then run `/cache-build` to save the artifacts.

#### Template doesn't fit my new niche
**Cause:** The cached template contains niche-specific details from the original build.
**Fix:** This is expected. During the review step, customize the voice, vocabulary, and examples for your new niche. The structural elements (section architecture, prompt framework, voice dimensions) should still be useful.

---

## What Gets Optimized (and What Doesn't)

### Optimized (routed to cheaper models)

| Phase | File | Task | Routed To | Why It's Safe |
|-------|------|------|-----------|---------------|
| Phase 7 | generate-content/SKILL.md | Content generation from prompt | Sonnet | Follows a detailed prompt; no creative decisions needed |
| Phase 9 | product-qa/SKILL.md | QA scanning for issues | Sonnet | Pattern-matching against a checklist |
| Phase 1 | product-idea/SKILL.md | Domain research | Sonnet | Information gathering, not creative strategy |
| Phase 3 | expert-profile/SKILL.md | Research subagents | Sonnet | Background research only; the profile design stays on Opus |
| Phase 8 | design-product/SKILL.md | Homepage structure | Sonnet | Template-following layout work |
| Phase 2 | build-database/SKILL.md | Entry seeding | Haiku | Repetitive data entry with no judgment calls |
| Various | Script generation tasks | Utility scripts | Haiku | Mechanical code generation from specs |

### Preserved on Opus (quality-critical)

| Phase | File | Task | Why It Stays on Opus |
|-------|------|------|----------------------|
| Phase 3 | expert-profile/SKILL.md | Expert persona design | Defines the voice and authority of all generated content |
| Phase 4 | content-blueprint/SKILL.md | Content blueprint architecture | Determines the structure and depth of every page |
| Phase 5 | write-prompt/SKILL.md | Prompt assembly and testing | The prompt IS the product — quality here cascades everywhere |
| All | build-product/SKILL.md | Orchestrator | Manages phase flow, decisions, and error recovery |
| All | User-facing conversations | Approval gates, menus, Q&A | Direct interaction with the user must be highest quality |
