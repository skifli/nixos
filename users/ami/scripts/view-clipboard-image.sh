#!/usr/bin/env bash
set -euo pipefail

TMP_IMG=$(mktemp --suffix=.png)
trap 'rm -f "$TMP_IMG"' EXIT

if wl-paste -t image/png > "$TMP_IMG" 2>/dev/null; then
    swayimg --size=image "$TMP_IMG"
else
    RAW_URI=$(wl-paste -t text/uri-list 2>/dev/null | sed 's/\r$//' | sed 's#^file://##' || true)

    if [ -n "$RAW_URI" ]; then
        URI=$(printf '%b' "${RAW_URI//%/\\x}")

        if [ -f "$URI" ]; then
            swayimg --scale=fit "$URI"
            exit 0
        fi
    fi

    # If everything fails, send a notification
    notify-send -e -a "Clipboard viewer" -i "$HOME/.local/share/misc/niri-icon.svg" -u low "No image" "Clipboard does not contain image data."
fi
