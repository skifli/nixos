{
  pkgs,
  userVars,
  ...
}:

{
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      wleave
    ];
  };
}
