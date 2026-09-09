{ ... }: rec {
  stateVersion = "26.05";

  optimiseBoot = true;
  optimiseBuilds = true;
  optimiseForHdd = false;

  buildSettings = {
    maxJobs = "auto";
    cores = 0;
  };

  cpuFreqGovernor = "schedutil"; # Set by fyde-nix qol.nix too, but system.nix inherit requires it

  enabledImports = [
    ../../modules/core/audio.nix
    # boot.nix not imported — fyde-nix handles boot for fydetabduo
    ../../modules/core/btrfs.nix
    ../../modules/core/fonts.nix
    ../../modules/core/locale.nix
    ../../modules/core/networking.nix
    ../../modules/core/security.nix
    ../../modules/core/services.nix
    ../../modules/core/system.nix
    ../../modules/core/users.nix
    ../../modules/core/zram.nix

    ../../modules/programs/oracle-proxy.nix
  ];

  enabledUsers = [ "fynix" ];

  outputs = {
    "DSI-1" = {
      mode = "2560x1600@59.999024";
      scale = 1.0;
      position = {
        x = 0;
        y = 0;
      };
      focus-at-startup = true;
    };
  };

  workspaces = {
    "1" = {
      open-on-output = "DSI-1";
    };
    "2" = {
      open-on-output = "DSI-1";
    };
    "3" = {
      open-on-output = "DSI-1";
    };
    "4" = {
      open-on-output = "DSI-1";
    };
    "5" = {
      open-on-output = "DSI-1";
    };
    "6" = {
      open-on-output = "DSI-1";
    };
    "7" = {
      open-on-output = "DSI-1";
    };
    "8" = {
      open-on-output = "DSI-1";
    };
  };

  niri = {
    gestures = {
      /*
        hot-corners = {
          top-left = [ ];
          };
      */
      hot-corners.off = [ ];
    };

    input = {
      touchpad = {
        tap = [ ];
        natural-scroll = [ ];
      };
    };
  };

  # Snapshotting on mah fydetabduo is provided by fyde-nix's fydetab-snapshot
  # (btrfs subvolume snapshot -r / with set-default rollback), not NixOS
  # snapper. The tablet is only a single top-level subvol (subvolid=5), so a
  # snapper config would snapshot the whole disk - tis a lotta data meow.

  sessionVariables = {
  };

  screen-lock-timeout = 15;
  screen-blank-timeout = 20;

  consoleKeymap = "uk";
  keyboardLayout = "gb";
  kbdVariant = "";

  latitude = 51.5;
  longitude = -0.1;

  locale = "en_GB.UTF-8";
  locale-simple = "en-GB";

  timezone = "Europe/London";
  location = "London+England";

  declarativeWifi = [
    "psk"
    {
      type = "psk";
      privacy = true;
    }
    "psk"
    "eap"
  ];
}
