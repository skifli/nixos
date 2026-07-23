({pkgs, ...}: {
  nixpkgs.overlays = [
    (final: prev: {
      inherit
        (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];

  # Use lib.mkForce to prevent infinite recursion / option conflicts
  nix.package = pkgs.lib.mkForce pkgs.lixPackageSets.stable.lix;
})
