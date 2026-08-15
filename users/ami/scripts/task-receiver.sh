#!/usr/bin/env bash
set -euo pipefail

# Inspired by axlefublr

DATA_DIR="$HOME/Documents/custom-scripts/task-scheduler"
QUEUE_DIR="$DATA_DIR/queue"
LOGS_DIR="$DATA_DIR/logs"

FONT="${FONT_MONOSPACE:-JetBrainsMono Nerd Font}"
FONT_SIZE="${FONT_SIZE_APPLICATIONS:-11}"

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
        UNIT_NAME="task-scheduler-$ID"

        systemd-run --user --scope --unit="$UNIT_NAME" \
            bash -c "cd $(printf '%q' "$CWD") && eval $(printf '%q' "$CMD")" > "$LOG_FILE" 2>&1 &
        
        sleep 1

        # Wait until every process inside the isolated cgroup has exited
        while systemctl --user is-active --quiet "$UNIT_NAME.scope" 2>/dev/null; do
            sleep 0.5
        done

        EXIT_CODE=$(systemctl --user show "$UNIT_NAME.scope" --property=ExecMainStatus --value 2>/dev/null || echo 0)

        if [ "$EXIT_CODE" -eq 0 ]; then
            sed -i 's/STATUS="running"/STATUS="completed"/' "$NEXT_TASK"
            echo -e "\e[1;32m[Success #$ID]\e[0m $CMD"
            notify-send -e -a "Task receiver" -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 3000 "Task completed (#$ID)" "$CMD"
        else
            echo -e "\e[1;31m[Failed #$ID]\e[0m $CMD"
            notify-send -e -a "Task receiver" -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" -u critical -t 0 "Task failed (#$ID)" "$CMD"

            WIN_ID=$(niri msg -j focused-window 2>/dev/null | jq -r '.id // empty' || true)
            [ -n "$WIN_ID" ] && niri msg action set-window-urgent --id "$WIN_ID" 2>/dev/null || true

            ACTION=$(printf "1. Retry task\n2. Edit command\n3. Mark failed / skip" | fuzzel --dmenu \
                --font="$FONT:size=$FONT_SIZE" \
                --prompt="Task #$ID Failed: " \
                --background-color=1e1e2eff \
                --text-color=cdd6f4ff \
                --width=25 --lines=3 --border-radius=10 || echo "skip")

            case "${ACTION,,}" in
                *retry*)
                    sed -i 's/STATUS="running"/STATUS="pending"/' "$NEXT_TASK"
                    sed -i 's/STATUS="failed"/STATUS="pending"/' "$NEXT_TASK"
                    continue
                    ;;
                *edit*)
                    NEW_CMD=$(echo "$CMD" | vipe)
                    if [ -n "$NEW_CMD" ]; then
                        ESCAPED_NEW_CMD=$(printf '%s\n' "$NEW_CMD" | sed -e 's/[\/&]/\\&/g')
                        sed -i "s/^CMD=\".*\"/CMD=\"$ESCAPED_NEW_CMD\"/" "$NEXT_TASK"
                        sed -i 's/STATUS="running"/STATUS="pending"/' "$NEXT_TASK"
                        sed -i 's/STATUS="failed"/STATUS="pending"/' "$NEXT_TASK"
                        continue
                    else
                        sed -i 's/STATUS="running"/STATUS="failed"/' "$NEXT_TASK"
                    fi
                    ;;
                *)
                    sed -i 's/STATUS="running"/STATUS="failed"/' "$NEXT_TASK"
                    ;;
            esac
        fi
        echo -e "\n"
    else
        sleep 1
    fi
done