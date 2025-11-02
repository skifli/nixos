{
  commonHostVars,
  pkgs,
  userVars,
  ...
}:

{
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      # Font Stuff
      font-awesome
      nerd-fonts.jetbrains-mono
      nerd-fonts.noto
      nerd-fonts.symbols-only
    ];

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "graphical-session.target";
      };

      style = ''
        /* Base background color */
        @define-color bg_main rgba(25, 25, 25, 0.65);
        @define-color bg_main_tooltip rgba(0, 0, 0, 0.7);

        /* Base background color of selections */
        @define-color bg_hover rgba(200, 200, 200, 0.3);
        /* Base background color of active elements */
        @define-color bg_active rgba(100, 100, 100, 0.5);

        /* Bae border color */
        @define-color border_main rgba(255, 255, 255, 0.2);

        /* Text color for entries, views and content in general */
        @define-color content_main white;
        /* Text color for entries that are unselected */
        @define-color content_inactive rgba(255, 255, 255, 0.25);

        * {
          border: none;
          border-radius: 0;
          font-family: ${commonHostVars.fonts.monospace.name}, FontAwesome6Free, JetBrainsMono, "NotoSansMono Nerd Font", SymbolsNerdFont; /* font-size: 13px; */
        }

        window#waybar {
          background: @bg_main;
          border-bottom: 1px solid @border_main;
          color: @content_main;
          /* font-size: 6px; */
          /* height: 20px; */
        }

        window#waybar:hover {
          /* font-size: 9px; */
          /* height: 50px; */
        }

        tooltip {
          background: @bg_main_tooltip;
          border-radius: 5px;
          border-width: 1px;
          border-style: solid;
          border-color: @border_main;
        }

        tooltip label{
          color: @content_main;
        }

        #cpu, #memory {
          padding: 3px;
        }

        #temperature {
          transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
        }

        #temperature.critical {
          padding-right: 3px;
          color: @warning_color;
          border-bottom: 3px dashed @warning_color;
          transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
        }

        #window {
          border-radius: 10px;
          margin-left: 20px;
          margin-right: 20px;
        }

        #tray {
          margin-left: 5px;
          margin-right: 5px;
        }

        #tray > .passive {
          border-top: none;
        }

        #tray > .active {
          border-top: 3px solid white;
        }

        #tray > .needs-attention {
          border-top: 3px solid @warning_color;
        }

        #tray > widget {
          transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
        }

        #tray > widget:hover {
          background: @bg_hover;
        }

        #pulseaudio {
          padding-left: 3px;
          padding-right: 3px;
          transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
        }

        #pulseaudio:hover, #network:hover {
          background: @bg_hover;
        }

        #network {
          padding-left: 3px;
          padding-right: 3px;
        }

        #clock {
          padding-right: 5px;
          padding-left: 5px;
          transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
        }

        #clock:hover {
          background: @bg_hover;
        }
      '';

      settings = {
        mainBar = {
          reload_style_on_change = true;
          layer = "top";
          position = "top";
          spacing = 0;
          height = 26;
          modules-left = [
            "custom/power"
            "cpu"
            "temperature"
            "memory"
            "group/tray-expander"
          ];
          modules-center = [
            "niri/window"
          ];
          modules-right = [
            "idle_inhibitor"
            "network"
            "pulseaudio"
            "clock"
            "custom/notification"
          ];

          # Custom modules
          "custom/power" = {
            format = " ❄︎ "; # Gap for spacing
            tooltip = "Power Menu";
            on-click = userVars.programs.logout-menu;
          };
          "custom/expand-icon" = {
            format = " "; # Gap for spacing
            tooltip = false;
          };
          "custom/notification" = {
            tooltip = false;
            format = " {icon} "; # Gaps for spacing
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

          # Module groups
          "group/tray-expander" = {
            orientation = "inherit";
            drawer = {
              transition-duration = 250;
            };
            modules = [
              "custom/expand-icon"
              "tray"
            ];
          };

          # Other module config
          cpu = {
            interval = 5;
            format = " {usage}%";
            on-click = "btop";
          };

          memory = {
            interval = 5;
            format = " {percentage}%";
            max-length = 10;
          };

          temperature = {
            format = " {temperatureC}°C";
            format-critical = " {temperatureC}°C";
            interval = 5;
            critical-threshold = 80;
            on-click = "btop";

            hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
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
              weeks-pos = "right";
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
            icon-size = 12;
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
          };

          pulseaudio = {
            format = "{icon}";
            scroll-step = 5;
            max-volume = 150;
            on-click = "pavucontrol";
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
