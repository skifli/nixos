{
  hostVars,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    # Enable screen colour automatic changing
    services.wlsunset = {
      enable = true;
      inherit (hostVars) latitude longitude;
      systemdTargets = ["graphical-session.target"];
    };
  };
}
