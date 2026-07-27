{
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      # inputs.concord.packages.${pkgs.system}.default
    ];
  };
}
