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
        bar = {
          dropdown-opacity = 95;
          layout = [
            {
              center = [ ];
              left = [
                "clock"
                "cpu"
                "dashboard"
                "microphone"
                "network"
                "notifications"
                "ram"
                "separator"
                "systray"
                "volume"
                "weather"
                "window-title"
              ];
              monitor = userVars.bar.output;
              right = [ ];
              show = true;
            }
            {
              center = [ ];
              left = [ ];
              monitor = "*";
              right = [ ];
              show = false;
            }
          ];
        };
        wallpaper = {
          monitors = [
            {
              fit-mode = "fill";
              name = "*";
              wallpaper = "/home/ami/.local/share/wallpaper";
            }
          ];
        };
      }
    };
  };
}
