{
  hostVars,
  inputs,
  pkgs,
  pkgsUnstable,
  userVars,
  ...
} @ attrs: let
  binds = import ./niri/binds.nix attrs;
  input = import ./niri/input.nix attrs;
  layout = import ./niri/layout.nix attrs;
  window-rule = import ./niri/window-rules.nix attrs;
  layer-rule = import ./niri/layer-rules.nix attrs;
in {
  home-manager = {
    users.${userVars.username} = {
      imports = [
        inputs.niri-nix.homeModules.default
      ];

      wayland.windowManager.niri = {
        enable = true;

        systemd.variables = [
          "--all"
        ];

        settings = {
          prefer-no-csd = true;
          hotkey-overlay.skip-at-startup = true;

          xwayland-satellite.enable = true;

          inherit input layout binds window-rule layer-rule;

          gestures.hot-corners.enable = false;
          clipboard.disable-primary = true;

          # Monitor outputs and workspaces directly from hostVars
          output = builtins.attrValues hostVars.outputs;
          workspace = builtins.attrValues hostVars.workspaces;

          # Spawn startup commands from userVars
          spawn-at-startup = userVars.niri.spawn-at-startup;

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

          # Alt-Tab recent-windows configuration (v25.11+)
          recent-windows = {
            open-delay-ms = 0;
            debounce-delay-ms = 100;
            preview-size._props = {natural = 256;};
            gap._props = {natural = 16;};
          };

          # Overview configuration (axlefublr style zoom scale)
          overview = {
            zoom = 0.5;
            prefer-centered-preview = true;
          };
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
