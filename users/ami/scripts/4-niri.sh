#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/niri_helpers.sh"

notify-send -e -a niri -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Anki configuration" "Restoring window positions"

# Send distractions to the nirius scratchpad
send_to_scratchpad "app_id" "ferdium"
send_to_scratchpad "app_id" "xfreerdp"
send_to_scratchpad "app_id" "anytype"

send_to_scratchpad "app_id" "org.gnome.Evince"
send_to_scratchpad "app_id" "dev.zed.Zed"
send_to_scratchpad "app_id" "wineboot.exe"
send_to_scratchpad "app_id" "affinity.exe"
send_to_scratchpad "app_id" "org.kde.dolphin"

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