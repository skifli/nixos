{
  inputs,
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
      packages = with pkgs; [
        kdePackages.dolphin
        kdePackages.dolphin-plugins

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
        nufraw-thumbnailer # Own choice
        resvg
        taglib_1

        unzip
      ];

      activation.setupDolphinrc = lib.hm.dag.entryAfter ["writeBoundary"] ''
                TARGET_FILE="${config.xdg.configHome}/dolphinrc"

                if [ ! -f "$TARGET_FILE" ]; then
                  mkdir -p "$(dirname "$TARGET_FILE")"
                  cat << 'EOF' > "$TARGET_FILE"
        MenuBar=Disabled

        [General]
        ShowFullPathInTitlebar=true
        Version=202
        ViewPropsTimestamp=2026,7,9,16,52,45.737

        [KFileDialog Settings]
        Places Icons Auto-resize=true
        Places Icons Static Size=0

        [MainWindow]
        MenuBar=Disabled

        [PreviewSettings]
        EnableRemoteFolderThumbnail=true
        MaximumRemoteSize=104857600
        Plugins=imagethumbnail,jpegthumbnail,directorythumbnail,ffmpegthumbs,exethumbnail,comicbookthumbnail,officeMarcothumbnail
        RemotePlugins=imagethumbnail,jpegthumbnail,directorythumbnail,ffmpegthumbs,exethumbnail,comicbookthumbnail,officeMarcothumbnail
        RemotePreviewSizeLimit=104857600
        UseDefaultRemotePreviewSizeLimit=false
        EOF
                fi
      '';
    };

    xdg.mimeApps.defaultApplications = {
      "inode/directory" = ["dolphin.desktop"];
      # "application/x-gnome-saved-search" = [ "dolphin.desktop" ];
    };

    xdg.configFile."kdeglobals".text = ''
      [KFileDialog Settings]
      Allow Expansion=true
      Automatically select filename extension=true
      Breadcrumb Navigation=true
      Decoration position=2
      Show Full Path=true
      Show Inline Previews=true
      Show Preview=true
      Show Speedbar=true
      Show hidden files=true
      Sort by=Name
      Sort directories first=true
      Sort hidden files last=false
      Sort reversed=false
      Speedbar Width=156
      View Style=DetailTree

      [PreviewSettings]
      EnableRemoteFolderThumbnail=true
      MaximumRemoteSize=104857600

      [General]
      TerminalApplication=${userVars.programs.terminal}
      TerminalService=${
        if userVars.programs.terminal == "ghostty"
        then "com.mitchellh.ghostty"
        else userVars.programs.terminal
      }.desktop
    '';
  };
}
