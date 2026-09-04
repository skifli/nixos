{
  inputs,
  userVars,
  ...
}:
{
  home-manager = {
    sharedModules = [ inputs.nix-index-database.homeModules.default ];

    users.${userVars.username} = {
      programs = {
        # 1. Disable default NixOS command-not-found handler to prevent duplication
        command-not-found.enable = false;

        nix-index = {
          enable = true;
          enableZshIntegration = userVars.programs.terminal-shell == "zsh";
        };

        nix-index-database.comma.enable = true;
      };
    };
  };
}
