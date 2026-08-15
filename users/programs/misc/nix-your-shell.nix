{
  inputs,
  pkgs,
  userVars,
  ...
}: {
  home-manager = {
    users.${userVars.username} = {
      programs = {
        # Whether to enable nix-your-shell, a wrapper for nix develop or nix-shell to retain the same shell inside the new environment.
        nix-your-shell = {
          enable = true;
          enableZshIntegration = userVars.programs.terminal-shell == "zsh";

          nix-output-monitor.enable = true; # Whether to enable nix-output-monitor. Pipe your nix-build output through the nix-output-monitor a.k.a nom to get additional information while building .
        };
      };
    };
  };
}
