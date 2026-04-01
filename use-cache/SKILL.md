---
name: use-cache
description: "Use at the start of a new build to check for cached templates from a previous build of the same product type. Reuses proven expert profiles, blueprints, and generation prompts."
argument-hint: [product-type]
---

## Context

The template cache stores proven build artifacts — expert profiles, content blueprints,
and generation prompts — organized by product type. When starting a new build of a
product type that has been built before, these templates provide a massive head start.

Instead of designing an expert profile from scratch (Phase 3), architecting a blueprint
from nothing (Phase 4), and assembling a prompt through trial and error (Phase 5), the
user starts from a proven template and customizes it for their new niche.

**Template cache directory:** `rewyse-ai/.optimizer/template-cache/{product-type}/`
**New build output directory:** `rewyse-ai/output/{project-slug}/`

**Cross-references:**
- `/cache-build` — Cache a completed build's artifacts
- `/build-product` — The main pipeline that uses the applied templates
- `/optimize-status` — Dashboard includes template cache section

**Important:** Templates are STARTING POINTS, not auto-approved outputs. Every template
must be reviewed and customized by the user before proceeding.

---

## Step 1: Check for Cache

### Determine Product Type

If `$ARGUMENTS` is provided, use it as the product type.

If no arguments provided, check two sources:

1. **Current build in progress** — If there is a `product-idea.md` in the most recent
   `rewyse-ai/output/{slug}/` directory, read it and extract the product type. Ask
   the user to confirm:

   > "Found a build in progress: `{slug}` ({product_type}).
   > Check for cached templates for **{product_type}** products? (Yes/No)"

2. **Ask the user** — If no build is in progress:

   > "What product type are you planning to build? (e.g., recipe, checklist, guide,
   > template, swipe-file)"

### Look Up Cache

Normalize the product type to lowercase kebab-case, then check:
`rewyse-ai/.optimizer/template-cache/{product-type}/cache-meta.json`

If the file does not exist or the directory is missing:

> "No cached templates for **{product_type}** products. Build from scratch
> with `/build-product`.
>
> After your build is complete, run `/cache-build` to save the artifacts
> for future reuse."

**Exit.**

If the file exists, read it and proceed to Step 2.

---

## Step 2: Present Cache Options

Read all template files in the cache directory:
- `expert-profile-template.md`
- `blueprint-template.md`
- `prompt-template.md`
- `qa-baseline.md` (if exists)
- `cache-meta.json`

Present the cache summary:

```
Found cached templates for {product_type} products!

Source: {source_build} ({cached_at})
Niche: {niche}
Entry count: {entry_count}
{Times used: {times_used} — if times_used > 0}

Available templates:
1. Expert Profile — proven voice, tone, vocabulary for {product_type} products
2. Content Blueprint — tested page structure with {section_count} sections
3. Generation Prompt — QA-approved prompt
{4. QA Baseline — {critical} critical, {warning} warnings from last build — if exists}

How would you like to use them?
- **Full reuse** — Copy all 3 templates as starting points for Phases 3-5 (fastest)
- **Selective** — Pick which templates to reuse
- **Review first** — Show me each template before deciding
- **Skip** — Build from scratch
```

Wait for user response.

### Handle "Review first"

For each template, display its content with a summary header:

```
--- Expert Profile Template ---
Source: {source_build} | Cached: {cached_at}

{full content of expert-profile-template.md}

Use this template? (Yes / No / Edit first)
```

Repeat for blueprint and prompt templates. Collect the user's decisions, then
proceed to Step 3 with the approved templates.

### Handle "Selective"

> "Which templates would you like to reuse?
> 1. Expert Profile
> 2. Content Blueprint
> 3. Generation Prompt
>
> Enter numbers (e.g., 1,3) or 'all':"

Proceed to Step 3 with the selected templates.

### Handle "Skip"

> "Skipping template cache. Run `/build-product` to build from scratch."

**Exit.**

---

## Step 3: Apply Templates

### Determine Target Directory

If a build is already in progress (a `rewyse-ai/output/{slug}/` directory exists
with `product-idea.md`), use that directory.

If no build is in progress, ask the user:

> "What's the project slug for your new build? (e.g., vegan-recipes)"

Create `rewyse-ai/output/{new-slug}/` if it does not exist.

### Copy Templates

For each approved template:

1. **Expert Profile**
   - Copy `expert-profile-template.md` to `rewyse-ai/output/{new-slug}/expert-profile.md`
   - Remove the template header comment (the `<!-- TEMPLATE: ... -->` block)
   - Present it to the user:

   > "**Expert Profile** copied from the {source_build} build. Review it below and
   > tell me what to adjust for your new niche:
   >
   > {display key sections: Voice & Tone, Vocabulary, Perspective}
   >
   > What changes do you need for **{new niche or 'your niche'}**?
   > (Enter changes, or 'looks good' to keep as-is)"

   Wait for user response. If changes are requested, apply them to the file.

2. **Content Blueprint**
   - Copy `blueprint-template.md` to `rewyse-ai/output/{new-slug}/content-blueprint.md`
   - Remove the template header comment
   - Present it to the user:

   > "**Content Blueprint** copied. Here's the page structure:
   >
   > {display section names and word counts}
   >
   > Adjust sections for your new niche?
   > (Enter changes, or 'looks good' to keep as-is)"

   Wait for user response. If changes are requested, apply them.

3. **Generation Prompt**
   - Copy `prompt-template.md` to `rewyse-ai/output/{new-slug}/generation-prompt.md`
   - Remove the template header comment
   - Present it to the user:

   > "**Generation Prompt** copied. Review the variable mapping and examples.
   >
   > {display first 20-30 lines showing the prompt structure}
   >
   > This prompt was tested and QA-approved for the {source_build} build.
   > Adjust for your new niche?
   > (Enter changes, or 'looks good' to keep as-is)"

   Wait for user response. If changes are requested, apply them.

### Update Cache Usage Counter

After applying templates, update `cache-meta.json`:
- Increment `times_used` by 1

---

## Step 4: Present Savings Report

After all templates are applied and reviewed:

```
Templates applied!

Target: rewyse-ai/output/{new-slug}/
Templates reused: {list of applied templates}

Phases accelerated:
{- Phase 3 (Expert Profile): Starting from proven template instead of scratch — if applied}
{- Phase 4 (Content Blueprint): Starting from proven structure — if applied}
{- Phase 5 (Generation Prompt): Starting from QA-approved prompt — if applied}

Estimated time saved: {10-25 minutes, scaled by number of templates applied}
Estimated cost saved: {20-60%, scaled by number of templates applied}

{If QA baseline exists:}
QA heads-up from last build:
- {critical} critical issues, {warning} warnings, {info} info items
- Watch for these patterns in your new build

Run /build-product to continue. {Phases 3-5 will have pre-filled templates
for you to review and customize — if all 3 applied}.
```

---

## Notes

- **Templates are NEVER auto-applied blindly.** Every template is presented for
  review. The user must confirm or customize before proceeding. This is a hard
  requirement, not a suggestion.
- **Different niches benefit from the same template.** A recipe expert profile
  template has the right voice dimensions, vocabulary categories, and perspective
  framework whether the recipes are for athletes or home cooks. The user just
  swaps the domain-specific terms.
- **The generation prompt is the highest-value template.** It took a test cycle
  (Phase 6) to prove it works. Reusing it saves the most time and iteration.
- **If the user says "looks good" to everything, that's fine.** Some product
  types are so structurally similar across niches that minimal customization is
  needed. The review step exists for cases where it IS needed.
- **The QA baseline is advisory only.** It warns the user about patterns to
  watch for but does not change any QA scanning behavior.
- **Cache is organized by product type, not niche.** "recipe" is the key,
  not "hyrox-recipes". This is intentional — the reusable parts are structural.
