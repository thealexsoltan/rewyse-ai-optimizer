# Rewyse AI — Claude Code Optimizer

A done-for-you optimization agent that routes 70% of your AI tasks to cheaper
models, optimizes batch sizes, reduces context, and adds smart skip logic.
Run it once, save 30-50% on every build.

## Skills

### optimize
**Slash command:** `/optimize`
**Triggers:** "optimize my agents", "reduce AI costs", "save tokens", "cheaper models",
"route to sonnet", "optimize token usage", "cost reduction", "optimize rollback"
**Description:** Scans the Rewyse AI pipeline, identifies which operations can run on
cheaper models, and applies optimizations with backups and approval gates.

### optimize-status
**Slash command:** `/optimize-status`
**Triggers:** "show optimization status", "what optimizations are active", "savings dashboard",
"how much am I saving", "optimizer status"
**Description:** Shows current optimization state, active changes, and estimated savings.

### optimize-help
**Slash command:** `/optimize-help`
**Triggers:** "how does the optimizer work", "will quality drop", "help with optimizer",
"troubleshoot optimization", "undo optimization"
**Description:** Support agent for the optimizer. Three modes:
Guide (walkthrough), Status (dashboard), Troubleshoot (fix issues).

### cache-build
**Slash command:** `/cache-build`
**Triggers:** "cache this build", "save build artifacts", "save templates from build",
"cache expert profile", "store build for reuse", "save proven templates"
**Description:** Caches a completed build's proven artifacts (expert profile, blueprint,
generation prompt) for reuse on future builds of the same product type. Requires at
least Phase 7 completed.

### use-cache
**Slash command:** `/use-cache`
**Triggers:** "reuse templates", "use cached build", "start from template",
"skip phases with cache", "use previous build templates", "check template cache"
**Description:** Checks for cached templates from a previous build of the same product
type and offers to apply them as starting points for Phases 3-5, with mandatory review.

## Prerequisites

- Rewyse AI main pipeline installed (`rewyse-ai/` directory)

## Getting Started

1. Run `/optimize` to scan and apply optimizations
2. Approve the plan
3. Every future build is now 30-50% cheaper
4. Run `/optimize-status` anytime to check savings
5. After a successful build, run `/cache-build` to save artifacts for reuse
6. Before a new build of the same type, run `/use-cache` to start from templates
