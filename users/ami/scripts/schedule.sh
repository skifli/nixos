#!/usr/bin/env bash
set -euo pipefail

# Inspired by axlefublr

DATA_DIR="$HOME/Documents/custom-scripts/task-scheduler"
QUEUE_DIR="$DATA_DIR/queue"
LOGS_DIR="$DATA_DIR/logs"

mkdir -p "$QUEUE_DIR" "$LOGS_DIR"

resolve_task_file() {
    local input="${1:-}"
    [ -z "$input" ] && return 1

    local raw_id
    raw_id=$(echo "$input" | sed 's/^0*//')
    [ -z "$raw_id" ] && raw_id="0"

    local padded_id
    padded_id=$(printf "%04d" "$raw_id" 2>/dev/null || echo "$raw_id")

    if [ -f "$QUEUE_DIR/$padded_id.task" ]; then
        echo "$QUEUE_DIR/$padded_id.task"
    elif [ -f "$QUEUE_DIR/$raw_id.task" ]; then
        echo "$QUEUE_DIR/$raw_id.task"
    elif [ -f "$QUEUE_DIR/$input.task" ]; then
        echo "$QUEUE_DIR/$input.task"
    else
        return 1
    fi
}

get_next_id() {
    local max_id=0
    shopt -s nullglob
    for f in "$QUEUE_DIR"/*.task; do
        local filename
        filename=$(basename "$f" .task)
        local num_id
        num_id=$(echo "$filename" | sed 's/^0*//')
        [ -z "$num_id" ] && num_id=0
        if [[ "$num_id" =~ ^[0-9]+$ ]] && [ "$num_id" -gt "$max_id" ]; then
            max_id="$num_id"
        fi
    done
    echo $((max_id + 1))
}

show_help() {
    cat << EOF
Task Scheduler CLI

Usage:
  schedule <command...>    Queue a new task
  schedule list | ls       List all pending, running, and recent tasks
  schedule edit <id>       Edit a pending task in \$EDITOR
  schedule rm <id>         Remove/cancel a queued task
  schedule logs <id>       View execution output log for a task
  schedule clear           Clear completed and failed tasks from history
EOF
}

if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

case "$1" in
    list|ls)
        echo -e "\e[1;34mID\tSTATUS\t\tCOMMAND\e[0m"
        echo ""
        shopt -s nullglob
        tasks=("$QUEUE_DIR"/*.task)
        if [ ${#tasks[@]} -eq 0 ]; then
            echo "No tasks in queue."
            exit 0
        fi
        for f in "${tasks[@]}"; do
            (
                source "$f"
                case "${STATUS:-pending}" in
                    pending)   COLOR="\e[1;33m" ;;
                    running)   COLOR="\e[1;35m" ;;
                    completed) COLOR="\e[1;32m" ;;
                    failed)    COLOR="\e[1;31m" ;;
                    *)         COLOR="\e[0m" ;;
                esac
                printf "%-6s ${COLOR}%-12s\e[0m %s\n" "$ID" "$STATUS" "$CMD"
            )
        done
        ;;

    edit)
        if [ -z "${2:-}" ]; then
            echo "Usage: schedule edit <task_id>"
            exit 1
        fi
        TASK_FILE=$(resolve_task_file "$2" || true)
        if [ -z "$TASK_FILE" ]; then
            echo "Error: Task '$2' not found."
            exit 1
        fi
        source "$TASK_FILE"
        if [ "$STATUS" != "pending" ]; then
            echo "Error: Cannot edit task in '$STATUS' state."
            exit 1
        fi
        "${EDITOR:-nano}" "$TASK_FILE"
        echo "Task updated."
        ;;

    rm|cancel)
        if [ -z "${2:-}" ]; then
            echo "Usage: schedule rm <task_id>"
            exit 1
        fi
        TASK_FILE=$(resolve_task_file "$2" || true)
        if [ -z "$TASK_FILE" ]; then
            echo "Error: Task '$2' not found."
            exit 1
        fi
        source "$TASK_FILE"
        rm -f "$TASK_FILE" "$LOGS_DIR/$ID.log"
        echo "Task '$ID' removed."
        ;;

    logs|log)
        if [ -z "${2:-}" ]; then
            echo "Usage: schedule logs <task_id>"
            exit 1
        fi
        TASK_FILE=$(resolve_task_file "$2" || true)
        if [ -z "$TASK_FILE" ]; then
            echo "Error: Task '$2' not found."
            exit 1
        fi
        source "$TASK_FILE"
        LOG_FILE="$LOGS_DIR/$ID.log"
        if [ ! -f "$LOG_FILE" ] || [ ! -s "$LOG_FILE" ]; then
            echo "[Log file is empty for task #$ID]"
            exit 0
        fi
        cat "$LOG_FILE"
        ;;

    clear)
        shopt -s nullglob
        for f in "$QUEUE_DIR"/*.task; do
            (
                source "$f"
                if [ "$STATUS" = "completed" ] || [ "$STATUS" = "failed" ]; then
                    rm -f "$f" "$LOGS_DIR/$ID.log"
                fi
            )
        done
        echo "Cleared finished tasks."
        ;;

    *)
        # Queue new task
        CMD="$*"
        NEXT_NUM=$(get_next_id)
        ID=$(printf "%04d" "$NEXT_NUM")

        TASK_FILE="$QUEUE_DIR/$ID.task"
        cat << EOF > "$TASK_FILE"
ID="$ID"
CWD="$(pwd)"
CMD=$(printf '%q' "$CMD")
STATUS="pending"
CREATED="$(date +'%Y-%m-%d %H:%M:%S')"
EOF

        notify-send -e -a "Task scheduler" -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 2500 "Task queued (#$ID)" "$CMD"
        echo "Queued task #$ID: $CMD"
        ;;
esac