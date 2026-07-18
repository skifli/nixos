{
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      anytype
      cameractrls
      cameractrls-gtk4
      # davinci-resolve # This was removed due to the builders not already having it and rebuilding was taking forever
      doxx
      droidcam
      evince # Document viewer
      ferdium
      fira-code
      haruna # Media player
      hblock
      imagemagick # mogrify EXIF
      kdePackages.gwenview # Image viewer
      # kdePackages.kate # Also installs kwrite
      kdePackages.qtwayland # Needed by typstwriter
      kicad
      ocrmypdf
      normcap
      noto-fonts
      noto-fonts-color-emoji
      prismlauncher
      javaPackages.compiler.temurin-bin.jdk-25 # For Prism Launcher
      proton-vpn
      qtscrcpy
      remmina
      scrcpy
      soundwireserver
      # siyuan

      mpv
    ];

    xdg.mimeApps.defaultApplications = {
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

  # `programs.adb` is deprecated in newer NixOS (systemd 258+ handles uaccess)
  # Install `adb` via `pkgs.android-tools` at the system level instead.
}
