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

      /*
         NOT NEEDED ANYMORE AS AWWW IS DONE SEPARATELY FOR NIRI WORKSPACE BLUR
      # Safely wraps wayle to include awww in its PATH before systemd runs it
      package = pkgs.symlinkJoin {
        name = "wayle-wrapped";
        paths = [pkgs.wayle];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/wayle --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.awww]}
        '';
      };
      */

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
                "custom-load"
                "ram"
                "weather"
              ];
              left = [
                "dashboard"
                "custom-screencast"
                "custom-screen_recorder"
                "niri-workspaces"
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
          niri-workspaces = {
            monitor-specific = false;
          };
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
            poll-interval-ms = 5000;
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
              middle-click = "${userVars.programs.terminal} -e ${userVars.programs.terminal-shell} -c \"systemctl reset-failed; systemctl --user reset-failed; ${userVars.programs.terminal-shell}\"";
              mode = "poll";
              restart-interval-ms = 1000;
              restart-policy = "never";
              right-click = "${userVars.programs.terminal} -e ${userVars.programs.terminal-shell} -c \"systemctl --user --type=service --state=failed; ${userVars.programs.terminal-shell}\"";
              scroll-down = "";
              scroll-up = "";
            }
            {
              id = "screencast";
              border-color = "auto";
              border-show = true;
              button-bg-color = "bg-surface-elevated";
              command = "casts=$(niri msg casts 2>/dev/null) && if echo \"$casts\" | grep -q \"Target:\"; then echo \"CAST\"; fi";
              format = "{{ output }}";
              hide-if-empty = true;
              icon-bg-color = "auto";
              icon-color = "status-error";
              icon-name = "media-record-symbolic";
              icon-show = true;
              interval-ms = 3000;
              label-color = "status-error";
              label-max-length = 0;
              label-show = true;
              left-click = "${userVars.programs.terminal} -e ${userVars.programs.terminal-shell} -c \"niri msg casts; ${userVars.programs.terminal-shell}\"";
              right-click = "sh -c \"niri msg casts | awk '/Session ID:/ {print \\$3}' | while read -r id; do niri msg action stop-cast --session-id \\\"\\$id\\\" && notify-send -e -a niri -i '/home/${userVars.username}/.local/share/misc/niri-icon.svg' -u low -t 2500 'Screencasts' \\\"Stopped stream ID: \\$id\\\"; done\"";
              mode = "poll";
              restart-interval-ms = 1000;
              restart-policy = "never";
              scroll-down = "";
              scroll-up = "";
            }
            {
              id = "screen_recorder";
              border-color = "auto";
              border-show = true;
              button-bg-color = "bg-surface-elevated";
              command = "if [ -f /tmp/gpu-screen-recorder.pid ] && kill -0 $(cat /tmp/gpu-screen-recorder.pid) 2>/dev/null; then echo \"REC\"; fi";
              format = "{{ output }}";
              hide-if-empty = true;
              icon-bg-color = "auto";
              icon-color = "status-error";
              icon-name = "media-record-symbolic";
              icon-show = true;
              interval-ms = 1000;
              label-color = "status-error";
              label-max-length = 0;
              label-show = true;
              left-click = "/home/${userVars.username}/.local/bin/record.sh --stop";
              right-click = "/home/${userVars.username}/.local/bin/record.sh";
              mode = "poll";
              restart-interval-ms = 1000;
              restart-policy = "never";
              scroll-down = "";
              scroll-up = "";
            }
            {
              id = "load";
              border-color = "auto";
              border-show = false; # CPU, RAM, Weather don't so this should not either
              button-bg-color = "bg-surface-elevated";
              command = "awk '{print $1, $2, $3}' /proc/loadavg";
              format = "{{ output }}";
              hide-if-empty = false;
              icon-bg-color = "auto";
              icon-color = "fg-default";
              icon-name = "ld-activity-symbolic";
              icon-show = true;
              interval-ms = 5000;
              label-color = "fg-default";
              label-max-length = 0;
              label-show = true;
              left-click = "${userVars.programs.terminal} -e btop";
              right-click = userVars.programs.system-monitor;
              mode = "poll";
              restart-interval-ms = 1000;
              restart-policy = "never";
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
            popup-stacking-order = "oldest-first"; # I hate the fact that the default is newest-first because whenever I get a new notification ALL of them move (I mean duh lol I'm so smart bahahah) as I'm sometimes trying to read one of them :sob:
            popup-close-behavior = "remove"; # Saves my probably autism ass of whenever I see the notification bar with even 01 and not just 00 as the number of unread notifications I HAVE to click to see what it is and get back down to 00 otherwise it irks me that there's possibly something unread :sob:. So this just helps for those kind of notifications.
            popup-max-visible = 10;
            popup-urgency-bar = "normal";
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
            poll-interval-ms = 5000;
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
          engine-enabled = false;
          # Disabled because I need to do some custom awww stuff

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
