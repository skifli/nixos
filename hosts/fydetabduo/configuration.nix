{
  hostname,
  inputs,
  ...
}: {
  _module.args = {inherit hostname;};

  imports = [
    ../common/default.nix

    # Full module (hardware + shell options, but shell is disabled)
    inputs.fyde-nix.nixosModules.fydetabduo
  ];

  hardware = {
    fydetabduo = {
      enable = true;

      landscape.enable = true;
      sensors.autoRotate = true;
      tabletMode.enable = true;
      modem.enable = true;

      shell = {
        enable = false;

        power.autoProfile = {
          enable = true;
          forcePerformanceOnAC = true;
        };
      };
    };
  };

  boot.loader.fydetabduo.enable = true;
}
