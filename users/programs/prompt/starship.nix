{ userVars, ... }:

{
  home-manager.users.${userVars.username} = {
    programs.starship = {
      enable = true;
      settings = { };
    };
  };
}
