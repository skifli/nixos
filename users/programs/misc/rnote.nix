{
  pkgs,
  userVars,
  ...
}:
{
  home-manager.users.${userVars.username} = {
    home.packages = [
      pkgs.rnote # Sketch & handwritten notes
    ];
  };
}
