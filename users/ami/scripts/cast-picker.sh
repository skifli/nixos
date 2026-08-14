#!/usr/bin/env bash
ACTION="${1:-window}"

if [ "$ACTION" = "window" ]; then
    WIN_ID=$(niri msg --json pick-window 2>/dev/null | jq -r '.id // empty')
    if [ -n "$WIN_ID" ]; then
        niri msg action set-dynamic-cast-window --id "$WIN_ID"
        notify-send -e -a niri -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u low -t 2500 "Screencast target" "Window ID $WIN_ID set as cast target"
    fi
elif [ "$ACTION" = "monitor" ]; then
    niri msg action set-dynamic-cast-monitor
    notify-send -e -a niri -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u low -t 2500 "Screencast target" "Focused monitor set as cast target"
elif [ "$ACTION" = "clear" ]; then
    niri msg action clear-dynamic-cast-target
    notify-send -e -a niri -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u low -t 2500 "Screencast target" "Cleared successfully"
fi