{
  inputs,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  overlay = _final: prev: {
    msitools = prev.msitools.overrideAttrs (_old: {
      doCheck = false;
    });

    v4l2loopback = prev.v4l2loopback.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        # Workaround for nixpkgs issue #576406:
        # External modules now run depmod (due to System.map in kernel.dev),
        # creating modules.alias etc. that conflict with aggregateModules.
        find $out/lib/modules -name "modules.alias*" -delete
        find $out/lib/modules -name "modules.dep*" -delete
        find $out/lib/modules -name "modules.symbols*" -delete
        find $out/lib/modules -name "modules.builtin*" -delete
        find $out/lib/modules -name "modules.order*" -delete
      '';
    });
  };
in
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

    nix-tree # Interactively browse a Nix store paths dependencies
    pkgsUnstable.gdu # Disk usage analyzer with console interface

    oci-cli # Oracle Cloud Infrastructure

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

  nixpkgs.overlays = [ overlay ];
}
