{ config, lib, ... }:

let
  cacheUrls = [
    "https://nixos-cache.warp-racing.com/c/admin/skifli-nixos"
    "https://sernix-cache.warp-racing.com/c/admin/skifli-sernix"
    "https://oracle-cache.warp-racing.com/c/admin/encore-sr-oracle-vps"
    "https://cachix.cachix.org"
    "https://nix-community.cachix.org/"
    "https://vicinae.cachix.org/"
    "https://nixpkgs-python.cachix.org"
    "https://cache.forall.systems"
    "https://nyx-cache.chaotic.cx/"
    "https://niri-nix.cachix.org"
    "https://fyde-nix.cachix.org"
  ];
in
{
  nix.settings = {
    extra-substituters = cacheUrls;
    extra-trusted-public-keys = [
      "skifli-nixos:xNH7IYz/XkeFkPVzag7TGFw2wY1pW8EVmnoLy194Htg="
      "skifli-sernix:sYPdAV6YDGzFKZnHJ3v7ifcjwlOegpM533z+UwBSR7g="
      "encore-sr-oracle-vps:ssTArP9V3BjHYh99ZrKgddRAxYf27LCh4+A7PnDn4aw="
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
      "cache.forall.systems:5PmD7QO4MSF8YgyRZtkSGXRDo96H3bybIf2SsQh8ScI="
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
      "niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="
      "fyde-nix.cachix.org-1:rlgYccagNG7hZhxBe7mzebJ9AlHzfqPZTmeyR1VuQoA="
    ];
  };

  # The cross-project caches are private. Only hosts that have this secret
  # receive its path in nix.conf; the Nix daemon reads the netrc as root.
  nix.settings.netrc-file = lib.mkIf (builtins.elem config.networking.hostName [
    "lyra"
    "fydetabduo"
  ]) config.age.secrets.xilo-cache-netrc.path;
}
