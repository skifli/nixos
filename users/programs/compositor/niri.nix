{
  hostVars,
  inputs,
  lib,
  pkgs,
  pkgsUnstable,
  userVars,
  ...
}@attrs:

{
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
        package = inputs.niri.packages.x86_64-linux.niri-stable.override {
          libdisplay-info = pkgs.libdisplay-info_0_2;
        }; # Fix for https://github.com/sodiboo/niri-flake/issues/1406
        settings = {
          prefer-no-csd = true;
          hotkey-overlay.skip-at-startup = true;

          xwayland-satellite = {
            enable = true;
            path = lib.getExe pkgs.xwayland-satellite;
          };

          input = {
            focus-follows-mouse.enable = true;
            warp-mouse-to-focus.enable = true; # Warp pointer to focused window

            mouse = {
              accel-profile = "adaptive";
            };
          };

          gestures.hot-corners.enable = false;

          # https://github.com/YaLTeR/niri/issues/2430
          clipboard.disable-primary = true;

          binds = import ./niri/binds.nix attrs;
          outputs = hostVars.outputs;
          workspaces = hostVars.workspaces;

          animations = {
            enable = true;

            workspace-switch.enable = true;
            window-open.enable = true;
            window-close.enable = true;
            window-movement.enable = true;
            window-resize.enable = true;
          };

          spawn-at-startup = [ ] ++ userVars.niri.spawn-at-startup;

          window-rules = [
            {
              open-maximized = true;
            }
            {
              matches = [ { is-focused = false; } ];

              opacity = 0.90;
            }
            {
              matches = [
                {
                  app-id = "(?i)anki";
                  title = "Anki";
                } # Doesn't match normal window, just some popups etc
                {
                  app-id = "(?i)anki";
                  title = "^(Checking)(.*)$";
                } # Syncing screen
                {
                  app-id = "(?i)anki";
                  title = "^(Choose Deck)(.*)$";
                }
                {
                  app-id = "(?i)anki";
                  title = "^(Export)(.*)$";
                }
                {
                  app-id = "(?i)anki";
                  title = "^(Import File)(.*)$";
                }
                {
                  app-id = "(?i)anki";
                  title = "^(Note Type)(.*)$";
                }
                {
                  app-id = "(?i)anki";
                  title = "^(Preferences)(.*)$";
                }
                {
                  app-id = "(?i)anki";
                  title = "^(Reset Card)(.*)$";
                }
                {
                  app-id = "(?i)anki";
                  title = "^(Syncing)(.*)$";
                }
                {
                  title = "^(Unlock Login Keyring)(.*)$";
                } # GNOME Keyring
                {
                  app-id = "(?i)${userVars.programs.browser}";
                  title = "^(Enter name of file to save to)(.*)$";
                } # Meant to be Zen save file screen
                {
                  app-id = "(?i)${userVars.programs.browser}";
                  title = "^(Removing Cookies and Site Data)(.*)$";
                } # Meant to be Zen browser site data screen
                {
                  app-id = "(?i)${userVars.programs.browser}";
                  title = "^(Save)(.*)$";
                } # Meant to be Zen save screen
              ];

              geometry-corner-radius = rec {
                bottom-left = 12.0;
                bottom-right = bottom-left;
                top-left = bottom-left;
                top-right = bottom-left;
              };

              clip-to-geometry = true;
            }
            {
              matches = [
                {
                  app-id = "(?i)anki";
                  title = "^(Current Card (Study))(.*)$";
                }
              ];

              open-floating = true;
            }
            {
              matches = [
                # File dialogs and system windows
                { title = "^(Open File)(.*)$"; }
                { title = "^(Select a File)(.*)$"; }
                { title = "^(Choose wallpaper)(.*)$"; }
                { title = "^(Open Folder)(.*)$"; }
                { title = "^(Save As)(.*)$"; }
                { title = "^(Library)(.*)$"; }

                #  Picture-in-Picture video
                { title = "^Picture-in-Picture$"; }
              ];

              open-floating = true;
              open-maximized = false;
            }
            {
              matches = [
                {
                  app-id = "(?i)pavucontrol";
                }
              ];

              open-maximized = false;
            }
          ]
          ++ userVars.niri.window-rules;

          layout = {
            gaps = 0;
            background-color = "transparent";
            center-focused-column = "on-overflow";
            always-center-single-column = true;
            empty-workspace-above-first = false;

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

  xdg.portal.configPackages = [ pkgs.niri ];
}
