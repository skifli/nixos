_: rec {
  stateVersion = "26.05";

  optimiseBoot = true;
  optimiseBuilds = true;
  optimiseForHdd = false;

  buildSettings = {
    maxJobs = "auto";
    cores = 0;
  };

  cpuFreqGovernor = "schedutil";

  enabledImports = [
    ../../modules/core/agenix.nix
    ../../modules/core/audio.nix
    ../../modules/core/btrfs.nix
    ../../modules/core/fonts.nix
    ../../modules/core/locale.nix
    ../../modules/core/networking.nix
    ../../modules/core/security.nix
    ../../modules/core/services.nix
    ../../modules/core/system.nix
    ../../modules/core/users.nix
    ../../modules/core/zram.nix
  ];

  enabledUsers = [ "pifi" ];

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

  outputs = {
    "HDMI-1" = {
      mode = "1920x1080@60";
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
      open-on-output = "HDMI-1";
    };
    "2" = {
      open-on-output = "HDMI-1";
    };
    "3" = {
      open-on-output = "HDMI-1";
    };
    "4" = {
      open-on-output = "HDMI-1";
    };
    "5" = {
      open-on-output = "HDMI-1";
    };
    "6" = {
      open-on-output = "HDMI-1";
    };
    "7" = {
      open-on-output = "HDMI-1";
    };
    "8" = {
      open-on-output = "HDMI-1";
    };
  };
}
