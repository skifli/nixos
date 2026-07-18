{
  hostVars,
  inputs,
  lib,
  pkgs,
  userVars,
  ...
} @ attrs: {
  nixpkgs.overlays = [
    inputs.niri.overlays.niri
  ]; # Add Niri overlay

  home-manager = {
    users.${userVars.username} = {
      imports = [
        inputs.niri.homeModules.niri
      ];

      # Niri automagically sets up a lot of needed stuff
      programs.niri = {
        enable = true;
        package = let
          inherit (pkgs.stdenv.hostPlatform) system;
        in
          inputs.niri.packages.${system}.niri-stable.override {
            libdisplay-info = pkgs.libdisplay-info_0_2;
          }; # Fix for https://github.com/sodiboo/niri-flake/issues/1406
        settings = {
          prefer-no-csd = true;
          hotkey-overlay.skip-at-startup = true;

          xwayland-satellite = {
            enable = true;
            path = lib.getExe pkgs.xwayland-satellite;
          };

          input =
            {
              warp-mouse-to-focus.enable = true; # Warp pointer to focused window

              focus-follows-mouse = {
                enable = true;
                max-scroll-amount = "10%"; # Allow focus-follows-mouse when it results in scrolling at most 10% of the screen.
              };

              mouse = {
                accel-profile = "adaptive";
              };

              keyboard = {
                repeat-delay = 300;
              };
            }
            // hostVars.niri.input;

          gestures.hot-corners.enable = false;

          # https://github.com/YaLTeR/niri/issues/2430
          clipboard.disable-primary = true;

          binds = import ./niri/binds.nix attrs;
          inherit (hostVars) outputs workspaces;

          animations = {
            enable = true;

            workspace-switch.enable = true;
            window-open.enable = true;
            window-close.enable = true;
            window-movement.enable = true;
            window-resize.enable = true;
          };

          inherit (userVars.niri) spawn-at-startup;

          window-rules =
            [
              {
                matches = [{is-focused = false;}];

                opacity = 0.90;
              }
              {
                matches = [{app-id = "(?i)${userVars.programs.terminal}";}];

                open-maximized = true;
              }
              /*
              {
                matches = [
                  {
                    title = "^(Unlock Login Keyring)(.*)$";
                  } # GNOME Keyring
                ];

                geometry-corner-radius = rec {
                  bottom-left = 12.0;
                  bottom-right = bottom-left;
                  top-left = bottom-left;
                  top-right = bottom-left;
                };

                clip-to-geometry = true;
              }
              */
            ]
            ++ userVars.niri.window-rules;

          layout = {
            gaps = 0;
            background-color = "transparent";
            center-focused-column = "on-overflow";
            always-center-single-column = true;
            empty-workspace-above-first = false;
            default-column-width = {}; # Allows windows to decide their initial width

            border = {
              enable = false;
              width = 2;
            };

            shadow = {
              enable = true;
              draw-behind-window = true;
              softness = 20;
              spread = 5;
              offset = {
                x = 5;
                y = 5;
              };
              color = "#000000aa";
            };

            struts = rec {
              top = 0;
              left = 0;
              right = left;
            };

            preset-column-widths = [
              {proportion = 1.0 / 3.0;}
              {proportion = 1.0 / 2.0;}
              {proportion = 2.0 / 3.0;}
            ];

            focus-ring.enable = false;
            tab-indicator.position = "top";
          };
        };
      };

      # Environment variables for Niri
      home.sessionVariables = {
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_DESKTOP = "niri";
      };

      /*
      # NOT NEEDED ANYMORE: NIRI JUST REQUIRES IT TO BE INSTALLED, IT DOES THE REST
      # Switch from `Install.WantedBy = [ "graphical-session.target" ]` as defined
      # in the service file provided by the xwayland-satellite package. This links
      # xwayland-satellite to niri specifically, and schedules it so that there is
      # a wayland session available when it starts.
      systemd.user.services.xwayland-satellite = {
        Unit = {
          Description = "Xwayland outside your Wayland";
          BindsTo = "graphical-session.target";
          PartOf = "graphical-session.target";
          After = "graphical-session.target";
          Requisite = "graphical-session.target";
        };
        Service = {
          Type = "notify";
          NotifyAccess = "all";
          ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
          StandardOutput = "journal";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
      */
    };
  };

  environment.systemPackages = with pkgs; [
    niri
  ];

  programs = {
    dconf.enable = true;
    niri.enable = true;

    uwsm = {
      enable = true;

      waylandCompositors = {
        niri = {
          prettyName = "Niri";
          comment = "Niri compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/niri-session";
        };
      };
    };
  };

  # services.polkit-gnome.enable = true;

  xdg.portal.configPackages = [pkgs.niri];
}
