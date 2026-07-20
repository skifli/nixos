{
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    services.wayle = {
      enable = true;
      autoInstallDependencies = true;

      # Tip: you can automatically translate your TOML config to Nix by running
      # nix-instantiate --eval --expr 'builtins.fromTOML (builtins.readFile ./config.toml)' | nixfmt
      settings = {
      };
    };
  };
}
