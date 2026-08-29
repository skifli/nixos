#!/usr/bin/env bash
set -euo pipefail

FONT="${FONT_MONOSPACE:-JetBrainsMono Nerd Font}"
FONT_SIZE="${FONT_SIZE_APPLICATIONS:-11}"

WINDOWS_JSON=$(niri msg -j windows 2>/dev/null || echo "[]")

if [ "$WINDOWS_JSON" = "[]" ] || [ -z "$WINDOWS_JSON" ]; then
    notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low "No windows" "No open windows found."
    exit 0
fi

FORMATTED_LIST=$(echo "$WINDOWS_JSON" | jq -r '
    .[] | 
    "\(.app_id // "Unknown") \u2014 \(.title // "Untitled") [WS: \(.workspace_id // "?")] (ID: \(.id))"
')

MAX_LINE_LEN=$(echo "$FORMATTED_LIST" | wc -L)
PADDING=4 
DYNAMIC_WIDTH=$(( MAX_LINE_LEN + PADDING ))

MIN_WIDTH=40
MAX_WIDTH=100

if [ "$DYNAMIC_WIDTH" -lt "$MIN_WIDTH" ]; then
    DYNAMIC_WIDTH=$MIN_WIDTH
elif [ "$DYNAMIC_WIDTH" -gt "$MAX_WIDTH" ]; then
    DYNAMIC_WIDTH=$MAX_WIDTH
fi

WINDOW_COUNT=$(echo "$FORMATTED_LIST" | wc -l) 

MIN_LINES=3
MAX_LINES=15
DYNAMIC_LINES=$WINDOW_COUNT

if [ "$DYNAMIC_LINES" -lt "$MIN_LINES" ]; then
    DYNAMIC_LINES=$MIN_LINES
elif [ "$DYNAMIC_LINES" -gt "$MAX_LINES" ]; then
    DYNAMIC_LINES=$MAX_LINES
fi

SELECTED=$(echo "$FORMATTED_LIST" | fuzzel --dmenu \
    --font="$FONT:size=$FONT_SIZE" \
    --prompt="Jump to Window: " \
    --background-color=1e1e2eff \
    --text-color=cdd6f4ff \
    --input-color=cdd6f4ff \
    --selection-color=585b70ff \
    --selection-text-color=cdd6f4ff \
    --width="$DYNAMIC_WIDTH" \
    --lines="$DYNAMIC_LINES" \
    --horizontal-pad=12 \
    --border-radius=10)

if [ -z "$SELECTED" ]; then
    exit 0
fi

WIN_ID=$(echo "$SELECTED" | sed -n 's/.*(ID: \([0-9]*\))/\1/p')

if [ -n "$WIN_ID" ]; then
    niri msg action focus-window --id "$WIN_ID"
fi
