{
  inputs,
  pkgs,
  ...
}:
{
  # Specify which packages to install on a system level
  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default # agenix CLI
    nixfmt # Formatting nix code
    deadnix # Find dead nix code
    fastfetch # Neofetch C alternative

    nixfmt
    nixd # Nix language server

    coreutils # Some Unix CLI utilities
    btop # Monitoring of system resources
    iotop # Monitoring of IO
    android-tools # Provides adb/fastboot (ensure adb available system-wide)

    fbcat # Allows taking screenshots of a TTY

    # WAS IN LYRA? MOVED HERE!
    ffmpeg-full
    # Ensure GStreamer plugins are present
    gst_all_1.gst-libav # Provides H.265/HEVC support
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    libpulseaudio # FIREFOX REQUIRES
  ];
}
