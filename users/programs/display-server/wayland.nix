{
  hostVars,
  pkgs,
  pkgsUnstable,
  userVars,
  ...
}:

{
  home-manager.users.${userVars.username} = {
    home = {
      # Set Wayland-friendly environment variables
      sessionVariables = {
        APP2UNIT_SLICES = "a=app-graphical.slice b=background-graphical.slice s=session-graphical.slice"; # https://github.com/Vladimir-csp/app2unit?tab=readme-ov-file#uwsm-integration
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

  # Enable fundamental Wayland utilities and portals
  environment.systemPackages = with pkgs; [
    # Core wayland utils
    wl-clipboard # CLI utilities for interacting with the Wayland clipboard

    # X11 compatability for Wayland
    xwayland-satellite

    # Misc
    pkgsUnstable.app2unit
  ];

  # Enable XWayland support system-wide
  programs.xwayland.enable = true;

  # Enable systemd user session support
  services.dbus.enable = true;

  # Session management
  services.gnome.gnome-keyring.enable = true;

  services.xserver = {
    enable = false;
    exportConfiguration = false; # Would make /etc/X11/xkb populated so tools like localectl work
    xkb = {
      layout = "${hostVars.keyboardLayout}";
      variant = "${hostVars.kbdVariant}";
    };
  };
}
