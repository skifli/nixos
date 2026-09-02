{
  inputs,
  lib,
  userVars,
  ...
}: {
  home-manager.sharedModules = [
    inputs.fyde-nix.homeManagerModules.wayle
    inputs.fyde-nix.homeManagerModules.swayidle
  ];

  home-manager.users.${userVars.username} = {
    services.wayle.settings.wallpaper.engine-enabled = lib.mkForce false;
  };
}
