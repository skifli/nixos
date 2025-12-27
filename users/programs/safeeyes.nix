{
  pkgs,
  userVars,
  ...
}:

{
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [ safeeyes ];

    systemd.user.services.safeeyes = {
      Unit = {
        After = [
          "graphical-session.target"
          "dbus.service"
        ];
        PartOf = [ "graphical-session.target" ];
        Description = "SafeEyes break reminder";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.safeeyes}/bin/safeeyes";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
