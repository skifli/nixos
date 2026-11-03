{
  config,
  lib,
  pkgs,
  userVars,
  ...
}:
let
  username = userVars.username;
  ntfyTopic = "grafana-alerts";
  ntfyServer = "https://ntfy.encore-sr.com";

  secretName = "${username}-ntfy-personal-token";
  hasSecret = builtins.hasAttr secretName config.age.secrets;
  tokenPath = config.age.secrets.${secretName}.path or "";
  homeDir = config.users.users.${username}.home;

  ntfyDesktopScript = pkgs.writeText "ntfy-desktop.py" (
    lib.replaceStrings
      [ "@TOPIC@" "@SERVER@" "@TOKEN_PATH@" "@NOTIFY_SEND@" "@ICON@" ]
      [
        ntfyTopic
        ntfyServer
        tokenPath
        "${pkgs.libnotify}/bin/notify-send"
        "${homeDir}/.local/share/misc/grafana-icon.svg"
      ]
      (builtins.readFile ./ntfy-desktop.py)
  );
in
{
  home-manager.users.${username} = lib.mkIf hasSecret {
    systemd.user.services.ntfy-desktop-notifications = {
      Unit = {
        Description = "ntfy to desktop notifications";
        PartOf = [ "graphical-session.target" ];
        After = [
          "graphical-session.target"
          "dbus-broker.service"
        ];
      };

      Service = {
        Type = "simple";
        ExecStart = pkgs.writeScript "ntfy-desktop" ''
          #!${pkgs.bash}/bin/bash
          export PYTHONPATH="${pkgs.python3Packages.websocket-client}/lib/python3.13/site-packages"
          exec ${pkgs.python3}/bin/python3 ${ntfyDesktopScript}
        '';
        Environment = [
          "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${toString config.users.users.${username}.uid}/bus"
        ];
        Restart = "always";
        RestartSec = "10s";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };

  environment.systemPackages = [
    pkgs.libnotify
    pkgs.python3
    pkgs.python3Packages.websocket-client
  ];
}
