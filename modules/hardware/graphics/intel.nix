{pkgs, ...}: {
  environment = {
    sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD"; # Force intel-media driver
    };

    systemPackages = with pkgs; [
      libva-utils
    ];
  };

  boot.kernelParams = [
    "intel_pstate=active"
    "i915.enable_psr=0" # Disables PSR completely. This is the most common workaround for fixing screen flickering, random system freezes, or graphical corruption.
    "i915.enable_guc=3" # Enable GuC/HuC firmware loading
    "i915.fastboot=1" # Skip unnecessary mode sets at boot
  ];

  services = {
    # Load the driver
    xserver.videoDrivers = ["modesetting"];
  };

  # OpenGL
  hardware = {
    graphics = {
      extraPackages = with pkgs; [
        # https://wiki.nixos.org/wiki/Accelerated_Video_Playback
        intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD

        # intel-compute-runtime # >= 12th Gen
        intel-compute-runtime-legacy1 # Gen 8,9,11

        # vpl-gpu-rt # for newer GPUs on NixOS >24.05 or unstable
        # onevpl-intel-gpu # for newer GPUs on NixOS <= 24.05
        intel-media-sdk # for older GPUs, instead of vpl-gpu-rt
      ];
    };
  };
}
