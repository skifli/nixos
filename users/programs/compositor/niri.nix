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
  windowRules = import ./niri/window-rules.nix attrs;
  layerRules = import ./niri/layer-rules.nix attrs;

  outputs = map (name: {
    _args = [name];
    inherit (hostVars.outputs.${name}) mode;
    position._props = hostVars.outputs.${name}.position;
  }) (builtins.attrNames hostVars.outputs);

  workspaces = map (name: {
    _args = [name];
    inherit (hostVars.workspaces.${name}) open-on-output;
  }) (builtins.attrNames hostVars.workspaces);
in {
  imports = [
    inputs.niri-nix.nixosModules.default
  ];

  home-manager = {
    users.${userVars.username} = {
      imports = [
        inputs.niri-nix.homeModules.default
        inputs.niri-nix.homeModules.stylix
      ];

      wayland.windowManager.niri = {
        enable = true;

        systemd.variables = [
          "--all"
        ];

        settings = {
          prefer-no-csd = [];
          hotkey-overlay.skip-at-startup = [];

          xwayland-satellite = [];

          gestures.hot-corners.off = [];
          clipboard.disable-primary = [];

          inherit input layout binds;

          # Top-level node lists
          output = outputs;
          workspace = workspaces;
          window-rule = windowRules;
          layer-rule = layerRules;

          # Animation settings (empty list [] = parameterless KDL flag/node)
          animations = {
            config-notification-open-close = [];
            exit-confirmation-open-close = [];
            horizontal-view-movement = [];
            overview-open-close = [];
            window-close = [];
            window-movement = [];
            window-open = [];
            window-resize = [];
            workspace-switch.off = [];
          };

          # Alt-Tab recent-windows configuration
          recent-windows = {
            open-delay-ms = 0;
            debounce-delay-ms = 100;
            preview-size._props.natural = 256;
            gap._props.natural = 16;
          };

          spawn-sh-at-startup = userVars.niri.spawn-sh-at-startup;

          # Overview configuration
          overview = {
            zoom = 0.5;
            prefer-centered-preview = [];
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
    pkgs.libnotify # Used for sending notifications to the notification daemon

    pkgsUnstable.nirius # niri utilities - currently on unstable 0.8.0 but normal packages only 0.7.1 as of 08/08/2026
  ];

  programs = {
    dconf.enable = true;

    # Niri NixOS module
    niri = {
      enable = true;

      useNautilus = false; # https://codeberg.org/bananad3v/niri-nix/src/branch/main/nixos-options.md#programs-niri-usenautilus

      # Below is managed below manually
      withUWSM = false; # https://codeberg.org/bananad3v/niri-nix/src/branch/main/nixos-options.md#programs-niri-withuwsm

      # Below is managed manually elsewhere and has custom portal setup + below last line for configPackages
      withXDG = false; # https://codeberg.org/bananad3v/niri-nix/src/branch/main/nixos-options.md#programs-niri-withxdg
    };

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
