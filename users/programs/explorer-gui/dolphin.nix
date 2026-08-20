{
  pkgs,
  userVars,
  ...
}: {
  /*
  nixpkgs.overlays = [
    inputs.dolphin-overlay.overlays.default # Not working - TODO: Fix myself later!?
  ]; # Add https://github.com/MattiDragon/dolphin-overlay
  */

  environment.etc."xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu"; # TODO: REMOVE AFTER https://github.com/NixOS/nixpkgs/issues/409986 IS SOLVED

  home-manager.users.${userVars.username} = {
    config,
    lib,
    ...
  }: {
    home = {
      # KDE service cache refresh.
      # This fixes missing/incorrect desktop integration after rebuilds
      # (for example default app handlers in Dolphin).
      activation.refreshKDECache = lib.hm.dag.entryAfter ["writeBoundary"] ''
        KBUILD="${pkgs.kdePackages.kservice}/bin/kbuildsycoca6"
        if [ -x "$KBUILD" ]; then
          "$KBUILD" >/tmp/kbuildsycoca6.log 2>&1 || true
        fi
      '';

      packages = with pkgs; [
        kdePackages.dolphin
        kdePackages.dolphin-plugins

        kdePackages.breeze-icons # For sidebar icons iirc

        kdePackages.qtsvg # Support for svg icons
        kdePackages.kio # Below ig, custom though
        kdePackages.kio-admin # Another custom
        kdePackages.kio-fuse # To mount remote filesystems via FUSE
        kdePackages.kio-extras # Extra protocols support (sftp, fish and more)

        # File previews - https://wiki.archlinux.org/title/Dolphin#File_previews
        libappimage
        libheif
        icoutils
        kdePackages.ark # File extraction
        kdePackages.ffmpegthumbs
        kdePackages.kactivitymanagerd
        kdePackages.kdegraphics-thumbnailers
        kdePackages.kimageformats
        kdePackages.kdesdk-thumbnailers
        kdePackages.kservice # For kbuildsycoca6
        kdePackages.qtimageformats
        kdePackages.qttools # qdbus etc
        nufraw-thumbnailer # Own choice
        resvg
        taglib_1

        unzip
      ];

      activation.setupDolphinrc = lib.hm.dag.entryAfter ["writeBoundary"] ''
        TARGET_FILE="${config.xdg.configHome}/dolphinrc"
        mkdir -p "$(dirname "$TARGET_FILE")"
        cat << 'EOF' > "$TARGET_FILE"
        [MainWindow]
        MenuBar=Disabled

        [General]
        ShowFullPathInTitlebar=true

        [KFileDialog Settings]
        Places Icons Auto-resize=true
        Places Icons Static Size=0

        [PreviewSettings]
        EnableRemoteFolderThumbnail=true
        MaximumRemoteSize=104857600
        Plugins=imagethumbnail,jpegthumbnail,directorythumbnail,ffmpegthumbs,exethumbnail,comicbookthumbnail,officeMarcothumbnail
        RemotePlugins=imagethumbnail,jpegthumbnail,directorythumbnail,ffmpegthumbs,exethumbnail,comicbookthumbnail,officeMarcothumbnail
        RemotePreviewSizeLimit=104857600
        UseDefaultRemotePreviewSizeLimit=false
        EOF
      '';
    };

    xdg.mimeApps.defaultApplications = {
      "inode/directory" = ["dolphin.desktop"];
      "application/zip" = ["org.kde.ark.desktop"];
      "application/x-7z-compressed" = ["org.kde.ark.desktop"];
      "application/x-bzip-compressed-tar" = ["org.kde.ark.desktop"];
      "application/x-compressed-tar" = ["org.kde.ark.desktop"];
      "application/x-rar" = ["org.kde.ark.desktop"];
      "application/x-tar" = ["org.kde.ark.desktop"];
      # "application/x-gnome-saved-search" = [ "dolphin.desktop" ];
    };
  };
}
