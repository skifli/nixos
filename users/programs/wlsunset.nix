{
  hostVars,
  pkgs,
  userVars,
  ...
}:

{
  home-manager.users.${userVars.username} = {
    # Enable screen colour automatic changing
    services.wlsunset = {
      enable = true;
      latitude = hostVars.latitude;
      longitude = hostVars.longitude;
      systemdTarget = "graphical-session.target";
    };
  };
}
