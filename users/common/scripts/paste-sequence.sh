#!/usr/bin/env bash
set -euo pipefail

QUEUE_FILE="/tmp/copyl-queue.txt"
# 0.75s gives DOM time to create the file and refocus the prompt
DELAY="${1:-0.75}"

if [ ! -f "$QUEUE_FILE" ] || [ ! -s "$QUEUE_FILE" ]; then
    mapfile -t URIS < <(wl-paste -t text/uri-list 2>/dev/null || wl-paste 2>/dev/null || true)
else
    mapfile -t URIS < "$QUEUE_FILE"
fi

VALID_URIS=()
for u in "${URIS[@]}"; do
    clean="$(echo "$u" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [ -n "$clean" ] && VALID_URIS+=("$clean")
done

TOTAL="${#VALID_URIS[@]}"
if [ "$TOTAL" -eq 0 ]; then
    notify-send -e -a "Paste sequence" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2000 "Error!" "No files in clipboard queue."
    exit 0
fi

notify-send -e -a "Paste sequence" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2000 "Attaching..." "$TOTAL files."

# Allow keyboard shortcut modifiers (Mod/Ctrl) to fully release
sleep 0.25

INDEX=1
for uri in "${VALID_URIS[@]}"; do
    FILE_NAME="$(basename "$(printf '%b' "${uri//%/\\x}" | sed 's#^file://##')")"

    # Update clipboard with 1 single file URI
    printf "%s\r\n" "$uri" | wl-copy --sensitive -t text/uri-list

    # Short pause for clipboard daemon to get the new data source
    sleep 0.1

    # Simulate Ctrl+V
    wtype -M ctrl -k v -m ctrl

    #  Wait for it to do file stuff before the next paste
    sleep "$DELAY"
    ((INDEX++))
done

# Restore the full list to the clipboard when finished
printf "%s\r\n" "${VALID_URIS[@]}" | wl-copy -t text/uri-list

notify-send -e -a "Paste sequence" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Success!" "Attached $TOTAL files!"
