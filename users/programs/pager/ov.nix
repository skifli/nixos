{
  pkgs,
  userVars,
  ...
}:
{
  home-manager.users.${userVars.username} = _: {
    home = {
      packages = with pkgs; [
        ov
      ];

      sessionVariables = {
        PAGER = "ov";
      };

      shellAliases = {
        ov = "ov -X --quit-if-one-screen";
      };
    };

    xdg.configFile."ov/config.yaml".text = ''
      QuitSmall: true
      IsWriteOriginal: true
      TabWidth: 4
    '';
  };
}
