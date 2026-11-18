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

    # Tell existing KDE/Qt applications that kdeglobals' palette changed.
    # KDE apps listen for this standard session-bus notification and can
    # refresh their palettes without being closed and relaunched.
    if command -v dbus-send >/dev/null 2>&1; then
        dbus-send --session --type=signal \
            /KGlobalSettings org.kde.KGlobalSettings.notifyChange \
            int32:0 int32:0 >/dev/null 2>&1 || true
    fi

    # The KDE portal serves file choosers (see niri-portals.conf). The palette
    # notification above should refresh it too, but restarting it here remains
    # a fallback for dialogs if its Qt palette does not update in place.
    # Absolute path because auto-theme-check.service's PATH has no systemctl.
    # try-restart leaves it stopped if it isn't running; next D-Bus activation
    # starts it with the newly selected theme.
    /run/current-system/sw/bin/systemctl --user try-restart plasma-xdg-desktop-portal-kde.service 2>/dev/null || true

    # Niri workspace layout refresh transitions
    # niri msg action do-screen-transition -d 1000 2>/dev/null || true
    # Got annoyed at the screen transition being a bit haphazard and yeah...
    notify-send -e -a "nixOS" -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 5000 "Theme Switcher" "Switched to $TARGET mode"
else
    notify-send -a "nixOS" -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" -u normal -t 5000 "Theme Switcher" "Switcher for $TARGET not found: $SWITCH_BIN"
    exit 1
fi
