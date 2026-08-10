#!/usr/bin/env bash

niri msg action do-screen-transition -d 250 2>/dev/null || true

CURRENT_TAG=$(cat /etc/specialisation 2>/dev/null || echo "day")
if [ "$CURRENT_TAG" = "day" ]; then
    TARGET="night"
else
    TARGET="day"
fi

notify-send -e -a "nixos" -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 2500 "Theme Switcher" "Switching to $TARGET mode"

if [ -x "/run/booted-system/specialisation/$TARGET/bin/switch-to-configuration" ]; then
    sudo /run/booted-system/specialisation/$TARGET/bin/switch-to-configuration switch
    notify-send -e -a "nixos" -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 2500 "Theme Switcher" "Switched to $TARGET mode"
else
    notify-send -a "nixos" -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" -u normal "Theme Switcher" "Specialisation $TARGET not found"
fi