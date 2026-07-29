#!/usr/bin/env bash

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
    local match_key="$1"
    local match_val="$2"
    local fallback_cmd="$3"

    local exists
    exists=$(echo "$WINDOWS_JSON" | jq -e --arg val "${match_val,,}" --arg key "$match_key" \
        '.[] | select(.[$key] != null and (.[$key] | ascii_downcase | contains($val)))' >/dev/null; echo $?)

    if [ "$exists" -ne 0 ]; then
        echo "Window '$match_val' not found. Running: $fallback_cmd"
        eval "$fallback_cmd &"
        
        local count=0
        while [ "$count" -lt 120 ]; do
            sleep 0.5
            fetch_windows
            
            if echo "$WINDOWS_JSON" | jq -e --arg val "${match_val,,}" --arg key "$match_key" \
                '.[] | select(.[$key] != null and (.[$key] | ascii_downcase | contains($val)))' >/dev/null; then
                echo "Window '$match_val' has appeared."
                return 0
            fi
            ((count++))
        done
        echo "Warning: Timeout reached waiting for '$match_val' to appear."
    else
        echo "Window '$match_val' already exists. Skipping command."
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

check_and_update_state() {
    local requested_layout="$1"
    
    mkdir -p "$STATE_DIR"
    
    if [ -f "$STATE_FILE" ]; then
        local last_layout
        last_layout=$(cat "$STATE_FILE")
        
        if [ "$last_layout" = "$requested_layout" ]; then
            echo "Windows are already arranged in the '$requested_layout' layout. Exiting."
            exit 0
        fi
    fi
    
    echo "$requested_layout" > "$STATE_FILE"
}
