{ userVars, ... }:

{
  home-manager.users.${userVars.username} = {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = userVars.programs.shell == "zsh";
    };
  };
}
