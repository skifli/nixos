#!/usr/bin/env bash

set -euo pipefail

# 1. Close if overview is already open
RAW_STATE=$(niri msg --json overview-state 2>/dev/null || echo '{"is_open":false}')
IS_OPEN=$(echo "$RAW_STATE" | jq -r '.is_open // false')

if [ "$IS_OPEN" = "true" ]; then
    niri msg action toggle-overview
    exit 0
fi

# 2. Fetch workspace list
WORKSPACES=$(niri msg --json workspaces 2>/dev/null || echo "[]")
if [ "$WORKSPACES" = "[]" ] || [ -z "$WORKSPACES" ]; then
    exit 1
fi

# 3. Get target workspaces, making sure the active/focused one is sorted last
TARGETS=$(echo "$WORKSPACES" | jq -r '
  [
    group_by(.output) | .[] | 
    sort_by(.idx) | 
    map(select(.active_window_id != null)) | 
    select(length > 0) | 
    .[length / 2 | floor]
  ] 
  | sort_by(.is_focused // false) 
  | .[].id
')

# 4. Focus workspaces (inactive monitors first, active monitor last)
if [ -n "$TARGETS" ]; then
    for WS_ID in $TARGETS; do
        nirius focus --workspace-id "$WS_ID" 2>/dev/null || true
    done
fi

# 5. Open overview
niri msg action toggle-overview
