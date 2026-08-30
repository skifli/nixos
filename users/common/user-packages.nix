{
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      anytype
      cachix # Command-line client for Nix binary cache hosting https://cachix.org
      cameractrls
      cameractrls-gtk4
      doxx
      evince # Document viewer
      ferdium
      fira-code
      haruna # Media player
      imagemagick # mogrify EXIF
      grim # Grab images from a Wayland compositor
      hblock
      kdePackages.gwenview # Image viewer
      moreutils # Used in some scripts (e.g., task-receiver.sh)
      mpv
      nix-prefetch
      nix-prefetch-github # REALLY USEFUL - e.g., `nix-prefetch-github skifli awatcher --rev e93f57b818d9c29952940ebb3e6927958a310166`
      normcap
      noto-fonts
      noto-fonts-color-emoji
      ocrmypdf
      proton-vpn
      proton-vpn-cli
      swayimg # Used in some scripts (e.g., view-clipboard-image.sh)
      wl-clipboard # Used in some scripts (e.g., emoji-picker.sh)
      wtype # Added for keystroke / paste simulation
      zstd # Short for Zstandard, this is a fast lossless compression algorithm, targeting real-time compression scenarios at zlib-level compression ratio
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
