{
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username}.home.packages = with pkgs; [
    anytype
    cameractrls
    cameractrls-gtk4
    # cherry-studio # This, kicad, and 1 below removed due to the builders not already having it and rebuilding was taking forever
    # davinci-resolve #
    droidcam
    evince # Document viewer
    ferdium
    fira-code
    haruna # Media player
    hblock
    imagemagick # mogrift EXIF
    kdePackages.gwenview # Image viewer
    # kdePackages.kate # Also installs kwrite
    kdePackages.qtwayland # Needed by typstwriter
    # kicad
    normcap
    noto-fonts
    noto-fonts-color-emoji
    prismlauncher
    javaPackages.compiler.temurin-bin.jdk-25 # For Prism Launcher
    protonvpn-gui
    qtscrcpy
    remmina
    scrcpy
    soundwireserver
    # siyuan

    mpv
  ];

    # `programs.adb` is deprecated in newer NixOS (systemd 258+ handles uaccess)
    # Install `adb` via `pkgs.android-tools` at the system level instead.
}
