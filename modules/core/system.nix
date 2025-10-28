{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git # Great insinuating tool
    wget # Downloader
  ];

  # Allow proprietary but redistributable firmware
  hardware.enableRedistributableFirmware = true;

  nix = {
    # Automatic garbage collection weekly
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Periodic optimisation of the nix store
    optimise = {
      automatic = true;
      dates = [ "00:00" ];
    };

    # Enable flakes + nix-command
    settings = {
      auto-optimise-store = false; # May make rebuilds longer but a smaller size if enabled, instead we have optimise.automatic enabled
      # Add flake support
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-platforms = [ "aarch64-linux" ]; # Allow cross-compilation
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true; # Run unpatched dynamic binaries on NixOS.
  system.stateVersion = "23.11"; # Do not change!
}
