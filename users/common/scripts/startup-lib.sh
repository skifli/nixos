#!/usr/bin/env bash
# Shared startup library for niri session initialisation
# Source this in your startup.sh: source "$HOME/.local/bin/startup-lib.sh"

log() {
    printf '%s [startup] %s\n' "$(date +'%F %T')" "$*"
}

# Overridable from startup.sh or the environment.
STARTUP_APP_TIMEOUT="${STARTUP_APP_TIMEOUT:-60}"
STARTUP_POLL_INTERVAL="${STARTUP_POLL_INTERVAL:-0.25}"
STARTUP_KEYRING_TIMEOUT="${STARTUP_KEYRING_TIMEOUT:-300}"

# Arguments:
#   cmd:        To run - e.g., ("anki", "anytype").
#   key:        Target window property JSON filter ("app_id" or "title").
#   val:        Value string used inside regex match tracking.
#   target_mon: Specific target monitor string ID (e.g., "DP-1").
#   target_ws:  Target workspace string indicator.
start_and_manage() {
    local cmd="$1"
    local key="$2"
    local val="$3"
    local target_mon="$4"
    local target_ws="$5"

    (
        local started=$SECONDS
        local app_pid win_id=""

        log "launching: ${cmd}"
        eval "${cmd} &"
        app_pid=$!

        # Poll for the window, but never forever: a crashed app can leave
        # this loop loopin for hours (and made the journal look empty).
        while [ $((SECONDS - started)) -lt "$STARTUP_APP_TIMEOUT" ]; do
            win_id=$(niri msg --json windows 2>/dev/null | jq -r --arg k "$key" --arg v "$val" '
              .[] | select(.[$k] != null and (.[$k] | ascii_downcase | contains($v | ascii_downcase))) | .id
            ' 2>/dev/null | head -n 1)

            [ -n "$win_id" ] && break

            # Give wrappers a few seconds to exec/fork before treating an exit
            # as a failure, then bail out early instead of polling for a minute.
            if [ $((SECONDS - started)) -ge 5 ] && ! kill -0 "$app_pid" 2>/dev/null; then
                log "WARNING: ${cmd} exited before opening a matching window"
                return 0
            fi

            sleep "$STARTUP_POLL_INTERVAL"
        done

        if [ -z "$win_id" ]; then
            if kill -0 "$app_pid" 2>/dev/null; then
                log "WARNING: ${cmd} produced no matching window within ${STARTUP_APP_TIMEOUT}s (still running)"
            else
                log "WARNING: ${cmd} produced no matching window within ${STARTUP_APP_TIMEOUT}s (already exited)"
            fi
            return 0
        fi

        log "found window ${win_id} for ${cmd}"

        if [ -n "$target_mon" ]; then
            niri msg action move-window-to-monitor --id "$win_id" "${target_mon}" \
                || log "WARNING: could not move ${cmd} to monitor ${target_mon}"
        fi
        if [ -n "$target_ws" ]; then
            niri msg action move-window-to-workspace "${target_ws}" --window-id "$win_id" \
                || log "WARNING: could not move ${cmd} to workspace ${target_ws}"
        fi
    )
}

is_any_keyring_locked() {
    local l_login l_def
    l_login=$(busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/login org.freedesktop.Secret.Collection Locked 2>/dev/null | awk '{print $2}')
    l_def=$(busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/Default_5fkeyring org.freedesktop.Secret.Collection Locked 2>/dev/null | awk '{print $2}')
    # Treat a missing D-Bus service/collection as not ready. Only report
    # unlocked after both collections were queried successfully.
    [ "$l_login" = "false" ] && [ "$l_def" = "false" ] && return 1
    return 0
}

# As all keyring dependent applications are not open yet, the gcr prompt will not show / automatically hide. So, this prompts it with dummy values to cause it to prompt the user via the GUI first. Done this early just to give it as much time to spawn the GUI.
# Do as early as possible though to give time for the GUI to exist
# And redirect stdin to /dev/null to avoid it blocking the script if it prompts for input (which is probably why something still hung all my startup stuff...)

# Make non-overlapping Secret Service requests so GCR can reopen an unlock
# prompt if it closes. Let each request exit naturally; killing a client while
# a D-Bus call is in flight can trigger a GNOME Keyring 50.0 assertion crash.
spawn_keyring_poll() {
    (
        local deadline=$((SECONDS + STARTUP_KEYRING_TIMEOUT))
        while is_any_keyring_locked; do
            if [ "$SECONDS" -ge "$deadline" ]; then
                log "keyring still locked after ${STARTUP_KEYRING_TIMEOUT}s; stopping prompt retries"
                return 0
            fi

            log "requesting keyring unlock prompt"
            # Suppress command output: secret-tool can print stored item data.
            secret-tool search --all --unlock xdg:schema org.freedesktop.Secret.Generic \
                </dev/null >/dev/null 2>&1 &
            local secret_pid=$!

            # Focus the prompt once if it appears, but leave the request alive.
            for _ in $(seq 1 60); do
                if ! kill -0 "$secret_pid" 2>/dev/null; then
                    break
                fi
                if niri msg --json windows 2>/dev/null | jq -e \
                    'any(.[]; .app_id == "gcr-prompter")' >/dev/null 2>&1; then
                    nirius focus --app-id gcr-prompter || true
                    break
                fi
                sleep 0.5
            done

            # Never overlap requests or cancel a live D-Bus call.
            wait "$secret_pid" 2>/dev/null || true
            if is_any_keyring_locked; then
                log "unlock request ended while keyring remains locked; retrying after a short pause"
                sleep 5
            fi
        done

        log "keyring unlocked"
    ) & disown
}

# Wait for keyring to unlock, then run the provided commands
# Usage: wait_for_keyring_then "cmd1" "cmd2" ...
wait_for_keyring_then() {
    (
        notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Locked" "Waiting for keyring to be unlocked..."
        log "waiting for keyring to unlock (timeout ${STARTUP_KEYRING_TIMEOUT}s)"

        local deadline=$((SECONDS + STARTUP_KEYRING_TIMEOUT))
        while is_any_keyring_locked; do
            if [ "$SECONDS" -ge "$deadline" ]; then
                log "WARNING: keyring still locked after ${STARTUP_KEYRING_TIMEOUT}s; skipping: $*"
                return 0
            fi
            sleep 0.5
        done

        log "keyring unlocked"
        notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Unlocked" "Launching keyring-dependent apps..."

        sleep 1 # Just a tad of a delay to ensure the keyring is fully ready for use

        for cmd in "$@"; do
            eval "$cmd"
        done

        wait # As we are in a subshell, this wait is for the background jobs in this subshell only

        notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Post-keyring apps" "Apps spawned"
    ) &
}

# Wait until NetworkManager says there is an established connection so apps that
# sync/phone-home on launch (anki, ferdium, anytype, ...) don't race w/ the wifi
# association + DHCP at startup. Times out so we technically won't block the session.
wait_for_network() {
    local timeout="${1:-60}"

    for _ in $(seq 1 "$timeout"); do
        if nmcli -t -f STATE general 2>/dev/null | grep -qx connected; then
            return 0
        fi

        sleep 1
    done

    log "WARNING: network not connected after ${timeout}s"
    return 1
}

# niri starts xwayland-satellite lazily when the first X11 client connects.
wait_for_xwayland() {
    local timeout="${1:-20}"
    local display="${DISPLAY:-:0}"
    local num="${display#*:}"

    num="${num%%.*}"

    if ! command -v python3 >/dev/null 2>&1; then
        log "WARNING: python3 not found; cannot probe Xwayland"
        return 1
    fi

    local started=$SECONDS
    while [ $((SECONDS - started)) -lt "$timeout" ]; do
        if python3 - "$num" >/dev/null 2>&1 <<'PY'
import socket, struct, sys

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.settimeout(2)
sock.connect("\0/tmp/.X11-unix/X" + sys.argv[1])
# Little-endian X11 connection setup: protocol 11.0, no auth data.
sock.sendall(struct.pack("<BxHHHH2x", 0x6C, 11, 0, 0, 0))
raise SystemExit(0 if sock.recv(8)[:1] == b"\x01" else 1)
PY
        then
            log "Xwayland ready on ${display}"
            return 0
        fi

        sleep 0.25
    done

    log "WARNING: Xwayland not ready after ${timeout}s"
    return 1
}
