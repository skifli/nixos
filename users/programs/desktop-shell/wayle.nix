{
  hostVars,
  pkgs,
  userVars,
  ...
}: {
  environment.systemPackages = with pkgs; [
    awww # Was getting this error - `could not apply wallpaper from config change, error: neither awww nor swww found in PATH, monitor: *`
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
          wrapProgram $out/bin/wayle --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.awww]}
        '';
      };

      # Needs wallpaper.engine-enabled = true; to work

      # Tip: you can automatically translate your TOML config to Nix by running
      # nix-instantiate --eval --expr 'builtins.fromTOML (builtins.readFile ./config.toml)' | nixfmt
      settings = {
        bar = {
          background-opacity = 5;
          button-bg-opacity = 50;
          button-label-size = 1.15;
          button-label-weight = "bold";
          button-rounding = "none";
          button-variant = "basic";
          dropdown-opacity = 95;
          layout = [
            {
              center = [
                "cpu"
                "ram"
                "weather"
              ];
              left = [
                "dashboard"
                "custom-system_errors"
                "window-title"
              ];
              monitor = userVars.bar.output;
              right = [
                "volume"
                "microphone"
                "systray"
                "network"
                "clock"
                "notifications"
              ];
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
          scale = 0.55;
        };
        general = {
          font-sans = "Monospace";
        };
        modules = {
          clock = {
            dropdown-show-seconds = true;
            format = "%a %d %B %Y - %T";
            icon-color = "fg-default";
            icon-show = false;
            label-color = "fg-default";
          };
          cpu = {
            format = "{{ percent }}% @{{ temp_c }}C @{{ freq_ghz }}GHz";
            icon-color = "fg-default";
            label-color = "fg-default";
            left-click = "${userVars.programs.terminal} -e btop";
            right-click = userVars.programs.system-monitor;
            thresholds = [
              {
                above = 70;
                icon-color = "status-warning";
                label-color = "status-warning";
              }
              {
                above = 90;
                icon-color = "status-error";
                label-color = "status-error";
              }
            ];
          };
          custom = [
            {
              border-color = "auto";
              border-show = true;
              button-bg-color = "bg-surface-elevated";
              command = "systemctl --user --no-pager list-units --state=failed --no-legend --plain | awk 'END { if (NR > 0) print \" Service Failed\" }'";
              format = "{{ output }}";
              hide-if-empty = true;
              icon-bg-color = "auto";
              icon-color = "status-error";
              icon-name = "dialog-error-symbolic";
              icon-show = true;
              id = "system_errors";
              interval-ms = 10000;
              label-color = "status-error";
              label-max-length = 0;
              label-show = true;
              left-click = "${userVars.programs.terminal} -e ${userVars.programs.terminal-shell} -c \"systemctl --type=service --state=failed; ${userVars.programs.terminal-shell}\"";
              middle-click = "";
              mode = "poll";
              restart-interval-ms = 1000;
              restart-policy = "never";
              right-click = "${userVars.programs.terminal} -e ${userVars.programs.terminal-shell} -c \"systemctl --user --type=service --state=failed; ${userVars.programs.terminal-shell}\"";
              scroll-down = "";
              scroll-up = "";
            }
          ];
          dashboard = {
            icon-color = "blue";
          };
          microphone = {
            icon-color = "green";
            label-color = "green";
            scroll-down = "wayle audio input-volume -2";
            scroll-up = "wayle audio input-volume +2";
            thresholds = [
              {
                above = 70;
                icon-color = "status-warning";
                label-color = "status-warning";
              }
              {
                above = 90;
                icon-color = "status-error";
                label-color = "status-error";
              }
            ];
          };
          network = {
            icon-color = "fg-default";
            label-color = "fg-default";
          };
          notifications = {
            icon-color = "fg-default";
            label-color = "fg-default";
            thresholds = [
              {
                above = 5;
                icon-color = "status-warning";
                label-color = "status-warning";
              }
              {
                above = 20;
                icon-color = "status-error";
                label-color = "status-error";
              }
            ];
          };
          ram = {
            format = "{{ percent }}%+{{ swap_percent }}%";
            icon-color = "fg-default";
            label-color = "fg-default";
            left-click = "${userVars.programs.terminal} -e btop";
            right-click = userVars.programs.system-monitor;
            thresholds = [
              {
                above = 80;
                icon-color = "status-warning";
                label-color = "status-warning";
              }
              {
                above = 95;
                icon-color = "status-error";
                label-color = "status-error";
              }
            ];
          };
          systray = {
            border-show = true;
            button-bg-color = "accent-hover";
            icon-scale = 1.4;
          };
          volume = {
            icon-color = "green";
            label-color = "green";
            scroll-down = "wayle audio output-volume -2";
            scroll-up = "wayle audio output-volume +2";
            thresholds = [
              {
                above = 80;
                icon-color = "status-warning";
                label-color = "status-warning";
              }
              {
                above = 90;
                icon-color = "status-error";
                label-color = "status-error";
              }
            ];
          };
          weather = {
            icon-color = "status-warning";
            label-color = "status-warning";
            location = "${toString hostVars.latitude},${toString hostVars.longitude}";
            time-format = "24h";
          };
          window-title = {
            button-bg-color = "fg-subtle";
            format = "{{ app }}: {{ title }}";
            icon-show = false;
            label-color = "fg-default";
            left-click = "${userVars.programs.terminal} -e ${userVars.programs.terminal-shell} -c \"niri msg windows; ${userVars.programs.terminal-shell}\"";
            right-click = "${userVars.programs.terminal} -e ${userVars.programs.terminal-shell} -c \"niri msg outputs; ${userVars.programs.terminal-shell}\"";
          };
        };
        styling = {
          palette = {
            bg = "#0d0c0c";
            blue = "#8ba4b0";
            elevated = "#282727";
            fg = "#c5c9c5";
            fg-muted = "#a6a69c";
            green = "#87a987";
            primary = "#8992a7";
            red = "#c4746e";
            surface = "#181616";
            yellow = "#c4b28a";
          };
          rounding = "none";
          scale = 0.75;
        };
        wallpaper = {
          engine-enabled = true;

          monitors =
            pkgs.lib.mapAttrsToList (monitorName: _: {
              fit-mode = "fill";
              name = monitorName;
              wallpaper = "/home/${userVars.username}/.local/share/wallpaper";
            })
            hostVars.outputs;
          transition-type = "none";
        };
      };
    };
  };
}
