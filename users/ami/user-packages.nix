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
      # davinci-resolve # This was removed due to the builders not already having it and rebuilding was taking forever
      doxx
      droidcam
      evince # Document viewer
      fira-code
      grim # Grab images from a Wayland compositor
      haruna # Media player
      hblock
      imagemagick # mogrify EXIF
      javaPackages.compiler.temurin-bin.jdk-25 # For Prism Launcher
      kdePackages.gwenview # Image viewer
      # kdePackages.kate # Also installs kwrite
      kdePackages.qtwayland # Needed by typstwriter
      kicad
      ocrmypdf
      moreutils # Used in some scripts (e.g., task-receiver.sh)
      nix-prefetch
      nix-prefetch-github # REALLY USEFUL - e.g., `nix-prefetch-github skifli awatcher --rev e93f57b818d9c29952940ebb3e6927958a310166`
      normcap
      noto-fonts
      noto-fonts-color-emoji
      prismlauncher
      proton-vpn
      qtscrcpy
      scrcpy
      soundwireserver
      # siyuan
      swayimg # Used in some scripts (e.g., view-clipboard-image.sh)
      termdown
      zstd # Short for Zstandard, this is a fast lossless compression algorithm, targeting real-time compression scenarios at zlib-level compression ratio

      mpv

      /*
         Not needed anymore?
      (pkgs.ferdium.overrideAttrs (oldAttrs: {
        postFixup = (oldAttrs.postFixup or "") + ''
          wrapProgram $out/bin/ferdium \
            --add-flags "--ozone-platform=wayland" \
            --add-flags "--enable-features=WaylandWindowDecorations,UseOzonePlatform,WebRTCPipeWireCapturer"
        '';
      }))
      */
      ferdium
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
