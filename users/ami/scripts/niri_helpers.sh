#!/usr/bin/env bash

# TODO - Integrate https://sr.ht/~tsdh/nirius for better technical debt

export PATH="$PATH:/run/current-system/sw/bin:$HOME/.nix-profile/bin"

export MON_1="HDMI-A-1"
export MON_2="DP-1"

export TIMEOUT=50 # 50*0.02 = 1s

STATE_DIR="$HOME/.cache/niri-layouts"
STATE_FILE="$STATE_DIR/last_layout"
FLOAT_STATE_DIR="$HOME/.local/state/nirius-floating"

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

    # Close overview if it's active as that can break scratchpad stuff
    niri msg action close-overview 2>/dev/null || true

    # If ALREADY in scratchpad, do nothing cus that broke a LOT :p
    if is_in_scratchpad "$match_key" "$match_val"; then
        return 0
    fi

    fetch_windows

    # Collect all matching visible window IDs
    local win_ids
    mapfile -t win_ids < <(echo "$WINDOWS_JSON" | jq -r ".[] | select(.$match_key != null) | select(.$match_key | ascii_downcase | contains(\"${match_val,,}\")) | .id")

    local valid_ids=()
    for id in "${win_ids[@]}"; do
        [ -n "$id" ] && [ "$id" != "null" ] && valid_ids+=("$id")
    done

    if [ ${#valid_ids[@]} -gt 0 ]; then
        mkdir -p "$FLOAT_STATE_DIR"
        local moved_count=0

        for win_id in "${valid_ids[@]}"; do
            # Save floating/tiled state before parking
            local is_floating
            is_floating=$(echo "$WINDOWS_JSON" | jq -r ".[] | select(.id == $win_id) | .is_floating")
            echo "$is_floating" > "$FLOAT_STATE_DIR/$win_id"

            # Focus the specific window first so nirius targets it because even if we did by app_id or title if there are multiple matching windows for said flag it can cause confusion, so we'll just focus it and rely on that matching
            niri msg action focus-window --id "$win_id"

            local f_wait=0
            while [ "$f_wait" -lt "$TIMEOUT" ]; do
                if niri msg --json windows | jq -e ".[] | select(.id == $win_id and .is_focused == true)" >/dev/null 2>&1; then
                    break
                fi
                sleep 0.02
                ((f_wait++))
            done

            nirius scratchpad-toggle || true

            ((moved_count++))

            # Poll until window appears in nirius list-scratchpad
            local t=0
            while ! is_in_scratchpad "$match_key" "$match_val" && [ "$t" -lt "$TIMEOUT" ]; do
                sleep 0.02
                ((t++))
            done
        done

        if [ "$moved_count" -gt 0 ]; then
            local s=""; [ "$moved_count" -gt 1 ] && s="s"
            notify-send -e -a niri -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 \
                "Scratchpad stash" "Sent $moved_count window$s ($match_key: $match_val) to scratchpad"
        fi
    fi
}

restore_from_scratchpad() {
    local match_key="$1"
    local match_val="$2"

    # Close overview if it's active as that can break scratchpad stuff
    niri msg action close-overview 2>/dev/null || true

    local restored_count=0

    # Keep restoring as long as there are matching windows remaining in the scratchpad
    while is_in_scratchpad "$match_key" "$match_val"; do
        local prev_scratch_count
        prev_scratch_count=$(nirius list-scratchpad 2>/dev/null | grep -i -c "$match_val" || true)

        local scratch_key="$match_key"
        [ "$scratch_key" = "app_id" ] && scratch_key="app-id"

        local target_id
        target_id=$(nirius list-scratchpad 2>/dev/null | grep -i -E "${scratch_key}: Some\(\"[^\"]*${match_val}[^\"]*\"\)" | sed -n -E 's/^id: ([0-9]+).*/\1/p' | head -n 1)

        local status=0
        if [ -n "$target_id" ]; then
            nirius scratchpad-show --id "$target_id" || status=$?
        else
            break
        fi

        if [ "$status" -eq 0 ]; then
            ((restored_count++))

            # Immediately restore floating/tiled state BEFORE checking list-scratchpad
            if [ -n "$target_id" ] && [ -f "$FLOAT_STATE_DIR/$target_id" ]; then
                fetch_windows
                local was_float
                was_float=$(cat "$FLOAT_STATE_DIR/$target_id")
                local is_now_float
                is_now_float=$(echo "$WINDOWS_JSON" | jq -r ".[] | select(.id == $target_id) | .is_floating")

                if [ "$was_float" = "false" ] && [ "$is_now_float" = "true" ]; then
                    niri msg action focus-window --id "$target_id"
                    niri msg action toggle-window-floating
                fi
                rm -f "$FLOAT_STATE_DIR/$target_id"
            fi

            # NOW poll until nirius list-scratchpad count decreases
            local t=0
            while [ "$t" -lt "$TIMEOUT" ]; do
                local curr_scratch_count
                curr_scratch_count=$(nirius list-scratchpad 2>/dev/null | grep -i -c "$match_val" || true)
                [ "$curr_scratch_count" -lt "$prev_scratch_count" ] && break
                sleep 0.02
                ((t++))
            done
        else
            break
        fi
    done

    if [ "$restored_count" -gt 0 ]; then
        local s=""; [ "$restored_count" -gt 1 ] && s="s"
        notify-send -e -a niri -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 \
            "Scratchpad restore" "Restored $restored_count window$s ($match_key: $match_val) from scratchpad"
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
        while [ "$count" -lt 150 ]; do # 150*0.1=15s
            sleep 0.1
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