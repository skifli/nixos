{
  inputs,
  pkgs,
  userVars,
  ...
}: {
  nixpkgs.overlays = [
    inputs.affinity-nix.overlays.default
  ];

  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      affinity-v3
    ];
  };
}
