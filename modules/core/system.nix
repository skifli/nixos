{
  hostname,
  hostVars,
  pkgs,
  userVars,
  ...
}: let
  caches = import ../../caches.nix;
in {
  environment.systemPackages = with pkgs; [
    git # Great insinuating tool
    wget # Downloader
    v4l-utils # Enables v4l2loopback GUI utilities
  ];

  # Allow proprietary but redistributable firmware
  hardware.enableRedistributableFirmware = true;

  nix = {
    /*
       Disable as it is now handled by nh down below
    # Automatic garbage collection weekly
    gc = {
      automatic = false;
      dates = "weekly";
      options = "--delete-older-than 30d";
      persistent = true; # Catch up on missed runs
    };
    */

    /*
    # Disabled because it just takes too long and yeah, if I get a better system maybe then though!
    # Periodic optimisation of the nix store
    optimise = {
      automatic = true;
      dates = ["weekly"];
      persistent = true; # Catch up on missed runs
    };
    */

    # Enable flakes + nix-command
    settings = {
      auto-optimise-store = false; # May make rebuilds longer but a smaller size if enabled, instead we have optimise.automatic enabled
      # Add flake support
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-platforms = ["aarch64-linux"]; # Allow cross-compilation
      use-xdg-base-directories = true;

      # Better build caching to reduce kworker load
      max-jobs = hostVars.buildSettings.maxJobs;
      cores = hostVars.buildSettings.cores;

      # Optimize disk I/O for builds
      fsync-metadata = false; # Don't fsync metadata on every change
      keep-build-log = false; # Don't keep build logs to reduce IO

      inherit (caches) substituters trusted-public-keys;
    };
  };

  nixpkgs.config.allowUnfree = true;

  powerManagement = {
    enable = true;
    inherit (hostVars) cpuFreqGovernor;
  };

  programs = {
    nh = {
      enable = true;
      flake = "/home/${userVars.username}/nixos"; # Assumes config in /etc/nixos
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
      flake = "/home/${userVars.username}/nixos#${hostname}"; # Assumes config in /etc/nixos
      flags = [];
      persistent = true; # Catch up on missed runs
    };

    stateVersion = "25.05"; # Do not change!
  };
}
