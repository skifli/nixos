#!/usr/bin/env bash
# Usage: find-or-make.sh "app_id" "affinity.exe" "affinity-v3"

KEY="$1"
VAL="$2"
CMD="$3"

WINDOWS=$(niri msg --json windows 2>/dev/null)
FOUND=$(echo "$WINDOWS" | jq -r ".[] | select(.$KEY != null) | select(.$KEY | ascii_downcase | contains(\"${VAL,,}\"))")

if [ -n "$FOUND" ]; then
    IS_FOCUSED=$(echo "$FOUND" | jq -r 'select(.is_focused == true)')
    if [ -n "$IS_FOCUSED" ]; then
        niri msg action focus-window-previous
    else
        WIN_ID=$(echo "$FOUND" | jq -r '.id' | head -n 1)
        niri msg action focus-window --id "$WIN_ID"
    fi
else
    eval "$CMD &"
fi