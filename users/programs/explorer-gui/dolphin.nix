{ pkgs, userVars, ... }:

{
  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu"; # TODO: 3REMOVE AFTER https://github.com/NixOS/nixpkgs/issues/409986 IS SOLVED

  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      kdePackages.dolphin
      kdePackages.dolphin-plugins

      kdePackages.qtsvg # Support for svg icons
      kdePackages.kio # Below ig, custom though
      kdePackages.kio-admin # Another custom
      kdePackages.kio-fuse # To mount remote filesystems via FUSE
      kdePackages.kio-extras # Extra protocols support (sftp, fish and more)

      # File previes - https://wiki.archlinux.org/title/Dolphin#File_previews
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

    xdg.mimeApps.defaultApplications = {
      "inode/directory" = [ "dolphin.desktop" ];
      # "application/x-gnome-saved-search" = [ "dolphin.desktop" ];
    };

    xdg.configFile."kdeglobals".text = ''
[KFileDialog Settings]
Allow Expansion=false
Automatically select filename extension=true
Breadcrumb Navigation=true
Decoration position=2
Show Full Path=false
Show Inline Previews=true
Show Preview=false
Show Speedbar=true
Show hidden files=true
Sort by=Name
Sort directories first=true
Sort hidden files last=false
Sort reversed=false
Speedbar Width=156
View Style=DetailTree

[PreviewSettings]
EnableRemoteFolderThumbnail=false
MaximumRemoteSize=0

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
