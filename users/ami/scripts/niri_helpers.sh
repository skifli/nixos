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

window_exists() {
    local match_key="$1"
    local match_val="${2,,}"

    fetch_windows
    echo "$WINDOWS_JSON" | jq -e \
        --arg k "$match_key" \
        --arg v "$match_val" \
        '.[] | select(.[$k] != null and (.[$k] | ascii_downcase | contains($v)))' >/dev/null
}

is_in_scratchpad() {
    local match_key="$1"
    local match_val="${2,,}"

    local scratch_list
    scratch_list=$(nirius list-scratchpad 2>/dev/null || true)
    [ -z "$scratch_list" ] && return 1

    if [ "$match_key" = "app_id" ]; then
        echo "$scratch_list" | grep -i -E "app-id: Some\(\"[^\"]*${match_val}[^\"]*\"\)" >/dev/null
    elif [ "$match_key" = "title" ]; then
        echo "$scratch_list" | grep -i -E "title: Some\(\"[^\"]*${match_val}[^\"]*\"\)" >/dev/null
    fi
}

send_to_scratchpad() {
    local match_key="$1"
    local match_val="$2"

    # Only toggle if the window EXISTS AND is NOT already in the scratchpad
    if window_exists "$match_key" "$match_val" && ! is_in_scratchpad "$match_key" "$match_val"; then
        local attempts=0
        local max_attempts=5

        while ! is_in_scratchpad "$match_key" "$match_val" && [ "$attempts" -lt "$max_attempts" ]; do
            if [ "$match_key" = "app_id" ]; then
                nirius scratchpad-toggle -a "$match_val" || true
            elif [ "$match_key" = "title" ]; then
                nirius scratchpad-toggle -t "$match_val" || true
            fi

            ((attempts++))
            sleep 0.15  # Gives niriusd time to process so it doesn't accidentally toggle it back out
        done

        # Send notification if it successfully landed in the scratchpad
        if is_in_scratchpad "$match_key" "$match_val"; then
            notify-send -e -a niri -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 \
                "Scratchpad stash" "Sent window with $match_key: $match_val to scratchpad"
        fi
    fi
}

restore_from_scratchpad() {
    local match_key="$1"
    local match_val="$2"

    # is_in_scratchpad already checks list-scratchpad, which therefore verifies existence in scratchpad
    if is_in_scratchpad "$match_key" "$match_val"; then
        local status=0
        if [ "$match_key" = "app_id" ]; then
            nirius scratchpad-toggle -a "$match_val" || status=$?
        elif [ "$match_key" = "title" ]; then
            nirius scratchpad-toggle -t "$match_val" || status=$?
        fi

        # Send notification only if nirius succeeded
        if [ "$status" -eq 0 ]; then
            notify-send -e -a niri -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 \
                "Scratchpad restore" "Restored window with $match_key: $match_val from scratchpad"
        fi
    fi
}

move_windows() {
    local match_key="$1"
    local match_val="$2"
    local target_mon="$3"
    local target_ws="$4"
    local target_width="$5"

    # Automatically un-scratchpad the window if it's hidden in the scratchpad
    restore_from_scratchpad "$match_key" "$match_val"

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

            # Check if 100% width is requested and the window is currently floating
            if [ "$target_width" = "100%" ]; then
                local is_floating
                is_floating=$(echo "$WINDOWS_JSON" | jq -r ".[] | select(.id == $win_id) | .is_floating")
                
                if [ "$is_floating" = "true" ]; then
                    niri msg action toggle-window-floating
                fi
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
