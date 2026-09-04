{
  hostVars,
  lib,
  pkgs,
  ...
}:
let
  sanitizeMode = mode: builtins.head (lib.splitString "@" mode);

  # 'e' forces DRM to prioritize and enable that output on the initial framebuffer
  videoKernelParams = lib.mapAttrsToList (
    name: conf:
    let
      isPrimary = conf.focus-at-startup or false;
      cleanMode = sanitizeMode (conf.mode or "1920x1080");
      flag = if isPrimary then "e" else "";
    in
    "video=${name}:${cleanMode}${flag}"
  ) (hostVars.outputs or { });
in
lib.mkIf (hostVars.videoDriver == "intel") {
  environment = {
    sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD"; # Force intel-media driver
    };
    systemPackages = with pkgs; [
      libva-utils
    ];
  };

  boot = {
    kernelParams = [
      "intel_pstate=active"
      "i915.enable_psr=0" # Disables PSR completely. This is the most common workaround for fixing screen flickering, random system freezes, or graphical corruption.
      "i915.enable_guc=3" # Enable GuC/HuC firmware loading
      "i915.fastboot=1" # Skip unnecessary mode sets at boot
    ]
    ++ videoKernelParams;

    # Early KMS: Load the Intel GPU driver in initrd stage 1 so the primary
    # monitor initializes before Plymouth and login without switching displays
    initrd = {
      enable = true;
      kernelModules = [ "i915" ];
    };
  };

  services = {
    # Load the driver
    xserver.videoDrivers = [ "modesetting" ];
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
        # intel-media-sdk # for older GPUs, instead of vpl-gpu-rt
        #
        # Known issues:
        # - End of life with various local privilege escalation vulnerabilites:
        #  - CVE-2023-22656
        #  - CVE-2023-45221
        #  - CVE-2023-47169
        #  - CVE-2023-47282
        #  - CVE-2023-48368
      ];
      extraPackages32 = with pkgs.driversi686Linux; [
        intel-media-driver
      ];
    };
  };
}
