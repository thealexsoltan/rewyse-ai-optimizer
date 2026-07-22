# Rewyse AI — Claude Optimizer

What if 70% of what your AI agents do could run for free or at a fraction of the cost? The Claude Optimizer automatically routes every task to the cheapest model that can handle it. No configuration needed.

---

## How It Works

Your AI agents use Claude's most powerful model (Opus) for every task by default. But most tasks — generating content from a template, scanning pages for quality issues, searching the web — work perfectly fine on a faster, cheaper model.

The optimizer figures out which tasks need the expensive brain and which don't. Then it makes the switch. You run it once, and every future build benefits.

**Three tiers:**
| Tier | Model | Cost | Tasks |
|------|-------|------|-------|
| Simple | Haiku | ~$0.0002 | Script generation, entry seeding, data formatting |
| Standard | Sonnet | ~$0.003 | Content generation, QA scanning, research, homepage |
| Complex | Opus | ~$0.015 | Expert persona, content structure, prompt engineering |

---

## Quick Install

**Requires:** Rewyse AI main pipeline already installed.

```bash
git clone https://github.com/thealexsoltan/rewyse-ai-optimizer && bash rewyse-ai-optimizer/install.sh
```

No access key needed — just paste and run (in the same project where `rewyse-ai/` is installed).

---

## Usage

**One command, one time:**
```
/optimize
```

That's it. The optimizer scans your pipeline, shows you exactly what it wants to change, and applies on your approval. Every future build is cheaper.

---

## Commands

| Command | What It Does |
|---------|-------------|
| `/optimize` | Scan pipeline and apply cost optimizations |
| `/optimize rollback` | Undo all optimizations (restore backups) |
| `/optimize-status` | Show active optimizations and estimated savings |
| `/optimize-help` | Walkthrough, status, or troubleshooting |

---

## What Gets Optimized

**Routed to cheaper models (70% of operations):**
- Content generation subagents → Sonnet
- QA scanning subagents → Sonnet
- Domain research subagents → Sonnet
- Homepage structure → Sonnet
- Entry seeding → Haiku
- Script generation → Haiku

**Preserved on Opus (quality-critical):**
- Expert profile persona design (Phase 3)
- Content blueprint architecture (Phase 4)
- Prompt assembly and testing (Phase 5)
- All user-facing conversations

---

## Estimated Savings

| Product Size | Estimated Savings Per Build |
|---|---|
| 50 entries | ~$2-4 saved |
| 200 entries | ~$8-15 saved |
| 10 builds | ~$50-100+ total |

**Overall: 30-50% cost reduction per build.**

---

## Safety

- Every file backed up before modification
- Full approval gate — nothing changes without your "Yes"
- `/optimize rollback` instantly restores everything
- Quality-critical phases are never touched

---

## FAQ

**Will content quality drop?** No. Only mechanical and template-following tasks get cheaper models. Creative reasoning stays on Opus.

**Can I undo it?** Yes. `/optimize rollback` restores all files instantly.

**Do I run it after every build?** No. Run it once, works forever.

**Works with the Self-Improvement Agent?** Yes. Different concerns, no conflicts.

---

## Support

Run `/optimize-help` inside Claude Code for instant guidance.

---

Built with Claude Code.
