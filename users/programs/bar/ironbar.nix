{
  inputs,
  userVars,
  commonHostVars,
  ...
}: {
  home-manager = {
    sharedModules = [inputs.ironbar.homeManagerModules.default];

    users.${userVars.username} = {
      programs.ironbar = {
        enable = true;
        systemd = true;

        config = {
          monitors = {
            "${userVars.bar.output}" = {
              anchor_to_edges = true;
              position = "top";
              height = 28; # Slightly increased to comfortably fit the 10.5pt font and padding

              start = [
                {
                  type = "sys_info";
                  class = "module module-sysinfo";
                  format = [
                    "↑ {uptime}"
                    "  {cpu_percent}%@{load_average_1}"
                    " {temp_c}°C"
                    " {memory_percent}%+{swap_percent}%"
                  ];
                }
                {
                  type = "tray";
                  class = "module module-tray";
                  icon_size = 15;
                }
              ];

              center = [
                {
                  type = "script";
                  class = "module module-failed-units";
                  mode = "poll";
                  interval = 10000;
                  cmd = "systemctl --user list-units --failed --state=failed --legend=no | wc -l";
                }
                {
                  type = "focused";
                  class = "module module-focused";
                  show_icon = true;
                  show_title = true;
                  max_length = 50;
                }
              ];

              end = [
                {
                  type = "network_manager";
                  class = "module module-network";
                }
                {
                  type = "volume";
                  class = "module module-volume";
                  max_volume = 150;
                }
                {
                  type = "clock";
                  class = "module module-clock";
                  format = "%a %d %B %Y - %H:%M:%S";
                }
                {
                  type = "notifications";
                  class = "module module-notifications";
                }
              ];
            };
          };
        };

        style =
          /*
          css
          */
          ''
            /* --- Custom Name Definitions Mapped to Wallust Placeholders --- */
            @define-color custom-primary #CDEBD6;         /* Main text */
            @define-color custom-secondary #AFDABC;       /* Sub-text */
            @define-color custom-background #16171A;      /* Main bar background */
            @define-color custom-surface #3D3E42;         /* Module background */
            @define-color custom-border #7B9984;          /* General border */
            @define-color custom-accent #46A44D;          /* Primary accent */
            @define-color custom-highlight #1C3943;       /* Highlight/Error */

            @define-color battery-warning-color #2A6657;
            @define-color battery-charging-color #70C68A;
            @define-color network-color #46A44D;
            @define-color network-hover-color #46A44D;
            @define-color bluetooth-hover-color #46A44D;
            @define-color transparent rgba(0, 0, 0, 0);

            /* --- Styles using your custom color names --- */
            * {
                font-family: ${commonHostVars.fonts.monospace.name}, "JetBrainsMono Nerd Font", "Noto Sans Nerd Font", sans-serif;
                font-size: 10.5pt;
                font-weight: normal;
                color: @custom-primary;
                border: none;
                border-radius: 0px;
                box-shadow: none;
                text-shadow: none;
                background-image: none;
                outline: none;
                margin: 0;
                padding: 0;
                transition-property: background-color, color, box-shadow, opacity;
                transition-duration: 0.25s;
                transition-timing-function: ease-in-out;
            }

            window#ironbar {
                background-color: @transparent;
            }

            #bar {
                background-color: alpha(@custom-background, 0.3);
                padding: 3px 12px;
                
                /* Full-width Styling */
                margin: 0px;
                border-radius: 0px;
                border-bottom: 2px solid alpha(@custom-accent, 0.8);

                /* Floating Capsule Styling Alternative:
                margin: 6px 15px 0px 15px;
                border-radius: 12px;
                border: 2px solid alpha(@custom-accent, 0.8);
                */
            }

            .bar-container {
                background-color: @transparent;
            }

            window, .background {
                background-color: @transparent;
            }

            #bar > .left,
            #bar > .center,
            #bar > .right {
                padding: 0 4px;
                background-color: @transparent; /* Removed solid beige debug background */
            }

            /* Pill module structure */
            .module {
                padding: 3px 10px;
                margin: 0 4px;
                border-radius: 8px;
                background-color: alpha(@custom-surface, 0.3);
                font-weight: normal;
                min-width: 40px;
            }

            .module:hover {
                background-color: alpha(@custom-surface, 0.9);
                color: @custom-accent;
                box-shadow: 0 0 5px alpha(@custom-accent, 0.3);
            }

            /* Module specific overrides */
            .module-sysinfo {
                color: @custom-primary;    
                font-weight: normal;
            }
            .module-sysinfo:hover {
                color: @custom-accent;
            }
            .module-sysinfo label {
                margin: 0 4px;
                font-size: 10pt;
            }

            .module-focused {
                color: @custom-primary;
                font-weight: bold;
            }

            .module-failed-units {
                color: @custom-highlight;
                font-weight: bold;
            }

            .module-volume {
                color: @custom-primary;
                padding: 3px 8px;
                font-weight: normal;
            }
            .module-volume:hover {
                color: @custom-accent;
                background-color: alpha(@custom-surface, 0.7);
            }

            .module-network {
                color: @network-color;
                padding: 3px 8px;
                font-weight: normal;
            }
            .module-network:hover {
                color: @network-hover-color;
                background-color: alpha(@custom-surface, 0.7);
            }

            .module-notifications {
                color: @custom-primary;
            }
            .module-notifications:hover {
                color: @custom-accent;
            }

            .module-clock {
                font-weight: bold;
                color: @custom-primary;
                font-size: 11pt;
                padding: 3px 9px;
                background-color: alpha(@custom-surface, 0.3);
            }
            .module-clock:hover {
                color: @custom-accent;
                background-color: alpha(@custom-surface, 0.8);
            }

            /* Clock Popup/Calendar Styling */
            .popup-clock {
                background-color: alpha(@custom-background, 0.3);
                padding: 15px;
                border-radius: 12px;
                border: 1px solid alpha(@custom-surface, 0.3);
                box-shadow: none;
                min-width: 300px;
            }

            .popup-clock .calendar-clock {
                font-family: ${commonHostVars.fonts.monospace.name}, "JetBrainsMono Nerd Font", "Noto Sans Nerd Font", sans-serif;
                font-size: 14pt;
                font-weight: bold;
                color: @custom-primary;
                margin-bottom: 20px;
                padding: 10px 15px;
                background-color: alpha(@custom-surface, 0.85);
                border-radius: 10px;
                border: 1px solid alpha(@custom-border, 0.4);
            }

            .popup-clock .calendar {
                font-family: ${commonHostVars.fonts.monospace.name}, "JetBrainsMono Nerd Font", "Noto Sans Nerd Font", sans-serif;
                font-size: 10.5pt;
                color: @custom-primary;
                background-color: @transparent;
            }

            .popup-clock .calendar header {
                background-color: @transparent;
                padding-bottom: 10px;
                margin-bottom: 10px;
                border-bottom: 1px solid alpha(@custom-surface, 0.5);
            }
            .popup-clock .calendar header label {
                font-weight: bold;
                color: @custom-accent;
                font-size: 12pt;
            }
            .popup-clock .calendar header button {
                background-color: @transparent;
                color: @custom-secondary;
                font-size: 16pt;
                padding: 0 8px;
                border-radius: 8px;
                min-width: 30px;
                min-height: 30px;
            }
            .popup-clock .calendar header button:hover {
                background-color: alpha(@custom-surface, 0.7);
                color: @custom-accent;
            }

            .popup-clock .calendar .day-name {
                color: @custom-secondary;
                font-size: 10pt;
                font-weight: normal;
                padding: 6px 0;
                margin-bottom: 8px;
                border-bottom: 1px solid alpha(@custom-surface, 0.3);
            }

            .popup-clock .calendar .day {
                color: @custom-primary;
                padding: 7px;
                border-radius: 8px;
                margin: 2px;
                background-color: alpha(@custom-surface, 0.2);
            }
            .popup-clock .calendar .day:hover {
                background-color: alpha(@custom-accent, 0.2);
                color: @custom-primary;
            }

            .popup-clock .calendar .day.current {
                background-color: @custom-accent;
                color: @custom-background;
                font-weight: bold;
                box-shadow: 0 0 10px alpha(@custom-accent, 0.6);
                border: 1px solid @custom-accent;
            }

            .popup-clock .calendar .day.selected {
                background-color: @custom-highlight;
                color: @custom-background;
                font-weight: bold;
                box-shadow: 0 0 10px alpha(@custom-highlight, 0.6);
                border: 1px solid @custom-highlight;
            }

            .popup-clock .calendar .day.other-month {
                color: alpha(@custom-primary, 0.3);
                background-color: @transparent;
            }

            /* --- Volume Popup Styling --- */
            .popup-volume {
                background-color: alpha(@custom-background, 0.3);
                padding: 5px;
                border-radius: 6px;
                border: 1px solid alpha(@custom-surface, 0.5);
                box-shadow: 0 2px 6px rgba(0,0,0,0.2);
                min-width: 100px;
                padding-left: 10px;
                padding-right: 0px;
            }

            .popup-volume .device-box {
                background-color: @transparent;
                padding-bottom: 3px;
                margin-bottom: 3px;
                border-bottom: 1px solid alpha(@custom-surface, 0.3);
            }

            .popup-volume .device-box .device-selector {
                background-color: alpha(@custom-surface, 0.6);
                color: @custom-primary;
                border-radius: 4px;
                padding: 2px 3px;
                margin-bottom: 3px;
                border: 1px solid alpha(@custom-border, 0.1);
                font-size: 8.5pt;
                min-width: 80px;
            }
            .popup-volume .device-box .device-selector:hover {
                background-color: alpha(@custom-surface, 0.8);
            }
            .popup-volume .device-box .device-selector label {
                font-size: 8.5pt;
            }

            .popup-volume .device-box .slider {
                min-height: 70px;
                min-width: 10px;
                background-color: @transparent;
                margin-top: 5px;
                margin-bottom: 5px;
            }

            .popup-volume .device-box .slider trough {
                background-color: alpha(@custom-primary, 0.1);
                min-width: 4px;
                border-radius: 2px;
            }

            .popup-volume .device-box .slider highlight {
                background-color: @custom-accent;
                min-width: 4px;
                border-radius: 2px;
            }

            .popup-volume .device-box .slider slider {
                background-color: @custom-highlight;
                border-radius: 4px;
                min-width: 10px;
                min-height: 10px;
                border: 1px solid @custom-primary;
            }
            .popup-volume .device-box .slider slider:hover {
                background-color: @custom-accent;
            }

            .popup-volume .device-box .btn-mute {
                background-color: alpha(@custom-surface, 0.6);
                color: @custom-primary;
                border-radius: 4px;
                padding: 2px 5px;
                margin-top: 3px;
                border: 1px solid alpha(@custom-border, 0.1);
                font-size: 8pt;
            }
            .popup-volume .device-box .btn-mute:hover {
                background-color: alpha(@custom-surface, 0.8);
                color: @custom-accent;
            }
            .popup-volume .device-box .btn-mute.muted {
                background-color: @custom-highlight;
                color: @custom-background;
            }

            .popup-volume .apps-box {
                margin-top: 10px;
                padding-top: 3px;
                border-top: 1px solid alpha(@custom-surface, 0.3);
            }

            .popup-volume .apps-box .app-box {
                margin-bottom: 12px;
                padding: 12px;
                background-color: alpha(@custom-surface, 0.2);
                border-radius: 4px;
                font-size: 8pt;
                min-width: 200px;
            }
            .popup-volume .apps-box .app-box:last-child {
                margin-bottom: 0;
            }

            .popup-volume .apps-box .app-box .title {
                font-weight: bold;
                color: @custom-primary;
                margin-bottom: 1px;
            }

            .popup-volume .apps-box .app-box .slider {
                min-height: unset;
                background-color: @transparent;
            }
            .popup-volume .apps-box .app-box .slider trough {
                background-color: alpha(@custom-primary, 0.05);
                min-height: 2px;
                border-radius: 1px;
            }
            .popup-volume .apps-box .app-box .slider highlight {
                background-color: @custom-accent;
                min-height: 2px;
                border-radius: 1px;
            }
            .popup-volume .apps-box .app-box .slider slider {
                background-color: @custom-highlight;
                border-radius: 3px;
                min-width: 7px;
                min-height: 7px;
                border: 1px solid alpha(@custom-primary, 0.5);
            }
            .popup-volume .apps-box .app-box .slider slider:hover {
                background-color: @custom-accent;
            }

            .popup-volume .apps-box .app-box .btn-mute {
                background-color: alpha(@custom-surface, 0.6);
                color: @custom-primary;
                border-radius: 3px;
                padding: 1px 3px;
                margin-left: 3px;
                border: 1px solid alpha(@custom-border, 0.1);
                font-size: 7.5pt;
            }
            .popup-volume .apps-box .app-box .btn-mute:hover {
                background-color: alpha(@custom-surface, 0.8);
                color: @custom-accent;
            }
            .popup-volume .apps-box .app-box .btn-mute.muted {
                background-color: @custom-highlight;
                color: @custom-background;
            }

            /* Tooltips */
            tooltip.background {
                background-color: alpha(@custom-background, 0.95);
                padding: 6px 10px;
                border-radius: 8px;
                border: 1px solid @custom-surface;
                box-shadow: 0 2px 8px rgba(0,0,0,0.3);
            }
            tooltip label {
                color: @custom-primary;
                font-size: 9.5pt;
                font-weight: normal;
            }
          '';

        features = [];
      };
    };
  };
}