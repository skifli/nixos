{
  inputs,
  pkgs,
  pkgsUnstable,
  userVars,
  ...
} @ attrs: let
  default = import ./niri/default.nix attrs;
in {
  imports = [
    inputs.niri-nix.nixosModules.default
  ];

  # Home-manager level configuration
  home-manager = {
    users.${userVars.username} = {
      imports = [
        inputs.niri-nix.homeModules.default
        inputs.niri-nix.homeModules.stylix
      ];

      # Import the default configuration from the sub-folder
      wayland.windowManager.niri = default;

      # Environment variables
      home.sessionVariables = {
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_DESKTOP = "niri";
      };
    };
  };

  # Used to be in home above only, here as well just in case
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
  };

  # NixOS-level configuration
  environment.systemPackages = [
    pkgs.niri
    pkgs.jq # Used for some scripts
    pkgs.libnotify # Used for sending notifications to the notification daemon

    pkgsUnstable.nirius # niri utilities - currently on unstable 0.8.0 but normal packages only 0.7.1 as of 08/08/2026
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

  xdg.portal.configPackages = [pkgs.niri];
}
