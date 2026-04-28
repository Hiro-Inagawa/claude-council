#!/usr/bin/env bash
set -e

SKILL_SRC="$(cd "$(dirname "$0")/skills/claude-council" && pwd)"
SKILL_DST="$HOME/.claude/skills/claude-council"

if [ ! -d "$SKILL_SRC" ]; then
    echo "Error: skill source not found at $SKILL_SRC"
    exit 1
fi

if [ -d "$SKILL_DST" ]; then
    echo "Existing install found at $SKILL_DST — backing up to ${SKILL_DST}.bak"
    mv "$SKILL_DST" "${SKILL_DST}.bak"
fi

cp -r "$SKILL_SRC" "$SKILL_DST"
echo "Installed to $SKILL_DST"
echo ""
echo "Next: set your output folder in $SKILL_DST/SKILL.md"
echo "  OUTPUT_FOLDER: ~/claude-council"
