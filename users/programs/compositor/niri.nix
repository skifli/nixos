{
  hostVars,
  inputs,
  lib,
  pkgs,
  pkgsUnstable,
  userVars,
  ...
} @ attrs: {
  home-manager = {
    users.${userVars.username} = {
      imports = [
        inputs.niri-nix.homeModules.default
      ];

      # Niri configuration via niri-nix home manager module
      wayland.windowManager.niri = {
        enable = true;

        settings = let
          bindImport = import ./niri/binds.nix attrs;
        in {
          prefer-no-csd = true;
          hotkey-overlay.skip-at-startup = true;

          # Xwayland configuration
          xwayland-satellite = {
            enable = true;
          };

          # Input settings
          input =
            {
              keyboard.repeat-delay = 300;
              mouse.accel-profile = "adaptive";
              warp-mouse-to-focus.enable = true;

              focus-follows-mouse = {
                enable = true;
                max-scroll-amount = "5%";
              };
            }
            // (hostVars.niri.input or {});

          # Gestures configuration
          gestures.hot-corners.enable = false;

          # Clipboard settings
          clipboard.disable-primary = true;

          # Monitor outputs directly from hostVars
          output = builtins.attrValues hostVars.outputs;

          # Workspaces directly from hostVars
          workspace = builtins.attrValues hostVars.workspaces;

          # Animation settings
          animations = {
            enable = true;

            config-notification-open-close.enable = true;
            exit-confirmation-open-close.enable = true;
            horizontal-view-movement.enable = true;
            overview-open-close.enable = true;
            window-close.enable = true;
            window-movement.enable = true;
            window-open.enable = true;
            window-resize.enable = true;
            workspace-switch.enable = false;
          };

          # Spawn at startup
          spawn-at-startup = userVars.niri.spawn-at-startup;

          # Alt-Tab recent windows customization (v25.11+)
          recent-windows = {
            open-delay-ms = 0;
            debounce-delay-ms = 100;
            preview-size._props = {natural = 256;};
            gap._props = {natural = 16;};
          };

          # Overview configuration (reduced zoom to fit more workspaces)
          overview = {
            zoom = 0.5;
            prefer-centered-preview = true;
          };

          # Layout configuration
          layout = {
            gaps = 0;
            background-color = "transparent";
            center-focused-column = "on-overflow";
            always-center-single-column = true;
            empty-workspace-above-first = false;

            default-column-width = {};

            preset-column-widths._children = [
              {proportion = 0.25;}
              {proportion = 1.0 / 3.0;}
              {proportion = 0.5;}
              {proportion = 2.0 / 3.0;}
              {proportion = 0.75;}
            ];

            border.on = false;
            border.width = 2;

            shadow = {
              on = true;
              draw-behind-window = true;
              softness = 20;
              spread = 5;
              offset._props = {
                x = 5;
                y = 5;
              };
              color = "#000000aa";
            };

            struts._props = {
              top = 0;
              left = 0;
              right = 0;
              bottom = 0;
            };

            focus-ring.on = false;
            tab-indicator.position = "top";
          };

          # Keyboard bindings
          binds = bindImport;

          # Window-specific rules
          window-rule =
            [
              # Terminal background blur
              {
                match._props.app-id._raw = ''r#"(?i)${userVars.programs.terminal}"#'';
                background-effect = {
                  blur = true;
                };
              }
              # Terminal open maximized
              {
                match._props.app-id._raw = ''r#"(?i)${userVars.programs.terminal}"#'';
                open-maximized = true;
              }
            ]
            ++ userVars.niri.window-rules;

          # Layer-shell rules (v25.01+)
          layer-rule = [
            {
              match._props = {
                namespace = "^notifications$";
              };
              block-out-from = "screen-capture";
            }
            {
              match._props = {
                namespace._raw = ''r#"^(gcr-prompter)"#'';
              };
              block-out-from = "screen-capture";
            }
            {
              match._props = {
                namespace._raw = ''r#"^(notifications|launcher|menu|${userVars.programs.launcher}|${userVars.programs.desktop-shell}.*)"#'';
                layer = "top";
              };
              background-effect = {
                blur = true;
                brightness = 0.9;
                saturation = 1.1;
              };
            }
          ];
        };
      };

      # Environment variables
      home.sessionVariables = {
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_DESKTOP = "niri";
      };

      # Misc files
      home.file.".local/share/misc" = {
        source = ../../${userVars.username}/assets/misc;
      };
    };
  };

  # NixOS-level configuration
  environment.systemPackages = [
    pkgs.niri
    pkgs.jq # Used for some scripts
    pkgs.libnotify # Used for sending notifications to the notif daemon

    pkgsUnstable.nirius # niri utilities - currently on unstable 0.8.0 but normal packages only 0.7.1 as of 08/08/2026
  ];

  programs = {
    dconf.enable = true;

    # Niri NixOS module
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

  xdg.portal.configPackages = [pkgs.niri];
}
