#!/usr/bin/env bash
# Shared startup library for niri session initialisation
# Source this in your startup.sh: source "$HOME/.local/bin/startup-lib.sh"

# Arguments:
#   cmd:        To run - e.g., ("anki", "anytype").
#   key:        Target window property JSON filter ("app_id" or "title").
#   val:        Value string used inside regex match tracking.
#   target_mon: Specific target monitor string ID (e.g., "DP-1").
#   target_ws:  Target workspace string indicator.
start_and_manage() {
    local cmd="$1"
    local key="$2"
    local val="$3"
    local target_mon="$4"
    local target_ws="$5"

    (
        eval "${cmd} &"
        while ! niri msg --json windows 2>/dev/null | grep -qi "\"${key}\": *\"[^\"]*${val}"; do
            sleep 0.1
        done

        WIN_ID=$(niri msg --json windows 2>/dev/null | jq -r --arg k "$key" --arg v "$val" '
          .[] | select(.[$k] != null and (.[$k] | ascii_downcase | contains($v | ascii_downcase))) | .id
        ' 2>/dev/null | head -n 1)

        if [ -n "$WIN_ID" ]; then
            if [ -n "$target_mon" ]; then
                niri msg action move-window-to-monitor --id "$WIN_ID" "${target_mon}"
            fi
            niri msg action move-window-to-workspace "${target_ws}" --window-id "$WIN_ID"
        fi
    ) &
}

is_any_keyring_locked() {
    local l_login l_def
    l_login=$(busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/login org.freedesktop.Secret.Collection Locked 2>/dev/null | awk '{print $2}')
    l_def=$(busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/Default_5fkeyring org.freedesktop.Secret.Collection Locked 2>/dev/null | awk '{print $2}')
    [ "$l_login" = "true" ] || [ "$l_def" = "true" ]
}

# As all keyring dependent applications are not open yet, the gcr prompt will not show / automatically hide. So, this prompts it with dummy values to cause it to prompt the user via the GUI first. Done this early just to give it as much time to spawn the GUI.
# Do as early as possible though to give time for the GUI to exist
# And redirect stdin to /dev/null to avoid it blocking the script if it prompts for input (which is probably why something still hung all my startup stuff...)

# Loop the secret-tool dummy lookup safely without overlapping windows because I think it sometimes times out awaiting user input which is annoying
spawn_keyring_poll() {
    (
        while true; do
            if ! is_any_keyring_locked; then
                break
            fi

            secret-tool search --all --unlock xdg:schema org.freedesktop.Secret.Generic </dev/null >/tmp/secret-tool.log 2>&1 & # Redirects stdout to a log file not dev/null, but stdin is dev/null
            SECRET_PID=$!

            # Polls lock status every second for up to 25 seconds
            # I THINK 25 is the standard d-bus method call timeout? Idk!
            for i in $(seq 1 25); do
                nirius focus --app-id gcr-prompter # Thanks to nirius - before it was this behemoth - niri msg action focus-window --id $(niri msg --json windows | jq -r '.[] | select(.app_id == "gcr-prompter") | .id' | head -n 1)

                sleep 1

                if ! is_any_keyring_locked; then
                    kill $SECRET_PID 2>/dev/null
                    break 2 # Break out of the main while-loop
                fi

                # If secret-tool died/timed-out early on its own, break the inner loop to spawn a new one
                if ! kill -0 $SECRET_PID 2>/dev/null; then
                    break
                fi
            done

            # Cleanup old PID if it's still alive after 25 seconds before restarting loop
            kill $SECRET_PID 2>/dev/null
            wait $SECRET_PID 2>/dev/null
        done
    ) & disown
}

# Wait for keyring to unlock, then run the provided commands
# Usage: wait_for_keyring_then "cmd1" "cmd2" ...
wait_for_keyring_then() {
    (
        notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Locked" "Waiting for keyring to be unlocked..."

        while is_any_keyring_locked; do
            sleep 0.5
        done

        notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Unlocked" "Launching keyring-dependent apps..."

        sleep 1 # Just a tad of a delay to ensure the keyring is fully ready for use

        for cmd in "$@"; do
            eval "$cmd"
        done

        wait # As we are in a subshell, this wait is for the background jobs in this subshell only

        notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Post-keyring apps" "Apps spawned"
    ) &
}

# Wait until NetworkManager says there is an established connection so apps that
# sync/phone-home on launch (anki, ferdium, anytype, ...) don't race w/ the wifi
# association + DHCP at startup. Times out so we technically won't block the session.
wait_for_network() {
    local timeout="${1:-60}"

    for _ in $(seq 1 "$timeout"); do
        if nmcli -t -f STATE general 2>/dev/null | grep -qx connected; then
            return 0
        fi

        sleep 1
    done

    return 1
}
