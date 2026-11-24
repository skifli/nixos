#!/usr/bin/env bash

# Defaults
TERMINAL="${TERMINAL:-ghostty}"
SHELL_BIN="$SHELL"
HOSTNAME="$(hostname)"
POST_ACTION="shell"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--reboot)
      POST_ACTION="reboot"
      shift
      ;;
    -s|--shutdown|--poweroff)
      POST_ACTION="shutdown"
      shift
      ;;
    -t|--terminal)
      TERMINAL="$2"
      shift 2
      ;;
    -h|--host)
      HOSTNAME="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

notify-send -e -a nixOS \
  -i "$HOME/.local/share/misc/nix-snowflake-rainbow.svg" \
  -u low -t 3500 \
  'nixOS Rebuild' 'Initing nixOS-rebuild switch'

"$HOME/.local/bin/floating-term.sh" "$TERMINAL" -e "$SHELL_BIN" -i -c "
  sudo -v || exit
  cd '$HOME/nixos' && sudo chown -R '$USER' .git/
  git pull &&
  git submodule update --init --recursive &&
  git log --oneline ORIG_HEAD..HEAD

  start_time=\$(date +%s.%N)

  # Keep the sudo timestamp alive only while nh runs, so activation does not
  # prompt after a long build when nobody is at the keyboard.
  (
    while sleep 60; do sudo -n -v || exit; done
  ) &
  sudo_keepalive_pid=\$!
  nh os switch path:. --accept-flake-config -H $HOSTNAME
  nh_status=\$?
  kill \$sudo_keepalive_pid 2>/dev/null || true
  wait \$sudo_keepalive_pid 2>/dev/null || true

  if [ \$nh_status -eq 0 ]; then
    end_time=\$(date +%s.%N)
    duration=\$(echo \"scale=2; \$end_time - \$start_time\" | bc)
    log_date=\$(date '+%Y-%m-%d %H:%M:%S')
    echo \"[\$log_date] [$HOSTNAME] switch execution time: \$duration seconds\" >> '$HOME/Documents/custom-scripts/nixos_rebuild.log'

    notify-send -e -a nixOS \\
      -i \"\$HOME/.local/share/misc/nix-snowflake-rainbow.svg\" \\
      -u low -t 8000 \\
      'Rebuild complete' \"Took \$duration seconds.\" || true

    pw-play /run/current-system/sw/share/sounds/freedesktop/stereo/complete.oga \\
      >/dev/null 2>&1 || true

    case '$POST_ACTION' in
      reboot)
        echo 'Rebuilding complete. Rebooting in 5 seconds (Ctrl+C to abort)...'
        sleep 5
        systemctl reboot
        ;;
      shutdown)
        echo 'Rebuilding complete. Shutting down in 5 seconds (Ctrl+C to abort)...'
        sleep 5
        systemctl poweroff
        ;;
      *)
        exec '$SHELL_BIN'
        ;;
    esac
  else
    echo 'Rebuild failed - dropping to shell.'
    exec '$SHELL_BIN'
  fi
"
