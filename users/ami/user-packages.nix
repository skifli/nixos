{
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      # davinci-resolve # This was removed due to the builders not already having it and rebuilding was taking forever
      droidcam
      javaPackages.compiler.temurin-bin.jdk-25 # For Prism Launcher
      # kdePackages.kate # Also installs kwrite
      kdePackages.qtwayland # Needed by typstwriter
      kicad
      prismlauncher
      qtscrcpy
      scrcpy
      # siyuan
      termdown
    ];
  };

  # `programs.adb` is deprecated in newer NixOS (systemd 258+ handles uaccess)
  # Install `adb` via `pkgs.android-tools` at the system level instead.
}
