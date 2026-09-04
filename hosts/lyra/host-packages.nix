{ pkgs, ... }: {
  # Specify which packages to install on a system level
  environment.systemPackages = with pkgs; [
    rkdeveloptool # For FydeTab Duo flashing
    smartmontools # https://wiki.nixos.org/wiki/Smartmontools
  ];
}
