#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="$HOME/Documents/custom-scripts"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/anki-pomodoro.state"

FOCUS_NOTIF_ID=0
BREAK_NOTIF_ID=0

get_dnd_status() {
    wayle notify status 2>/dev/null | grep -i "Do Not Disturb" | grep -i "enabled" || true
}

set_dnd() {
    local target="$1" # "on" or "off"
    local current
    current=$(get_dnd_status)

    if [ "$target" = "on" ] && [ -z "$current" ]; then
        wayle notify dnd 2>/dev/null || true
    elif [ "$target" = "off" ] && [ -n "$current" ]; then
        wayle notify dnd 2>/dev/null || true
    fi
}

dismiss_notif() {
    local id="$1"

    if [ "$id" -ne 0 ]; then
        notify-send -a "anki" -r "$id" -t 1000 "Dismissed" "" &>/dev/null || true
    fi
}

cleanup() {
    set_dnd "off"
    rm -f "$STATE_FILE"
    
    dismiss_notif "$FOCUS_NOTIF_ID"
    dismiss_notif "$BREAK_NOTIF_ID"
    
    stty echo cbreak
    printf "\e[?25h"
}
trap cleanup EXIT INT TERM

ROUND=1

while true; do
    clear
    echo "Anki Pomodoro session - round $ROUND"
    echo ""
    echo "Terminal controls:"
    echo "  [Space] : Pause / Resume"
    echo "  [q]     : Skip timer"
    echo ""
    echo "Press ENTER to start 25-minute focus session (or 'u' to undo, 'q' to quit)..."
    echo ""
    
    dismiss_notif "$BREAK_NOTIF_ID"
    BREAK_NOTIF_ID=0

    read -r -p "Start Focus #$ROUND > " CHOICE
    if [[ "$CHOICE" =~ ^[qQ] ]]; then
        echo "Exiting Pomodoro."
        break
    fi

    if [[ "$CHOICE" =~ ^[uU] ]]; then
        if [ "$ROUND" -gt 1 ]; then
            ROUND=$((ROUND - 1))
            clear
            echo "Focus session #$ROUND complete"
            echo ""
            echo "Press ENTER to start 5-minute break (or 'u' to undo mistake)..."
            echo ""
            read -r -p "Start Break #$ROUND > " BREAK_CHOICE

            dismiss_notif "$FOCUS_NOTIF_ID"
            FOCUS_NOTIF_ID=0

            if [[ "$BREAK_CHOICE" =~ ^[uU] ]]; then
                continue
            fi

            echo "break" > "$STATE_FILE"
            notify-send -e -a "anki" -i "/home/${USER}/.local/share/misc/Anki-icon.svg" -u normal "Break started" "5 minutes break time. Notifications unmuted."
            termdown 5m -T "Break #$ROUND" || true
            BREAK_NOTIF_ID=$(notify-send -p -e -a "anki" -i "/home/${USER}/.local/share/misc/Anki-icon.svg" -u critical -t 0 "Break ended" "Break finished. Ready for Round $((ROUND + 1))?")
        fi
        ROUND=$((ROUND + 1))
        continue
    fi

    # Focus Phase
    echo "focus" > "$STATE_FILE"
    set_dnd "on"
    notify-send -e -a "anki" -i "/home/${USER}/.local/share/misc/Anki-icon.svg" -u low "Focus session started" "Round $ROUND: 25 minutes focus. Notifications muted."

    termdown 25m -T "Focus #$ROUND" || true

    # Focus Complete
    set_dnd "off"

    FOCUS_NOTIF_ID=$(notify-send -p -e -a "anki" -i "/home/${USER}/.local/share/misc/Anki-icon.svg" -u critical -t 0 "Focus complete" "Round $ROUND finished. Time for a 5-minute break.")

    clear
    echo "Focus session #$ROUND complete"
    echo ""
    echo "Press ENTER to start 5-minute break (or 'u' to undo mistake)..."
    echo ""
    read -r -p "Start Break #$ROUND > " BREAK_CHOICE

    dismiss_notif "$FOCUS_NOTIF_ID"
    FOCUS_NOTIF_ID=0

    if [[ "$BREAK_CHOICE" =~ ^[uU] ]]; then
        continue
    fi

    # Break Phase
    echo "break" > "$STATE_FILE"
    notify-send -e -a "anki" -i "/home/${USER}/.local/share/misc/Anki-icon.svg" -u normal "Break started" "5 minutes break time. Notifications unmuted."

    termdown 5m -T "Break #$ROUND" || true

    BREAK_NOTIF_ID=$(notify-send -p -e -a "anki" -i "/home/${USER}/.local/share/misc/Anki-icon.svg" -u critical -t 0 "Break ended" "Break finished. Ready for Round $((ROUND + 1))?")

    ROUND=$((ROUND + 1))
done
