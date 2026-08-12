#!/usr/bin/env bash

ICON_ARGS=()
if [[ -f "${NIRI_ICON_PATH:-}" ]]; then
    ICON_ARGS=(-i "$NIRI_ICON_PATH")
fi

clear_notification() {
    local type="$1"
    local id="$2"
    local file="$NIRI_STATE_DIR/${type}_${id}"

    if [[ -f "$file" ]]; then
        local notif_id
        notif_id=$(cat "$file" 2>/dev/null || true)
        if [[ -n "$notif_id" ]]; then
            notify-send -r "$notif_id" -e -a "niri" "${ICON_ARGS[@]}" -u low -t 1500 \
                "Urgent alert resolved" "Attention resolved." 2>/dev/null || true
        fi
        rm -f "$file"
    fi
}

urgency_hook() {
    local event="$1"
    local id="$2"
    local urgent="$3"
    local raw_json="$4"

    case "$event" in
        WindowUrgencyChanged)
            if [[ "$urgent" == "true" ]]; then
                date +%s > "$NIRI_STATE_DIR/last_win"

                if [[ ! -f "$NIRI_STATE_DIR/win_${id}" ]]; then
                    IFS=$'\t' read -r app title <<< "$(niri_get_window_info "$id")"

                    app="${app:-Application}"
                    title="${title:-ID $id}"

                    local notif_id
                    notif_id=$(notify-send -p -e -a "niri" "${ICON_ARGS[@]}" -u critical -t 0 "Urgent window" "$app: $title" 2>/dev/null || true)
                    if [[ -n "$notif_id" ]]; then
                        echo "$notif_id" > "$NIRI_STATE_DIR/win_${id}"
                    fi
                fi
            else
                clear_notification "win" "$id"
            fi
            ;;

        WorkspaceUrgencyChanged)
            if [[ "$urgent" == "true" ]]; then
                local win_ts
                win_ts=$(cat "$NIRI_STATE_DIR/last_win" 2>/dev/null || echo 0)

                (
                    sleep 0.15
                    local latest_win_ts now
                    latest_win_ts=$(cat "$NIRI_STATE_DIR/last_win" 2>/dev/null || echo 0)
                    now=$(date +%s)

                    if [[ "$latest_win_ts" -eq "$win_ts" ]] && (( (now - latest_win_ts) > 1 )) && [[ ! -f "$NIRI_STATE_DIR/ws_${id}" ]]; then
                        local notif_id
                        notif_id=$(notify-send -p -e -a "niri" "${ICON_ARGS[@]}" -u critical -t 0 "Urgent workspace" "Workspace $id has urgent windows." 2>/dev/null || true)
                        if [[ -n "$notif_id" ]]; then
                            echo "$notif_id" > "$NIRI_STATE_DIR/ws_${id}"
                        fi
                    fi
                ) &
            else
                clear_notification "ws" "$id"
            fi
            ;;

        WindowFocusChanged)
            if [[ -n "$id" ]]; then
                clear_notification "win" "$id"
            fi
            ;;
    esac
}

# Register hook function with the streamer
NIRI_HOOKS+=("urgency_hook")