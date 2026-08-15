{
  hostVars,
  lib,
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {lib, ...}: {
    home = {
      packages = with pkgs; [
        ov
      ];

      sessionVariables = {
        PAGER = "ov";
      };

      shellAliases = {
        ov = "ov -X --QuitSmall";
      };
    };

    xdg.configFile."ov/config.yaml".text = ''
      QuitSmall: true
      IsWriteOriginal: true
      TabWidth: 4
    '';
  };
}
