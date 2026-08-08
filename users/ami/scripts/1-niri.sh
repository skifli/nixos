#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/niri_helpers.sh"

notify-send -e -a niri -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u low -t 1000 "Default configuration" "Restoring window positions"

# 1st Monitor
move_windows "app_id" "zen-beta" "$MON_1" "1" "100%"
move_windows "app_id" "anki" "$MON_1" "2" "100%"
move_windows "app_id" "gcr-prompter" "$MON_1" "2"

# Not really wanted in this configuration but in case they are open, move them to the 1st monitor as well
move_windows "app_id" "org.gnome.Evince" "$MON_1" "3"
move_windows "app_id" "dev.zed.Zed" "$MON_1" "3"
move_windows "app_id" "affinity.exe" "$MON_1" "3"
move_windows "app_id" "org.kde.dolphin" "$MON_1" "3"

# 2nd Monitor
move_windows "title" "anytype" "$MON_2" "1" "100%"
move_windows "app_id" "ferdium" "$MON_2" "2" "100%"
move_windows "app_id" "remmina" "$MON_2" "3" "100%"

# Focus windows
focus_window "app_id" "ferdium"
focus_window "app_id" "anki"
focus_window "app_id" "gcr-prompter"

notify-send -e -a niri -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u low -t 1000 "Default configuration" "Window positions restored"