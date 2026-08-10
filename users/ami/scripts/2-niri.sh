#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/niri_helpers.sh"

notify-send -e -a niri -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u low -t 2500 "NEA configuration" "Initing window positions"

# Future me: For zed you can do e.g., :45:10 to put ze cursor on line 45, column 10
ensure_window_exists "org.gnome.Evince" "main.pdf — hmon NEA Writeup" "evince ~/Documents/hmon-nea/src/out/main.pdf" "org.gnome.Evince" "main.pdf — hmon NEA Writeup"
ensure_window_exists "dev.zed.Zed" "hmon-nea —" "zeditor ~/Documents/hmon-nea ~/Documents/hmon-nea/src/main.tex" "dev.zed.Zed" "hmon-nea —"
ensure_window_exists "dev.zed.Zed" "hmon —" "zeditor ~/Documents/hmon ~/Documents/hmon/src/main.c" "dev.zed.Zed" "hmon —"

# Check if the process is already running to avoid duplicates
if ! pgrep -f "zeditor-synctex.sh" > /dev/null; then
  notify-send -e -a niri -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u low -t 2500 "NEA configuration" "Launching Zed SyncTeX daemon"

  # 3>&- closes File Descriptor 3, stopping direnv from blocking
  bash ~/Documents/hmon-nea/src/zeditor-synctex.sh </dev/null >/dev/null 2>&1 3>&- &

  disown
fi

notify-send -e -a niri -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u low -t 2500 "NEA configuration" "Restoring window positions"

# 1st Monitor
move_windows "title" "main.pdf — hmon NEA Writeup" "$MON_1" "1" "33%" # Evince - put on the left of Zeditor to make moving between Zeditors easier
move_windows "title" "hmon-nea —" "$MON_1" "1" "67%" # Zeditor
move_windows "title" "hmon —" "$MON_1" "1" "100%" # Zeditor
move_windows "app_id" "gcr-prompter" "$MON_1" "1"
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
focus_window "title" "main.pdf — hmon NEA Writeup"
focus_window "app_id" "gcr-prompter"

notify-send -e -a niri -i "/home/${USER}/.local/share/misc/niri-icon.svg" -u low -t 2500 "NEA configuration" "Window positions restored"