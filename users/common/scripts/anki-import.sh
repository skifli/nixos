#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")
TMP_FILE="/tmp/anki_clip_${TIMESTAMP}.txt"

if [ -n "${WAYLAND_DISPLAY:-}" ]; then
    wl-paste > "$TMP_FILE"
fi

if [ ! -s "$TMP_FILE" ]; then
    notify-send -e -a "anki" -i "/home/${USER}/.local/share/misc/Anki-icon.svg" -u low "Import error" "Clipboard is empty."
    rm -f "$TMP_FILE"

    exit 1
fi

notify-send -e -a "anki" -i "/home/${USER}/.local/share/misc/Anki-icon.svg" -u low "Clipboard import" "Initiated."

anki "$TMP_FILE"
