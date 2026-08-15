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

MODE_OPTIONS="1. Fast continuous (50ms)
2. Interval anti-AFK (10s)
3. Click burst (100 clicks)
4. Custom interval"
MODE_PROMPT="Auto-Clicker Mode: "
MAX_LEN=$(echo "$MODE_OPTIONS" | wc -L)
MODE_WIDTH=$(( ${#MODE_PROMPT} + MAX_LEN + 4 ))

MODE_SELECTION=$(echo "$MODE_OPTIONS" | fuzzel --dmenu \
    --font="$FONT:size=$FONT_SIZE" \
    --prompt="$MODE_PROMPT" \
    --background-color=1e1e2eff \
    --text-color=cdd6f4ff \
    --input-color=cdd6f4ff \
    --selection-color=585b70ff \
    --selection-text-color=cdd6f4ff \
    --width="$MODE_WIDTH" \
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
        INPUT_PROMPT="Delay in seconds (e.g., 0.1, 2): "
        INPUT_WIDTH=$(( ${#INPUT_PROMPT} + 15 ))

        DELAY_INPUT=$(fuzzel --dmenu \
            --font="$FONT:size=$FONT_SIZE" \
            --prompt="$INPUT_PROMPT" \
            --background-color=1e1e2eff \
            --text-color=cdd6f4ff \
            --width="$INPUT_WIDTH" \
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