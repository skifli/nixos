{inputs, userVars, ...}: {
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
                    " {cpu_percent}%@{load_average_1}"
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

        style = /* css */ ''
          
        '';

        package = inputs.ironbar;
        features = [];
      };
    };
  };
}
