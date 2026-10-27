{
  hostname,
  inputs,
  hostVars,
  ...
}:
{
  _module.args = { inherit hostname; };

  imports = [
    ../common/default.nix

    # Pi 5 hardware via nixos-raspberrypi
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
  ];

  hardware.raspberry-pi = {
    config = { };
  };

  boot.loader = {
    raspberry-pi = {
      enable = true;
    };
  };

  services.openssh.enable = true;
  services.tailscale = {
    enable = true;
  };

  networking.networkmanager = {
    enable = true;
    wifi = {
      backend = "wpa_supplicant";
      macAddress = "permanent";
      scanRandMacAddress = false;
    };
  };

  # WiFi credentials
  networking.wireless.networks = {
    "vodafoneD7400B" = {
      psk = "6nCxaGaNC29tbALJ";
    };
    "SGS-Onboarding" = {
      psk = "staffgoddington23";
    };
    "SGS-BYOD-Student" = {
      identity = "aneeq.weerasinghe@saintolaves.net";
      password = "Plex_exl12";
    };
  };

  # Root password for initial SSH access
  users.users.root = {
    initialHashedPassword = "$6$lR9TojrZu.e7s/3F$kx1hlutk/R2Hp4mSZRzOrKCft6aqt15gI76zBrSDbucCWtQx.73BLmNZAAxfuUNp6mYm/C5HPiOqg6M6GTlqO.";
  };

  # Ensure WiFi firmware is included
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  time.timeZone = "Europe/London";
  console.keyMap = "uk";
  i18n.defaultLocale = "en_GB.UTF-8";

  system.stateVersion = "26.05";
}
