# Axlefublr da goat: Copy file path as Wayland URI list
copyl() {
  if [ -n "$1" ]; then
    local abs_path
    abs_path=$(realpath "$1")
    echo -n "file://$abs_path" | "${WL_COPY_BIN}" -t text/uri-list
    notify-send -e -a nixos -i "/home/${USER}/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 2500 "Clipboard" "Copied URI to clipboard: file://$abs_path"
  else
    echo "Usage: copyl <file>"
  fi
}

# Axlefublr da goat: Read file selection buffer
blammo() {
  if [ -f /tmp/blammo ]; then
    cat /tmp/blammo
  elif [ -f "$HOME/Documents/custom-scripts/blammo" ]; then
    cat "$HOME/Documents/custom-scripts/blammo"
  else
    echo "No blammo selection found"
  fi
}

# Axlefublr again!
precmd() {
  if [ -f /tmp/blammo ]; then
    blammo_in=$(cat /tmp/blammo 2>/dev/null)
  elif [ -f "$HOME/Documents/custom-scripts/blammo" ]; then
    blammo_in=$(cat "$HOME/Documents/custom-scripts/blammo" 2>/dev/null)
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

eval "$(pay-respects zsh)"