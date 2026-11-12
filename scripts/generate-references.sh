#!/usr/bin/env bash
set -euo pipefail

# Generate TerraMaster TOS skill reference files and templates from upstream:
#
#   terramaster-tos/tos-app-pkg-tools
#
# References are copied 1:1 (no renaming) so inter-chapter relative links keep
# working and weekly upstream diffs contain only real content changes:
#
#   - "TOS 7 Application Development Guide/01_Overview.md … 20_Appendix.md"
#       -> references/01_Overview.md … 20_Appendix.md
#   - "Developer/agent-api/README.md"    -> references/agent-api.md   (rename
#     needed: two README.md files cannot live in one flat directory)
#   - "TOSAppSelfTestingTool/README.md"  -> references/self-testing.md
#
# The upstream root README.md (table of contents) is intentionally NOT copied:
# its routing role here belongs to SKILL.md.
#
# Package templates are copied verbatim into assets/templates/ (code and
# configs need exact bytes; merging them into markdown would lose syntax):
#
#   TOS 7-template-deb-single -> assets/templates/deb-single
#   TOS 7-template-deb-dual   -> assets/templates/deb-dual
#   TOS 7-template-docker     -> assets/templates/docker
#
# Usage: ./scripts/generate-references.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_DIR="$REPO_DIR/skills/terramaster-tos-development-skills"
REFS_DIR="$SKILL_DIR/references"
TEMPLATES_DIR="$SKILL_DIR/assets/templates"
WORK_DIR=$(mktemp -d)

UPSTREAM_REPO="https://github.com/terramaster-tos/tos-app-pkg-tools.git"
GUIDE_DIR="TOS 7 Application Development Guide"

cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

# ── Sparse clone (only the documentation subtrees) ─────────────────────

echo "==> Sparse-cloning $UPSTREAM_REPO..."

git clone --depth 1 --filter=blob:none --sparse --quiet "$UPSTREAM_REPO" "$WORK_DIR/upstream"
git -C "$WORK_DIR/upstream" sparse-checkout set \
    "$GUIDE_DIR" \
    "Developer/agent-api" \
    "TOSAppSelfTestingTool" \
    "TOS 7-template-deb-single" \
    "TOS 7-template-deb-dual" \
    "TOS 7-template-docker"
echo "    Cloned."

# ── Collect version info ───────────────────────────────────────────────

UP_COMMIT=$(git -C "$WORK_DIR/upstream" rev-parse --short HEAD)
UP_DATE=$(git -C "$WORK_DIR/upstream" log -1 --format=%ci)

echo "==> Source version:"
echo "    tos-app-pkg-tools: $UP_COMMIT ($UP_DATE)"

# ── Copy chapters 1:1 ──────────────────────────────────────────────────

mkdir -p "$REFS_DIR"

echo ""
echo "==> Copying guide chapters (1:1, no renaming)..."

MISSING_SOURCES=0
CHAPTERS_COPIED=0
shopt -s nullglob

for i in $(seq -w 1 20); do
    # Quote the fixed part so spaces in $GUIDE_DIR survive; leave *.md
    # unquoted so the glob expands to the single chapter file.
    files=("$WORK_DIR/upstream/$GUIDE_DIR/${i}_"*.md)
    if [[ ${#files[@]} -eq 1 ]]; then
        cp "${files[0]}" "$REFS_DIR/"
        echo "  OK: $(basename "${files[0]}")"
        CHAPTERS_COPIED=$((CHAPTERS_COPIED + 1))
    else
        echo "  WARN: chapter $i not found upstream (matches: ${#files[@]}), skipping" >&2
        MISSING_SOURCES=$((MISSING_SOURCES + 1))
    fi
done
shopt -u nullglob

# ── Copy standalone docs (the two unavoidable renames) ─────────────────

echo ""
echo "==> Copying standalone documentation..."

copy_doc() {
    local src="$1" dst="$2" label="$3"
    if [[ -f "$src" ]]; then
        cp "$src" "$REFS_DIR/$dst"
        echo "  OK: $dst ($label)"
    else
        echo "  WARN: $label not found upstream, skipping" >&2
        MISSING_SOURCES=$((MISSING_SOURCES + 1))
    fi
}

copy_doc "$WORK_DIR/upstream/Developer/agent-api/README.md" \
    "agent-api.md" "Agent API"

copy_doc "$WORK_DIR/upstream/TOSAppSelfTestingTool/README.md" \
    "self-testing.md" "Self-Testing Tool"

# ── Copy package templates verbatim ────────────────────────────────────

echo ""
echo "==> Copying package templates..."

copy_template() {
    local src="$1" dst="$2"
    if [[ -d "$src" ]]; then
        rm -rf "$TEMPLATES_DIR/$dst"
        mkdir -p "$TEMPLATES_DIR/$dst"
        cp -R "$src/." "$TEMPLATES_DIR/$dst/"
        echo "  OK: templates/$dst ($(find "$TEMPLATES_DIR/$dst" -type f | wc -l | tr -d ' ') files)"
    else
        echo "  WARN: template $dst not found upstream, skipping" >&2
        MISSING_SOURCES=$((MISSING_SOURCES + 1))
    fi
}

copy_template "$WORK_DIR/upstream/TOS 7-template-deb-single" "deb-single"
copy_template "$WORK_DIR/upstream/TOS 7-template-deb-dual" "deb-dual"
copy_template "$WORK_DIR/upstream/TOS 7-template-docker" "docker"

# ── Write version metadata ─────────────────────────────────────────────

echo ""
echo "==> Writing metadata..."

cat > "$REFS_DIR/.source-version" <<EOF
source_repo='terramaster-tos/tos-app-pkg-tools'
source_commit='$UP_COMMIT'
source_date='$UP_DATE'
generated='$UP_DATE'
EOF

TOTAL_MD=$(find "$REFS_DIR" -name '*.md' | wc -l | tr -d ' ')
TOTAL_FILES=$(find "$SKILL_DIR" -type f -not -name '.DS_Store' | wc -l | tr -d ' ')
SKILL_SIZE=$(du -sh "$SKILL_DIR" | cut -f1 | sed 's/  */ /g')

echo ""
echo "==> Done! Generated $CHAPTERS_COPIED/20 chapters, $TOTAL_MD reference files."
echo "    Skill size: $SKILL_SIZE across $TOTAL_FILES files."
echo "    Output: $SKILL_DIR/"

if [[ $MISSING_SOURCES -gt 0 ]]; then
    echo "ERROR: $MISSING_SOURCES source file(s)/dir(s) missing upstream (renamed or removed)." >&2
    echo "Update the paths in this script, otherwise the affected references go stale." >&2
    exit 1
fi
