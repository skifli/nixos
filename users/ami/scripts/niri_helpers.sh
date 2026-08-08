#!/usr/bin/env bash

# TODO - Integrate https://sr.ht/~tsdh/nirius for better technical debt

export PATH="$PATH:/run/current-system/sw/bin:$HOME/.nix-profile/bin"

export MON_1="HDMI-A-1"
export MON_2="DP-1"

STATE_DIR="$HOME/.cache/niri-layouts"
STATE_FILE="$STATE_DIR/last_layout"

fetch_windows() {
    WINDOWS_JSON=$(niri msg --json windows)
}

# Initial fetch
fetch_windows

move_windows() {
    local match_key="$1"
    local match_val="$2"
    local target_mon="$3"
    local target_ws="$4"
    local target_width="$5"

    fetch_windows

    while read -r win_id; do
        if [ -n "$win_id" ]; then
            niri msg action focus-window --id "$win_id"
            
            if [ "$target_mon" = "$MON_2" ]; then
                niri msg action move-column-to-monitor-right
            else
                niri msg action move-column-to-monitor-left
            fi
            
            niri msg action focus-monitor "$target_mon"
            niri msg action move-column-to-workspace "$target_ws"
                
            if [ -n "$target_width" ] && [ "$target_width" != "1/1" ]; then
                niri msg action set-column-width "$target_width"
            fi
        fi
    done < <(niri msg --json windows | jq -r ".[] | select(.$match_key != null) | select(.$match_key | ascii_downcase | contains(\"${match_val,,}\")) | .id")
}

ensure_window_exists() {
    local match_app_id="$1"
    local match_title="$2"
    local fallback_cmd="$3"
    local watch_app_id="$4"
    local watch_title="$5"

    local exists

    exists=$(echo "$WINDOWS_JSON" | jq -e \
        --arg app "${match_app_id,,}" \
        --arg title "${match_title,,}" \
        '.[] | select((.app_id != null and (.app_id | ascii_downcase | contains($app))) and (.title != null and (.title | ascii_downcase | contains($title))))' >/dev/null; echo $?)

    if [ "$exists" -ne 0 ]; then
        local app_name=""
        if [ -n "$match_title" ]; then
            app_name="$match_title"
        elif [ -n "$match_app_id" ]; then
            app_name="$match_app_id"
        else
            app_name="application"
        fi

        # -t 0 tells the notification server never to auto-expire it
        local notif_id
        notif_id=$(notify-send -p -e -a niri -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u low -t 0 \
            "Starting $app_name" \
            "Window not found - launching...")
        
        eval "$fallback_cmd &"
        
        local count=0
        while [ "$count" -lt 30 ]; do
            sleep 0.5
            fetch_windows
            
            if echo "$WINDOWS_JSON" | jq -e \
                --arg w_app "${watch_app_id,,}" \
                --arg w_title "${watch_title,,}" \
                '.[] | select((.app_id != null and (.app_id | ascii_downcase | contains($w_app))) and (.title != null and (.title | ascii_downcase | contains($w_title))))' >/dev/null; then
                
                if [ -n "$notif_id" ]; then
                    # -r means replace, so replace old notification with id notif_id
                    notify-send -r "$notif_id" -e -a niri -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u low -t 2500 \
                        "$app_name ready" \
                        "Window detected successfully."
                fi
                return 0
            fi
            ((count++))
        done
                
        if [ -n "$notif_id" ]; then
            notify-send -r "$notif_id" -e -a niri -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u normal -t 5000 \
                "$app_name Launch timeout" \
                "The window was not detected successfully."
        fi
    else
        echo "Specific window configuration already exists. Skipping launch."
    fi
}

focus_window() {
    local match_key="$1"
    local match_val="$2"

    fetch_windows
    local win_id
    win_id=$(echo "$WINDOWS_JSON" | jq -r ".[] | select(.$match_key != null) | select(.$match_key | ascii_downcase | contains(\"${match_val,,}\")) | .id" | head -n 1)

    if [ -n "$win_id" ]; then
        niri msg action focus-window --id "$win_id"
    else
        echo "Window '$match_val' not found to focus."
    fi
}
