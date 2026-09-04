{
  hostname,
  hostVars,
  pkgs,
  ...
}:
let
  primaryUser = builtins.head hostVars.enabledUsers; # Dynamically gets "ami" (or whichever user is enabled for this host)
in
{
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

    # Periodic optimisation of the nix store
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
      persistent = true; # Catch up on missed runs
    };

    # Enable flakes + nix-command
    settings = {
      auto-optimise-store = false; # May make rebuilds longer but a smaller size if enabled, instead we have optimise.automatic enabled
      # Add flake support
      experimental-features = [
        "nix-command"
        "flakes"
        "flake-self-attrs"
      ];
      extra-platforms = [ "aarch64-linux" ]; # Allow cross-compilation
      use-xdg-base-directories = true;

      # Better build caching to reduce kworker load
      max-jobs = hostVars.buildSettings.maxJobs;
      cores = hostVars.buildSettings.cores;

      # Optimize disk I/O for builds
      fsync-metadata = false; # Don't fsync metadata on every change
      keep-build-log = false; # Don't keep build logs to reduce IO
    };

    /*
      https://discourse.nixos.org/t/lix-mismatch-in-feature-name-compared-to-nix/59879
      Had something probably similar with flake-self-attrs
    */
    extraOptions = ''
      experimental-features = nix-command flakes flake-self-attrs
    '';
  };

  nixpkgs.config.allowUnfree = true;

  powerManagement = {
    enable = true;
    inherit (hostVars) cpuFreqGovernor;
  };

  # `path:` is needed prepended before programs.nh.flake and system.autoUpgrade.flake otherwise they shalt error on git submodules - error: getting status of '/nix/store/x-source/users/programs/browser/zen/profile-default/hidden/space-routing.nix'

  programs = {
    nh = {
      enable = true;
      flake = "path:/home/${primaryUser}/nixos"; # Assumes config in /home/${primaryUser}/nixos
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 7d --keep 10"; # Keep any generation used within the last 7 days, and keep the last 10 generations no matter what
      };
    };
    git.config.safe.directory = [
      "/home/${primaryUser}/nixos"
    ];
    nix-ld.enable = true; # Run unpatched dynamic binaries on NixOS.
  };

  system = {
    autoUpgrade = {
      enable = true;
      dates = "weekly";
      allowReboot = false;
      operation = "boot"; # Only change on boot
      flake = "path:/home/${primaryUser}/nixos#${hostname}"; # Assumes config in /home/${primaryUser}/nixos
      flags = [ ];
      persistent = true; # Catch up on missed runs
    };

    # Copy the NixOS configuration file and link it from the resulting system
    # (/run/current-system/configuration.nix). This is useful in case you
    # accidentally delete configuration.nix.
    # copySystemConfiguration = true;
    # NOT SUPPORTED WITH FLAKES

    stateVersion = hostVars.stateVersion;
  };
}
