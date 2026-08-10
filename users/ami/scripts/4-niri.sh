#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/niri_helpers.sh"

notify-send -e -a niri -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Anki configuration" "Restoring window positions"

# Not really wanted in this configuration but in case they are open, move them out the way
DISTRACTIONS=( ferdium remmina anytype )

for APP in "${DISTRACTIONS[@]}"; do
    move_windows app_id "$APP" "$MON_2" "5" || true
done

# 1st Monitor
move_windows app_id "anki" "$MON_1" "1" "100%"
move_windows "app_id" "gcr-prompter" "$MON_1" "1"

# 2nd Monitor
move_windows app_id "zen-beta" "$MON_2" "1" "100%"

# Focus windows
focus_window "app_id" "anki"
focus_window "app_id" "zen-beta"
focus_window "app_id" "gcr-prompter"

notify-send -e -a niri -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Anki configuration" "Window positions restored"
