{
  pkgs,
  userVars,
  ...
}:

{
  home-manager.users.${userVars.username} = {
    services.xrdp = {
      enable = true;
      defaultWindowManager = "${pkgs.uwsm}/bin/uwsm start "
          + (
              if userVars.programs.compositor == "niri"
              then "${pkgs.niri}/bin/niri-session"
              else "${pkgs.${userVars.programs.compositor}}/bin/${userVars.programs.compositor}"
            );
      openFirewall = true;
      audio.enable = true;
    };
  };
}
