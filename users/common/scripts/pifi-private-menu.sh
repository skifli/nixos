#!/usr/bin/env bash
set -euo pipefail

choice="$(printf 'Open private vault\nClose private vault\n' | fuzzel --dmenu --prompt='Pifi private: ')"

case "$choice" in
  'Open private vault')
    exec ghostty -e pifi-private-open
    ;;
  'Close private vault')
    exec ghostty -e pifi-private-close
    ;;
esac
