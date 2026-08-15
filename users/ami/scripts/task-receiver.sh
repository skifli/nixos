#!/usr/bin/env bash
set -euo pipefail

# Inspired by axlefublr

DATA_DIR="$HOME/.local/share/task-scheduler"
QUEUE_DIR="$DATA_DIR/queue"
LOGS_DIR="$DATA_DIR/logs"

mkdir -p "$QUEUE_DIR" "$LOGS_DIR"

notify-send -e -a "Task receiver" -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 2500 "Task receiver started" "Listening for tasks..."
echo "Listening for queued tasks..."

while true; do
    shopt -s nullglob
    TASKS=("$QUEUE_DIR"/*.task)

    NEXT_TASK=""
    for f in "${TASKS[@]}"; do
        if grep -q 'STATUS="pending"' "$f"; then
            NEXT_TASK="$f"
            break
        fi
    done

    if [ -n "$NEXT_TASK" ] && [ -f "$NEXT_TASK" ]; then
        unset ID CWD CMD STATUS
        source "$NEXT_TASK"

        sed -i 's/STATUS="pending"/STATUS="running"/' "$NEXT_TASK"

        notify-send -e -a "Task receiver" -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 2500 "Executing task (#$ID)" "$CMD (in $CWD)"
        echo -e "\e[1;35m[Executing #$ID]\e[0m $CMD (in $CWD)"

        LOG_FILE="$LOGS_DIR/$ID.log"

        if (cd "$CWD" && eval "$CMD") > "$LOG_FILE" 2>&1; then
            sed -i 's/STATUS="running"/STATUS="completed"/' "$NEXT_TASK"
            echo -e "\e[1;32m[Success #$ID]\e[0m $CMD"
            notify-send -e -a "Task receiver" -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 3000 "Task completed (#$ID)" "$CMD"
        else
            sed -i 's/STATUS="running"/STATUS="failed"/' "$NEXT_TASK"
            echo -e "\e[1;31m[Failed #$ID]\e[0m $CMD"
            notify-send -e -a "Task receiver" -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" -u critical -t 0 "Task failed (#$ID)" "$CMD"
        fi
        echo -e "\n"
    else
        sleep 1
    fi
done