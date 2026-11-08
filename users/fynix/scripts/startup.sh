#!/usr/bin/env bash

source "$HOME/.local/bin/startup-lib.sh"

notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Locked" "Polling for keyring unlock..."

spawn_keyring_poll

wait_for_network 60 || true

# All apps on fydetabduo
start_and_manage "ferdium" "app_id" "ferdium" "" "1"
start_and_manage "zen-beta" "app_id" "zen-beta" "" "2"
start_and_manage "anki" "title" "User 1 - Anki" "" "3"
start_and_manage "anytype" "app_id" "anytype" "" "4"

notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Pre-keyring apps" "Apps spawned"

wait_for_keyring_then

wait

niri msg action focus-workspace 1

notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 5000 "Startup complete" "All startup tasks completed"
