#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/niri_helpers.sh"

notify-send -e -a niri -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Anki configuration" "Restoring window positions"

# Send distractions to the nirius scratchpad
send_to_scratchpad "app_id" "ferdium"
send_to_scratchpad "title" "TigerVNC"
send_to_scratchpad "app_id" "anytype"

send_to_scratchpad "app_id" "org.gnome.Evince"
send_to_scratchpad "app_id" "dev.zed.Zed"
send_to_scratchpad "app_id" "wineboot.exe"
send_to_scratchpad "app_id" "affinity.exe"
send_to_scratchpad "app_id" "org.kde.dolphin"

# Anki Pomodoro stuff

if is_in_scratchpad "title" "Anki Pomodoro"; then
    restore_from_scratchpad "title" "Anki Pomodoro"
else
    ensure_window_exists "com.mitchellh.ghostty" "Anki Pomodoro" "${BASH_SOURCE%/*}/floating-term.sh ghostty -w 50% -h 30% --title='Anki Pomodoro' -e ${BASH_SOURCE%/*}/anki-pomodoro.sh" "com.mitchellh.ghostty" "Anki Pomodoro"
fi

# 1st Monitor
move_windows "app_id" "anki" "$MON_1" "1" "100%"
move_windows "app_id" "gcr-prompter" "$MON_1" "1"

# 2nd Monitor
move_windows "app_id" "zen-beta" "$MON_2" "1" "100%"
move_windows "title" "Anki Pomodoro" "$MON_2" "1" "50%"

# Focus windows
focus_window "app_id" "anki"
focus_window "app_id" "zen-beta"
focus_window "title" "Anki Pomodoro"
focus_window "app_id" "gcr-prompter"

notify-send -e -a niri -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Anki configuration" "Window positions restored"
