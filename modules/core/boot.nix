{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Workaround for nixpkgs issue #576406: external modules now run depmod (due to
  # System.map in kernel.dev), generating modules.alias/dep/etc that conflict with
  # the kernel's own files during buildEnv aggregation. We copy the module tree but
  # strip the conflicting top-level metadata files, keeping the actual .ko intact.
  # This must be applied at the point of use because chaotic's linuxPackages_cachyos
  # is built via callPackage against its own nixpkgs, so a nixpkgs.overlays
  # // override cannot reliably get to the nested v4l2loopback attribute.
  fixedV4l2loopback =
    pkgs.runCommand "v4l2loopback-fixed"
      {
        version = config.boot.kernelPackages.v4l2loopback.version;
      }
      ''
        subdir=lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}
        mkdir -p $out/$subdir
        cp -r ${config.boot.kernelPackages.v4l2loopback}/$subdir/. $out/$subdir/
        # Remove the conflicting metadata files that buildEnv will otherwise choke on
        find $out/$subdir -maxdepth 1 -name 'modules.*' -delete
      '';

  # The Plymouth script engine builds one virtual canvas sized to the largest
  # connected display. Breeze positions the logo/spinner once, when the theme
  # loads. Whichever monitor registers first determines that canvas, so if a
  # bigger monitor appears a moment later everything stays centred on the old
  # (smaller) canvas and ends up off-centre on every display.
  #
  # Patch the NixOS-branded Breeze theme to re-run the layout whenever the
  # canvas size changes (i.e., a display was added/removed after startup).
  breezePlymouth =
    (pkgs.kdePackages.breeze-plymouth.override {
      logoFile = config.boot.plymouth.logo;
      logoName = "nixos";
      osName = config.system.nixos.distroName;
      osVersion = config.system.nixos.release;
    }).overrideAttrs
      (old: {
        postInstall = (old.postInstall or "") + ''
          substituteInPlace $out/share/plymouth/themes/breeze/breeze.script \
            --replace-fail 'global.spin = Spinner();' 'global.spin = Spinner();

          // Re-centre everything when the largest display changes size (e.g., a
          // monitor that appears after the theme script has loaded).
          global.layout_width = Window.GetWidth();
          global.layout_height = Window.GetHeight();

          fun Relayout() {
              global.layout_width = Window.GetWidth();
              global.layout_height = Window.GetHeight();

              logo.x = Window.GetX() + Window.GetWidth() / 2 - logo.image.GetWidth() / 2;
              logo.y = Window.GetY() + Window.GetHeight() / 2 - logo.image.GetHeight() / 2;
              logo.SetPosition(logo.x, logo.y, logo.z);

              logo.name.x = Window.GetX() + Window.GetWidth() / 2 - logo.name.GetImage().GetWidth() / 2;
              logo.name.y = logo.y + logo.image.GetHeight() + logo.name.GetImage().GetHeight() / 2;
              logo.name.SetPosition(logo.name.x, logo.name.y, logo.name.z);

              for (i = 0; i <= spin.count; ++i) {
                  if (i % spin.steps != 0) {
                      continue;
                  }
                  center_offset = logo.image.GetWidth() / 2 - spin[i].width / 2;
                  top_offset = logo.image.GetHeight() + logo.name.GetImage().GetHeight() + spin[i].height;
                  spin[i].SetPosition(logo.x + center_offset, logo.y + top_offset, logo.z);
              }

              top_of_the_text = TextYOffset();
          }' \
            --replace-fail 'fun refresh_callback() {' 'fun refresh_callback() {
              if (Window.GetWidth() != global.layout_width || Window.GetHeight() != global.layout_height) {
                  Relayout();
              }'
        '';
      });
in
{
  boot = {
    # Allow cross-compilation (only on x86_64 emulating aarch64)
    binfmt.emulatedSystems = lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
      "aarch64-linux"
    ];

    # Use high-performance CachyOS Kernel (BORE Scheduler + Thin LTO)
    kernelPackages = pkgs.linuxPackages_cachyos;

    # Use the depmod-conflict-free v4l2loopback (see fixedV4l2loopback above).
    # mkForce overrides the auto-generated hardware-configuration.nix entry.
    extraModulePackages = lib.mkForce [ fixedV4l2loopback ];
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
      themePackages = lib.mkForce [ breezePlymouth ]; # See breezePlymouth above: multi-monitor centring fix.
    };

    kernel.sysctl = {
      # Reduce kworker IO pressure during heavy builds
      "vm.dirty_ratio" = 10; # Percentage of RAM before aggressive writeback
      "vm.dirty_background_ratio" = 5; # Background writeback threshold
      "vm.dirty_writeback_centisecs" = 500; # Reduce frequency of writeback
    };

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
          backdrop = "#202626"; # Matches the wallpaper
          wallpapers = [ pkgs.nixos-artwork.wallpapers.gear.gnomeFilePath ];
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
  };

  services.udev.extraRules = ''
    # Set BFQ scheduler for mechanical HDDs only (rotational == 1)
    # ATTR{queue/rotational}=="1" is a backup just in case because this is behind a host flag but whatever
    ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  ''; # Only applies to HDDs!

  environment.systemPackages = with pkgs; [
    btrfs-progs # BTRFS support
  ];
}
