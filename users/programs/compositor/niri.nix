{
  hostVars,
  inputs,
  lib,
  pkgs,
  pkgsUnstable,
  userVars,
  ...
}@attrs:
let
  default = import ./niri/default.nix attrs;
  safeeyesApp = lib.findFirst (app: app ? breakWindowTitlePrefix) {
    appId = "";
    breakWindowTitlePrefix = "";
  } (userVars.protectedCloseApps or [ ]);
  inherit (pkgsUnstable) nirius;
  safeeyesFocusGuard = pkgs.writeShellScript "safeeyes-focus-guard" ''
    exec ${pkgs.python3}/bin/python3 ${./niri/safeeyes-focus-guard.py} \
      ${lib.escapeShellArg safeeyesApp.appId} \
      ${lib.escapeShellArg safeeyesApp.breakWindowTitlePrefix} \
      ${pkgs.niri}/bin/niri \
      ${lib.escapeShellArg (builtins.toJSON hostVars.orderedOutputs)}
  '';
in
{
  imports = [
    inputs.niri-nix.nixosModules.default
  ];

  # Home-manager level configuration
  home-manager = {
    users.${userVars.username} = {
      imports = [
        inputs.niri-nix.homeModules.default
      ];

      # Import the default configuration from the sub-folder
      wayland.windowManager.niri = default;

      # Environment variables
      home.sessionVariables = {
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_DESKTOP = "niri";
      };

      systemd.user.services.niriusd = {
        Unit = {
          Description = "nirius daemon";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${nirius}/bin/niriusd";
          Restart = "on-failure";
          RestartSec = "2s";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      systemd.user.services.safeeyes-focus-guard = lib.mkIf (safeeyesApp.appId != "") {
        Unit = {
          Description = "Keep SafeEyes breaks focused on their own output";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = safeeyesFocusGuard;
          Restart = "always";
          RestartSec = "2s";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  /*
    # Used to be in home above only, here as well just in case.
    # Edit: removed because actually uwsm should handle these
    # and otherwise these are set e.g., even when in a TTY which
    # is not what we want.

    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_DESKTOP = "niri";
    };
  */

  # NixOS-level configuration
  environment.systemPackages = [
    pkgs.niri
    pkgs.bc # Used for some scripts
    pkgs.jq # Used for some scripts
    pkgs.libnotify # Used for sending notifications to the notification daemon

    nirius # Nirius utilities and daemon
  ];

  programs = {
    dconf.enable = true; # Niri nixOS module enables this by default but anyway

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
          binPath = "${pkgs.niri}/bin/niri-session";
        };
      };
    };
  };

  xdg.portal.configPackages = [ pkgs.niri ];
}
