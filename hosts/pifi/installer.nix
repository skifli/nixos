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
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5
  ];

  # Raspberry Pi 5 specific hardware configuration
  hardware.raspberrypi = {
    model = 5;
    firmware = {
      configTxt = ''
        dtoverlay=dwc2,dr_mode=host
        dtparam=pciex1_gen=3
        dtparam=rtc_bbat_vchg=3000000
        max_framebuffers=2
        disable_overscan=1
        disable_fw_kms_setup=1
      '';
    };
    overclock = {
      arm_freq = 3000;
      gpu_freq = 1000;
      over_voltage_delta = 50000;
      arm_boost = true;
    };
  };

  # Boot configuration
  boot.loader = {
    raspberrypi = {
      enable = true;
      version = 2;
    };
    generic-extlinux-compatible.enable = true;
  };

  # SSH + Tailscale for initial access
  services.openssh.enable = true;
  services.tailscale = {
    enable = true;
    ipv4 = "100.120.18.23";
    advertiseExitNode = true;
    ssh = true;
  };

  # Root password for initial SSH access (change on first login!)
  users.users.root = {
    initialHashedPassword = "$6$lR9TojrZu.e7s/3F$kx1hlutk/R2Hp4mSZRzOrKCft6aqt15gI76zBrSDbucCWtQx.73BLmNZAAxfuUNp6mYm/C5HPiOqg6M6GTlqO.";
  };

  # NetworkManager with wifi
  networking.networkmanager = {
    enable = true;
    wifi = {
      backend = "wpa_supplicant";
      macAddress = "permanent";
      scanRandMacAddress = false;
    };
  };

  # WiFi credentials from agenix secret
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

  # Ensure WiFi firmware is included
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  # Timezone & locale
  time.timeZone = "Europe/London";
  console.keyMap = "uk";
  i18n.defaultLocale = "en_GB.UTF-8";

  # System state version
  system.stateVersion = "26.05";
}
