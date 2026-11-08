#!/usr/bin/env bash

source "$HOME/.local/bin/startup-lib.sh"

FOCUSED_MONITOR="${1:-}"
SECOND_MONITOR="${2:-}"

notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Locked" "Polling for keyring unlock..."

# As all keyring dependent applications are not open yet, the gcr prompt will not show / automatically hide.
# So, this prompts it with dummy values to cause it to prompt the user via the GUI first.
# Done this early just to give it as much time to spawn the GUI.
# And redirect stdin to /dev/null to avoid it blocking the script if it prompts for input.
spawn_keyring_poll

wait_for_network 60 || true

# Apps that don't need keyring unlock
start_and_manage "zen-beta" "app_id" "zen-beta" "$FOCUSED_MONITOR" "1"
start_and_manage "anki" "title" "User 1 - Anki" "$FOCUSED_MONITOR" "2" # Otherwise it would sometimes just move the syncing window not the actual window which was annoying... tad of a workaround... but it works!
start_and_manage "ferdium" "app_id" "ferdium" "$SECOND_MONITOR" "2"

notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Pre-keyring apps" "Apps spawned"

# Bg process: wait for keyring to be unlocked, then launch apps that depend on the keyring
# Safeyes is NOT keyring dependant, but one time wayle took a while to starup and it meant safeeyes' tray icon dependency popped up with an error and the only options were disable it or quit - so I had to do a manual restart. So, just to be safe it has been plopped here because by now waiting for the unlock means in the meantime wayle has DEFINITELY started and registered for notifications, etc
wait_for_keyring_then \
    'start_and_manage "anytype" "app_id" "anytype" "$SECOND_MONITOR" "1"' \
    'safeeyes & disown'

# Now wait for all background startAndManage jobs to finish
wait

niri msg action focus-monitor "$FOCUSED_MONITOR"
niri msg action focus-workspace 1

notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 5000 "Startup complete" "All startup tasks completed"
