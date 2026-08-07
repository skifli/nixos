{
  hostVars,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      sunsetr
    ];
  };
}
