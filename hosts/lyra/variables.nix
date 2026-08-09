{
  # Feature toggles
  # disableX = true;

  optimiseBoot = true;
  optimiseBuilds = true;

  # Host configuration
  cpuFreqGovernor = "performance";
  enabledImports = [
    # Host specific modules
    ../../modules/core/audio.nix
    ../../modules/core/boot.nix
    ../../modules/core/fonts.nix
    ../../modules/core/gaming.nix
    ../../modules/core/locale.nix
    ../../modules/core/networking.nix
    ../../modules/core/printing.nix
    ../../modules/core/security.nix
    ../../modules/core/services.nix
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
    "DP-1" = {
      _args = ["DP-1"];
      mode._props = {
        width = 1440;
        height = 900;
        refresh = 59.89;
      };
      position._props = {
        x = 1920; # Right of the other monitor
        y = 0;
      };
    };
    "HDMI-A-2" = {
      _args = ["HDMI-A-2"];
      mode._props = {
        width = 1920;
        height = 1080;
        refresh = 74.99;
      };
      position._props = {
        x = 0;
        y = 0;
      };
      focus-at-startup = true;
    };
  };

  workspaces = {
    "1" = {
      _args = ["1"];
      open-on-output = "HDMI-A-2";
    };
    "2" = {
      _args = ["2"];
      open-on-output = "HDMI-A-2";
    };
    "3" = {
      _args = ["3"];
      open-on-output = "HDMI-A-2";
    };
    "4" = {
      _args = ["4"];
      open-on-output = "HDMI-A-2";
    };

    "5" = {
      _args = ["5"];
      open-on-output = "DP-1";
    };
    "6" = {
      _args = ["6"];
      open-on-output = "DP-1";
    };
    "7" = {
      _args = ["7"];
      open-on-output = "DP-1";
    };
    "8" = {
      _args = ["8"];
      open-on-output = "DP-1";
    };
  };

  niri.input = {
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

