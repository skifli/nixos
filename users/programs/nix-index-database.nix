{
  inputs,
  pkgs,
  userVars,
  ...
}: {
  # 1. Disable default NixOS command-not-found handler to prevent duplication
  programs.command-not-found.enable = false;

  home-manager = {
    sharedModules = [inputs.nix-index-database.homeModules.default];

    users.${userVars.username} = {
      home.packages = with pkgs; [
        nix-locate
      ];

      programs = {
        nix-index = {
          enable = true;
          enableZshIntegration = true;
        };

        nix-index-database.comma.enable = true;
      };
    };
  };
}
