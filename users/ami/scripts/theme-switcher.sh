#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"

if [ -z "$TARGET" ]; then
    CURRENT_TAG=$(cat /etc/specialisation 2>/dev/null || echo "light")
    if [ "$CURRENT_TAG" = "light" ]; then
        TARGET="dark"
    else
        TARGET="light"
    fi

    notify-send -e -a "nixos" -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 5000 "Theme Switcher" "Switching to $TARGET mode..."
fi

SWITCH_BIN="/run/booted-system/specialisation/$TARGET/bin/switch-to-configuration"
if [ ! -x "$SWITCH_BIN" ]; then
    SWITCH_BIN="/run/current-system/specialisation/$TARGET/bin/switch-to-configuration"
fi

if [ -x "$SWITCH_BIN" ]; then
    # Note: Changed from 'switch' to 'test' to not add to history to save a buncha clutter
    sudo "$SWITCH_BIN" test
    
    # Niri workspace layout refresh transitions
    # niri msg action do-screen-transition -d 1000 2>/dev/null || true
    # Got annoyed at the screen transition being a bit haphazard and yeah...
    notify-send -e -a "nixos" -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 5000 "Theme Switcher" "Switched to $TARGET mode"
else
    notify-send -a "nixos" -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" -u normal -t 5000 "Theme Switcher" "Specialisation $TARGET not found"
fi