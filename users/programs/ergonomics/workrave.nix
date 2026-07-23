{
  pkgs,
  userVars,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {
      workrave = prev.workrave.overrideAttrs (oldAttrs: {
        preFixup =
          (oldAttrs.preFixup or "")
          + ''
            gappsWrapperArgs+=(
              --set GDK_BACKEND "x11"
            )
          '';
      });
    })
  ];

  home-manager = {
    users.${userVars.username} = {
      home.packages = with pkgs; [
        workrave
      ];

      dconf.settings = {
        "org/workrave/breaks/daily-limit" = {enabled = false;};
        "org/workrave/breaks/micro-pause" = {enabled = true;};
        "org/workrave/breaks/rest-break" = {enabled = true;};

        "org/workrave/distribution" = {
          port = 27273;
          reconnect-attempts = 3;
          reconnect-interval = 15;
        };

        "org/workrave/general" = {usage-mode = 0;};

        "org/workrave/gui" = {
          force-x11 = true;
          trayicon-enabled = true;
          block-mode = 0; # Merged from [gui/breaks]
        };

        "org/workrave/gui/applet" = {
          cycle-time = 10;
          fallback-enabled = false;
        };
        "org/workrave/gui/applet/daily-limit" = {position = 0;};
        "org/workrave/gui/applet/micro-pause" = {position = 0;};
        "org/workrave/gui/applet/rest-break" = {position = 0;};

        "org/workrave/gui/breaks/daily-limit" = {
          ignorable-break = true;
          skippable-break = true;
        };
        "org/workrave/gui/breaks/micro-pause" = {
          ignorable-break = true;
          skippable-break = true;
        };
        "org/workrave/gui/breaks/rest-break" = {
          enable-shutdown = true;
          exercises = 5;
          ignorable-break = true;
          skippable-break = true;
        };

        "org/workrave/gui/main-window" = {
          cycle-time = 10;
          head = 0;
          x = 0;
          y = 0;
        };
        "org/workrave/gui/main-window/daily-limit" = {position = 2;};
        "org/workrave/gui/main-window/micro-pause" = {
          flags = 0;
          position = 0;
        };
        "org/workrave/gui/main-window/rest-break" = {position = 1;};

        "org/workrave/sound" = {volume = 100;};

        # Note: Sound events omitted here so Workrave uses its default store paths.
        # Cus hardcoding the specific /nix/store/ hash will cause breakages when Workrave updates.

        "org/workrave/timers/daily-limit" = {
          activity-sensitive = true;
          limit = 36000;
          snooze = 1200;
        };
        "org/workrave/timers/micro-pause" = {
          activity-sensitive = true;
          auto-reset = 30;
          limit = 600;
          snooze = 150;
        };
        "org/workrave/timers/rest-break" = {
          activity-sensitive = true;
          auto-reset = 300;
          limit = 3600;
          snooze = 300;
        };
      };
    };
  };
}
