#!/usr/bin/env bash

TERMINAL="${1:-ghostty}"
SHELL_BIN="${2:-$SHELL}"
HOSTNAME="${3:-$(hostname)}"

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
  sudo GC_INITIAL_HEAP_SIZE=\"\$CUSTOM_NIXOS_REBUILD_GC\" nixos-rebuild switch --flake 'path:.#$HOSTNAME'

  if [ \$? -eq 0 ]; then
    end_time=\$(date +%s.%N)
    duration=\$(echo \"scale=2; \$end_time - \$start_time\" | bc)
    log_date=\$(date '+%Y-%m-%d %H:%M:%S')
    echo \"[\$log_date] zngunsh execution time: \$duration seconds\" >> '$HOME/Documents/custom-scripts/nixos_rebuild.log'
  fi

  exec '$SHELL_BIN'
"