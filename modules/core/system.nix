{
  hostname,
  hostVars,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    git # Great insinuating tool
    wget # Downloader
    v4l-utils # Enables v4l2loopback GUI utilities
  ];

  # Allow proprietary but redistributable firmware
  hardware.enableRedistributableFirmware = true;

  nix = {
    # Automatic garbage collection weekly
    gc = {
      automatic = false; # Now handled by nh down below
      dates = "weekly";
      options = "--delete-older-than 30d";
      persistent = true; # Catch up on missed runs
    };

    # Periodic optimisation of the nix store
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
      persistent = true; # Catch up on missed runs
    };

    # Enable flakes + nix-command
    settings = {
      auto-optimise-store = false; # May make rebuilds longer but a smaller size if enabled, instead we have optimise.automatic enabled
      download-buffer-size = 1048576000; # 1GB
      # Add flake support
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-platforms = [ "aarch64-linux" ]; # Allow cross-compilation
      use-xdg-base-directories = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = hostVars.cpuFreqGovernor;
  };

  programs = {
    nh = {
      enable = true;
      flake = "/etc/nixos"; # Assumes config in /etc/nixos
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 7d --keep 10"; # Keep any generation used within the last 7 days, and keep the last 10 generations no matter what
      };
    };
    nix-ld.enable = true; # Run unpatched dynamic binaries on NixOS.
  };

  system = {
    autoUpgrade = {
      enable = true;
      dates = "weekly";
      allowReboot = false;
      operation = "boot"; # Only change on boot
      flake = "/etc/nixos#${hostname}"; # Assumes config in /etc/nixos
      flags = [
        "--update-input"
        "nixpkgs"
        "--no-write-lock-file"
      ];
      persistent = true; # Catch up on missed runs
    };

    stateVersion = "25.05"; # Do not change!
  };
}
