{ pkgs, userVars, ... }:

{
  home-manager.users.${userVars.username}.home.packages = with pkgs; [
    anytype
    davinci-resolve
    droidcam
    evince # Document viewer
    ferdium
    fira-code
    haruna # Media player
    imagemagick # mogrift EXIF
    kdePackages.gwenview # Image viewer
    # kdePackages.kate # Also installs kwrite
    kdePackages.qtwayland # Needed by typstwriter
    kicad
    noto-fonts
    noto-fonts-color-emoji
    protonvpn-gui
    remmina

    mpv
  ];

  programs.adb.enable = true; /* For DroidCam */
}
