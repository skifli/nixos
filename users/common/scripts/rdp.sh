#!/usr/bin/env bash
set -euo pipefail

TUNNEL_PIDS=()
cleanup_vnc_tunnels() {
    local pid
    for pid in "${TUNNEL_PIDS[@]:-}"; do
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
    done
}
trap cleanup_vnc_tunnels EXIT

focused_desktop_size() {
    niri msg -j focused-output 2>/dev/null \
        | jq -er '"\(.logical.width | ceil)x\(.logical.height | ceil)"' 2>/dev/null
}

set_remote_output_size() {
    local ssh_target="$1"
    local host_alias="$2"
    local key_file="$3"
    local desktop_size="$4"
    local -a ssh_options=(
        -o BatchMode=yes
        -o ConnectTimeout=10
        -o "HostKeyAlias=$host_alias"
    )

    if [[ -n "$key_file" ]]; then
        ssh_options+=(-i "$key_file")
    fi

    # Set the compositor output before connecting, then prevent TigerVNC from
    # feeding later window-manager size changes back into the server output.
    ssh "${ssh_options[@]}" "$ssh_target" \
        "XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-0 /run/current-system/sw/bin/wlr-randr --output HEADLESS-1 --custom-mode ${desktop_size}@60Hz"
}

launch_vncviewer() {
    local server="$1"
    local desktop_size="$2"
    shift 2
    local resize_log="${XDG_STATE_HOME:-$HOME/.local/state}/rdp/resize.log"
    mkdir -p "${resize_log%/*}"

    log_resize() {
        printf '%s %s\n' "$(date +'%F %T')" "$*" >>"$resize_log"
    }

    log_resize "starting viewer; fixed server desktop size: $desktop_size"

    # Fullscreen uses the whole output, including space reserved by the local
    # panel. A maximised window is shorter than the output on some primary
    # monitors, which otherwise leaves scrollbars around the remote desktop.
    local -a viewer_options=(
        -FullScreen=1
        -FullScreenMode=Current
        -FullscreenSystemKeys=1
        -RemoteResize=0
    )
    vncviewer "${viewer_options[@]}" "$server" "$@"
}

connect_oracle_vnc() {
    local secret_file="/run/agenix/vnc-oracle"
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
    local desktop_size
    desktop_size="$(focused_desktop_size)" || {
        notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u critical "VNC Error" "Could not read the focused monitor size"
        return 1
    }

    if ! set_remote_output_size "$user@$host" oracle-nix "$key_file" "$desktop_size"; then
        notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u critical "VNC Error" "Could not set Oracle's VNC desktop to $desktop_size. Check that wlr-randr is installed on the server."
        return 1
    fi

    notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u low "VNC Connection" "Connecting to Oracle server via SSH tunnel"

    # Keep the SSH forward alive for the full viewer session.
    ssh -N -i "$key_file" \
        -o ExitOnForwardFailure=yes \
        -o ServerAliveInterval=15 \
        -o ServerAliveCountMax=3 \
        -o BatchMode=yes \
        -o HostKeyAlias=oracle-nix \
        -L "127.0.0.1:$port:127.0.0.1:$port" \
        "$user@$host" &
    TUNNEL_PIDS+=("$!")
    local tunnel_pid="${TUNNEL_PIDS[-1]}"

    local attempt ready=0
    for attempt in {1..50}; do
        if (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null; then
            ready=1
            break
        fi
        if ! kill -0 "$tunnel_pid" 2>/dev/null; then
            notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u critical "VNC Error" "SSH tunnel to Oracle failed to start"
            return 1
        fi
        sleep 0.1
    done
    if [ "$ready" -ne 1 ]; then
        notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u critical "VNC Error" "Timed out waiting for the Oracle SSH tunnel"
        return 1
    fi

    notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u low "VNC Connection" "Launching VNC viewer"

    launch_vncviewer "127.0.0.1::$port" "$desktop_size" "$@"
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

    local host host_alias local_port
    case "$target" in
        PIFI)
            host="${PIFI_VNC_HOST:-}"
            host_alias="pifi"
            local_port=15900
            ;;
        PISTOR)
            host="${PISTOR_VNC_HOST:-}"
            host_alias="pistor"
            local_port=15901
            ;;
        *)
            echo "Error: Unknown VNC target: $target" >&2
            exit 1
            ;;
    esac

    if [ -z "$host" ]; then
        notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u critical "VNC Error" "Missing host in $secret_file"
        echo "Error: Missing host in $secret_file" >&2
        exit 1
    fi

    local desktop_size
    desktop_size="$(focused_desktop_size)" || {
        notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u critical "VNC Error" "Could not read the focused monitor size"
        return 1
    }

    if ! set_remote_output_size "root@$host" "$host_alias" "" "$desktop_size"; then
        notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u critical "VNC Error" "Could not set $target's VNC desktop to $desktop_size. Check that wlr-randr is installed on the server."
        return 1
    fi

    local attempt ready=0
    ssh -N \
        -o ExitOnForwardFailure=yes \
        -o ServerAliveInterval=15 \
        -o ServerAliveCountMax=3 \
        -o BatchMode=yes \
        -o "HostKeyAlias=$host_alias" \
        -L "127.0.0.1:$local_port:127.0.0.1:5900" \
        "root@$host" &
    TUNNEL_PIDS+=("$!")
    local tunnel_pid="${TUNNEL_PIDS[-1]}"

    for attempt in {1..50}; do
        if (exec 3<>"/dev/tcp/127.0.0.1/$local_port") 2>/dev/null; then
            ready=1
            break
        fi
        if ! kill -0 "$tunnel_pid" 2>/dev/null; then
            notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u critical "VNC Error" "SSH tunnel to $target failed to start"
            return 1
        fi
        sleep 0.1
    done
    if [ "$ready" -ne 1 ]; then
        notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u critical "VNC Error" "Timed out waiting for the $target SSH tunnel"
        return 1
    fi

    notify-send -e -a VNCViewer -i "$HOME/.local/share/misc/663376.png" -u low "VNC Connection" "Opening secure SSH tunnel to $target"
    launch_vncviewer "127.0.0.1::$local_port" "$desktop_size" "$@"
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
