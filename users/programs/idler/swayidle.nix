{
  hostVars,
  lib,
  pkgs,
  userVars,
  ...
}: let
  minutes = 60; # Seconds
  screen-lock-timeout = hostVars.screen-lock-timeout * minutes;
  screen-blank-timeout = hostVars.screen-blank-timeout * minutes;

  niri-bin = "${pkgs.niri}/bin/niri"; # IPC stuff so fine
  swaylock = "${pkgs.swaylock}/bin/swaylock -f -i /home/${userVars.username}/.local/share/wallpaper-blurred";

  display = status: "${niri-bin} msg action power-${status}-monitors";
in
  lib.mkIf (hostVars.hostname != "fydetab") {
    home-manager.users.${userVars.username} = {
      home.shellAliases = {
        inherit swaylock; # Fancy by default!
      };

      services.swayidle = {
        enable = true;

        timeouts = [
          # 1. Lock screen(s)
          {
            timeout = screen-lock-timeout;
            command = swaylock;
          }

          # 2. Turn off monitor(s) while locked
          {
            timeout = screen-blank-timeout;
            command = display "off";
            resumeCommand = display "on";
          }
        ];

        events = {
          lock = swaylock;

          before-sleep = "${swaylock}; ${display "off"}";
          after-resume = display "on";
        };

        systemdTargets = ["graphical-session.target"];
      };
    };

    # Work around to https://github.com/NixOS/nixpkgs/issues/143365
    security.pam.services.swaylock = {};
  }
