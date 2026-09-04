{
  config,
  hostVars,
  lib,
  pkgs,
  ...
}:
let
  secretPath = ../../secrets + "/${hostVars.hostname}" + "/warp-prefixes.env";
  hasWarpPrefixes = builtins.pathExists secretPath;
in
{
  services.cloudflare-warp = {
    enable = true;
    package = pkgs.cloudflare-warp.override { headless = true; };
  };

  environment.shellAliases = {
    w-on = "warp-cli connect";
    w-off = "warp-cli disconnect";
    w-st = "warp-cli status";
  };

  # Oneshot that checks the current wifi SSID against a prefix list stored in
  # an Agenix secret. If the SSID matches, WARP is registered if it is
  # needed and connected. On non-matching networks the service exits
  # immediately.
  systemd.services.warp-ensure = lib.mkIf hasWarpPrefixes {
    description = "Ensure Cloudflare WARP is connected on matching wifi networks";
    after = [
      "network-online.target"
      "warp-svc.service"
    ];
    wants = [ "warp-svc.service" ];
    path = with pkgs; [
      networkmanager
      cloudflare-warp
      gnugrep
      coreutils
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
      TimeoutStartSec = 30;
      Environment = "WARP_PREFIXES_FILE=${config.age.secrets."${hostVars.hostname}-warp-prefixes".path}";
      ExecStart = pkgs.writeShellScript "warp-ensure" ''
        set -euo pipefail

        WARP_CLI="${pkgs.cloudflare-warp}/bin/warp-cli"

        mapfile -t PREFIXES < <(
          grep -v '^\s*#' "$WARP_PREFIXES_FILE" | grep -v '^\s*$' || true
        )

        if [ ''${#PREFIXES[@]} -eq 0 ]; then
          echo "warp-ensure: no prefixes configured, skipping"
          exit 0
        fi

        # Wait for a wifi connection to appear - NetworkManager may not have
        # connected yet (optimiseBoot disables NetworkManager-wait-online).
        SSID=""
        for i in {1..120}; do
          SSID="$(nmcli -t -f 802-11-wireless.ssid connection show --active 2>/dev/null | tail -1)"
          if [ -n "$SSID" ]; then
            break
          fi
          sleep 1
        done

        if [ -z "$SSID" ]; then
          echo "warp-ensure: no active wifi connection after 2m, skipping"
          exit 0
        fi

        MATCHED=false
        for prefix in "''${PREFIXES[@]}"; do
          prefix="''${prefix%$'\n'}"
          prefix="''${prefix%"''${prefix##*[![:space:]]}"}"
          if [[ "$SSID" == "$prefix"* ]]; then
            MATCHED=true
            break
          fi
        done

        if [ "$MATCHED" = false ]; then
          echo "warp-ensure: SSID '$SSID' does not match any prefix, skipping"
          exit 0
        fi

        echo "warp-ensure: SSID '$SSID' matches a prefix, ensuring WARP"

        # Wait briefly for warp-svc D-Bus interface to be ready
        for i in {1..10}; do
          if $WARP_CLI status &>/dev/null; then
            break
          fi
          sleep 1
        done

        STATUS="$($WARP_CLI status 2>&1 || true)"
        if echo "$STATUS" | grep -qi "registration missing\|not registered"; then
          echo "warp-ensure: registering with Cloudflare WARP"
          $WARP_CLI registration new
        fi

        STATUS="$($WARP_CLI status 2>&1 || true)"
        if ! echo "$STATUS" | grep -qi "connected"; then
          echo "warp-ensure: connecting to WARP"

          $WARP_CLI connect

          # Wait for connection to establish
          for i in {1..15}; do
            STATUS="$($WARP_CLI status 2>&1 || true)"

            if echo "$STATUS" | grep -qi "connected"; then
              break
            fi
            sleep 1
          done
        fi

        echo "warp-ensure: done"
      '';
    };
  };

  # Timer triggers warp-ensure shortly after boot.  Kept outside the
  # multi-user.target → graphical.target chain so it never blocks niri.
  systemd.timers.warp-ensure = lib.mkIf hasWarpPrefixes {
    description = "Trigger WARP check after boot";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = 0;
      Unit = "warp-ensure.service";
    };
  };
}
