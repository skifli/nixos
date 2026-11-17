#!/usr/bin/env bash
# Usage: find-or-make.sh "app_id" "app-match" "launch-command" [excluded-title-regex]
KEY="$1"
VAL="$2"
CMD="$3"
EXCLUDE_TITLE_REGEX="${4:-}"

WINDOWS=$(niri msg --json windows 2>/dev/null)
FOUND=$(echo "$WINDOWS" | jq -r --arg key "$KEY" --arg val "${VAL,,}" --arg exclude "$EXCLUDE_TITLE_REGEX" '
  .[]
  | select(.[$key] != null)
  | select(.[$key] | ascii_downcase | contains($val))
  | select(if $exclude == "" then true else ((.title // "") | test($exclude; "i") | not) end)
')

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
