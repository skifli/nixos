{
  hostVars,
  lib,
  pkgs,
  userVars,
  ...
}:
let
  ignoreList = (userVars.kdeConnectExcluded or [ ]) ++ [ hostVars.hostname ];

  # Filter out self + any excluded devices
  otherDevices = lib.filterAttrs (name: _: !builtins.elem name ignoreList) (
    userVars.tailscaleDevices or { }
  );

  customDevicesString = builtins.concatStringsSep "," (builtins.attrValues otherDevices);
in
{
  home-manager.users.${userVars.username} = { lib, ... }: {
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };

    home.activation.kdeconnectCustomDevices = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      CONFIG_DIR="$HOME/.config/kdeconnect"
      CONFIG_FILE="$CONFIG_DIR/config"
      DEVICES="${customDevicesString}"

      $DRY_RUN_CMD mkdir -p "$CONFIG_DIR"
      if [ -f "$CONFIG_FILE" ]; then
        if grep -q "^customDevices=" "$CONFIG_FILE"; then
          $DRY_RUN_CMD sed -i "s|^customDevices=.*|customDevices=$DEVICES|" "$CONFIG_FILE"
        else
          if grep -q "^\[General\]" "$CONFIG_FILE"; then
            $DRY_RUN_CMD sed -i "/^\[General\]/a customDevices=$DEVICES" "$CONFIG_FILE"
          else
            $DRY_RUN_CMD printf "\n[General]\ncustomDevices=%s\n" "$DEVICES" >> "$CONFIG_FILE"
          fi
        fi
        # The Bluetooth backend keeps the adapter in BR/EDR inquiry, which
        # makes A2DP playback stutter and lag. KDE Connect 26.x calls this
        # backend AsyncLinkProvider (older releases: BluetoothLinkProvider).
        if grep -q "^disabled_providers=" "$CONFIG_FILE"; then
          $DRY_RUN_CMD sed -i "s|^disabled_providers=.*|disabled_providers=AsyncLinkProvider|" "$CONFIG_FILE"
        elif grep -q "^\[General\]" "$CONFIG_FILE"; then
          $DRY_RUN_CMD sed -i "/^\[General\]/a disabled_providers=AsyncLinkProvider" "$CONFIG_FILE"
        else
          $DRY_RUN_CMD printf "\n[General]\ndisabled_providers=AsyncLinkProvider\n" >> "$CONFIG_FILE"
        fi
      else
        $DRY_RUN_CMD printf "[General]\ncustomDevices=%s\ndisabled_providers=AsyncLinkProvider\n" "$DEVICES" > "$CONFIG_FILE"
      fi
    '';

    # Refresh service
    systemd.user.services.kdeconnect-refresh = {
      Unit = {
        Description = "Refresh KDE Connect devices";
        After = [ "kdeconnect.service" ];
        Requires = [ "kdeconnect.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnect-cli --refresh";
      };
    };

    # Refresh timer
    systemd.user.timers.kdeconnect-refresh = {
      Timer = {
        OnBootSec = "1m";
        OnUnitActiveSec = "1m";
        AccuracySec = "10s";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };

  networking.firewall = rec {
    # Done in tailscale.nix already
    # trustedInterfaces = [ "tailscale0" ];

    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };
}
