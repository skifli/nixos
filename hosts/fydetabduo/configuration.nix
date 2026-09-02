{
  hostname,
  inputs,
  ...
}: {
  _module.args = {inherit hostname;};

  imports = [
    ../common/default.nix

    # All hardware features
    inputs.fyde-nix.nixosModules.fydetabduo-hardware

    # Shell sub-modules: power management + fydetab-update package
    # (shell.enable = false skips labwc/compositor stuff)
    inputs.fyde-nix.nixosModules.shell
  ];

  hardware.fydetabduo = {
    enable = true;

    sensors.autoRotate = true;
    tabletMode.enable = true;
    modem.enable = true;
    npu.enable = true;

    installer-tools.enable = true;

    shell = {
      enable = false;

      packages.enable = false; # Cherry-picked in host-packages.nix instead
      power.autoProfile = {
        enable = true;
        forcePerformanceOnAC = true;
      };
    };
  };

  boot.loader.fydetabduo.enable = true;

  services.openssh.enable = false; # Use Tailscale instead!

  systemd.tmpfiles.rules = [
    "d /home/fynix/.cache 0755 fynix users -"
  ];
}
