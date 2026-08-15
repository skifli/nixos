#!/usr/bin/env bash
set -euo pipefail

TODO_FILE="$HOME/Documents/custom-scripts/todo.json"
FONT="${FONT_MONOSPACE:-JetBrainsMono Nerd Font}"
FONT_SIZE="${FONT_SIZE_APPLICATIONS:-11}"

mkdir -p "$(dirname "$TODO_FILE")"
[ -f "$TODO_FILE" ] || echo "[]" > "$TODO_FILE"

fuzzel_prompt() {
    local prompt="$1"
    local text_data="${2:-}"
    local min_lines="${3:-0}"
    
    local num_lines=0
    local prompt_len=${#prompt}
    local calculated_width=35

    if [ -n "$text_data" ]; then
        # Calculate height
        num_lines=$(echo "$text_data" | wc -l)
        if [ "$num_lines" -gt 12 ]; then
            num_lines=12
        fi
        if [ "$num_lines" -lt "$min_lines" ]; then
            num_lines="$min_lines"
        fi

        # Find longest line length
        local longest
        longest=$(echo "$text_data" | wc -L 2>/dev/null || echo "$text_data" | awk '{ if (length > max) { max = length } } END { print max }')
        
        if [ -n "$longest" ] && [ "$longest" -gt 0 ]; then
            calculated_width=$((longest + prompt_len + 4))
        fi
    else
        num_lines="$min_lines"
        calculated_width=$((prompt_len + 30))
    fi

    if [ "$calculated_width" -lt 35 ]; then calculated_width=35; fi
    if [ "$calculated_width" -gt 120 ]; then calculated_width=120; fi

    fuzzel --dmenu \
        --minimal-lines \
        --font="$FONT:size=$FONT_SIZE" \
        --prompt="$prompt" \
        --background-color=1e1e2eff \
        --text-color=cdd6f4ff \
        --input-color=cdd6f4ff \
        --selection-color=585b70ff \
        --selection-text-color=cdd6f4ff \
        --width="$calculated_width" \
        --lines="$num_lines" \
        --horizontal-pad=12 \
        --border-radius=10
}

if [ "${1:-}" = "--startup" ]; then
    NOW=$(date +%s)
    STARTUP_ITEMS=$(jq -r --argjson now "$NOW" '.[] | select(.done != true) | select(.on_startup == true or (.due_ts != null and .due_ts <= $now)) | "\u2022 " + .text' "$TODO_FILE")

    if [ -n "$STARTUP_ITEMS" ]; then
        notify-send -e -a "todos" -i "$HOME/.local/share/misc/niri-icon.svg" -u critical -t 0 "Pending reminders" "$STARTUP_ITEMS"
    fi

    exit 0
fi

if [ "${1:-}" = "--check" ]; then
    NOW=$(date +%s)

    jq -r --argjson now "$NOW" '.[] | select(.done != true and .due_ts != null and .due_ts <= $now and .notified != true) | .id + "|" + .text' "$TODO_FILE" | while IFS='|' read -r id text; do
        notify-send -e -a "todos" -i "$HOME/.local/share/misc/niri-icon.svg" -u critical -t 0 "Reminder due" "$text"
        TMP=$(mktemp)
        jq --arg id "$id" 'map(if .id == $id then .notified = true else . end)' "$TODO_FILE" > "$TMP" && mv "$TMP" "$TODO_FILE"
    done
    
    exit 0
fi

format_ts_str() {
    local ts="$1"
    local cur_yr target_yr
    cur_yr=$(date +%Y)
    target_yr=$(date -d "@$ts" +%Y)

    if [ "$cur_yr" = "$target_yr" ]; then
        date -d "@$ts" "+%b %d %H:%M"
    else
        date -d "@$ts" "+%b %d %Y %H:%M"
    fi
}

parse_time_preset() {
    local choice="$1"
    local sel_lower
    sel_lower=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    NOW=$(date +%s)
    DUE_TS="null"
    DUE_STR=""
    ON_STARTUP="false"

    case "$sel_lower" in
        *"1 hour"*)
            DUE_TS=$((NOW + 3600))
            DUE_STR="$(format_ts_str "$DUE_TS")"
            ;;
        *"tonight"*)
            set +e
            DUE_TS=$(date -d "today 20:00" +%s 2>/dev/null)
            set -e
            if [ -z "$DUE_TS" ] || [ "$DUE_TS" -le "$NOW" ]; then
                DUE_TS=$(date -d "tomorrow 20:00" +%s)
            fi
            DUE_STR="$(format_ts_str "$DUE_TS")"
            ;;
        *"startup"*)
            ON_STARTUP="true"
            DUE_STR="Next Startup"
            ;;
        *"morning"*)
            DUE_TS=$(date -d "tomorrow 09:00" +%s)
            DUE_STR="$(format_ts_str "$DUE_TS")"
            ;;
        *"tomorrow"*)
            DUE_TS=$((NOW + 86400))
            DUE_STR="$(format_ts_str "$DUE_TS")"
            ;;
        *"1 week"*)
            DUE_TS=$((NOW + 604800))
            DUE_STR="$(format_ts_str "$DUE_TS")"
            ;;
        *"relative"*)
            REL_INPUT=$(echo "" | fuzzel_prompt "Time offset (e.g., 2 hours, 3 days): " "" 0)
            if [ -n "$REL_INPUT" ]; then
                set +e
                PARSED_TS=$(date -d "now + $REL_INPUT" +%s 2>/dev/null)
                set -e
                if [ -n "$PARSED_TS" ]; then
                    DUE_TS="$PARSED_TS"
                    DUE_STR="$(format_ts_str "$DUE_TS")"
                else
                    notify-send -e -u critical -a "todos" -i "$HOME/.local/share/misc/niri-icon.svg" "Invalid time" "Could not parse relative time '$REL_INPUT'"
                fi
            fi
            ;;
        *"absolute"*)
            ABS_INPUT=$(echo "" | fuzzel_prompt "Exact time (e.g., 2026-08-25 14:00): " "" 0)
            if [ -n "$ABS_INPUT" ]; then
                set +e
                PARSED_TS=$(date -d "$ABS_INPUT" +%s 2>/dev/null)
                set -e
                if [ -n "$PARSED_TS" ]; then
                    DUE_TS="$PARSED_TS"
                    DUE_STR="$(format_ts_str "$DUE_TS")"
                else
                    notify-send -e -u critical -a "todos" -i "$HOME/.local/share/misc/niri-icon.svg" "Invalid date" "Could not parse date '$ABS_INPUT'"
                fi
            fi
            ;;
        *"no reminder"*)
            DUE_TS="null"
            DUE_STR=""
            ;;
        *)
            DUE_TS="null"
            DUE_STR=""
            ;;
    esac
}

NOW=$(date +%s)

ACTIVE_TODOS_JSON=$(jq -c --argjson now "$NOW" '
    [ .[] | select(.done != true) ] |
    (
        (map(select(.due_ts != null and .on_startup != true)) | sort_by(.due_ts)) +
        (map(select(.on_startup == true))) +
        (map(select(.due_ts == null and .on_startup != true)) | sort_by([.id, (.text | ascii_downcase)]))
    ) |
    map({
        id: .id,
        display: (
            (
                if .on_startup == true then
                    "[Boot] "
                elif .due_ts != null then
                    if .due_ts < $now then
                        "[OVERDUE: " + .due_str + "] "
                    else
                        "[" + .due_str + "] "
                    end
                else
                    "[Task] "
                end
            ) + .text
        )
    })
' "$TODO_FILE")

SORTED_ACTIVE_TODOS=$(echo "$ACTIVE_TODOS_JSON" | jq -r '.[].display')

ADD_HEADER="[+ Add New Todo / Reminder]"
HISTORY_FOOTER="[View Completed Tasks / History]"

MENU_TEXT="$ADD_HEADER"
if [ -n "$SORTED_ACTIVE_TODOS" ]; then
    MENU_TEXT="$MENU_TEXT
$SORTED_ACTIVE_TODOS"
fi
MENU_TEXT="$MENU_TEXT
$HISTORY_FOOTER"

SELECTED=$(echo "$MENU_TEXT" | fuzzel_prompt "Todo & Reminders: " "$MENU_TEXT" 3)

[ -z "$SELECTED" ] && exit 0

if [[ "$SELECTED" == *"$ADD_HEADER"* ]]; then
    TODO_TEXT=$(echo "" | fuzzel_prompt "New Task: " "" 0)
    [ -z "$TODO_TEXT" ] && exit 0

    TIME_PRESETS="1. In 1 Hour
2. Tonight (20:00)
3. Next System Startup (Boot)
4. Next Morning (09:00)
5. Tomorrow (Same Time)
6. In 1 Week
7. Custom Relative (e.g., 2 hours, 3 days)
8. Custom Absolute (e.g., 2026-08-25 14:00)
9. No Reminder (Task Only)"

    TIME_SEL=$(echo "$TIME_PRESETS" | fuzzel_prompt "Set Reminder Preset: " "$TIME_PRESETS" 9)
    [ -z "$TIME_SEL" ] && exit 0

    parse_time_preset "$TIME_SEL"

    NEW_ID=$(date +%s%N)
    TMP=$(mktemp)
    jq --arg id "$NEW_ID" \
       --arg text "$TODO_TEXT" \
       --argjson due_ts "$DUE_TS" \
       --arg due_str "$DUE_STR" \
       --argjson on_startup "$ON_STARTUP" \
       '. += [{"id": $id, "text": $text, "done": false, "due_ts": $due_ts, "due_str": $due_str, "on_startup": $on_startup, "notified": false}]' \
       "$TODO_FILE" > "$TMP" && mv "$TMP" "$TODO_FILE"

    if [ "$ON_STARTUP" = "true" ]; then
        notify-send -e -u low -a "todos" -i "$HOME/.local/share/misc/niri-icon.svg" "Todo added" "'$TODO_TEXT' (set for next startup)"
    elif [ "$DUE_STR" != "" ]; then
        notify-send -e -u low -a "todos" -i "$HOME/.local/share/misc/niri-icon.svg" "Reminder set" "'$TODO_TEXT' (due: $DUE_STR)"
    else
        notify-send -e -u low -a "todos" -i "$HOME/.local/share/misc/niri-icon.svg" "Task added" "$TODO_TEXT"
    fi

    exec "$0"

elif [[ "$SELECTED" == *"$HISTORY_FOOTER"* ]]; then
    COMPLETED_ITEMS=$(jq -r '.[] | select(.done == true) | "[Done] " + .text + "  (ID:" + .id + ")"' "$TODO_FILE")

    if [ -z "$COMPLETED_ITEMS" ]; then
        notify-send -e -u low -a "todos" -i "$HOME/.local/share/misc/niri-icon.svg" "History empty" "No completed tasks in history."
        exit 0
    fi

    HISTORY_MENU="[Clear All Completed History]
$COMPLETED_ITEMS"

    HIST_SEL=$(echo "$HISTORY_MENU" | fuzzel_prompt "Completed History: " "$HISTORY_MENU" 3)
    [ -z "$HIST_SEL" ] && exit 0

    if [[ "$HIST_SEL" == *"[Clear All Completed History]"* ]]; then
        TMP=$(mktemp)
        jq 'map(select(.done != true))' "$TODO_FILE" > "$TMP" && mv "$TMP" "$TODO_FILE"
        notify-send -e -u low -a "todos" -i "$HOME/.local/share/misc/niri-icon.svg" "History cleared"
    else
        HIST_ID=$(echo "$HIST_SEL" | sed -n 's/.*(ID:\([0-9]*\))/\1/p')
        [ -z "$HIST_ID" ] && exit 0

        HIST_ACT_MENU="1. Restore to Active Tasks
2. Delete Permanently"
        HIST_ACT_SEL=$(echo "$HIST_ACT_MENU" | fuzzel_prompt "Action: " "$HIST_ACT_MENU" 2)

        case "$(echo "$HIST_ACT_SEL" | tr '[:upper:]' '[:lower:]')" in
            *"restore"*)
                TMP=$(mktemp)
                jq --arg id "$HIST_ID" 'map(if .id == $id then .done = false | .notified = false else . end)' "$TODO_FILE" > "$TMP" && mv "$TMP" "$TODO_FILE"
                notify-send -e -u low -a "todos" -i "$HOME/.local/share/misc/niri-icon.svg" "Task restored"
                ;;
            *"delete"*)
                TMP=$(mktemp)
                jq --arg id "$HIST_ID" 'map(select(.id != $id))' "$TODO_FILE" > "$TMP" && mv "$TMP" "$TODO_FILE"
                notify-send -e -u low -a "todos" -i "$HOME/.local/share/misc/niri-icon.svg" "Task deleted"
                ;;
        esac
    fi

else
    TODO_ID=$(echo "$ACTIVE_TODOS_JSON" | jq -r --arg sel "$SELECTED" '.[] | select(.display == $sel) | .id' | head -n1)
    [ -z "$TODO_ID" ] && exit 0

    ACTION_MENU="1. Mark Completed
2. Change Reminder Preset
3. Edit Task Text
4. Delete Permanently"
    ACTION_SEL=$(echo "$ACTION_MENU" | fuzzel_prompt "Action: " "$ACTION_MENU" 4)

    ACT_LOWER=$(echo "$ACTION_SEL" | tr '[:upper:]' '[:lower:]')

    case "$ACT_LOWER" in
        *"completed"*)
            TMP=$(mktemp)
            jq --arg id "$TODO_ID" 'map(if .id == $id then .done = true else . end)' "$TODO_FILE" > "$TMP" && mv "$TMP" "$TODO_FILE"
            notify-send -e -u low -a "todos" -i "$HOME/.local/share/misc/niri-icon.svg" "Task completed"
            ;;
        *"change"*)
            TIME_PRESETS="1. In 1 Hour
2. Tonight (20:00)
3. Next System Startup (Boot)
4. Next Morning (09:00)
5. Tomorrow (Same Time)
6. In 1 Week
7. Custom Relative (e.g., 2 hours, 3 days)
8. Custom Absolute (e.g., 2026-08-25 14:00)
9. Remove Reminder"
            TIME_SEL=$(echo "$TIME_PRESETS" | fuzzel_prompt "New Reminder Preset: " "$TIME_PRESETS" 9)
            [ -z "$TIME_SEL" ] && exit 0

            parse_time_preset "$TIME_SEL"

            TMP=$(mktemp)
            jq --arg id "$TODO_ID" \
               --argjson due_ts "$DUE_TS" \
               --arg due_str "$DUE_STR" \
               --argjson on_startup "$ON_STARTUP" \
               'map(if .id == $id then .due_ts = $due_ts | .due_str = $due_str | .on_startup = $on_startup | .notified = false else . end)' \
               "$TODO_FILE" > "$TMP" && mv "$TMP" "$TODO_FILE"
            notify-send -e -u low -a "todos" -i "$HOME/.local/share/misc/niri-icon.svg" "Reminder updated"
            ;;
        *"edit"*)
            OLD_TEXT=$(jq -r --arg id "$TODO_ID" '.[] | select(.id == $id) | .text' "$TODO_FILE")
            NEW_TEXT=$(echo "" | fuzzel_prompt "Edit Task: " "" 0)
            if [ -n "$NEW_TEXT" ]; then
                TMP=$(mktemp)
                jq --arg id "$TODO_ID" --arg text "$NEW_TEXT" \
                   'map(if .id == $id then .text = $text else . end)' \
                   "$TODO_FILE" > "$TMP" && mv "$TMP" "$TODO_FILE"
                notify-send -e -u low -a "todos" -i "$HOME/.local/share/misc/niri-icon.svg" "Task updated"
            fi
            ;;
        *"delete"*)
            TMP=$(mktemp)
            jq --arg id "$TODO_ID" 'map(select(.id != $id))' "$TODO_FILE" > "$TMP" && mv "$TMP" "$TODO_FILE"
            notify-send -e -u low -a "todos" -i "$HOME/.local/share/misc/niri-icon.svg" "Task deleted"
            ;;
        *)
            exit 0
            ;;
    esac
fi