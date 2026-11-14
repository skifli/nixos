#!/usr/bin/env bash
set -euo pipefail

connect_oracle_vnc() {
    local secret_file="/run/agenix/${USER}-vnc-oracle"
    local key_file="/run/agenix/${USER}-oracle-vnc-key"

    if [ ! -f "$secret_file" ] || [ ! -f "$key_file" ]; then
        notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u critical "VNC Error" "Missing secret file or SSH key in /run/agenix/!"
        exit 1
    fi

    unset SSH_HOST SSH_USER VNC_PORT
    source "$secret_file"

    local host="${SSH_HOST:-}"
    local user="${SSH_USER:-}"
    local port="${VNC_PORT:-5901}"

    notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u low "VNC Connection" "Connecting to Oracle server via SSH tunnel"

    # Open SSH tunnel in background
    ssh -f -i "$key_file" -L "$port:127.0.0.1:$port" "$user@$host" sleep 1 # Keeps the tunnel open just long enough for the local vncviewer to make a connection. Once closed, the SSH tunnel will automatically clean itself up and exit.

    notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u low "VNC Connection" "Launching VNC viewer"

    vncviewer "127.0.0.1:$port" "$@"
}

connect_wayvnc() {
    local target="$1"
    shift 1 2>/dev/null || true

    local secret_file="/run/agenix/${USER}-vnc-pis"

    if [ ! -f "$secret_file" ]; then
        notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u critical "VNC Error" "Secret file missing: $secret_file"
        echo "Error: Secret file missing: $secret_file" >&2
        exit 1
    fi

    unset PIFI_VNC_HOST PIFI_VNC_USER PISTOR_VNC_HOST PISTOR_VNC_USER VNC_PORT VNC_PASS
    source "$secret_file"

    local host user
    case "$target" in
        PIFI)
            host="${PIFI_VNC_HOST:-}"
            user="${PIFI_VNC_USER:-}"
            ;;
        PISTOR)
            host="${PISTOR_VNC_HOST:-}"
            user="${PISTOR_VNC_USER:-}"
            ;;
        *)
            echo "Error: Unknown VNC target: $target" >&2
            exit 1
            ;;
    esac

    local port="${VNC_PORT:-5900}"
    local pass="${VNC_PASS:-}"

    if [ -z "$host" ] || [ -z "$user" ] || [ -z "$pass" ]; then
        notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u critical "VNC Error" "Missing host, user, or password in $secret_file"
        echo "Error: Missing host, user, or password in $secret_file" >&2
        exit 1
    fi

    notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u low "VNC Connection" "Connecting to $target ($host:$port)"
    VNC_USERNAME="$user" VNC_PASSWORD="$pass" vncviewer "$host:$port" "$@"
}

TARGET="${1:-}"
FONT="${FONT_MONOSPACE:-}"
FONT_SIZE="${FONT_SIZE_APPLICATIONS:-}"

if [ -z "$TARGET" ]; then
    OPTIONS="1. Oracle Server (VNC)
2. Pifi (VNC)
3. Pistor (VNC)"
    PROMPT="Connect to: "
    MAX_LEN=$(echo "$OPTIONS" | wc -L)
    WIDTH=$(( ${#PROMPT} + MAX_LEN + 4 ))

    TARGET=$(echo "$OPTIONS" | fuzzel --dmenu \
        --font="$FONT:size=$FONT_SIZE" \
        --prompt="$PROMPT" \
        --background-color=1e1e2eff \
        --text-color=cdd6f4ff \
        --input-color=cdd6f4ff \
        --selection-color=585b70ff \
        --selection-text-color=cdd6f4ff \
        --width="$WIDTH" \
        --lines=3 \
        --horizontal-pad=12 \
        --border-radius=10)
else
    shift 1
fi

TARGET_NORM=$(echo "$TARGET" | tr '[:upper:]' '[:lower:]')

notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u low "Remote desktop" "Connecting to: $TARGET"

case "$TARGET_NORM" in
    *oracle*|*1*)                     connect_oracle_vnc "$@" ;;
    *pifi-vnc*|*2*|*"pifi vnc"*)       connect_wayvnc PIFI "$@" ;;
    *pistor-vnc*|*3*|*"pistor vnc"*)   connect_wayvnc PISTOR "$@" ;;
    *)
        [ -n "$TARGET" ] && notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u low "Remote desktop" "Cancelled or invalid selection: '$TARGET'"
        exit 0
        ;;
esac
