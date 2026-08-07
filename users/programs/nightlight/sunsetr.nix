{
  hostVars,
  lib,
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {lib, ...}: {
    home.packages = with pkgs; [
      sunsetr
    ];

    home.activation.setSunsetrCoordinates = lib.hm.dag.entryAfter ["writeBoundary"] ''
      sed -i 's/^latitude.*/latitude=${toString hostVars.latitude}/' "$HOME/.config/sunsetr/sunsetr.toml"
      sed -i 's/^longitude.*/longitude=${toString hostVars.longitude}/' "$HOME/.config/sunsetr/sunsetr.toml"
    '';
  };
}
