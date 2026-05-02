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
    programs.vogix = {
      enable = true;
      scheme = "vogix16";
      theme = "retro";
      variant = "light";
    };

    stylix = {
      enable = true;
      autoEnable = false;

      cursor = {
        package = commonHostVars.cursor.package;
        size = commonHostVars.cursor.size;
        name = commonHostVars.cursor.day.name;
      };
      icons = commonHostVars.icons;
      fonts = commonHostVars.fonts;
    };

    gtk = {
      enable = true;

      iconTheme = {
        package = commonHostVars.icons.package;
        name = commonHostVars.icons.light;
      };
    };
  };

  home-manager.sharedModules = [
    inputs.vogix.homeManagerModules.default
    inputs.stylix.homeModules.stylix
  ];
}
