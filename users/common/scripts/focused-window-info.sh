#!/usr/bin/env bash

INFO=$(niri msg focused-window 2>/dev/null || true)
if [ -n "$INFO" ]; then
    echo "$INFO" | wl-copy
    SUMMARY=$(echo "$INFO" | grep -E '^(Window ID|Title|App ID|PID|Workspace ID)')
    notify-send -e -a niri -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u low -t 3500 "Focused Window Info" "$SUMMARY"
fi