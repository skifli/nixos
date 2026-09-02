#!/usr/bin/env bash

PICKED=$(niri msg pick-color 2>/dev/null || true)
if [ -n "$PICKED" ]; then
    HEX=$(echo "$PICKED" | grep -i "Hex:" | awk '{print $2}')
    if [ -n "$HEX" ]; then
        echo -n "$HEX" | wl-copy --sensitive
        notify-send -e -a niri -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u low -t 3000 "Color Picked" "$HEX (copied to clipboard)"
    fi
fi
