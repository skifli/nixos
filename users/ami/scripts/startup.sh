#!/usr/bin/env bash

# niri discards the stdout/stderr of spawn-at-startup commands. Keep a per-run log.
log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/startup"
mkdir -p "$log_dir"
log_file="$log_dir/startup-$(date +%Y%m%d-%H%M%S).log"
ln -sfn "$log_file" "$log_dir/latest.log"
find "$log_dir" -maxdepth 1 -name 'startup-*.log' -mtime +30 -delete 2>/dev/null || true
exec >>"$log_file" 2>&1
printf '\n===== %s startup.sh %s =====\n' "$(date +'%F %T')" "$*"

source "$HOME/.local/bin/startup-lib.sh"

FOCUSED_MONITOR="${1:-}"
SECOND_MONITOR="${2:-}"

notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Locked" "Polling for keyring unlock..."

# As all keyring dependent applications are not open yet, the gcr prompt will not show / automatically hide.
# So, this prompts it with dummy values to cause it to prompt the user via the GUI first.
# Done this early just to give it as much time to spawn the GUI.
# And redirect stdin to /dev/null to avoid it blocking the script if it prompts for input.
spawn_keyring_poll

# Launch all apps IMMEDIATELY in background so they open within niri's 60s
# at-startup window. Window rules with at-startup=true will place them.
# Network/Xwayland/keyring waits run in parallel.
log "launching all startup apps immediately for at-startup window rules"

# Pre-keyring apps (no keyring dependency) - window rules handle placement,
# so pass empty target_mon/target_ws to skip redundant moves in start_and_manage
start_and_manage "zen-beta" "app_id" "zen-beta" "" "" &
start_and_manage "anki" "title" "User 1 - Anki" "" "" &
start_and_manage "ferdium" "app_id" "ferdium" "" "" &

# Keyring-dependent apps launched after unlock (outside at-startup window)
# These still need manual moves since at-startup rules won't apply
wait_for_keyring_then \
    'start_and_manage "anytype" "app_id" "anytype" "$SECOND_MONITOR" "1"' \
    'safeeyes & disown' &

# Parallel waits (don't block app launches)
wait_for_network 60 || true &
wait_for_xwayland 20 || true &

# Wait for everything
wait
log "all startup jobs finished"

notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 5000 "Startup complete" "All startup tasks completed"
