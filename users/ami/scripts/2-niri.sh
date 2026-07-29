#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/niri_helpers.sh"

# Check state. If it was the last state it will exit, otherwise update and continue
check_and_update_state "nea"

echo "Initing 'nea' window positions..."

ensure_window_exists "title" "main.pdf — hmon NEA Writeup" "evince ~/Documents/hmon-nea/out/main.pdf"
ensure_window_exists "title" "hmon-nea —" "zeditor ~/Documents/hmon-nea"
ensure_window_exists "title" "hmon —" "zeditor ~/Documents/hmon"

echo "Restoring 'nea' window positions..."

# 1st Monitor
move_windows "title" "main.pdf — hmon NEA Writeup" "$MON_1" "1" "33%" # Evince - put on the left of Zeditor to make moving between Zeditors easier
move_windows "title" "hmon-nea —" "$MON_1" "1" "67%" # Zeditor
move_windows "title" "hmon —" "$MON_1" "1" "100%" # Zeditor
move_windows "app_id" "ferdium" "$MON_1" "2" "100%"
move_windows "app_id" "anki" "$MON_1" "3" "100%"

# Not really wanted in this configuration but in case they are open, move them to the 1st monitor as well
move_windows "app_id" "affinity.exe" "$MON_1" "4"
move_windows "app_id" "org.kde.dolphin" "$MON_1" "4"

# 2nd monitor
move_windows "title" "anytype" "$MON_2" "1" "100%"
move_windows "app_id" "zen-beta" "$MON_2" "2" "100%"
move_windows "app_id" "remmina" "$MON_2" "3" "100%"

# Focus windows
focus_window "app_id" "zen-beta"
focus_window "title" "hmon-nea —"

echo "Window rearrangement complete!"