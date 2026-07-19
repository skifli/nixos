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

  xdg.portal.extraPortals = with pkgs; [
    kdePackages.kwallet
  ];

  security.pam.services = {
    ${userVars.programs.login-manager}.kwallet = {
      enable = true;
      package = pkgs.kdePackages.kwallet-pam;
    };
  };

  # Enable systemd user session support
  services = {
    dbus.enable = true;

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
