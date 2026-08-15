#!/usr/bin/env bash
set -euo pipefail

CACHE_DIR="$HOME/Documents/custom-scripts"
mkdir -p "$CACHE_DIR"
TMP_IMG="$CACHE_DIR/clipboard-preview.png"

if wl-paste -t image/png > "$TMP_IMG" 2>/dev/null; then
    swayimg --scale=fit "$TMP_IMG"

    rm -f "$TMP_IMG"
else
    # Check if clipboard contains a file URI
    URI=$(wl-paste -t text/uri-list 2>/dev/null | sed 's#^file://##' || true)

    if [ -n "$URI" ] && [ -f "$URI" ]; then
        swayimg --scale=fit "$URI"
    else
        notify-send -e -a "Clipboard viewer" -i "$HOME/.local/share/misc/niri-icon.svg" -u low "No image" "Clipboard does not contain image data."
    fi
fi