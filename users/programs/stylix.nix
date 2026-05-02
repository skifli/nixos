{
  commonHostVars,
  hostVars,
  inputs,
  lib,
  pkgs,
  userVars,
  ...
}:

{
  home-manager.users.${userVars.username} = {
    # Runtime color switching with vogix for instant day/night transitions
    services.vogix = {
      enable = true;
      settings = {
        lat = hostVars.latitude;
        lng = hostVars.longitude;
        autoSwitchTime = true; # Auto-detect based on location
      };
    };

    # Theme cursor, fonts, and icons directly without stylix module
    home.pointerCursor = {
      package = commonHostVars.cursor.package;
      size = commonHostVars.cursor.size;
      name = commonHostVars.cursor.day.name;
      x11.enable = true;
      gtk.enable = true;
    };

    gtk = {
      enable = true;

      font = {
        package = commonHostVars.fonts.sansSerif.package;
        name = commonHostVars.fonts.sansSerif.name;
        size = commonHostVars.fonts.sizes.applications;
      };

      iconTheme = {
        package = commonHostVars.icons.package;
        name = commonHostVars.icons.light;
      };
    };

    qt = {
      enable = true;

      platformTheme.name = "gtk3";
      style = {
        package = commonHostVars.icons.package;
        name = "gtk2";
      };
    };
  };

  home-manager.sharedModules = [
    inputs.vogix.homeModules.default
  ];
}
