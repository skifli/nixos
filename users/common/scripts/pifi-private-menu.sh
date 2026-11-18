#!/usr/bin/env bash
set -euo pipefail

FONT="${FONT_MONOSPACE:-JetBrainsMono Nerd Font}"
FONT_SIZE="${FONT_SIZE_APPLICATIONS:-11}"
TERMINAL="${1:-${TERMINAL:-ghostty}}"
OPTIONS='Open private vault
Close private vault'
PROMPT='Pifi private vault: '
MAX_LEN=$(printf '%s\n' "$OPTIONS" | wc -L)
WIDTH=$(( ${#PROMPT} + MAX_LEN + 4 ))

choice="$(printf '%s\n' "$OPTIONS" | fuzzel --dmenu \
  --font="$FONT:size=$FONT_SIZE" \
  --prompt="$PROMPT" \
  --background-color=1e1e2eff \
  --text-color=cdd6f4ff \
  --input-color=cdd6f4ff \
  --selection-color=585b70ff \
  --selection-text-color=cdd6f4ff \
  --width="$WIDTH" \
  --lines=2 \
  --horizontal-pad=12 \
  --border-radius=10)"

case "$choice" in
  'Open private vault')
    exec floating-term.sh -w 55% -h 35% "$TERMINAL" -e pifi-private-open
    ;;
  'Close private vault')
    exec floating-term.sh -w 55% -h 35% "$TERMINAL" -e pifi-private-close
    ;;
esac
