{
  hostVars,
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      sunsetr
    ];

    home.activation.setSunsetrCoordinates = lib.hm.dag.entryAfter ["writeBoundary"] ''
      sed -i 's/^latitude.*/latitude=${hostVars.latitude}/' "$HOME/.config/sunsetr/sunsetr.toml"
      sed -i 's/^longitude.*/longitude=${hostVars.longitude}/' "$HOME/.config/sunsetr/sunsetr.toml"
    '';
  };
}
