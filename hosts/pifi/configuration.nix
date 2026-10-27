{
  hostname,
  inputs,
  hostVars,
  pkgs,
  ...
}:
let
  primaryUser = builtins.head hostVars.enabledUsers;
in
{
  _module.args = { inherit hostname; };

  imports = [
    ../common/default.nix

    # Pi 5 hardware via nixos-raspberrypi (boot, firmware, overclock)
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
  ];

  # Raspberry Pi 5 specific hardware configuration
  hardware.raspberry-pi = {
    config = {};
  };

  # Boot configuration
  boot.loader = {
    raspberry-pi = {
      enable = true;
    };
    # generic-extlinux-compatible.enable = true;
  };

  # Minimal: just SSH for initial access, Tailscale for identity preservation
  services.openssh.enable = true;
  services.tailscale = {
    enable = true;
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

  # Timezone & locale
  time.timeZone = "Europe/London";
  console.keyMap = "uk";
  i18n.defaultLocale = "en_GB.UTF-8";

  # System state version
  system.stateVersion = "26.05";
}