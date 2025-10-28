{ userVars, ... }:

{
  home-manager.users.${userVars.username} = {
    services.swaync.enable = true;
  };
}
