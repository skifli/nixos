# Fix TERM when the client advertises a terminal type we don't have terminfo for
# (e.g., SSHing from ghostty to a machine without ghostty's terminfo installed,
# like fydetabduo). Without this, `clear` fails and readline/ls echo garbled or
# duplicate text because the terminal can't interpret cursor-movement codes.
if [ -n "${TERM-}" ] && ! infocmp "$TERM" >/dev/null 2>&1; then
    export TERM=xterm-256color
fi

# Axlefublr da goat: Read file selection buffer
blammo() {
  if [ -f /tmp/blammo ]; then
    cat /tmp/blammo
  elif timeout 1 test -f "$HOME/Documents/custom-scripts/blammo" && timeout 1 cat "$HOME/Documents/custom-scripts/blammo"; then
    :
  else
    echo "No blammo selection found"
  fi
}

# Axlefublr again!
precmd() {
  if [ -f /tmp/blammo ]; then
    blammo_in=$(cat /tmp/blammo 2>/dev/null)
  elif timeout 1 test -f "$HOME/Documents/custom-scripts/blammo" && blammo_in=$(timeout 1 cat "$HOME/Documents/custom-scripts/blammo" 2>/dev/null); then
    :
  fi
}

# -t 0 prevents disappearing until manual closing
safe_reboot() {
  local target_action=$1
  shift
  if [ -f /tmp/gpu-screen-recorder.pid ] && kill -0 $(cat /tmp/gpu-screen-recorder.pid) 2>/dev/null; then
    notify-send -e -a nixOS -t 0 -u critical -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" "Shutdown refused" "Screen recording is currently in progress!"
    return 1
  fi
  if pgrep -f "nixos-rebuild|nh os switch" >/dev/null; then
    notify-send -e -a nixOS -t 0 -u critical -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" "Shutdown refused" "nixOS system rebuild is currently active!"
    return 1
  fi
  urgent_wins=$(niri msg --json windows 2>/dev/null | jq -r '.[] | select(.is_urgent == true) | .id')
  if [ -n "$urgent_wins" ]; then
    notify-send -e -a nixOS -t 0 -u critical -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" "Shutdown refused" "There are urgent windows requiring attention!"
    return 1
  fi
  systemctl "$target_action" "$@"
}

alias reboot="safe_reboot reboot"
alias shutdown="safe_reboot shutdown"
