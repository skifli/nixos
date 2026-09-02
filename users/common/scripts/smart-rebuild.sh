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
  cd '$HOME/nixos' && sudo chown -R '$USER' .git/
  git pull &&
  git submodule update --init --recursive &&
  git log --oneline ORIG_HEAD..HEAD

  start_time=\$(date +%s.%N)

  nh os switch path:. --accept-flake-config -H $HOSTNAME

  if [ \$? -eq 0 ]; then
    end_time=\$(date +%s.%N)
    duration=\$(echo \"scale=2; \$end_time - \$start_time\" | bc)
    log_date=\$(date '+%Y-%m-%d %H:%M:%S')
    echo \"[\$log_date] switch execution time: \$duration seconds\" >> '$HOME/Documents/custom-scripts/nixos_rebuild.log'

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
