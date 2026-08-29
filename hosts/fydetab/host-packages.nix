{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ffmpeg-full
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    libpulseaudio
  ];
}
