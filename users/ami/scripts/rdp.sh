#!/usr/bin/env bash
set -euo pipefail

connect_rdp() {
    local host="$1"
    local user="$2"
    local pass="$3"
    shift 3 2>/dev/null || true

    local kbd
    kbd="${RDP_KBD:-0x00000809}"

    if [ -z "$host" ] || [ -z "$user" ]; then
        notify-send -e -a xfreerdp -i "/home/${USER}/.local/share/misc/663376.png" -u critical "RDP Error" "Missing RDP_HOST or RDP_USER in Agenix secret file!"
        echo "Error: Host and User must be set in the secret file." >&2
        exit 1
    fi

    printf "%s\n" "$pass" | xfreerdp /from-stdin:force \
        /v:"$host" \
        /u:"$user" \
        /d:"" \
        /sec:tls \
        /kbd:layout:"$kbd" \
        /drive:home,"$HOME" \
        /cert:ignore \
        +clipboard \
        /dynamic-resolution \
        -grab-keyboard \
        "$@"
}

run_target() {
    local secret_name="$1"
    shift 1 2>/dev/null || true

    local secret_file="/run/agenix/${USER}-${secret_name}"

    if [ ! -f "$secret_file" ]; then
        notify-send -e -a xfreerdp -i "/home/${USER}/.local/share/misc/663376.png" -u critical "RDP Error" "Secret file missing: $secret_file"
        echo "Error: Secret file missing: $secret_file" >&2
        exit 1
    fi

    # Clear environment variables before sourcing to prevent bleeding
    unset RDP_HOST RDP_USER RDP_PASS SSH_HOST SSH_USER

    source "$secret_file"

    local host="${RDP_HOST:-${SSH_HOST:-}}"
    local user="${RDP_USER:-${SSH_USER:-}}"
    local pass="${RDP_PASS:-}"

    connect_rdp "$host" "$user" "$pass" "$@"
}

TARGET="${1:-}"
FONT="${FONT_SANS_SERIF:-}"

if [ -z "$TARGET" ]; then
    TARGET=$(printf "1. Pifi Linux (RDP)\n2. Pifi Windows (RDP)\n3. Oracle Server (RDP)" | fuzzel --dmenu \
        --font="$FONT:size=14" \
        --prompt="Connect to: " \
        --background-color=1e1e2eff \
        --text-color=cdd6f4ff \
        --input-color=cdd6f4ff \
        --width=35 \
        --lines=3 \
        --horizontal-pad=12 \
        --border-radius=10)
fi

TARGET_NORM=$(echo "$TARGET" | tr '[:upper:]' '[:lower:]')

case "$TARGET_NORM" in
    *pifi-linux*|*1*|*"pifi linux"*) run_target "rdp-pifi-linux" "$@" ;;
    *pifi-win*|*2*|*"pifi windows"*)   run_target "rdp-pifi-win" "$@" ;;
    *oracle*|*3*)                     run_target "vnc-oracle" "$@" ;;
    *)
        [ -n "$TARGET" ] && notify-send -e -a xfreerdp -i "/home/${USER}/.local/share/misc/663376.png" -u low "Remote desktop" "Cancelled or invalid selection: '$TARGET'"
        exit 0
        ;;
esac