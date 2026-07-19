{
  hostVars,
  pkgs,
  pkgsUnstable,
  userVars,
  ...
}: {
  # Set Wayland-friendly environment variables
  environment.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NIXOS_OZONE_WL = "1";
    # QT_QPA_PLATFORM = "wayland"; # Not needed - https://discourse.nixos.org/t/davinci-resolve-only-launches-as-root/54258/6
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_WAYLAND_SHELL_INTEGRATION = "xdg-shell";
    SDL_VIDEODRIVER = "wayland";
  };

  # Enable fundamental Wayland utilities and portals
  environment.systemPackages = with pkgs; [
    # Core wayland utils
    wl-clipboard # CLI utilities for interacting with the Wayland clipboard

    # X11 compatability for Wayland
    xwayland-satellite

    slurp # https://wiki.archlinux.org/title/XDG_Desktop_Portal#Using_multiple_monitors_with_xdg-desktop-portal-wlr

    kdePackages.kwallet # Provides helper service
    kdePackages.kwallet-pam # PRovides helper service
    kdePackages.kwalletmanager # Provids KCMs and stuff
  ];

  # Enable XWayland support system-wide
  programs.xwayland.enable = true;

  xdg.portal = {
    extraPortals = with pkgs; [
      kdePackages.kwallet
    ];

    /*
    error: The option `xdg.portal.config.niri."org.freedesktop.impl.portal.Secret"' has conflicting definition values:
       - In `/nix/store/kwvm7rkxjxkyvcyky1jsmlihwydb637w-source/hosts/common/default.nix': "kwallet"
       - In `/nix/store/7blcfay1hap81n2bc9j4d8b1cxrvng50-source/nixos/modules/programs/wayland/niri.nix': "gnome-keyring"
       Use `lib.mkForce value` or `lib.mkDefault value` to change the priority on any of these definitions.
    */
    config.${userVars.programs.compositor}."org.freedesktop.impl.portal.Secret" = pkgs.lib.mkForce "kwallet";
  };

  security.pam.services = {
    # If enabled, pam_wallet will attempt to automatically unlock the user’s default KDE wallet upon login.
    # If the user has no wallet named “kdewallet”, or the login password does not match their wallet password,
    # KDE will prompt separately after login.
    ${userVars.programs.login-manager}.kwallet = {
      enable = true;
      forceRun = true;
      package = pkgs.kdePackages.kwallet-pam;
    };
  };

  systemd.user.services.pam-kwallet-init = {
    description = "Unlock kwallet from pam credentials";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init";
      Slice = "background.slice";
      Restart = "no";
    };
  };

  # Enable systemd user session support
  services = {
    dbus = {
      enable = true;
      packages = with pkgs; [
        kdePackages.kwallet
      ];
    };

    # Session management
    gnome.gnome-keyring.enable = false;

    xserver = {
      enable = false;
      exportConfiguration = false; # Would make /etc/X11/xkb populated so tools like localectl work

      xkb = {
        layout = "${hostVars.keyboardLayout}";
        variant = "${hostVars.kbdVariant}";
      };
    };
  };
}
