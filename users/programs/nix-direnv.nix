{userVars, ...}: {
  home-manager.users.${userVars.username} = {
    programs.direnv = {
      enable = true;
      enableZshIntegration = userVars.programs.terminal-shell == "zsh";
      nix-direnv.enable = true;
    };
  };
}
