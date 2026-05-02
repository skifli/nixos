{ pkgs, pkgsUnstable, ... }:

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
      timeout = 1; # How long to wait on initial boot choices before proceeding into default sys

      limine = {
        enable = true;
        biosSupport = false;
        efiSupport = true;
        maxGenerations = 50;
        style = {
          wallpapers = [ pkgsUnstable.nixos-artwork.wallpapers.binary-blue.gnomeFilePath ];
          wallpaperStyle = "centered";
        };
      };

      systemd-boot = {
        enable = false;
        consoleMode = "max";
        configurationLimit = 50;
      };

      grub = {
        enable = false; # In favour of above

        configurationLimit = 50;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
    };

    # Filesystems support
    supportedFilesystems = [
      "btrfs"
      # "exfat"
      "ext4"
      # "fat32" # Old eh
      "ntfs"
    ];
    tmp.cleanOnBoot = true; # Cleanse tmp dir
  };

  environment.systemPackages = with pkgs; [
    btrfs-progs # BTRFS support
  ];
}
