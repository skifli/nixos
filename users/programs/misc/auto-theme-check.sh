#!/usr/bin/env bash
set -euo pipefail

# Paths for notifications and desktop commands
RUN_UID=$(id -u)
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$RUN_UID/bus"
export XDG_RUNTIME_DIR="/run/user/$RUN_UID"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

# Just in case
SUNWAIT_BIN="${SUNWAIT_BIN:-sunwait}"
SWITCHER_BIN="${SWITCHER_BIN:-$HOME/.local/bin/theme-switcher.sh}"
ICON_PATH="${ICON_PATH:-$HOME/.local/share/misc/nix-snowflake-rainbow.svg}"

while true; do
  set +e
  "$SUNWAIT_BIN" poll "${LAT_VAL}${LAT_DIR}" "${LON_VAL}${LON_DIR}" >/tmp/sunwait.log 2>&1
  STATUS=$?
  set -e

  # Possible outputs - 2: It is DAY or twilight. 3: It is NIGHT. 1: It is an Error.
  if [ "$STATUS" -eq 2 ]; then
    WANTED="light"
  elif [ "$STATUS" -eq 3 ]; then
    WANTED="dark"
  else
    echo "Sunwait error code: $STATUS" >&2
    sleep 60
    continue
  fi

if [[ "$(readlink -f /run/current-system)" == *"-light-"* ]]; then
    CURRENT_TAG="light"
else
    CURRENT_TAG="dark"
fi

  if [ "$WANTED" != "$CURRENT_TAG" ]; then
    echo "Theme mismatch detected. Switching to $WANTED mode."
    notify-send -e -a "nixOS" -i "$ICON_PATH" -u low -t 5000 "Auto-theme switcher" "Switching to $WANTED mode..."
    "$SWITCHER_BIN" "$WANTED"
  fi

  # Wait until the next solar transition (sunrise or sunset)
  # Default behavior of 'sunwait wait' without 'rise'/'set' option is 'both',
  # So, it blocks until the very next sunrise or sunset event occurs.
  echo "Waiting until next sunrise or sunset..."
  set +e
  "$SUNWAIT_BIN" wait "${LAT_VAL}${LAT_DIR}" "${LON_VAL}${LON_DIR}"
  WAIT_STATUS=$?
  set -e

  if [ "$WAIT_STATUS" -ne 0 ]; then
    echo "Sunwait wait returned error code: $WAIT_STATUS. Retrying in 60s..."
    sleep 60
  else
    # Pause 5 seconds to prevent I think what is a race-condition where wait unblocked, the script looped back, poll was run, but it was too soon and poll just about hit the current state and didn't update to the next one, causing the script to break.
    sleep 5
  fi
done
