---
name: cache-build
description: "Use after a completed build to cache its proven artifacts (expert profile, blueprint, generation prompt) for reuse on future builds of the same product type."
argument-hint: [project-slug]
---

## Context

After completing a build, the pipeline produces several proven artifacts — the expert
profile, content blueprint, generation prompt, test results, and QA report. These
artifacts are product-type-specific, not niche-specific. A recipe product always needs
the same page structure, similar voice patterns, and the same generation prompt shape
regardless of whether the recipes are for Hyrox athletes or vegans.

This skill extracts those artifacts and saves them to a template cache, organized by
product type. Future builds of the same product type can reuse these templates via
`/use-cache`, potentially skipping Phases 3-5 entirely.

**Template cache directory:** `rewyse-ai/.optimizer/template-cache/{product-type}/`
**Build output directory:** `rewyse-ai/output/{project-slug}/`

**Cross-references:**
- `/use-cache` — Apply cached templates to a new build
- `/optimize-status` — Dashboard includes template cache section
- `/optimize-help` — FAQ entries for caching system

---

## Step 1: Locate the Build

If `$ARGUMENTS` is provided, use it as the project slug.

If no arguments provided, scan `rewyse-ai/output/` for project directories:

1. List all subdirectories in `rewyse-ai/output/`
2. For each, check if `product-idea.md` exists (minimum viable build)
3. Present the list:

```
Found {N} builds in rewyse-ai/output/:

1. {slug-1} — {product type from product-idea.md}
2. {slug-2} — {product type from product-idea.md}
...

Which build do you want to cache? (Enter number or slug)
```

Wait for the user's selection.

### Validate Build Completeness

Once a build is selected, verify it has reached at least Phase 7 (content generated):

**Required files (must exist):**
- `rewyse-ai/output/{slug}/product-idea.md`
- `rewyse-ai/output/{slug}/expert-profile.md`
- `rewyse-ai/output/{slug}/content-blueprint.md`
- `rewyse-ai/output/{slug}/generation-prompt.md`

**Optional files (cached if present):**
- `rewyse-ai/output/{slug}/test-results.md`
- `rewyse-ai/output/{slug}/qa-report.md`

If any required file is missing:

> "Build `{slug}` is incomplete — missing {file}. The template cache requires at
> least Phase 7 (content generated) to be completed. Finish the build first, then
> re-run `/cache-build {slug}`."

---

## Step 2: Extract Reusable Artifacts

Read `rewyse-ai/output/{slug}/product-idea.md` to extract:
- **Product type** (e.g., "recipe", "checklist", "guide", "template", "swipe-file")
- **Niche** (e.g., "Hyrox performance nutrition")
- **Entry count** (number of entries/pages in the product)

Then read each artifact file:

1. **Expert Profile** — Read `expert-profile.md`. This contains the voice, tone,
   vocabulary, perspective, and knowledge boundaries. The structural elements
   (section headings, voice dimensions, vocabulary categories) are reusable.
   The specific content (niche vocabulary, domain expertise) will be customized.

2. **Content Blueprint** — Read `content-blueprint.md`. This contains the page
   structure: section names, word counts, formatting rules, variable mappings.
   The structural skeleton is highly reusable across niches of the same product type.

3. **Generation Prompt** — Read `generation-prompt.md`. This is the assembled
   prompt that combines expert profile + blueprint + variables. The prompt
   architecture is reusable; the specific examples and niche references will
   be customized.

4. **Test Results** (if exists) — Read `test-results.md`. This provides evidence
   that the prompt passed the quality gate. Useful as a reference for what
   "good" looks like.

5. **QA Report** (if exists) — Read `qa-report.md`. This provides the quality
   baseline: what issues were found, severity distribution. Useful for knowing
   what to watch for on future builds.

---

## Step 3: Check for Existing Cache

Determine the product type from the product-idea.md file. Normalize it to lowercase
kebab-case (e.g., "Recipe" -> "recipe", "Swipe File" -> "swipe-file").

Check if `rewyse-ai/.optimizer/template-cache/{product-type}/cache-meta.json` exists.

If it exists, read it and present:

> "A template cache already exists for **{product_type}** products (from
> `{source_build}`, cached on {cached_at}).
>
> Replace it with this build's artifacts? (Yes/No)"

Wait for user response:
- **Yes**: Proceed to Step 4 (overwrite)
- **No**: Exit without changes

If no cache exists, proceed directly to Step 4.

---

## Step 4: Save to Template Cache

Create the directory `rewyse-ai/.optimizer/template-cache/{product-type}/` if it
does not exist.

Save the following files:

### 4a. Expert Profile Template

Write `expert-profile-template.md`:
- Copy the full content of `expert-profile.md`
- Add a header comment at the top:

```
<!-- TEMPLATE: Expert profile for {product_type} products.
     Source build: {slug} | Cached: {date}
     Customize voice, tone, and vocabulary for your specific niche. -->
```

### 4b. Blueprint Template

Write `blueprint-template.md`:
- Copy the full content of `content-blueprint.md`
- Add a header comment at the top:

```
<!-- TEMPLATE: Content blueprint for {product_type} products.
     Source build: {slug} | Cached: {date}
     Adjust sections, word counts, and formatting for your niche. -->
```

### 4c. Prompt Template

Write `prompt-template.md`:
- Copy the full content of `generation-prompt.md`
- Add a header comment at the top:

```
<!-- TEMPLATE: Generation prompt for {product_type} products.
     Source build: {slug} | Cached: {date}
     Review variable mapping and niche-specific examples. -->
```

### 4d. QA Baseline

If `qa-report.md` exists, write `qa-baseline.md`:
- Copy the full content of `qa-report.md`
- Add a header comment at the top:

```
<!-- BASELINE: QA results from {slug} build.
     Use as reference for common issues in {product_type} products. -->
```

### 4e. Cache Metadata

Write `cache-meta.json`:

```json
{
  "product_type": "{product-type}",
  "source_build": "{slug}",
  "cached_at": "{YYYY-MM-DD}",
  "phases_cached": ["expert-profile", "content-blueprint", "generation-prompt"],
  "has_qa_baseline": true|false,
  "has_test_results": true|false,
  "qa_score": {"critical": N, "warning": N, "info": N},
  "niche": "{niche from product-idea.md}",
  "entry_count": N,
  "times_used": 0
}
```

**Notes on `qa_score`:**
- Parse the QA report summary for issue counts by severity
- If no QA report exists, set `qa_score` to `null`

**Notes on `phases_cached`:**
- Always includes `"expert-profile"`, `"content-blueprint"`, `"generation-prompt"`
- These are the three phases that can be accelerated by reuse

---

## Step 5: Present Summary

After all files are saved, present:

```
Build cached successfully!

Product type: {type}
Source build: {slug}
Niche: {niche}
Entry count: {N}

Templates saved:
- Expert profile template ({word count} words)
- Content blueprint template ({section count} sections)
- Generation prompt template ({word count} words)
{- QA baseline ({critical} critical, {warning} warnings, {info} info) — if exists}

Cache location: rewyse-ai/.optimizer/template-cache/{product-type}/

Next time you build a {type} product, run /use-cache to start from
these proven templates — potentially skipping Phases 3-5 entirely.
```

---

## Notes

- **Templates are structural, not content-specific.** A recipe template works for
  Hyrox recipes or vegan recipes. The page structure, voice dimensions, and prompt
  architecture are the same. Only the niche-specific details change.
- **One cache per product type.** If the user caches a second build of the same type,
  the old cache is replaced (after confirmation). This keeps things simple and ensures
  the cache always reflects the latest proven build.
- **The cache only stores files, not Notion state.** Templates are markdown files,
  not database snapshots. They accelerate the SKILL.md phases, not the Notion API work.
- **QA baseline is informational.** It tells the user "last time we built this type,
  QA found these patterns." It does not auto-configure QA rules.
- **Minimum Phase 7.** We require content generation to be complete because that proves
  the expert profile, blueprint, and prompt actually work together. Caching untested
  artifacts would defeat the purpose.
