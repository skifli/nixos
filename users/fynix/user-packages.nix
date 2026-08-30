{
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      anytype
      evince
      ferdium
      grim
      hblock
      wl-clipboard

      mpv
    ];

    xdg = {
      mimeApps.defaultApplications = {
        "application/pdf" = "org.gnome.Evince.desktop";
        "image/bmp" = "org.kde.gwenview.desktop";
        "image/gif" = "org.kde.gwenview.desktop";
        "image/jpeg" = "org.kde.gwenview.desktop";
        "image/png" = "org.kde.gwenview.desktop";
        "image/svg+xml" = "org.kde.gwenview.desktop";
        "image/tiff" = "org.kde.gwenview.desktop";
        "image/webp" = "org.kde.gwenview.desktop";
        "image/x-portable-bitmap" = "org.kde.gwenview.desktop";
        "image/x-portable-graymap" = "org.kde.gwenview.desktop";
        "image/x-portable-pixmap" = "org.kde.gwenview.desktop";
        "image/x-xbitmap" = "org.kde.gwenview.desktop";
      };
    };
  };
}
