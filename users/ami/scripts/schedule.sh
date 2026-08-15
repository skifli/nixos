#!/usr/bin/env bash
set -euo pipefail

# Inspired by axlefublr

FIFO_PATH="$HOME/Documents/custom-scripts/task-scheduler"
mkdir -p "$(dirname "$FIFO_PATH")"
[ -p "$FIFO_PATH" ] || mkfifo "$FIFO_PATH"

if [ $# -eq 0 ]; then
    echo "Usage: schedule <command...>"
    exit 1
fi

# Write CWD\0COMMAND\0 into the FIFO
printf "%s\0%s\0" "$PWD" "$*" > "$FIFO_PATH"

notify-send -e -a "Task Scheduler" -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 2500 "Task queued" "$*"