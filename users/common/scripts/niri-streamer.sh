#!/usr/bin/env bash
set -euo pipefail

# Single instance lock
LOCK_FILE="/tmp/niri-streamer.lock"
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
    exit 0
fi

MAIN_PID="$$"
export NIRI_STATE_DIR="/tmp/niri-state-${UID}"
mkdir -m 0700 -p "$NIRI_STATE_DIR"

date +%s > "$NIRI_STATE_DIR/.session_start"

# Cleanup state directory on process exit
cleanup() {
    if [[ "${BASHPID:-$$}" -eq "$MAIN_PID" ]]; then
        rm -rf "$NIRI_STATE_DIR"
    fi
}
trap cleanup EXIT INT TERM

export NIRI_ICON_PATH="$HOME/.local/share/misc/niri-icon.svg"

# Shared helper: Get window info safely
niri_get_window_info() {
    local target_id="$1"
    niri msg --json windows 2>/dev/null | jq -r --argjson w "$target_id" '
        first(.[] | select(.id == $w)) | "\(.app_id // "Application")\t\(.title // "Window")"
    ' 2>/dev/null || echo -e "Application\tID $target_id"
}
export -f niri_get_window_info

# Hook registration system
declare -a NIRI_HOOKS=()

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="${NIRI_HOOKS_DIR:-$SCRIPT_DIR/hooks}"
if [[ -d "$HOOKS_DIR" ]]; then
    for hook_file in "$HOOKS_DIR"/*.sh; do
        if [[ -f "$hook_file" ]]; then
            # Source hook file to register its callback
            # shellcheck source=/dev/null
            source "$hook_file"
        fi
    done
fi

# Ze main loop
while read -r line; do
    [[ -z "$line" ]] && continue

    # Parse event header
    parsed=$(jq -r 'keys[0] as $k | "\($k) \(.[$k].id // "") \(.[$k].urgent // "")"' <<< "$line" 2>/dev/null) || continue
    read -r event id urgent <<< "$parsed"

    # Security check: Make sure that all IDs are numeric to prevent path traversal in hooks. Is this really needed? Hell nah. Am I keeping it because I can? Hell yes!
    if [[ -n "$id" && ! "$id" =~ ^[0-9]+$ ]]; then
        continue
    fi

    # Dispatch event to all registered hooks
    for hook_fn in "${NIRI_HOOKS[@]:-}"; do
        if declare -f "$hook_fn" >/dev/null; then
            "$hook_fn" "$event" "$id" "$urgent" "$line" || true
        fi
    done

done < <(niri msg --json event-stream)
