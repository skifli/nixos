{ pkgs, userVars, ... }:

{
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      starship
    ];

    programs.starship = {
      enable = true;
      settings = { };
    };
  };
}
