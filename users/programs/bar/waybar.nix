{
  commonHostVars,
  hostVars,
  pkgs,
  userVars,
  ...
}:
{
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      font-awesome
    ];

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "graphical-session.target";
      };

      style = ''
        @define-color bg_main rgba(25, 25, 25, 0.65);
        @define-color bg_main_tooltip rgba(0, 0, 0, 0.7);
        @define-color border_main rgba(255, 255, 255, 0.2);
        @define-color content_main white;
        @define-color warning_color #ff6666;

        * {
          border: none;
          border-radius: 0;
          font-family: ${commonHostVars.fonts.monospace.name}, FontAwesome;
          font-size: 13px;
          min-height: 26px;
        }

        window#waybar {
          background: @bg_main;
          border-bottom: 1px solid @border_main;
          color: @content_main;
        }

        tooltip {
          background: @bg_main_tooltip;
          border-radius: 5px;
          border: 1px solid @border_main;
        }

        tooltip label { color: @content_main; }

        /* === Module base === */
        #cpu, #memory, #temperature, #network, #pulseaudio, #clock,
        #tray, #privacy, #user, #load, #idle_inhibitor,
        #custom-notification, #systemd-failed-units, #niri-window {
          padding: 0 6px;
          transition: background 200ms ease-in-out;
        }

        /* consistent vertical alignment */
        #cpu label, #memory label, #temperature label, #network label,
        #pulseaudio label, #clock label, #tray label, #privacy label,
        #user label, #load label, #idle_inhibitor label,
        #custom-notification label, #systemd-failed-units label, #niri-window label {
          padding-top: 2px;
          padding-bottom: 2px;
        }

        /* fixed icon width */
        .icon, .fa, .fas, .far, .fab {
          min-width: 1.2em;
          padding-left: 4px;
          padding-right: 4px;
        }

        /* add slight margins between groups */
        #user, #cpu, #load, #temperature, #memory, #group-tray-expander {
          margin-right: 2px;
        }

        /* align right-side modules evenly */
        #privacy, #idle_inhibitor, #network, #pulseaudio, #clock, #custom-notification {
          padding-left: 6px;
          padding-right: 6px;
        }

        /* make notification not hug the screen edge */
        #custom-notification { margin-right: 6px; }

        #tray { margin: 0 5px; }
        #tray > .active { border-top: 3px solid white; }
        #tray > .needs-attention { border-top: 3px solid @warning_color; }

        #temperature.critical, #idle_inhibitor.activated {
          background-color: @warning_color;
        }

        #clock tooltip label { font-family: monospace; }

        /* cpu + load visually grouped */
        #cpu {
          margin-right: 0px;
          padding-right: 0px;
        }

        #load {
          margin-left: 0px;
          padding-left: 0px;
        }
      '';

      settings = {
        mainBar = {
          reload_style_on_change = true;
          layer = "top";
          position = "top";
          output = userVars.waybar.output;
          spacing = 0;

          modules-left = [
            "user"
            "cpu"
            "load"
            "temperature"
            "memory"
            "group/tray-expander"
          ];

          modules-center = [
            "systemd-failed-units"
            "niri/window"
          ];

          modules-right = [
            "privacy"
            "idle_inhibitor"
            "network"
            "pulseaudio"
            "clock"
            "custom/notification"
          ];

          # Custom modules
          "custom/expand-icon" = {
            format = " "; # 1 trailing space fixes cut-off
            tooltip = false;
          };

          "custom/notification" = {
            tooltip = false;
            format = "{icon}";
            format-icons = {
              notification = "󱅫";
              none = "";
              dnd-notification = "";
              dnd-none = "󰂛";
              inhibited-notification = "";
              inhibited-none = "";
              dnd-inhibited-notification = "";
              dnd-inhibited-none = "";
            };
            return-type = "json";
            exec-if = "which swaync-client";
            exec = "swaync-client -swb";
            on-click = "sleep 0.1 && swaync-client -t -sw";
            on-click-right = "sleep 0.1 && swaync-client -d -sw";
            escape = true;
          };

          "custom/weather" = {
            exec = "/home/${userVars.username}/.local/bin/get_weather.sh ${hostVars.location}";
            return-type = "json";
            format = "{}";
            tooltip = true;
            interval = 3600;
          };

          # Module groups
          "group/tray-expander" = {
            orientation = "inherit";
            drawer.transition-duration = 250;
            modules = [
              "custom/expand-icon"
              "tray"
            ];
          };

          user = {
            format = "↑ {work_H}:{work_M}";
            interval = 60;
            icon = false;
          };

          cpu = {
            interval = 5;
            format = " {usage}%";
          };

          load = {
            interval = 5;
            format = "@{load1}";
          };

          memory = {
            interval = 5;
            format = " {percentage}%+{swapPercentage}%";
          };

          privacy = {
            icon-spacing = 4;
            icon-size = 16;
            transition-duration = 250;
            modules = [
              {
                type = "screenshare";
                tooltip = true;
                tooltip-icon-size = 18;
              }
              {
                type = "audio-out";
                tooltip = true;
                tooltip-icon-size = 18;
              }
              {
                type = "audio-in";
                tooltip = true;
                tooltip-icon-size = 18;
              }
            ];
            ignore-monitor = true;
            ignore = [
              {
                type = "audio-in";
                name = "cava";
              }
              {
                type = "screenshare";
                name = "obs";
              }
            ];
          };

          temperature = {
            format = " {temperatureC}°C";
            format-critical = " {temperatureC}°C";
            interval = 5;
            critical-threshold = 80;
            hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
          };

          systemd-failed-units = {
            hide-on-ok = true;
            format = "✗ {nr_failed_system}/{nr_failed_user}";
            format-ok = "✓";
            system = true;
            user = true;
          };

          "niri/window" = {
            format = "{title:.50}";
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
            tooltip-format-activated = "Inhibiting idle";
            tooltip-format-deactivated = "Allowing idle";
          };

          clock = {
            format = "{:%a %d %B %Y - %T}";
            interval = 1;
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "year";
              mode-mon-col = 3;
              weeks-pos = "left";
              on-scroll = 1;
              on-click-right = "mode";
              format = {
                months = "<span color='#ffead3'><b>{}</b></span>";
                days = "<span color='#ecc6d9'><b>{}</b></span>";
                weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                today = "<span color='#ff6699'><b><u>{}</u></b></span>";
              };
            };
            actions = {
              on-click-right = "mode";
              on-click-forward = "tz_up";
              on-click-backward = "tz_down";
              on-scroll-up = "shift_up";
              on-scroll-down = "shift_down";
            };
          };

          tray = {
            icon-size = 16;
            spacing = 4;
          };

          network = {
            format-icons = [
              "󰤯"
              "󰤟"
              "󰤢"
              "󰤢"
              "󰤨"
            ];
            format = "{icon}";
            interval = 5;
            format-wifi = "{icon}";
            format-ethernet = "";
            format-disconnected = "󰌙";
            tooltip-format-wifi = "{essid} ({frequency} GHz)\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
            tooltip-format-ethernet = "⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
            tooltip-format-disconnected = "Disconnected";
            on-click = "nmcli dev wifi";
          };

          pulseaudio = {
            format = "{icon}  {volume}%";
            scroll-step = 5;
            max-volume = 200;
            on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
            on-click-right = "pavucontrol";
            tooltip-format = "{volume}%";
            format-muted = "󰝟";
            format-icons = [
              ""
              ""
              ""
            ];
          };
        };
      };
    };
  };
}
