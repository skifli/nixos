{
  inputs,
  pkgs,
  userVars,
  ...
}: {
  home-manager = {
    sharedModules = [inputs.nix-index-database.homeModules.default];

    users.${userVars.username} = {
      home.packages = with pkgs; [
        nix-index
      ];

      programs = {
        # 1. Disable default NixOS command-not-found handler to prevent duplication
        command-not-found.enable = false;

        nix-index = {
          enable = true;
          enableZshIntegration = true;
        };

        nix-index-database.comma.enable = true;
      };
    };
  };
}
