{
  hostVars,
  pkgs,
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
    seahorse # Managing gnome keyring secrets
    libsecret # For testing & needed for polling gcr-prompter in startupScript
    kdePackages.polkit-kde-agent-1 # Polkit stuff
  ];

  # Enable XWayland support system-wide
  programs.xwayland.enable = true;

  systemd = {
    # Try fix some gnome-keyring oddities
    services."autovt@tty1".enable = false;
    services."getty@tty1".enable = false;

    # Start the agent as a graphical user service
    user.services.polkit-kde-agent-1 = {
      description = "polkit-kde-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # Enable systemd user session support
  services = {
    dbus.enable = true;

    # Session management
    gnome.gnome-keyring.enable = pkgs.lib.mkForce true;

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
