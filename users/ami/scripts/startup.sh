#!/usr/bin/env bash

FOCUSED_MONITOR="${1:-}"
SECOND_MONITOR="${2:-}"

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
            niri msg action move-window-to-monitor --id "$WIN_ID" "${target_mon}"
            niri msg action move-window-to-workspace "${target_ws}" --window-id "$WIN_ID"
        fi
    ) &
}

notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Locked" "Polling for keyring unlock..."

# As all keyring dependent applications are not open yet, the gcr prompt will not show / automatically hide. So, this prompts it with dummy values to cause it to prompt the user via the GUI first. Done this early just to give it as much time to spawn the GUI.
# Do as early as possible though to give time for the GUI to exist
# And redirect stdin to /dev/null to avoid it blocking the script if it prompts for input (which is probably why something still hung all my startup stuff...)

# Loop the secret-tool dummy lookup safely without overlapping windows because I think it sometimes times out awaiting user input which is annoying
(
    while true; do
        # 1. Always check lock status FIRST before spawning
        IS_LOCKED=$(busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/aliases/default org.freedesktop.Secret.Collection Locked 2>/dev/null | awk '{print $2}')
        if [ "$IS_LOCKED" = "false" ]; then
            break # Keyring is unlocked, exit loop!
        fi

        # 2. Fire off the prompt in the background
        secret-tool lookup xdg:schema org.freedesktop.Secret.Generic </dev/null >/tmp/secret-tool.log 2>&1 & # Redirects stdout to a log file not dev/null, but stdin is dev/null
        SECRET_PID=$!

        # 3. Poll lock status every second for up to 25 seconds
        # I THINK 25 is the standard d-bus method call timeout? Idk!
        for i in $(seq 1 25); do
            nirius focus --app-id gcr-prompter # Thanks to nirius - before it was this behemoth - niri msg action focus-window --id $(niri msg --json windows | jq -r '.[] | select(.app_id == "gcr-prompter") | .id' | head -n 1)

            sleep 1

            IS_LOCKED=$(busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/aliases/default org.freedesktop.Secret.Collection Locked 2>/dev/null | awk '{print $2}')

            if [ "$IS_LOCKED" = "false" ]; then
                kill $SECRET_PID 2>/dev/null
                break 2 # Break out of the main while-loop
            fi

            # If secret-tool died/timed-out early on its own, break the inner loop to spawn a new one
            if ! kill -0 $SECRET_PID 2>/dev/null; then
                break
            fi
        done

        # 4. Cleanup old PID if it's still alive after 25 seconds before restarting loop
        kill $SECRET_PID 2>/dev/null
        wait $SECRET_PID 2>/dev/null
    done
) & disown

# Apps that don't need keyring unlock
start_and_manage "zen-beta" "app_id" "zen-beta" "$FOCUSED_MONITOR" "1"
start_and_manage "anki" "title" "User 1 - Anki" "$FOCUSED_MONITOR" "2" # Otherwise it would sometimes just move the syncing window not the actual window which was annoying... tad of a workaround... but it works!
start_and_manage "ferdium" "app_id" "ferdium" "$SECOND_MONITOR" "2"

notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Pre-keyring apps" "Apps spawned"

# Bg process: wait for keyring to be unlocked, then launch apps that depend on the keyring
(
  notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Locked" "Waiting for keyring to be unlocked..."

  while [ "$(busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/aliases/default org.freedesktop.Secret.Collection Locked 2>/dev/null | awk '{print $2}')" != "false" ]; do
    sleep 0.5
  done

  notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Unlocked" "Launching keyring-dependent apps..."

  sleep 1 # Just a tad of a delay to ensure the keyring is fully ready for use

  start_and_manage "anytype" "app_id" "anytype" "$SECOND_MONITOR" "1"

  # Safeyes is NOT keyring dependant, but one time wayle took a while to starup and it meant safeeyes' tray icon dependency popped up with an error and the only options were disable it or quit - so I had to do a manual restart. So, just to be safe it has been plopped here because by now waiting for the unlock means in the meantime wayle has DEFINITELY started and registered for notifications, etc
  safeeyes & disown

  wait # As we are in a subshell, this wait is for the background jobs in this subshell only

  notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Post-keyring apps" "Apps spawned"
) &

# Now wait for all background startAndManage jobs to finish
wait

niri msg action focus-monitor "$FOCUSED_MONITOR"
niri msg action focus-workspace 1

notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 5000 "Startup complete" "All startup tasks completed"
