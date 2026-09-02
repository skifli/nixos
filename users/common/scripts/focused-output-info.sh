#!/usr/bin/env bash

INFO=$(niri msg focused-output 2>/dev/null || true)
if [ -n "$INFO" ]; then
    echo "$INFO" | wl-copy --sensitive
    SUMMARY=$(echo "$INFO" | grep -E '^(Output|Current mode|Logical position|Logical size|Scale)')
    notify-send -e -a niri -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u low -t 3500 "Focused Output Info" "$SUMMARY"
fi
