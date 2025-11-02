{ pkgs, ... }:

{
  boot = {
    # Allow cross-compilation
    binfmt.emulatedSystems = [
      "aarch64-linux"
    ];

    kernelPackages = pkgs.linuxPackages_latest; # Use latest kernel version available
    kernelParams = [
      "preempt=full" # Lower latency but less throughput
      # "quiet" # Non verbose boot mode
      # "splash" # Eye-candy loading screen
    ];

    loader = {
      efi = {
        canTouchEfiVariables = true; # E.g., can set as default boot entry
        efiSysMountPoint = "/boot";
      };
      timeout = 5; # How long to wait on initial boot choices before proceeding into default sys

      systemd-boot.enable = false; # In favour of below
      grub = {
        enable = true; # Tried systemd-boot, much more involved so grub it is

        configurationLimit = 50;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
    };

    # Filesystems support
    supportedFilesystems = [
      "ntfs"
      # "exfat"
      "ext4"
      # "fat32"
      # "btrfs"
    ];
    tmp.cleanOnBoot = true; # Cleanse tmp dir
  };
}
