#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/niri_helpers.sh"

echo "Initing 'f1is' window positions..."

ensure_window_exists "affinity.exe" "" "affinity-v3" "wineboot.exe" "Wine"

echo "Restoring 'f1is' window positions..."

# 1st Monitor
move_windows "app_id" "zen-beta" "$MON_1" "1" "100%"
move_windows "app_id" "wineboot.exe " "$MON_1" "2" # Affinity booting-up
move_windows "app_id" "affinity.exe" "$MON_1" "2" "100%"
move_windows "app_id" "anki" "$MON_1" "3" "100%"

# Not really wanted in this configuration but in case they are open, move them to the 1st monitor as well
move_windows "app_id" "org.gnome.Evince" "$MON_1" "4"
move_windows "app_id" "dev.zed.Zed" "$MON_1" "4"
move_windows "app_id" "org.kde.dolphin" "$MON_1" "4"

# 2nd monitor
move_windows "title" "anytype" "$MON_2" "1" "100%"
move_windows "app_id" "ferdium" "$MON_2" "2" "100%"
move_windows "app_id" "remmina" "$MON_2" "3" "100%"

# Focus windows
focus_window "app_id" "ferdium"
focus_window "app_id" "wineboot.exe" # Affinity booting-up
focus_window "app_id" "affinity.exe"

echo "Window rearrangement complete!"