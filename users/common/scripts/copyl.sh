#!/usr/bin/env bash
set -euo pipefail

MODE="uri"
if [ "${1:-}" = "--text" ] || [ "${1:-}" = "-t" ]; then
    MODE="text"
    shift
fi

if [ $# -eq 0 ]; then
    echo "Usage: copyl [--text|-t] <file...>" >&2
    exit 1
fi

URIS=()
for f in "$@"; do
    abs="$(realpath "$f")"
    URIS+=("file://$abs")
done

if [ "$MODE" = "uri" ]; then
    # Pasteable as file attachment in other apps.
    printf "%s\r\n" "${URIS[@]}" | wl-copy -t text/uri-list
    TYPE_MSG="URI link(s)"
else
    # Plain text string (file:///home/...)
    printf "%s\n" "${URIS[@]}" | wl-copy
    TYPE_MSG="file:// URL(s)"
fi

COUNT="${#URIS[@]}"
if [ "$COUNT" -eq 1 ]; then
    LABEL="$(basename "$1")"
else
    LABEL="$COUNT files"
fi

notify-send -e -a "Clipboard" -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 2000 "Clipboard" "Copied $TYPE_MSG: $LABEL"
