#!/usr/bin/env bash
set -euo pipefail

TMP_FILE=$(mktemp /tmp/anki_clip_XXXXXX.txt)

if [ -n "${WAYLAND_DISPLAY:-}" ]; then
    wl-paste > "$TMP_FILE" || true
fi

if [ ! -s "$TMP_FILE" ]; then
    notify-send -e -a "anki" -i "/home/${USER}/.local/share/misc/Anki-icon.svg" -u low "Import error" "Clipboard is empty."
    rm -f "$TMP_FILE"
    exit 1
fi

# Anki's default text import expects tab-separated fields. Ignore blank lines
# and Anki import directives, but reject whitespace-only or malformed data.
HAS_VALID_ROW=0
INVALID_ROW=0
while IFS= read -r LINE || [ -n "$LINE" ]; do
    LINE=${LINE%$'\r'}

    [[ "$LINE" =~ ^[[:space:]]*$ ]] && continue
    [[ "$LINE" == \#* ]] && continue

    if [[ "$LINE" != *$'\t'* ]]; then
        INVALID_ROW=1
        break
    fi

    FRONT=${LINE%%$'\t'*}
    REMAINDER=${LINE#*$'\t'}
    BACK=${REMAINDER%%$'\t'*}

    if [[ ! "$FRONT" =~ [^[:space:]] || ! "$BACK" =~ [^[:space:]] ]]; then
        INVALID_ROW=1
        break
    fi

    HAS_VALID_ROW=1
done < "$TMP_FILE"

if [ "$INVALID_ROW" -eq 1 ] || [ "$HAS_VALID_ROW" -eq 0 ]; then
    notify-send -e -a "anki" -i "/home/${USER}/.local/share/misc/Anki-icon.svg" -u low "Import error" "Clipboard must contain tab-separated card fields."
    rm -f "$TMP_FILE"
    exit 1
fi

notify-send -e -a "anki" -i "/home/${USER}/.local/share/misc/Anki-icon.svg" -u low "Clipboard import" "Initiated."

anki "$TMP_FILE"
