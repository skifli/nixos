{
  hostVars,
  pkgs,
  userVars,
  ...
}: {
  environment.systemPackages = with pkgs; [
    awww # Was getting this error - `could not apply wallpaper from config change, error: neither awww nor swww found in PATH, monitor: *`
    playerctl
  ];

  home-manager.users.${userVars.username} = {
    services.wayle = {
      enable = true;
      autoInstallDependencies = true;

      # Safely wraps wayle to include awww in its PATH before systemd runs it
      package = pkgs.symlinkJoin {
        name = "wayle-wrapped";
        paths = [pkgs.wayle];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/wayle --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.awww pkgs.playerctl]}
        '';
      };

      # Needs wallpaper.engine-enabled = true; to work

      # Tip: you can automatically translate your TOML config to Nix by running
      # nix-instantiate --eval --expr 'builtins.fromTOML (builtins.readFile ./config.toml)' | nixfmt
      settings = {
        bar = {
          dropdown-opacity = 95;
          layout = [
            {
              center = [];
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
              right = [];
              show = true;
            }
            {
              center = [];
              left = [];
              monitor = "*";
              right = [];
              show = false;
            }
          ];
        };
        wallpaper = {
          engine-enabled = true;

          monitors = pkgs.lib.mapAttrsToList (monitorName: _: {
            fit-mode = "fill";
            name = monitorName;
            wallpaper = "/home/${userVars.username}/.local/share/wallpaper";
          }) hostVars.outputs;
        };
      };
    };
  };
}
