# Optimizer Reference

Complete routing rules, operation catalog, batch configurations, and optimization patterns
for the Rewyse AI Claude Code Optimizer.

---

## Section 1: Three-Tier Model Routing

Every subagent call in the Rewyse AI pipeline falls into one of three complexity tiers.
The optimizer assigns each operation to the cheapest model that maintains quality.

### Haiku Tier (complexity < 0.3) — $0.0002/call

Mechanical operations that follow exact templates with zero creative judgment.
The subagent receives structured input and produces structured output using
a fixed pattern. A rules engine could do this work — the LLM is just convenient.

**Characteristics:**
- Input is fully specified (JSON, lists, property maps)
- Output is deterministic or near-deterministic
- No language quality requirements beyond basic correctness
- Failure is binary (works or doesn't) — no quality spectrum

**Operations that qualify:**
- Node.js script generation for Notion database creation (property mapping)
- Notion API script execution and error handling
- Icon/emoji assignment to pages from a predefined mapping
- Entry seeding from a user-provided list (Option A in build-database)
- Distribution counting scripts (how many entries per category)
- Simple data formatting and restructuring

### Sonnet Tier (complexity 0.3-0.7) — $0.003/call

Template-following operations that need real language ability but follow a clear
pattern. The subagent has an explicit prompt template, reference materials,
and structured output format. Quality varies, but the "good enough" bar is
achievable without deep reasoning.

**Characteristics:**
- Input includes a prompt template or checklist to follow
- Output requires natural language quality (coherent, on-topic, well-structured)
- Has a reference to follow (expert profile, blueprint, generation prompt)
- Quality exists on a spectrum but the template constrains the range

**Operations that qualify:**
- Content generation from a parameterized prompt (Phase 6 and 7)
- QA scanning against a defined checklist (Phase 9)
- Domain research — web search + summarize findings (Phase 1 and 3)
- Homepage structure creation and sub-page organization (Phase 8)
- Filtered view creation following filter DSL (Phase 8)
- Batch entry population with AI-generated data (Phase 2, Option B)
- Market research for product expansion (Phase 10)

### Opus Tier (complexity > 0.7) — $0.015/call

Operations requiring creative reasoning, architectural thinking, or nuanced
judgment. These produce outputs where quality differences are immediately
visible and directly impact the final product. No template can fully
constrain the work — the model must make judgment calls.

**Characteristics:**
- Output quality is the primary value of the entire pipeline phase
- Requires synthesizing multiple inputs into something novel
- No single "correct" answer — quality depends on taste and expertise
- Downstream phases amplify errors (bad persona = bad content x100 pages)

**Operations that MUST stay on Opus:**
- Expert profile persona design — voice, tone, vocabulary, perspective (Phase 3)
- Content blueprint section architecture — structure, flow, word counts (Phase 4)
- Prompt assembly and test validation (Phase 5)
- Build-product orchestrator — all user-facing interactions (Phase 0)
- Test content review and root cause diagnosis (Phase 6, main agent)
- Any approval gate or user-facing conversation

**Important:** These are main agent operations, not subagents. They run on the
parent model (Opus) by default and should never be routed. The optimizer's
job is to route SUBAGENT calls, not to change the parent model.

---

## Section 2: Operation Catalog

Complete inventory of every subagent call in the Rewyse AI pipeline. This is the
source of truth for the optimizer's scan in Step 2.

| Phase | File | Operation | Subagent Pattern | Current Model | Recommended | Complexity | Notes |
|-------|------|-----------|-----------------|---------------|-------------|------------|-------|
| 1 | product-idea/SKILL.md | Domain research | "Use a subagent (Agent tool, model: sonnet)" | Sonnet | Sonnet (keep) | 0.4 | Already optimally routed. Web search + summarize. |
| 2 | build-database/SKILL.md | Entry seeding — user list (Option A) | Batch creation script, not a subagent | N/A | N/A | 0.1 | This is a script, not a subagent. No model routing needed. |
| 2 | build-database/SKILL.md | Entry seeding — AI-generated (Option B) | "use a subagent (Agent tool, model: sonnet)" | Sonnet | Sonnet (keep) | 0.5 | Needs language quality for realistic entry data. |
| 3 | expert-profile/SKILL.md | Domain research | "Use a subagent (Agent tool, model: sonnet)" | Sonnet | Sonnet (keep) | 0.4 | Already optimally routed. Web search + summarize. |
| 3 | expert-profile/SKILL.md | Persona design | Main agent (no subagent) | Opus (parent) | Opus (keep) | 0.9 | Quality-critical. DO NOT route. |
| 4 | content-blueprint/SKILL.md | Section architecture | Main agent (no subagent) | Opus (parent) | Opus (keep) | 0.8 | Quality-critical. No subagents to route. |
| 5 | write-prompt/SKILL.md | Prompt assembly | Main agent (no subagent) | Opus (parent) | Opus (keep) | 0.9 | Quality-critical. No subagents to route. |
| 6 | test-content/SKILL.md | Sample generation (2-3 pages) | "launch a subagent (Agent tool, model: sonnet)" | Sonnet | Sonnet (keep) | 0.5 | Already optimally routed. Small batch, template-following. |
| 7 | generate-content/SKILL.md | Content generation (batches) | "Agent tool, model: sonnet, run_in_background: true" | Sonnet | Sonnet (keep) | 0.5 | Already optimally routed. Biggest cost center — batch optimization has more impact here. |
| 8 | design-product/SKILL.md | Filtered view creation (Step 4b) | "Deploy parallel agents (up to 8)" | Opus (default) | Sonnet | 0.4 | **Not routed.** Agents follow a clear filter DSL pattern. Should be Sonnet. |
| 8 | design-product/SKILL.md | Content copy script (page mode) | Script execution, not a subagent | N/A | N/A | 0.1 | Node.js script — no model routing. |
| 8 | design-product/SKILL.md | Icon assignment script | Script execution, not a subagent | N/A | N/A | 0.1 | Node.js script — no model routing. |
| 9 | product-qa/SKILL.md | QA scanning (batches) | "model: sonnet, run_in_background: true" | Sonnet | Sonnet (keep) | 0.4 | Already optimally routed. Checklist-based scanning. |
| 9 | product-qa/SKILL.md | Targeted regeneration | "batches of 3-5 with subagents" | Opus (default) | Sonnet | 0.5 | **Not routed.** Follows the same pattern as generate-content. Should be Sonnet. |
| 10 | product-expand/SKILL.md | Market research | "Launch a subagent (Agent tool, model: sonnet)" | Sonnet | Sonnet (keep) | 0.4 | Already optimally routed. Web search + summarize. |

### Summary by Routing Action

**Already optimal (no change needed): 8 operations**
- product-idea domain research (Sonnet)
- build-database AI entry seeding (Sonnet)
- expert-profile domain research (Sonnet)
- test-content sample generation (Sonnet)
- generate-content batch generation (Sonnet)
- product-qa QA scanning (Sonnet)
- product-expand market research (Sonnet)

**Needs routing (default Opus -> recommended model): 2 operations**
- design-product filtered view agents (Opus default -> Sonnet)
- product-qa targeted regeneration agents (Opus default -> Sonnet)

**Not subagent operations (no routing applies): 3 operations**
- build-database entry seeding from list (Node.js script)
- design-product content copy script (Node.js script)
- design-product icon assignment script (Node.js script)

**Quality-critical main agent work (must stay Opus): 4 operations**
- expert-profile persona design
- content-blueprint section architecture
- write-prompt prompt assembly
- build-product orchestrator

---

## Section 3: Batch Size Optimization

Batch sizes control how many entries each subagent processes per wave. Smaller batches
are more reliable but create more orchestration overhead (each wave = one orchestrator
cycle parsing results, updating logs, and launching the next wave).

### Current vs. Optimized Batch Sizes

| Entry Count | Current Default | Optimized Batch Size | Waves Reduced | Reasoning |
|-------------|----------------|---------------------|---------------|-----------|
| 10-30 | 5-10 | 10-15 | ~50% fewer | Small products — one wave can handle most entries |
| 30-50 | 5-10 | 15 | ~40% fewer | Two waves instead of 3-5 |
| 50-100 | 5-10 | 15-20 | ~50% fewer | 3-5 waves instead of 5-10 |
| 100-200 | 5-10 | 20 | ~60% fewer | 5-10 waves instead of 10-20 |

### Why Fewer Waves Saves Money

Each wave incurs orchestration overhead:
1. The main agent (Opus) parses all subagent results
2. Updates content-log.json or qa-report
3. Reports progress to the user
4. Launches the next wave

At Opus pricing ($0.015/call), each orchestration cycle costs significantly more than
the token overhead of larger batches on Sonnet ($0.003/call).

**Formula:** `overhead_per_wave = opus_parse_cost + opus_log_update_cost`
Reducing from 10 waves to 5 saves ~5 orchestration cycles = meaningful Opus token savings.

### Constraints

- **Notion API rate limit:** ~3 requests/second (350ms between calls, 5 concurrent max)
- **Subagent context window:** Larger batches mean more entries in the subagent's context.
  Above 20 entries, context size starts impacting Sonnet's output quality.
- **Error blast radius:** If a subagent fails with a batch of 20, all 20 entries need
  re-processing. With batches of 10, only 10 are affected. Balance reliability vs. cost.

### Affected Files

- `generate-content/SKILL.md` — Step 2 batching rules (currently "batches of 5-10")
- `product-qa/SKILL.md` — Step 3 batch sizing (currently "5-10 per batch")

---

## Section 4: Context Reduction Patterns

Subagents often receive more context than they need. Trimming context reduces input
tokens, which reduces cost per call — especially meaningful for operations that run
many times (content generation, QA scanning).

### Pattern 1: QA Scanning — Trim Expert Profile

**File:** `product-qa/SKILL.md` (Step 3 subagent prompt)

**Current:** The QA subagent prompt instructs reading the full `expert-profile.md`,
which includes expertise definition, credentials, knowledge boundaries, and the
voice sample — often 500+ words.

**Optimized:** The QA subagent only needs the Voice & Tone section and Vocabulary
section for Check 2 (Expert Voice). It does not need the expert's background story,
credential justification, knowledge boundaries, or the sample paragraph.

**Implementation:** Add this instruction to the subagent prompt in Step 3:
> "From expert-profile.md, read only the **Voice & Tone** section and **Vocabulary**
> section. Skip the Expertise Definition, Perspective, Knowledge Boundaries, and
> Voice Sample sections — they are not needed for QA checks."

**Estimated savings:** ~40% reduction in expert-profile context per QA subagent call.
For a product with 50 entries across 5 QA batches, this saves ~2000 tokens per batch.

### Pattern 2: Test Content — Skip Redundant Upstream Files

**File:** `test-content/SKILL.md` (Step 3 subagent prompt)

**Current:** The subagent receives the full generation prompt, which already embeds
the expert profile and content blueprint. The SKILL.md also lists expert-profile.md
and content-blueprint.md as optional reads.

**Optimized:** The generation prompt IS the context. It already contains the system
context (from expert profile) and content structure (from blueprint). The subagent
does not need to separately read those upstream files.

**Implementation:** Add a note to Step 3:
> "Do not pass expert-profile.md or content-blueprint.md to the subagent separately.
> The generation prompt already incorporates both. Passing them again doubles the
> context without adding information."

**Estimated savings:** ~30% reduction in test-content subagent context. Small absolute
impact (only 2-3 subagents), but establishes the pattern.

### Pattern 3: Generate Content — Already Optimized

**File:** `generate-content/SKILL.md`

The generation prompt is already the sole context for subagents. No reduction needed.
The SKILL.md correctly passes only `generation-prompt.md`, entry JSON, and database
config to each subagent.

---

## Section 5: Skip-If-Done Patterns

Skip-if-done logic prevents re-processing work that was already completed in a
previous session or run. This is especially valuable for large products where
generation or QA might span multiple sessions.

### Pattern 1: Generate Content — Resume from Content Log

**File:** `generate-content/SKILL.md`

**Current state:** Already implemented. Step 1 reads `content-log.json` and filters
out entries with status `"published"` or `"generated"`. Only processes entries not
yet in the log, or entries with `status: "failed"`.

**Enhancement:** Add an explicit count report before the user confirmation prompt:
> "Resuming from previous session. Skipping {N} already-published entries.
> {M} remaining ({F} failed retries + {R} new entries)."

### Pattern 2: Product QA — Re-scan Only Changed Entries

**File:** `product-qa/SKILL.md`

**Current state:** No skip logic. Every QA run scans all published entries.

**Enhancement:** If `qa-report.md` already exists and the user is re-running QA:
1. Read the previous report
2. Extract entries that were marked CLEAN (no issues)
3. Check if those entries have been regenerated since the last QA scan
   (compare `content-log.json` timestamps to QA report date)
4. Offer the user a choice:
   > "Previous QA report found ({date}). {N} entries were clean, {M} had issues.
   > Options:
   > - **Full scan** — Re-scan all {total} entries
   > - **Delta scan** — Scan only {M} flagged entries + {K} entries regenerated since last scan
   > - **Flagged only** — Re-scan only the {M} entries that had issues"

**Implementation:** Add a check at the beginning of Step 2, before querying the database:
> "If `qa-report.md` exists in the state directory, read it and parse the entry-level
> results. Cross-reference with `content-log.json` to identify entries modified since
> the last scan. Present the delta scan option to the user before proceeding."

### Pattern 3: Design Product — Check for Existing Homepage

**File:** `design-product/SKILL.md`

**Current state:** No skip logic. Running design-product always creates a new homepage.

**Enhancement:** Before creating the homepage, check `design-config.json` for an
existing `homepage_id`. If found, verify the page still exists in Notion. If it does:
> "Found existing homepage ({title}). Options:
> - **Rebuild** — Delete and recreate from scratch
> - **Update** — Keep the page, update content and views only
> - **New** — Create a second homepage alongside the existing one"

This prevents accidental duplicate homepages and preserves existing shareable links.

---

## Section 6: Quality-Critical Operations (DO NOT OPTIMIZE)

These operations MUST stay on the parent model (Opus). They are the creative core
of the pipeline — the outputs that determine whether the final product is worth
$5 or $50.

### Expert Profile Persona Design (Phase 3)

**Why:** The expert persona defines WHO writes every page. A weaker model produces
generic personas ("friendly expert who loves helping people") instead of specific,
opinionated ones ("a sports nutritionist who believes periodization is more important
than calorie counting and pushes back on the IIFYM crowd").

**Impact of downgrade:** Generic voice -> generic content -> indistinguishable product.
The persona multiplies across every page. A 10% quality drop here means a 10% drop
across 100+ pages.

### Content Blueprint Architecture (Phase 4)

**Why:** Section design requires understanding how information flows, what the ICP
needs at each point in the page, and how sections interact. A weaker model produces
flat section lists instead of thoughtfully structured pages.

**Impact of downgrade:** Poor structure -> repetitive sections, missing flow, wrong
emphasis. The blueprint constrains every page, so structural errors are systemic.

### Prompt Assembly and Test Validation (Phase 5)

**Why:** Prompt engineering is meta-reasoning — building instructions that another
model follows. It requires understanding how language models interpret constraints
and how to phrase rules that produce consistent output across diverse inputs.

**Impact of downgrade:** Ambiguous prompts -> inconsistent output -> more QA failures
-> more regeneration -> higher total cost (false economy).

### Build Product Orchestrator (Phase 0)

**Why:** User-facing conversation. The orchestrator manages state, presents options,
handles edge cases, and guides the user through a 10-phase process. This requires
the highest conversational and reasoning ability.

---

## Section 7: Savings Estimation

### Model Routing Savings

Based on the operation catalog (Section 2):

| Category | Operations | Current Cost | Optimized Cost | Savings |
|----------|-----------|-------------|---------------|---------|
| Already on Sonnet | 7 | $0.003/call | $0.003/call | 0% |
| Opus default -> Sonnet | 2 | $0.015/call | $0.003/call | 80% per call |
| Quality-critical (keep Opus) | 4 | $0.015/call | $0.015/call | 0% |
| Scripts (no model) | 3 | N/A | N/A | N/A |

**Net routing savings:** Most subagent operations were already routed in this pipeline.
The 2 unrouted operations (design-product views, product-qa regeneration) save 80% each
when they fire, but they are not the highest-frequency operations.

### Batch Optimization Savings

For a typical 50-entry product:
- **Current:** ~10 waves of 5 entries = 10 orchestration cycles
- **Optimized:** ~4 waves of 12-15 entries = 4 orchestration cycles
- **Saved:** ~6 Opus orchestration cycles

Each orchestration cycle involves the main agent (Opus) reading results, updating logs,
and launching the next wave. Estimated saving: ~10-15% of total build cost.

### Context Reduction Savings

- QA scanning: ~40% context reduction per subagent call (5 calls for 50 entries)
- Test content: ~30% context reduction per subagent call (2-3 calls)
- Combined: ~5% of total build cost

### Skip-If-Done Savings

Savings depend on usage pattern:
- First build: 0% savings (nothing to skip)
- Resume after interruption: up to 80% savings on remaining phases
- Re-run QA after fixes: up to 70% savings (scan only changed entries)
- Re-run design after content changes: prevents duplicate homepage creation

### Combined Estimate

| Product Size | Estimated Total Savings | Primary Driver |
|-------------|------------------------|---------------|
| Small (10-30 entries) | 15-25% | Batch optimization, context reduction |
| Medium (30-80 entries) | 25-40% | Batch optimization, model routing on re-runs |
| Large (80-200 entries) | 35-50% | All four categories contribute significantly |

The larger the product, the more subagent calls occur, and the more each optimization
compounds. For a 200-entry product, batch optimization alone can save 10+ Opus
orchestration cycles.

---

## Section 8: Config Schema

The optimizer stores its state in `rewyse-ai/.optimizer/config.json`.

```json
{
  "version": 1,
  "applied_at": "2026-03-31T00:00:00Z",
  "optimizations": [
    {
      "file": "design-product/SKILL.md",
      "type": "model_routing",
      "operation": "filtered view creation agents (Step 4b)",
      "from": "opus (default)",
      "to": "sonnet",
      "estimated_savings": "80% per call"
    },
    {
      "file": "product-qa/SKILL.md",
      "type": "model_routing",
      "operation": "targeted regeneration subagents (Step 6)",
      "from": "opus (default)",
      "to": "sonnet",
      "estimated_savings": "80% per call"
    },
    {
      "file": "generate-content/SKILL.md",
      "type": "batch_optimization",
      "operation": "content generation batch sizing (Step 2)",
      "from": "5-10 per batch (static)",
      "to": "dynamic sizing (10-20 based on entry count)",
      "estimated_savings": "40-60% fewer waves"
    },
    {
      "file": "product-qa/SKILL.md",
      "type": "batch_optimization",
      "operation": "QA scanning batch sizing (Step 3)",
      "from": "5-10 per batch",
      "to": "dynamic sizing (10-20 based on entry count)",
      "estimated_savings": "40-60% fewer waves"
    },
    {
      "file": "product-qa/SKILL.md",
      "type": "context_reduction",
      "operation": "QA subagent expert profile context",
      "from": "full expert-profile.md",
      "to": "Voice & Tone + Vocabulary sections only",
      "estimated_savings": "~40% context reduction per QA subagent"
    },
    {
      "file": "test-content/SKILL.md",
      "type": "context_reduction",
      "operation": "test subagent redundant upstream files",
      "from": "generation prompt + optional expert-profile + content-blueprint",
      "to": "generation prompt only (already embeds both)",
      "estimated_savings": "~30% context reduction per test subagent"
    },
    {
      "file": "product-qa/SKILL.md",
      "type": "skip_if_done",
      "operation": "delta scan for re-runs",
      "from": "always scans all published entries",
      "to": "offers delta scan based on previous qa-report.md",
      "estimated_savings": "up to 70% on QA re-runs"
    },
    {
      "file": "generate-content/SKILL.md",
      "type": "skip_if_done",
      "operation": "resume reporting enhancement",
      "from": "silently skips completed entries",
      "to": "explicit skip count in progress report",
      "estimated_savings": "clarity improvement, no direct cost savings"
    }
  ],
  "estimated_total_savings": "30-50%",
  "quality_preserved": [
    "expert-profile (Phase 3 — persona design)",
    "content-blueprint (Phase 4 — section architecture)",
    "write-prompt (Phase 5 — prompt engineering)",
    "build-product (Phase 0 — orchestrator)"
  ]
}
```

### Field Definitions

| Field | Type | Description |
|-------|------|-------------|
| `version` | number | Increments on each optimization run. 0 = unoptimized. |
| `applied_at` | ISO-8601 string | Timestamp of the most recent optimization. |
| `optimizations` | array | Every change applied, with before/after states. |
| `optimizations[].file` | string | Relative path from `rewyse-ai/` to the modified file. |
| `optimizations[].type` | enum | One of: `model_routing`, `batch_optimization`, `context_reduction`, `skip_if_done`. |
| `optimizations[].operation` | string | Human-readable description of the specific operation. |
| `optimizations[].from` | string | Original state before optimization. |
| `optimizations[].to` | string | New state after optimization. |
| `optimizations[].estimated_savings` | string | Estimated cost or efficiency improvement. |
| `estimated_total_savings` | string | Overall estimated savings range for a full build. |
| `quality_preserved` | array | Phases explicitly excluded from optimization. |
