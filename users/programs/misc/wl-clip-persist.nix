{userVars, ...}: {
  home-manager.users.${userVars.username} = {
    services.wl-clip-persist = {
      enable = true;

      clipboardType = "regular";
    };
  };
}
