{ ... }: rec {
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

  enabledUsers = [ "pistor" ];

  tailscaleDevices = {
    fydetabduo = "100.107.134.34";
    lenovo-a2016a40 = "100.103.254.124";
    lyra = "100.76.87.14";
    oneplus-be2013 = "100.100.169.28";
    oracle-nix = "100.78.161.125";
    pifi = "100.120.18.23";
    pistor = "100.x.x.x"; # TBD
  };

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