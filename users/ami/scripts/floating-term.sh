#!/usr/bin/env bash
set -euo pipefail

TIMEOUT=200 # Roughly idk some amount of seconds... like 10s I guess? (200 * 0.05 = 10s)
TERM_CMD="${1:-ghostty}"
ID="floating-term-$(date +%s%N)"

case "$TERM_CMD" in
  ghostty)
    ghostty +new-window --title="$ID" &
    ;;
  *)
    "$TERM_CMD" --title="$ID" &
    ;;
esac

WINDOW_ID=""

for i in $(seq 1 $TIMEOUT); do
  WINDOW_ID=$(niri msg --json windows 2>/dev/null | jq -r ".[] | select(.title == \"$ID\") | .id" 2>/dev/null || true)
  if [ -n "$WINDOW_ID" ]; then break; fi
  sleep 0.05
done

if [ -z "$WINDOW_ID" ]; then
  notify-send -e -a nirius -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u critical -t 5000 "Error" "Timed out waiting for floating window $ID"
  exit 1
fi

niri msg action focus-window --id "$WINDOW_ID"

# Helper function to fetch current [width, height] array
get_size() {
  niri msg --json focused-window 2>/dev/null | jq -c ".layout.window_size"
}

OLD_SIZE=$(get_size)
OLD_W=$(echo "$OLD_SIZE" | jq '.[0]' 2>/dev/null)
OLD_H=$(echo "$OLD_SIZE" | jq '.[1]' 2>/dev/null)

niri msg action toggle-window-floating
niri msg action set-window-height 40%
niri msg action set-column-width 40%

# 5. Wait for both width and height to change (or size to stabilize)
LAST_SIZE=""

for i in $(seq 1 $TIMEOUT); do
  NEW_SIZE=$(get_size)
  NEW_W=$(echo "$NEW_SIZE" | jq '.[0]' 2>/dev/null || true)
  NEW_H=$(echo "$NEW_SIZE" | jq '.[1]' 2>/dev/null || true)

  if [ -n "$NEW_W" ] && [ -n "$NEW_H" ]; then
    # Both width and height updated
    if [ "$NEW_W" -ne "$OLD_W" ] && [ "$NEW_H" -ne "$OLD_H" ]; then
      break
    fi

    # Stabilization fallback
    if [ "$NEW_SIZE" != "$OLD_SIZE" ] && [ "$NEW_SIZE" = "$LAST_SIZE" ]; then
      break
    fi
  fi

  LAST_SIZE="$NEW_SIZE"
  sleep 0.05
done

niri msg action focus-window --id "$WINDOW_ID" # Just in case the window lost focus in the meantime
niri msg action center-window