{
  commonHostVars,
  lib,
  inputs,
  pkgs,
  ...
}:

{
  imports = [ inputs.stylix.nixosModules.stylix ];

  stylix = {
    enable = true;
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.day}.yaml";
    cursor = {
      package = commonHostVars.cursor.package;
      size = commonHostVars.cursor.size;
      name = lib.mkDefault commonHostVars.cursor.day.name;
    };
    icons = commonHostVars.icons;
    fonts = commonHostVars.fonts;
  };

  specialisation = {
    day.configuration =
      {
        pkgs,
        ...
      }:
      {
        stylix = {
          base16Scheme = "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.day}.yaml";
          cursor.name = commonHostVars.cursor.day.name;
        };
      };

    night.configuration =
      {
        pkgs,
        ...
      }:
      {
        stylix = {
          base16Scheme = "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.night}.yaml";
          cursor.name = commonHostVars.cursor.night.name;
        };
      };
  };
}
