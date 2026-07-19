{
  inputs,
  userVars,
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
              height = 24;

              start = [
                {
                  type = "sys_info";
                  format = [
                    "↑ {uptime}"
                    "  {cpu_percent}%@{load_average_1}"
                    " {temp_c}°C"
                    " {memory_percent}%+{swap_percent}%"
                  ];
                }
                {
                  type = "tray";
                  icon_size = 16;
                }
              ];

              center = [
                {
                  type = "script";
                  mode = "poll";
                  interval = 10000;
                  cmd = "systemctl --user list-units --failed --state=failed --legend=no | wc -l";
                }
                {
                  type = "focused";
                  show_icon = true;
                  show_title = true;
                  max_length = 50;
                }
              ];

              end = [
                {
                  type = "network_manager";
                }
                # Native Audio Volume
                {
                  type = "volume";
                  max_volume = 150;
                }
                # Native Clock
                {
                  type = "clock";
                  format = "%a %d %B %Y - %H:%M:%S";
                }
                # SwayNC integration using a custom widget button
                {
                  type = "notifications";
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
:root {
    --color-dark-primary: #1c1c1c;
    --color-dark-secondary: #2d2d2d;
    --color-white: #fff;
    --color-active: #6699cc;
    --color-urgent: #8f0a0a;

    --margin-lg: 1em;
    --margin-sm: 0.5em;
}

* {
    border-radius: 0;
    border: none;
    box-shadow: none;
    background-image: none;
    font-family: monospace;
}

scale > trough {
    background-color: var(--color-dark-secondary);
}

scale > trough > highlight {
    background-color: var(--color-active);
    border-style: solid;
    border-color: var(--color-active);
    border-width: 0.2em;
}

scale > trough > slider {
    background-color: var(--color-white);
}

switch > slider {
    background-color: var(--color-white);
}

switch:checked {
    background-color: var(--color-active);
}

switch:not(:checked) {
  background-color: var(--color-dark-secondary);
}

#bar, popover, popover contents, calendar, popover .view {
    background-color: var(--color-dark-primary);
}

box, button, label {
    background-color: #0000;
    color: var(--color-white);
}

button {
    padding-left: var(--margin-sm);
    padding-right: var(--margin-sm);
}

button:hover, button:active, *:selected {
    background-color: var(--color-dark-secondary);
}

#end > * + * {
    margin-left: var(--margin-lg);
}

.sysinfo > * + * {
    margin-left: var(--margin-sm);
}

.clock {
    font-weight: bold;
}

.popup-clock .calendar-clock {
    font-size: 2.0em;
}

.popup-clock .calendar .today {
    background-color: var(--color-active);
}

.workspaces .item.visible {
    box-shadow: inset 0 -1px var(--color-white);
}
          '';

        features = [];
      };
    };
  };
}
