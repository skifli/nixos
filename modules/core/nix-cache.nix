{ config, lib, ... }:

let
  cacheUrls = [
    "https://nixos-cache.warp-racing.com/c/admin/skifli-nixos"
    "https://sernix-cache.warp-racing.com/c/admin/skifli-sernix"
    "https://oracle-cache.warp-racing.com/c/admin/encore-sr-oracle-vps"
  ];
in
{
  nix.settings = {
    extra-substituters = cacheUrls;
    extra-trusted-public-keys = [
      "skifli-nixos:xNH7IYz/XkeFkPVzag7TGFw2wY1pW8EVmnoLy194Htg="
      "skifli-sernix:sYPdAV6YDGzFKZnHJ3v7ifcjwlOegpM533z+UwBSR7g="
      "encore-sr-oracle-vps:ssTArP9V3BjHYh99ZrKgddRAxYf27LCh4+A7PnDn4aw="
    ];
  };

  # The cross-project caches are private. Only hosts that have this secret
  # receive its path in nix.conf; the Nix daemon reads the netrc as root.
  nix.settings.netrc-file = lib.mkIf (builtins.elem config.networking.hostName [ "lyra" "fydetabduo" ])
    config.age.secrets.xilo-cache-netrc.path;
}
