{ pkgs, userVars, ... }:

{
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      nemo-with-extensions
    ];

    xdg.desktopEntries.nemo = {
      name = "Nemo";
      exec = "${pkgs.nemo-with-extensions}/bin/nemo";
    };

    xdg.mimeApps.defaultApplications = {
      "inode/directory" = [ "nemo.desktop" ];
      "application/x-gnome-saved-search" = [ "nemo.desktop" ];
    };
  };
}
