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

  outputNodes = map (name: { output."${name}" = hostVars.outputs.${name}; }) (builtins.attrNames hostVars.outputs);
  workspaceNodes = map (name: { workspace."${name}" = hostVars.workspaces.${name}; }) (builtins.attrNames hostVars.workspaces);
  windowRuleNodes = map (rule: { window-rule = rule; }) windowRules;
  layerRuleNodes = map (rule: { layer-rule = rule; }) layerRules;
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
          prefer-no-csd = {};
          hotkey-overlay.skip-at-startup = {};

          xwayland-satellite = {};

          gestures.hot-corners.off = {};
          clipboard.disable-primary = {};

          inherit input layout binds;

          # Animation settings (empty set = enabled feature, .off = disabled)
          animations = {
            config-notification-open-close = {};
            exit-confirmation-open-close = {};
            horizontal-view-movement = {};
            overview-open-close = {};
            window-close = {};
            window-movement = {};
            window-open = {};
            window-resize = {};
            workspace-switch.off = {};
          };

          # Alt-Tab recent-windows configuration (v25.11+)
          recent-windows = {
            open-delay-ms = 0;
            debounce-delay-ms = 100;
            preview-size = { natural = 256; };
            gap = { natural = 16; };
          };

          spawn-sh-at-startup = userVars.niri.spawn-sh-at-startup;

          # Overview configuration
          overview = {
            zoom = 0.5;
            prefer-centered-preview = {};
          };

          # Top-level repeated nodes via _children
          _children =
            outputNodes
            ++ workspaceNodes
            ++ windowRuleNodes
            ++ layerRuleNodes;
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
    niri = {
      enable = true;

      useNautilus = false; # https://codeberg.org/bananad3v/niri-nix/src/branch/main/nixos-options.md#programs-niri-usenautilus
      withUWSM = true; # https://codeberg.org/bananad3v/niri-nix/src/branch/main/nixos-options.md#programs-niri-withuwsm
      withXDG = true; # https://codeberg.org/bananad3v/niri-nix/src/branch/main/nixos-options.md#programs-niri-withxdg
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