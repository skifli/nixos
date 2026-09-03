{pkgs, ...}: {
  services.cloudflare-warp.enable = true;

  systemd.user.packages = [pkgs.cloudflare-warp];
  systemd.user.targets.graphical-session.wants = ["warp-taskbar.service"];

  environment.shellAliases = {
    w-on = "warp-cli connect";
    w-off = "warp-cli disconnect";
    w-st = "warp-cli status";
  };
}
