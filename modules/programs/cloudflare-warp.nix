{ pkgs, ... }: {
  services.cloudflare-warp = {
    enable = true;
    package = pkgs.cloudflare-warp.override { headless = true; };
  };

  environment.shellAliases = {
    w-on = "warp-cli connect";
    w-off = "warp-cli disconnect";
    w-st = "warp-cli status";
  };
}
