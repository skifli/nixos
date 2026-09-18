{
  pkgs,
  pkgsUnstable,
  userVars,
  ...
}:
{
  home-manager.users.${userVars.username} = {
    home.packages = [
      pkgsUnstable.wayscriber # Unstable as it is actively developed - stable only has 0.9.19
      pkgs.slurp # Needed by wayscriber's selection screenshot helpers (grim / wl-clipboard already present)
    ];

    # Keep the wayscriber daemon running so the overlay toggles instantly
    systemd.user.services.wayscriber = {
      Unit = {
        Description = "Wayscriber screen annotation daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgsUnstable.wayscriber}/bin/wayscriber --daemon";
        Restart = "on-failure";
        RestartSec = "2s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
