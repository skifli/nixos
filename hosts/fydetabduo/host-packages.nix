{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # fyde-nix fydetab-specific
    fydetab-update
    fydetab-wallpaper

    # Tablet essentials (cherry-picked from shell/packages.nix)
    brightnessctl
    iio-sensor-proxy
    grim
    slurp
    wl-clipboard
    swaylock-effects
    wlopm
    usb-modeswitch

    # Hardware debug
    rkdeveloptool

    # Fonts (from shell/packages.nix)
    jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
  ];
}
