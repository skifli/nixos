{userVars, ...}: {
  home-manager.users.${userVars.username} = {
    programs.yazi = {
      enable = true;
      settings = {};
      shellWrapperName = "y";
    };
  };
}
