{ pkgs, ... }:

{
  # Specify which packages to install on a system level
  environment.systemPackages = with pkgs; [
    ffmpeg-full
    # Ensure GStreamer plugins are present
    gst_all_1.gst-libav # Provides H.265/HEVC support
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    libpulseaudio # FIREFOX REQUIRES
    
    opentabletdriver # Tablet input
    rkdeveloptool # For FydeTab Duo flashing
    smartmontools # https://wiki.nixos.org/wiki/Smartmontools
  ];

  systemd.user.services.opentabletdriver = {
    description = "Open source, cross-platform, user-mode tablet driver";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.opentabletdriver}/bin/otd-daemon";
      Restart = "on-failure";
    };
  };
}
