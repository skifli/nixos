#!/usr/bin/env bash

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

    return 1
}

start_and_manage() {
    local cmd="$1"
    local key="$2"
    local val="$3"
    local target_ws="$4"

    (
        eval "${cmd} &"
        while ! niri msg --json windows 2>/dev/null | grep -qi "\"${key}\": *\"[^\"]*${val}"; do
            sleep 0.1
        done

        WIN_ID=$(niri msg --json windows 2>/dev/null | jq -r --arg k "$key" --arg v "$val" '
          .[] | select(.[$k] != null and (.[$k] | ascii_downcase | contains($v | ascii_downcase))) | .id
        ' 2>/dev/null | head -n 1)

        if [ -n "$WIN_ID" ]; then
            niri msg action move-window-to-workspace "${target_ws}" --window-id "$WIN_ID"
        fi
    ) &
}

is_any_keyring_locked() {
    local l_login l_def
    l_login=$(busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/login org.freedesktop.Secret.Collection Locked 2>/dev/null | awk '{print $2}')
    l_def=$(busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/Default_5fkeyring org.freedesktop.Secret.Collection Locked 2>/dev/null | awk '{print $2}')
    [ "$l_login" = "true" ] || [ "$l_def" = "true" ]
}

notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Locked" "Polling for keyring unlock..."

(
    while true; do
        if ! is_any_keyring_locked; then
            break
        fi

        secret-tool search --all --unlock xdg:schema org.freedesktop.Secret.Generic </dev/null >/tmp/secret-tool.log 2>&1 &
        SECRET_PID=$!

        for i in $(seq 1 25); do
            nirius focus --app-id gcr-prompter

            sleep 1

            if ! is_any_keyring_locked; then
                kill $SECRET_PID 2>/dev/null
                break 2
            fi

            if ! kill -0 $SECRET_PID 2>/dev/null; then
                break
            fi
        done

        kill $SECRET_PID 2>/dev/null
        wait $SECRET_PID 2>/dev/null
    done
) & disown

wait_for_network 60 || true
start_and_manage "ferdium" "app_id" "ferdium" "1"
start_and_manage "zen-beta" "app_id" "zen-beta" "2"
start_and_manage "anki" "title" "User 1 - Anki" "3"
start_and_manage "anytype" "app_id" "anytype" "4"

notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Pre-keyring apps" "Apps spawned"

(
  notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Locked" "Waiting for keyring to be unlocked..."

  while is_any_keyring_locked; do
    sleep 0.5
  done

  notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Unlocked" "Keyring ready"

  wait

  notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Post-keyring apps" "Apps spawned"
) &

wait

niri msg action focus-workspace 1

notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 5000 "Startup complete" "All startup tasks completed"
