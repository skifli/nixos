{pkgs, ...}: {
  # Feature toggles
  # disableX = true;

  optimiseBoot = true;
  optimiseBuilds = true;
  optimiseForHdd = false;

  # nixOS config building-related settings
  buildSettings = {
    maxJobs = "auto";
    cores = 0;
  };

  # Host configuration
  cpuFreqGovernor = "performance";
  enabledImports = [
    # Host specific modules
    ../../modules/core/audio.nix
    ../../modules/core/boot.nix
    ../../modules/core/btrfs.nix
    ../../modules/core/fonts.nix
    ../../modules/core/gaming.nix
    ../../modules/core/locale.nix
    ../../modules/core/networking.nix
    ../../modules/core/printing.nix
    ../../modules/core/security.nix
    ../../modules/core/services.nix
    ../../modules/core/smartd.nix
    ../../modules/core/system.nix
    ../../modules/core/users.nix
    ../../modules/core/zram.nix

    ../../modules/hardware/graphics.nix

    ../../modules/programs/clamav.nix
  ];

  # User configuration
  enabledUsers = ["ami"];

  # Hardware configuration
  videoDriver = "intel"; # Empty to import none.

  # TODO - FIX: A lot of assumptions are made based on there only being 2 monitors right now...
  outputs = {
    # WARNING: Must manually update new attrs in users/programs/compositor/niri/settings.nix
    "DP-1" = {
      mode = "1440x900@59.89";
      scale = 1.0;
      position = {
        x = 1920;
        y = 0;
      };
    };
    "HDMI-A-2" = {
      mode = "1920x1080@74.99";
      scale = 1.0;
      position = {
        x = 0;
        y = 0;
      };
      focus-at-startup = true;
    };
  };

  workspaces = {
    "1" = {open-on-output = "HDMI-A-2";};
    "2" = {open-on-output = "HDMI-A-2";};
    "3" = {open-on-output = "HDMI-A-2";};
    "4" = {open-on-output = "HDMI-A-2";};

    "5" = {open-on-output = "DP-1";};
    "6" = {open-on-output = "DP-1";};
    "7" = {open-on-output = "DP-1";};
    "8" = {open-on-output = "DP-1";};
  };

  devices = [
    # -d nvme: Use NVMe driver
    # -H: Monitor NVMe health status & available spare threshold
    # -W 4,70,80: Report on 4°C delta, warn at 70°C, critical at 80°C
    # -s (S/../.././02): Quick background self-test daily at 2:00 AM
    {
      device = "/dev/nvme0n1";
      options = "-d nvme -H -W 4,70,80 -s (S/../.././02)";
    }

    /*
       TODO - Fix: Add to Pi config as no longer on this device
    # -a: Monitor all standard ATA SMART attributes
    # -o on -S on: Enable background testing & auto-save of attribute data
    # -n standby,q: Never wake up the HDD from sleep/standby to run checks
    # -W 4,50,55: Warn at 50°C, Critical at 55°C
    # -C 197+: Alert immediately on any Current Pending Sectors (failing drive)
    # -U 198+: Alert immediately on any Offline Uncorrectable Sectors (bad sectors)
    # -s (S/../.././03|L/../../6/04): Short test daily at 3:00 AM, Long scan Saturdays at 4:00 AM
    {
      device = "/dev/sda";
      options = "-a -o on -S on -n standby,q -W 4,50,55 -C 197+ -U 198+ -s (S/../.././03|L/../../6/04)";
    }
    */
  ];

  printerDrivers = [
    (pkgs.writeTextDir "share/cups/model/OKI-MC363-PS.ppd" (builtins.readFile ./assets/OKI-MC363-PS.ppd))
  ];

  # Default printer is the first printer
  printers = [
    {
      name = "OKI_DATA_CORP_MC363";
      description = "OKI DATA CORP MC363 Multifunction Color Printer";
      location = "Office";
      deviceUri = "usb://OKI%20DATA%20CORP/MC363?serial=AK75045339&interface=1";
      model = "OKI-MC363-PS.ppd";

      ppdOptions = {
        PageSize = "A4";
        Duplex = "DuplexNoTumble"; # Set default 2-sided printing
      };
    }
  ];

  niri.input = {
  };

  sessionVariables = {
    GC_INITIAL_HEAP_SIZE = "4G";
  };

  screen-lock-timeout = 5;
  screen-blank-timeout = 15;

  # Localisation
  consoleKeymap = "uk"; # TTY keymap
  keyboardLayout = "gb"; # Keyboard layout

  kbdVariant = ""; # Keyboard variant (can be empty)

  latitude = 51.5;
  longitude = -0.1;

  locale = "en_GB.UTF-8"; # System locale
  locale-simple = "en-GB"; # Simple locale for programs that don't like the full one

  timezone = "Europe/London"; # Your timezone
  location = "London+England";
}
