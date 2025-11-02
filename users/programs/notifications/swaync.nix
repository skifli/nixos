{ userVars, ... }:

{
  home-manager.users.${userVars.username} = {
    services.swaync = {
      enable = true;

      settings = {
        fit-to-screen = false;

        control-center-height = -1;
        control-center-width = 500;
      };
    };
  };
}
