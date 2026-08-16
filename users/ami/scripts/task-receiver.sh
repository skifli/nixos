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

        BEFORE_WIN_IDS=$(niri msg -j windows 2>/dev/null | jq -r '.[].id' 2>/dev/null | tr '\n' ' ')

        EVENT_FIFO=$(mktemp -u)
        mkfifo "$EVENT_FIFO"
        exec 4<> "$EVENT_FIFO"

        niri msg -j event-stream >&4 2>/dev/null &
        STREAM_PID=$!

        FIRST_WORD=$(echo "$CMD" | awk '{print $1}')
        CMD_BASE=$(basename "$FIRST_WORD" .sh)
        CMD_LOWER=$(echo "$CMD_BASE" | tr '[:upper:]' '[:lower:]')

        systemd-run --user --scope --unit="$UNIT_NAME" \
            bash -c "cd $(printf '%q' "$CWD") && eval $(printf '%q' "$CMD")" > "$LOG_FILE" 2>&1 &

        TRACKED_WIN_ID=""
        GRACE_TICKS=0

        while true; do
            SCOPE_ACTIVE=0
            if systemctl --user is-active --quiet "$UNIT_NAME.scope" 2>/dev/null; then
                SCOPE_ACTIVE=1
            fi

            if read -t 0.1 -u 4 LINE; then
                if [ -n "$LINE" ]; then
                    WIN_JSON=$(echo "$LINE" | jq -c '.WindowOpenedOrChanged.window // empty' 2>/dev/null || true)
                    
                    if [ -n "$WIN_JSON" ]; then
                        EVENT_WIN_ID=$(echo "$WIN_JSON" | jq -r '.id')
                        EVENT_APP_ID=$(echo "$WIN_JSON" | jq -r '.app_id // ""' | tr '[:upper:]' '[:lower:]')
                        EVENT_TITLE=$(echo "$WIN_JSON" | jq -r '.title // ""' | tr '[:upper:]' '[:lower:]')

                        if [ -z "$TRACKED_WIN_ID" ] && ! [[ " $BEFORE_WIN_IDS " =~ " $EVENT_WIN_ID " ]]; then
                            if [[ "$EVENT_APP_ID" == *"ghostty"* ]] || [[ "$EVENT_TITLE" == *"floating-term"* ]] || [[ "$EVENT_TITLE" == *"$CMD_LOWER"* ]] || [[ "$EVENT_APP_ID" == *"$CMD_LOWER"* ]]; then
                                TRACKED_WIN_ID="$EVENT_WIN_ID"
                                echo -e "\e[1;33m[Task #$ID]\e[0m Tracking window ID: $TRACKED_WIN_ID"
                            fi
                        fi
                    fi

                    CLOSED_ID=$(echo "$LINE" | jq -r '.WindowClosed.id // empty' 2>/dev/null || true)
                    if [ -n "$TRACKED_WIN_ID" ] && [ "$CLOSED_ID" = "$TRACKED_WIN_ID" ]; then
                        break
                    fi
                fi
            fi

            # If systemd scope ended and no window has been detected yet, wait up to 1.5s grace period
            if [ "$SCOPE_ACTIVE" -eq 0 ] && [ -z "$TRACKED_WIN_ID" ]; then
                ((GRACE_TICKS++)) || true
                if [ "$GRACE_TICKS" -ge 15 ]; then
                    break
                fi
            fi
        done

        kill "$STREAM_PID" 2>/dev/null || true
        exec 4>&-
        rm -f "$EVENT_FIFO"

        EXIT_CODE=$(systemctl --user show "$UNIT_NAME.scope" --property=ExecMainStatus --value 2>/dev/null || echo 0)
        [ -z "$EXIT_CODE" ] && EXIT_CODE=0

        # If a floating terminal window was successfully tracked and closed by the user, mark as success
        if [ -n "$TRACKED_WIN_ID" ]; then
            EXIT_CODE=0
        fi

        if [ "$EXIT_CODE" -eq 0 ]; then
            sed -i 's/STATUS="running"/STATUS="completed"/' "$NEXT_TASK"
            echo -e "\e[1;32m[Success #$ID]\e[0m $CMD"
            notify-send -e -a "Task receiver" -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 3000 "Task completed (#$ID)" "$CMD"
        else
            echo -e "\e[1;31m[Failed #$ID]\e[0m $CMD"
            notify-send -e -a "Task receiver" -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" -u critical -t 0 "Task failed (#$ID)" "$CMD"

            WIN_ID=$(niri msg -j focused-window 2>/dev/null | jq -r '.id // empty' || true)
            [ -n "$WIN_ID" ] && niri msg action set-window-urgent --id "$WIN_ID" 2>/dev/null || true

            CHOICES="1. Retry task
2. Edit command
3. Mark failed / skip"
            PROMPT="Task #$ID Failed: "
            MAX_LEN=$(echo "$CHOICES" | wc -L)
            CALC_WIDTH=$(( ${#PROMPT} + MAX_LEN + 4 ))

            ACTION=$(echo "$CHOICES" | fuzzel --dmenu \
                --font="$FONT:size=$FONT_SIZE" \
                --prompt="$PROMPT" \
                --background-color=1e1e2eff \
                --text-color=cdd6f4ff \
                --width="$CALC_WIDTH" \
                --lines=3 \
                --border-radius=10 || echo "skip")

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