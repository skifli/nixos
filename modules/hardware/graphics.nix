{...}: {
  imports = [
    ./graphics/intel.nix
  ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
