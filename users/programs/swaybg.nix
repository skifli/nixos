{
  pkgs,
  userVars,
  ...
}:

{
  home-manager.users.${userVars.username} = {
    systemd.user.services.swaybg = {
      Unit = {
        Description = "Wallpaper";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.swaybg}/bin/swaybg -i /home/${userVars.username}/.local/share/wallpaper.jpg";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
