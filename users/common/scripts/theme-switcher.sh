#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"

if [ -z "$TARGET" ]; then
    if [[ "$(readlink -f /run/current-system)" == *"-light-"* ]]; then
        TARGET="dark"
    else
        TARGET="light"
    fi

    notify-send -e -a "nixOS" -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 5000 "Theme Switcher" "Switching to $TARGET mode..."
fi

# Locate the right switcher from the system profile.
#
# /run/current-system changes when you enter a specialisation, so it
# cannot reliably be used to find the parent/light configuration.
#
# /nix/var/nix/profiles/system always represents the currently selected
# system generation, and its specialisation directory stays the same
# when switching between specialisations.
case "$TARGET" in
    dark)
        SWITCH_BIN="/nix/var/nix/profiles/system/specialisation/dark/bin/switch-to-configuration"
        ;;
    light)
        SWITCH_BIN="/nix/var/nix/profiles/system/bin/switch-to-configuration"
        ;;
    *)
        notify-send -a "nixOS" -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" \
            -u normal -t 5000 "Theme Switcher" "Invalid target: $TARGET"
        exit 1
        ;;
esac

if [ -x "$SWITCH_BIN" ]; then
    # Note: Changed from 'switch' to 'test' to not add to history to save a buncha clutter
    sudo "$SWITCH_BIN" test

    # The KDE portal serves the file chooser (see niri-portals.conf) and is a
    # long-lived Qt process. It builds its palette from kdeglobals once at
    # startup and never re-reads it, so file dialogs keep the old light/dark
    # colours until it restarts. Restart it after every theme change.
    # Absolute path because auto-theme-check.service's PATH has no systemctl.
    # try-restart: if it isn't running, the next D-Bus activation starts it
    # with the new theme anyway.
    /run/current-system/sw/bin/systemctl --user try-restart plasma-xdg-desktop-portal-kde.service 2>/dev/null || true

    # Niri workspace layout refresh transitions
    # niri msg action do-screen-transition -d 1000 2>/dev/null || true
    # Got annoyed at the screen transition being a bit haphazard and yeah...
    notify-send -e -a "nixOS" -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 5000 "Theme Switcher" "Switched to $TARGET mode"
else
    notify-send -a "nixOS" -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" -u normal -t 5000 "Theme Switcher" "Switcher for $TARGET not found: $SWITCH_BIN"
    exit 1
fi
