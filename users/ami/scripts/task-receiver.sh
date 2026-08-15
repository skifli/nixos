#!/usr/bin/env bash
set -euo pipefail

# Inspired by axlefublr

FIFO_PATH="$HOME/Documents/custom-scripts/task-scheduler"
mkdir -p "$(dirname "$FIFO_PATH")"
[ -p "$FIFO_PATH" ] || mkfifo "$FIFO_PATH"

notify-send -e -a "Task Receiver" -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 2500 "Task receiver started" "Listening on $FIFO_PATH"
echo "Listening on $FIFO_PATH..."

while true; do
    # Read NUL-delimited CWD and CMD
    
    if read -r -d $'\0' WORK_DIR < "$FIFO_PATH" && read -r -d $'\0' CMD < "$FIFO_PATH"; then
        [ -z "$CMD" ] && continue
        
        notify-send -e -a "Task Receiver" -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 2500 "Executing task" "$CMD (in $WORK_DIR)"
        echo -e "\e[1;35m[Executing]\e[0m $CMD (in $WORK_DIR)"
        
        if (cd "$WORK_DIR" && eval "$CMD"); then
            echo -e "\e[1;32m[Success]\e[0m $CMD"

            notify-send -e -a "Task Receiver" -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 3000 "Task completed" "$CMD"
        else
          echo -e "\e[1;31m[Failed]\e[0m $CMD"

          notify-send -e -a "Task Receiver" -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" -u critical -t 0 "Task failed" "$CMD"
        fi

        echo "\n"
    fi
done