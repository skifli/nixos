#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="$HOME/Documents/custom-scripts"
mkdir -p "$STATE_DIR"
PID_FILE="$STATE_DIR/autoclicker.pid"

FONT="${FONT_MONOSPACE:-JetBrainsMono Nerd Font}"
FONT_SIZE="${FONT_SIZE_APPLICATIONS:-11}"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")

    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID" 2>/dev/null || true
        rm -f "$PID_FILE"

        notify-send -e -a "Auto-Clicker" -i "$HOME/.local/share/misc/niri-icon.svg" -u low "Auto-Clicker stopped" "Clicking loop terminated."

        exit 0
    fi

    rm -f "$PID_FILE"
fi

if ! pgrep -f ydotoold >/dev/null 2>&1; then
    # Disown and pipe to avoid blocking the script, and nohup to keep the daemon going br
    nohup ydotoold >/dev/null 2>&1 &

    sleep 0.2 # Just in case
fi

MODE_SELECTION=$(printf "1. Fast continuous (50ms)\n2. Interval anti-AFK (10s)\n3. Click burst (100 clicks)\n4. Custom interval" | fuzzel --dmenu \
    --font="$FONT:size=$FONT_SIZE" \
    --prompt="Auto-Clicker Mode: " \
    --background-color=1e1e2eff \
    --text-color=cdd6f4ff \
    --input-color=cdd6f4ff \
    --selection-color=585b70ff \
    --selection-text-color=cdd6f4ff \
    --width=40 \
    --lines=4 \
    --horizontal-pad=12 \
    --border-radius=10 || true)

[ -z "$MODE_SELECTION" ] && exit 0

DELAY="0.05"
COUNT=0

case "${MODE_SELECTION,,}" in
    *fast*)
        DELAY="0.05"
        ;;
    *interval*)
        DELAY="10"
        ;;
    *burst*)
        DELAY="0.05"
        COUNT=100
        ;;
    *custom*)
        DELAY_INPUT=$(fuzzel --dmenu \
            --font="$FONT:size=$FONT_SIZE" \
            --prompt="Delay in seconds (e.g., 0.1, 2): " \
            --background-color=1e1e2eff \
            --text-color=cdd6f4ff \
            --width=40 \
            --lines=0 \
            --horizontal-pad=12 \
            --border-radius=10 || true)
        [ -z "$DELAY_INPUT" ] && exit 0
        DELAY="$DELAY_INPUT"
        ;;
esac

(
    trap 'rm -f "$PID_FILE"' EXIT
    
    CLICKS=0
    
    while true; do
        ydotool click 0xC0
        CLICKS=$((CLICKS + 1))

        if [ "$COUNT" -gt 0 ] && [ "$CLICKS" -ge "$COUNT" ]; then
            notify-send -e -a "Auto-Clicker" -i "$HOME/.local/share/misc/niri-icon.svg" -u low "Burst complete" "Completed $COUNT clicks."
            break
        fi

        sleep "$DELAY"
    done
) &

CLICKER_PID=$!
echo "$CLICKER_PID" > "$PID_FILE"

notify-send -e -a "Auto-Clicker" -i "$HOME/.local/share/misc/niri-icon.svg" -u low "Auto-Clicker started" "Mode: $MODE_SELECTION\nPress hotkey again to stop."