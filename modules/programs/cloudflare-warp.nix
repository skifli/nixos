{pkgs, ...}: {
  services.cloudflare-warp.enable = true;

  systemd.packages = [pkgs.cloudflare-warp];
  systemd.user.services.warp-taskbar.wantedBy = ["graphical-session.target"];

  environment.shellAliases = {
    w-on = "warp-cli connect";
    w-off = "warp-cli disconnect";
    w-st = "warp-cli status";
  };
}
