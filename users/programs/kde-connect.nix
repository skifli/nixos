{
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };

    # Refresh service
    systemd.user.services.kdeconnect-refresh = {
      Unit = {
        Description = "Refresh KDE Connect devices";

        # So this only runs AFTER the main service is running
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
        WantedBy = ["default.target"];
      };
    };
  };

  networking.firewall = rec {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };
}
