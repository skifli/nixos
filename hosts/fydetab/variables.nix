{pkgs, ...}: rec {
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
    ../../modules/core/boot.nix
    ../../modules/core/fonts.nix
    ../../modules/core/locale.nix
    ../../modules/core/networking.nix
    ../../modules/core/security.nix
    ../../modules/core/services.nix
    ../../modules/core/system.nix
    ../../modules/core/users.nix
    ../../modules/core/zram.nix
  ];

  enabledUsers = ["fynix"];

  outputs = {
    "DSI-1" = {
      mode = "1200x2000@59.999024";
      scale = 1.25;
      transform = "flipped";
      focus-at-startup = true;
    };
  };

  workspaces = {
    "1" = {open-on-output = "DSI-1";};
    "2" = {open-on-output = "DSI-1";};
    "3" = {open-on-output = "DSI-1";};
    "4" = {open-on-output = "DSI-1";};
    "5" = {open-on-output = "DSI-1";};
    "6" = {open-on-output = "DSI-1";};
    "7" = {open-on-output = "DSI-1";};
    "8" = {open-on-output = "DSI-1";};
  };

  niri.input = {
    touch.map-to-output = "DSI-1";
    tablet.map-to-output = "DSI-1";
  };

  sessionVariables = {
    LIBGL_ALWAYS_SOFTWARE = "1";
    GALLIUM = "llvmpipe";
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
}
