#!/usr/bin/env bash
set -euo pipefail

connect_rdp() {
    local host="$1"
    local user="$2"
    local pass="$3"
    shift 3 2>/dev/null || true

    local kbd
    kbd=${RDP_KBD:-}

    if [ -z "$host" ] || [ -z "$user" ]; then
        notify-send -e -a FreeRDP -i "/home/${USER}/.local/share/misc/663376.png" -u critical "RDP Error" "Missing RDP_HOST or RDP_USER in Agenix secret file!"
        echo "Error: Host and user must be set in the secret file." >&2
        exit 1
    fi

    # FreeRDP allows setting the title, but not TigerVNC. This leads me to a problem where that means I have to have multiple matches in the window-rules but then it also makes my custom scripts more annoying because I have to take into account both of those types. So, my extremely elegant solution is to just... make FreeRDP look like TigerVNC :sob:. Welp, at least it works ;).
    printf "%s\n" "$pass" | sdl-freerdp /from-stdin:force \
        /v:"$host" \
        /u:"$user" \
        /d:"" \
        /t:"TigerVNC" \
        /kbd:layout:"$kbd" \
        /kbd:lang:"$kbd" \
        /kbd:remap:0x5b=0x0 \
        /drive:home,"$HOME" \
        /cert:ignore \
        +clipboard \
        +dynamic-resolution \
        +grab-keyboard \
        "$@" # The kbd ones don't even seem to work but WHATEVER :sob: had to do some stuff to the servers to make them default to the right layout ;-;
}

connect_oracle_vnc() {
    local secret_file="/run/agenix/${USER}-vnc-oracle"
    local key_file="/run/agenix/${USER}-oracle-vnc-key"

    if [ ! -f "$secret_file" ] || [ ! -f "$key_file" ]; then
        notify-send -e -a VNCViewer -i "/home/${USER}/.local/share/misc/663376.png" -u critical "VNC Error" "Missing secret file or SSH key in /run/agenix/!"
        exit 1
    fi

    unset SSH_HOST SSH_USER VNC_PORT
    source "$secret_file"

    local host="${SSH_HOST:-}"
    local user="${SSH_USER:-}"
    local port="${VNC_PORT:-5901}"

    # Open SSH tunnel in background
    ssh -f -i "$key_file" -L "$port:127.0.0.1:$port" "$user@$host" sleep 10 # Keeps the tunnel open just long enough for the local vncviewer to make a connection. Once closed, the SSH tunnel will automatically clean itself up and exit.
    
    vncviewer "127.0.0.1:$port" "$@"
}

run_target() {
    local secret_name="$1"
    local title="$2"
    shift 2 2>/dev/null || true

    local secret_file="/run/agenix/${USER}-${secret_name}"

    if [ ! -f "$secret_file" ]; then
        notify-send -e -a FreeRDP -i "/home/${USER}/.local/share/misc/663376.png" -u critical "RDP Error" "Secret file missing: $secret_file"
        echo "Error: Secret file missing: $secret_file" >&2
        exit 1
    fi

    unset RDP_HOST RDP_USER RDP_PASS
    source "$secret_file"

    connect_rdp "${RDP_HOST:-}" "${RDP_USER:-}" "${RDP_PASS:-}" "$@"
}

TARGET="${1:-}"
FONT="${FONT_SANS_SERIF:-}"

if [ -z "$TARGET" ]; then
    TARGET=$(printf "1. Pifi Linux (RDP)\n2. Pifi Windows (RDP)\n3. Oracle Server (VNC)" | fuzzel --dmenu \
        --font="$FONT:size=14" \
        --prompt="Connect to: " \
        --background-color=1e1e2eff \
        --text-color=cdd6f4ff \
        --input-color=cdd6f4ff \
        --selection-color=585b70ff \
        --selection-text-color=cdd6f4ff \
        --width=35 \
        --lines=3 \
        --horizontal-pad=12 \
        --border-radius=10)
else
    shift 1
fi

TARGET_NORM=$(echo "$TARGET" | tr '[:upper:]' '[:lower:]')

case "$TARGET_NORM" in
    *pifi-linux*|*1*|*"pifi linux"*) run_target "rdp-pifi-linux" "$@" ;;
    *pifi-win*|*2*|*"pifi windows"*)   run_target "rdp-pifi-win" "$@" ;;
    *oracle*|*3*)                     connect_oracle_vnc "$@" ;;
    *)
        [ -n "$TARGET" ] && notify-send -e -a FreeRDP -i "/home/${USER}/.local/share/misc/663376.png" -u low "Remote desktop" "Cancelled or invalid selection: '$TARGET'"
        exit 0
        ;;
esac
