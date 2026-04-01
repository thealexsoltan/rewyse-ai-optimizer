#!/bin/bash
# Rewyse AI — Claude Code Optimizer Installer
# Adds /optimize, /optimize-status, and /optimize-help to your Claude Code project.
# Compatible with bash 3.2+ (macOS default)

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Rewyse AI — Claude Code Optimizer${NC}"
echo -e "${BLUE}  Installing add-on...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Detect project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
INSTALL_DIR="$PROJECT_ROOT/rewyse-ai-optimizer"

# Check that main Rewyse AI repo is installed
if [ ! -d "$PROJECT_ROOT/rewyse-ai" ]; then
  echo -e "${RED}[error]${NC} Rewyse AI main pipeline not found at $PROJECT_ROOT/rewyse-ai/"
  echo "        Install the main pipeline first, then run this installer."
  exit 1
fi
echo -e "${GREEN}[ok]${NC} Rewyse AI main pipeline found"

# Move to correct location if needed
if [ "$(basename "$SCRIPT_DIR")" = "rewyse-ai-optimizer" ]; then
  echo -e "${GREEN}[ok]${NC} Already installed at $SCRIPT_DIR"
else
  if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}[!]${NC} rewyse-ai-optimizer/ already exists at $INSTALL_DIR"
    echo "    Remove it first or install manually."
    exit 1
  fi
  mv "$SCRIPT_DIR" "$INSTALL_DIR"
  SCRIPT_DIR="$INSTALL_DIR"
  echo -e "${GREEN}[ok]${NC} Moved to $INSTALL_DIR"
fi

# Create .optimizer directory in main repo
mkdir -p "$PROJECT_ROOT/rewyse-ai/.optimizer/backups"
mkdir -p "$PROJECT_ROOT/rewyse-ai/.optimizer/template-cache"
echo -e "${GREEN}[ok]${NC} Created rewyse-ai/.optimizer/ directory"

# Register slash commands in .claude/skills/
SKILLS_DIR="$PROJECT_ROOT/.claude/skills"
SKILL_COUNT=0

create_skill() {
  local name="$1"
  local desc="$2"
  local arg_hint="$3"
  local body="$4"

  local skill_dir="$SKILLS_DIR/$name"
  local skill_file="$skill_dir/SKILL.md"

  if [ -f "$skill_file" ]; then
    return
  fi

  mkdir -p "$skill_dir"

  if [ -n "$arg_hint" ]; then
    printf "%s\n" "---" "name: $name" "description: $desc" "$arg_hint" "---" "" > "$skill_file"
  else
    printf "%s\n" "---" "name: $name" "description: $desc" "---" "" > "$skill_file"
  fi

  printf "%b\n" "$body" >> "$skill_file"
  SKILL_COUNT=$((SKILL_COUNT + 1))
}

create_skill "optimize" \
  "Scan the Rewyse AI pipeline and apply cost optimizations — route tasks to cheaper models, optimize batches, reduce context." \
  "argument-hint: [rollback]" \
  "Read and follow the full instructions in \`rewyse-ai-optimizer/optimize/SKILL.md\`.\n\nAlso read \`rewyse-ai-optimizer/optimize/reference.md\` for routing rules and optimization catalog."

create_skill "optimize-status" \
  "Show current optimization state, active changes, and estimated savings." \
  "" \
  "Read and follow the full instructions in \`rewyse-ai-optimizer/optimize-status/SKILL.md\`."

create_skill "optimize-help" \
  "Get help with the Claude Code Optimizer — walkthrough, status, or troubleshooting." \
  "argument-hint: [question]" \
  "Read and follow the full instructions in \`rewyse-ai-optimizer/optimize-help/SKILL.md\`.\n\nAlso read \`rewyse-ai-optimizer/optimize-help/reference.md\` for FAQ and troubleshooting."

create_skill "cache-build" \
  "Cache a completed build's proven artifacts (expert profile, blueprint, prompt) for reuse on future builds of the same product type." \
  "argument-hint: [project-slug]" \
  "Read and follow the full instructions in \`rewyse-ai-optimizer/cache-build/SKILL.md\`."

create_skill "use-cache" \
  "Check for cached templates from a previous build and apply them as starting points for a new build of the same product type." \
  "argument-hint: [product-type]" \
  "Read and follow the full instructions in \`rewyse-ai-optimizer/use-cache/SKILL.md\`."

if [ "$SKILL_COUNT" -gt 0 ]; then
  echo -e "${GREEN}[ok]${NC} Registered $SKILL_COUNT new slash commands in .claude/skills/"
else
  echo -e "${GREEN}[ok]${NC} All 5 slash commands already registered"
fi

# Add registration to root CLAUDE.md
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
  if grep -q "rewyse-ai-optimizer" "$CLAUDE_MD" 2>/dev/null; then
    echo -e "${GREEN}[ok]${NC} CLAUDE.md already has Optimizer registration"
  else
    cat >> "$CLAUDE_MD" << 'REGISTRATION'

---

### Rewyse AI — Claude Code Optimizer (`rewyse-ai-optimizer/`)

See `rewyse-ai-optimizer/CLAUDE.md` for full documentation.

**Commands:**
- `/optimize` — Scan pipeline and apply cost optimizations
- `/optimize rollback` — Undo all optimizations
- `/optimize-status` — Show active optimizations and savings
- `/optimize-help` — Walkthrough, status, and troubleshooting
- `/cache-build` — Cache a completed build's artifacts for future reuse
- `/use-cache` — Reuse cached templates when starting a new build
REGISTRATION
    echo -e "${GREEN}[ok]${NC} Added Optimizer registration to CLAUDE.md"
  fi
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Claude Code Optimizer installed!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  How to use:"
echo ""
echo "  1. Run /optimize to scan and apply optimizations"
echo "  2. Approve the plan"
echo "  3. Every future build is now 30-50% cheaper"
echo ""
echo "  Check savings:    /optimize-status"
echo "  Need help:        /optimize-help"
echo "  Cache a build:    /cache-build [slug]"
echo "  Reuse templates:  /use-cache [product-type]"
echo ""
