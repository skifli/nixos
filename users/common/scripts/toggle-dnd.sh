#!/usr/bin/env bash

current=$(wayle notify status 2>/dev/null | grep -i "Do Not Disturb" | grep -i "enabled" || true)

wayle notify dnd 2>/dev/null || true

ICON="$HOME/.local/share/misc/nix-snowflake-rainbow.svg"
if [ -z "$current" ]; then
    # Was disabled, now enabled. Notify that notifications are back.
    notify-send -e -a "DND" -i "$ICON" -u low -t 2500 "Do Not Disturb" "Notifications enabled" || true
fi
