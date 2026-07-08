{
  hostVars,
  pkgs,
  userVars,
  ...
}: let
  minutes = 60; # Seconds
  screen-lock-timeout = hostVars.screen-lock-timeout * minutes;
  screen-blank-timeout = hostVars.screen-blank-timeout * minutes;

  loginctl = "${pkgs.systemd}/bin/loginctl lock-session";
  niri-bin = "${pkgs.niri}/bin/niri"; # IPC stuff so fine
  swaylock = "${pkgs.swaylock-effects}/bin/swaylock -f -i /home/${userVars.username}/.local/share/wallpaper --effect-blur 7x5 --fade-in 0.2";

  display = status: "${niri-bin} msg action power-${status}-monitors";
in {
  home-manager.users.${userVars.username} = {
    home.shellAliases = {
      inherit swaylock; # Fancy by default!
    };

    services.swayidle = {
      enable = true;

      timeouts = [
        {
          timeout = screen-blank-timeout;
          command = display "off";
        }
        {
          timeout = screen-blank-timeout + screen-lock-timeout;
          command = loginctl;
        }
      ];
      events = {
        lock = swaylock;
        "before-sleep" = (display "off") + ";" + swaylock;
        "after-resume" = display "on";
      };

      systemdTargets = ["graphical-session.target"];
    };
  };

  # Work around to https://github.com/NixOS/nixpkgs/issues/143365
  security.pam.services.swaylock = {};
}
