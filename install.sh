#!/usr/bin/env bash
set -euo pipefail

# Install/update the TerraMaster TOS 7 app development skill for AI coding assistants
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/artamonovtech/terramaster-tos-development-skills/main/install.sh | bash
#   # or
#   ./install.sh [--claude|--cursor|--windsurf|--copilot|--codex|--gemini|--opencode|--cline|--aider|--amp|--goose|--roo|--agents|--custom PATH]

REPO_URL="https://github.com/artamonovtech/terramaster-tos-development-skills.git"
SKILL_NAME="terramaster-tos-development-skills"
# The skill lives at skills/<name>/ inside the repository (vercel-labs/skills layout)
SKILL_SUBDIR="skills/$SKILL_NAME"
TARGET=""

print_help() {
    cat <<'EOF'
TerraMaster TOS App Development Skill Installer

Usage: install.sh [OPTIONS]

Options:
  --agents        Cross-agent standard (.agents/skills/terramaster-tos-development-skills)
  --claude        Claude Code (~/.claude/skills/terramaster-tos-development-skills)
  --cursor        Cursor (.cursor/skills/terramaster-tos-development-skills)
  --windsurf      Windsurf (.windsurf/skills/terramaster-tos-development-skills)
  --copilot       GitHub Copilot (.github/skills/terramaster-tos-development-skills)
  --codex         OpenAI Codex (.agents/skills/terramaster-tos-development-skills)
  --gemini        Gemini CLI (.gemini/skills/terramaster-tos-development-skills)
  --opencode      OpenCode (.opencode/skills/terramaster-tos-development-skills)
  --cline         Cline (.cline/skills/terramaster-tos-development-skills)
  --aider         Aider (.aider/skills/terramaster-tos-development-skills)
  --amp           Amp (.amp/skills/terramaster-tos-development-skills)
  --goose         Goose (.goose/skills/terramaster-tos-development-skills)
  --roo           Roo Code (.roo/skills/terramaster-tos-development-skills)
  --custom PATH   Custom path
  -h, --help      Show this help

Without options, installs to .agents/skills/terramaster-tos-development-skills (cross-agent standard).

To update, just run the install script again.
EOF
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        --agents)    TARGET=".agents/skills/$SKILL_NAME" ;;
        --claude)    TARGET="$HOME/.claude/skills/$SKILL_NAME" ;;
        --cursor)    TARGET=".cursor/skills/$SKILL_NAME" ;;
        --windsurf)  TARGET=".windsurf/skills/$SKILL_NAME" ;;
        --copilot)   TARGET=".github/skills/$SKILL_NAME" ;;
        --codex)     TARGET=".agents/skills/$SKILL_NAME" ;;
        --gemini)    TARGET=".gemini/skills/$SKILL_NAME" ;;
        --opencode)  TARGET=".opencode/skills/$SKILL_NAME" ;;
        --cline)     TARGET=".cline/skills/$SKILL_NAME" ;;
        --aider)     TARGET=".aider/skills/$SKILL_NAME" ;;
        --amp)       TARGET=".amp/skills/$SKILL_NAME" ;;
        --goose)     TARGET=".goose/skills/$SKILL_NAME" ;;
        --roo)       TARGET=".roo/skills/$SKILL_NAME" ;;
        --custom)    ;; # next arg will be the path
        --help|-h)   print_help ;;
        *)
            if [[ -z "$TARGET" ]]; then
                TARGET="$arg"
            else
                echo "Unknown option: $arg"
                exit 1
            fi
            ;;
    esac
done

# Default: cross-agent standard
if [[ -z "$TARGET" ]]; then
    TARGET=".agents/skills/$SKILL_NAME"
fi

# ── Target safety checks ───────────────────────────────────────────────
# The target directory is deleted (`rm -rf`) before every install, so refuse
# dangerous or ambiguous destinations before any destructive step.
if [[ "$TARGET" == "/" || "$TARGET" == "$HOME" || "$TARGET" == "$HOME/" ]]; then
    echo "ERROR: refusing to install to '$TARGET'." >&2
    exit 1
fi
if [[ "$TARGET" == *..* ]]; then
    echo "ERROR: refusing target with '..' path components: '$TARGET'." >&2
    exit 1
fi
if [[ -d "$TARGET" && -n "$(ls -A "$TARGET" 2>/dev/null)" && ! -f "$TARGET/SKILL.md" ]]; then
    echo "ERROR: '$TARGET' exists, is not empty, and contains no SKILL.md." >&2
    echo "    It does not look like a previous install of this skill, so it" >&2
    echo "    will NOT be deleted. Use an empty directory, an existing install" >&2
    echo "    of this skill, or a different --custom path." >&2
    exit 1
fi

echo "==> Installing TerraMaster TOS app development skill"
echo "    Target: $TARGET"

# Clone/update into a scratch dir, then copy the skill directory to the target.
# (The repo stores the skill under skills/<name>/, so a plain clone alone would
# leave SKILL.md one level too deep for agent skill directories.)
TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

echo "==> Cloning repository..."
git clone --quiet --depth 1 "$REPO_URL" "$TMP_DIR/repo"

if [[ ! -f "$TMP_DIR/repo/$SKILL_SUBDIR/SKILL.md" ]]; then
    echo "    ERROR: $SKILL_SUBDIR/SKILL.md not found in repository!"
    exit 1
fi

mkdir -p "$(dirname "$TARGET")"
rm -rf "$TARGET"
cp -R "$TMP_DIR/repo/$SKILL_SUBDIR" "$TARGET"

echo "==> Verifying..."
if [[ -f "$TARGET/SKILL.md" ]]; then
    REFS=$(find "$TARGET/references" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    echo "    SKILL.md: OK"
    echo "    References: $REFS files"
    echo "    Templates: $(find "$TARGET/assets/templates" -type f 2>/dev/null | wc -l | tr -d ' ') files"

    if [[ -f "$TARGET/references/.source-version" ]]; then
        # Parse the metadata file WITHOUT executing it: it is repo-owned
        # content and could be tampered with upstream — never `source` it.
        kv() { sed -n "s/^$1='\([^']*\)'$/\1/p" "$TARGET/references/.source-version" | head -n 1; }
        echo "    Source: $(kv source_repo) $(kv source_commit) ($(kv source_date))"
    fi
else
    echo "    ERROR: SKILL.md not found!"
    exit 1
fi

echo ""
echo "==> Done!"
echo ""
echo "Update later:  ./install.sh (run again with the same flags)"
