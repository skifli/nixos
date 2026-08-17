{
  pkgs,
  pkgsUnstable,
  ...
}: {
  boot = {
    # Allow cross-compilation
    binfmt.emulatedSystems = [
      "aarch64-linux"
    ];

    # Previous: kernelPackages = pkgs.linuxPackages_latest; # Use latest kernel version available
    kernelPackages = pkgs.linuxPackages_cachyos; # Use high-performance CachyOS Kernel (BORE Scheduler + Thin LTO)
    kernelParams = [
      "preempt=full" # Lower latency but less throughput
      "quiet" # Non-verbose boot mode
      "splash" # Eye-candy loading screen
      "loglevel=3" # Restricts kernel log messages to errors/critical only
      "boot.shell_on_fail" # Drops to a recovery shell safely if boot fails instead of locking up
      "rd.udev.log_level=3" # Quiets early udev device manager logs
      "rd.systemd.show_status=false" # Hides systemd startup text in initrd
      "vt.global_cursor_default=0" # Hides the blinking text cursor on the console
    ];

    # "splash" above
    plymouth = {
      enable = true;
      theme = "breeze"; # A NixOS branded variant of the breeze theme when config.boot.plymouth.theme == "breeze", otherwise [ ].
    };

    kernel.sysctl = [
      # Reduce kworker IO pressure during heavy builds
      "vm.dirty_ratio=10" # Percentage of RAM before aggressive writeback
      "vm.dirty_background_ratio=5" # Background writeback threshold
      "vm.dirty_writeback_centisecs=500" # Reduce frequency of writeback
    ];

    # CachyOS-specific pkg
    zfs.package = pkgs.zfs_cachyos;

    loader = {
      efi = {
        canTouchEfiVariables = true; # E.g., can set as default boot entry
        efiSysMountPoint = "/boot";
      };

      # Hide the OS choice for bootloaders.
      # It's still possible to open the bootloader list by pressing any key
      # It will just not appear on screen unless a key is pressed
      timeout = 0; # How long to wait on initial boot choices before proceeding into default sys

      limine = {
        enable = true;
        biosSupport = false;
        efiSupport = true;
        maxGenerations = 50;
        style = {
          wallpapers = [pkgsUnstable.nixos-artwork.wallpapers.binary-blue.gnomeFilePath];
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

    tmp = {
      useTmpfs = true;
      useZram = false;

      tmpfsSize = "75%"; # Allows /tmp to grow up to 75% of RAM dynamically if needed
      tmpfsHugeMemoryPages = "within_size"; # Only allocate huge memory pages if it will be fully within i_size. Also respect madvise(2) hints. Recommended.

      cleanOnBoot = true;
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
