{
  hostVars,
  pkgs,
  userVars,
  ...
}:

{
  home-manager.users.${userVars.username} = {
    home = {
      # Enable fundamental Wayland utilities and portals
      packages = with pkgs; [
        # Core wayland utils
        wl-clipboard # CLI utilities for interacting with the Wayland clipboard
        wlogout # Customisable GUI logout menu
      ];

      # Set Wayland-friendly environment variables
      sessionVariables = {
        CLUTTER_BACKEND = "wayland";
        EGL_PLATFORM = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        GDK_BACKEND = "wayland";
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
        OZONE_PLATFORM = "wayland";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        QT_WAYLAND_SHELL_INTEGRATION = "xdg-shell";
        SDL_VIDEODRIVER = "wayland";
        XDG_SESSION_TYPE = "wayland";
      };
    };
  };

  # Enable XWayland support system-wide
  programs.xwayland.enable = true;

  # Enable systemd user session support
  services.dbus.enable = true;

  # Session management
  services.gnome.gnome-keyring.enable = true;

  services.xserver = {
    enable = true;
    exportConfiguration = false; # Would make /etc/X11/xkb populated so tools like localectl work
    xkb = {
      layout = "${hostVars.keyboardLayout}";
      variant = "${hostVars.kbdVariant}";
    };
  };

  # Set up XDG environment and portal services for Wayland apps
  xdg.portal = {
    enable = true;
    wlr.enable = true; # Automatically adds xdg-desktop-portal-wlr into extraPortals
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config = {
      common.default = [
        "wlr"
        "gtk"
      ]; # Define portal priority
    };
  };
}
