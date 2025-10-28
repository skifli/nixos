{ pkgs, userVars, ... }:

{
  home-manager.users.${userVars.username} = {
    programs.waybar = {
      enable = true;
      settings.mainBar.layer = "top";
      systemd = {
        enable = true;
        target = "graphical-session.target";
      };
    };
  };
}
