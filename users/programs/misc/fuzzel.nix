{
  userVars,
  ...
}:
{
  home-manager.users.${userVars.username} = {
    programs.fuzzel = {
      enable = true;

      settings = {
        main = {
          dpi-aware = "no";
        };
      };
    };
  };
}
