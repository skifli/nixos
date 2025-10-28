{
  hostVars,
  pkgs,
  userVars,
  ...
}:
let
  minutes = 60; # Seconds
  screen-lock-timeout = hostVars.screen-lock-timeout * minutes;
  screen-blank-timeout = hostVars.screen-blank-timeout * minutes;

  loginctl = "${pkgs.systemd}/bin/loginctl";
  niri-bin = "${pkgs.niri}/bin/niri"; # IPC stuff so fine
  swaylock = "${pkgs.swaylock}/bin/swaylock";

  lock-session = pkgs.writeShellScript "lock-session" ''
    ${swaylock} -f
    ${niri-bin} msg action power-off-monitors
  '';

  before-sleep = pkgs.writeShellScript "before-sleep" ''
    ${loginctl} lock-session
  '';
in
{
  home-manager.users.${userVars.username} = {
    programs.swaylock = {
      enable = true;
    };

    services.swayidle = {
      enable = true;

      timeouts = [
        {
          timeout = screen-blank-timeout;
          command = "${niri-bin} msg action power-off-monitors";
        }
        {
          timeout = screen-blank-timeout + screen-lock-timeout;
          command = "${loginctl} lock-session";
        }
      ];
      events = [
        {
          event = "lock";
          command = lock-session.outPath;
        }
        {
          event = "before-sleep";
          command = before-sleep.outPath;
        }
      ];

      systemdTarget = "graphical-session.target";
    };
  };

  # Work around to https://github.com/NixOS/nixpkgs/issues/143365
  security.pam.services.swaylock = { };
}
