{...}: {
  services.cloudflare-warp.enable = true;

  environment.shellAliases = {
    w-on = "warp-cli connect";
    w-off = "warp-cli disconnect";
    w-st = "warp-cli status";
  };
}
