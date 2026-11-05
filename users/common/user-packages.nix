{
  inputs,
  lib,
  pkgs,
  userVars,
  ...
}:
{
  home-manager.users.${userVars.username} = {
    home.packages =
      with pkgs;
      [
        anytype
        cachix # Command-line client for Nix binary cache hosting https://cachix.org
        cameractrls
        cameractrls-gtk4
        doxx
        evince # Document viewer

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

        # Ferdium's Linux tray advertises `ferdium-tray-${this.iconRevision}` and
        # points IconThemePath at a temp dir. Wayle ignores IconThemePath and the
        # revision is unbounded, so no theme icon can match and the tray falls
        # back to the "missing icon" placeholder. Rename the tray icon to the
        # static `ferdium` name that the package already installs into hicolor.
        # The replacement keeps the exact original byte length so the asar
        # archive's file offsets stay valid.
        (ferdium.overrideAttrs (oldAttrs: {
          postFixup = (oldAttrs.postFixup or "") + ''
            asar="$out/opt/Ferdium/resources/app.asar"
            chmod +w "$asar"
            perl -0pi -e 's!`ferdium-tray-.{20}`!q{"ferdium"} . (" " x 26)!ge' "$asar"
          '';
          nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.perl ];
        }))

        fira-code
        haruna # Media player
        imagemagick # mogrify EXIF
        grim # Grab images from a Wayland compositor
        hblock
        kdePackages.gwenview # Image viewer
        krename # Powerful renamer
        moreutils # Used in some scripts (e.g., task-receiver.sh)
        mpv
        nix-prefetch
        nix-prefetch-github # REALLY USEFUL - e.g., `nix-prefetch-github skifli awatcher --rev e93f57b818d9c29952940ebb3e6927958a310166`
        normcap
        noto-fonts
        noto-fonts-color-emoji
        ocrmypdf
        poppler-utils
        proton-vpn
        proton-vpn-cli
        swayimg # Used in some scripts (e.g., view-clipboard-image.sh)
        inputs.terminal-wakatime.packages.${pkgs.stdenv.hostPlatform.system}.default
        wl-clipboard # Used in some scripts (e.g., emoji-picker.sh)
        wtype # Added for keystroke / paste simulation
        zstd # Short for Zstandard, this is a fast lossless compression algorithm, targeting real-time compression scenarios at zlib-level compression ratio
      ]
      # OnlyOffice only publishes x86_64 Linux builds in nixpkgs right now, so
      # keep the tablet (aarch64) evaluating by skipping it there until the
      # upstream aarch64 PR lands.
      ++ lib.optional pkgs.stdenv.hostPlatform.isx86_64 pkgs.onlyoffice-desktopeditors;

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
