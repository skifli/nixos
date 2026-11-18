#!/usr/bin/env bash
# Wayle pomodoro module - outputs current state for polling
# State file: ~/.local/state/pomodoro/state
# Actions: left-click = start/pause, right-click = skip, middle-click = reset

set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/pomodoro"
STATE_FILE="$STATE_DIR/state"
mkdir -p "$STATE_DIR"

# Read current state
if [[ -f "$STATE_FILE" ]]; then
    source "$STATE_FILE"
else
    PHASE="idle"      # idle, focus, break
    REMAINING=0
    ROUND=0
    START_TIME=0
    PAUSED=0
    TOTAL_DURATION=0
fi

# Handle actions from wayle clicks
ACTION="${1:-}"
case "$ACTION" in
    start-pause)
        if [[ "$PHASE" == "idle" ]]; then
            PHASE="focus"
            ROUND=$((ROUND + 1))
            REMAINING=1500  # 25 min
            TOTAL_DURATION=1500
            START_TIME=$(date +%s)
            PAUSED=0
            notify-send -e -a "pomodoro" -i "$HOME/.local/share/misc/Anki-icon.svg" -u low "Focus started" "Round $ROUND: 25 minutes. Notifications muted."
            wayle notify dnd 2>/dev/null || true
        elif [[ "$PHASE" == "focus" || "$PHASE" == "break" ]]; then
            if [[ "$PAUSED" == "1" ]]; then
                # Resume
                PAUSED=0
                START_TIME=$(date +%s)
            else
                # Pause
                PAUSED=1
                # Calculate remaining from elapsed
                ELAPSED=$(( $(date +%s) - START_TIME ))
                REMAINING=$(( REMAINING - ELAPSED ))
            fi
        fi
        ;;
    skip)
        if [[ "$PHASE" == "focus" ]]; then
            # Skip to break
            PHASE="break"
            REMAINING=300  # 5 min
            TOTAL_DURATION=300
            START_TIME=$(date +%s)
            PAUSED=0
            wayle notify dnd 2>/dev/null || true
            notify-send -e -a "pomodoro" -i "$HOME/.local/share/misc/Anki-icon.svg" -u normal "Break started" "5 minutes break. Notifications unmuted."
        elif [[ "$PHASE" == "break" ]]; then
            # Skip break, go to idle
            PHASE="idle"
            REMAINING=0
            ROUND=0
            notify-send -e -a "pomodoro" -i "$HOME/.local/share/misc/Anki-icon.svg" -u low "Pomodoro ended" "Session complete."
        fi
        ;;
    reset)
        PHASE="idle"
        REMAINING=0
        ROUND=0
        START_TIME=0
        PAUSED=0
        wayle notify dnd 2>/dev/null || true
        notify-send -e -a "pomodoro" -i "$HOME/.local/share/misc/Anki-icon.svg" -u low "Pomodoro reset" "Ready for new session."
        ;;
esac

# Update remaining time if running
if [[ "$PHASE" == "focus" || "$PHASE" == "break" ]] && [[ "$PAUSED" == "0" ]]; then
    ELAPSED=$(( $(date +%s) - START_TIME ))
    REMAINING=$(( TOTAL_DURATION - ELAPSED ))
    if [[ $REMAINING -le 0 ]]; then
        REMAINING=0
        if [[ "$PHASE" == "focus" ]]; then
            # Focus complete -> break
            PHASE="break"
            REMAINING=300
            TOTAL_DURATION=300
            START_TIME=$(date +%s)
            wayle notify dnd 2>/dev/null || true
            notify-send -e -a "pomodoro" -i "$HOME/.local/share/misc/Anki-icon.svg" -u critical -t 0 "Focus complete" "Round $ROUND finished. Time for a 5-minute break."
        else
            # Break complete -> next focus or idle
            if [[ $ROUND -ge 4 ]]; then
                PHASE="idle"
                ROUND=0
                notify-send -e -a "pomodoro" -i "$HOME/.local/share/misc/Anki-icon.svg" -u critical -t 0 "Pomodoro complete" "4 rounds done! Take a long break."
            else
                PHASE="idle"
                notify-send -e -a "pomodoro" -i "$HOME/.local/share/misc/Anki-icon.svg" -u critical -t 0 "Break ended" "Ready for Round $((ROUND + 1))? Click to start."
            fi
        fi
    fi
fi

# Save state
cat > "$STATE_FILE" <<EOF
PHASE="$PHASE"
REMAINING=$REMAINING
ROUND=$ROUND
START_TIME=$START_TIME
PAUSED=$PAUSED
TOTAL_DURATION=$TOTAL_DURATION
EOF

# Output for wayle - compact: just emoji when idle, short when active
case "$PHASE" in
    idle)
        echo "🍅"
        ;;
    focus)
        MIN=$(( REMAINING / 60 ))
        SEC=$(( REMAINING % 60 ))
        if [[ $PAUSED -eq 1 ]]; then
            printf "⏸️ %d:%02d" "$MIN" "$SEC"
        else
            printf "🍅 %d:%02d" "$MIN" "$SEC"
        fi
        ;;
    break)
        MIN=$(( REMAINING / 60 ))
        SEC=$(( REMAINING % 60 ))
        printf "☕ %d:%02d" "$MIN" "$SEC"
        ;;
esac