{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Make Ghostty's advertised TERM usable on incoming SSH sessions.
    ghostty.terminfo
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
    alsa-utils

    # Hardware debug
    rkdeveloptool

    # Fonts (from shell/packages.nix)
    jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
  ];
}
