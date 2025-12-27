{
  hostname,
  lib,
  pkgs,
  ...
}@attrs: # Combine everything passed into here into one variable, attrs (includes not explicitly used variables)

let
  commonHostVars = import ./variables.nix { inherit pkgs; };
  hostVars = import ../${hostname}/variables.nix // {
    inherit hostname;
  }; # Merges hostname with the other config, to more seamlessly combine

  usersVars =
    (import ../../users/variables.nix {
      inherit (hostVars) enabledUsers;
      inherit lib;
    }).usersVars; # Get variables for all users enabled for this host

  idleConfig = {
    CPUWeight = "20"; # Defaults to 100 for all processes. Lower value means lower priority. This is a arbitrary weight integer.
    CPUQuota = "85%"; # Absolute limit on how much CPU time is granted even if nothing else is going on. This is a percent value.
    IOWeight = "20"; # IOWeight is much the same as CPUWeight.
    Slice = "nix-daemon.slice";
    OOMScoreAdjust = 1000; # If a kernel-level OOM event does occur anyway, strongly prefer killing nix-daemon child processes
  };
in
{
  config = lib.mkMerge [
    {
      _module.args = { inherit commonHostVars hostVars usersVars; }; # Pass these to future imported modules automagically

      environment.shellAliases = commonHostVars.shellAliases;
    }

    (lib.mkIf hostVars.optimiseBoot {
      # Don't wait to be online to start, can cause a oh you're now online notification after boot but tis fine!
      systemd.services.NetworkManager-wait-online.enable = false;

      networking.dhcpcd = {
        # Don’t wait for IPs at boot
        wait = "background";

        # (Optional) Skip duplicate-IP ARP checks for home LANs
        extraConfig = "noarp";
      };
    })

    # https://github.com/NixOS/nixpkgs/blob/2fb006b87f04c4d3bdf08cfdbc7fab9c13d94a15/nixos/modules/services/system/nix-daemon.nix
    (lib.mkIf hostVars.optimiseBuilds {
      # Make it so user stuff is a way higher priority than nix builds, meaning the system stays snappy when compiling!
      systemd = {
        # Create a separate slice for nix-daemon that is memory-managed by the userspace systemd-oomd killer.
        slices."nix-daemon".sliceConfig = {
          ManagedOOMMemoryPressure = "kill";
          ManagedOOMMemoryPressureLimit = "50%";
        };

        services = {
          nix-daemon.serviceConfig = idleConfig;
          nixos-upgrade.serviceConfig = idleConfig;
        };
      };

      nix = {
        daemonCPUSchedPolicy = lib.mkForce "idle"; # The idle policy may greatly improve responsiveness of a system performing expensive builds.
        daemonIOSchedClass = lib.mkForce "idle";
        daemonIOSchedPriority = lib.mkForce 7; # N/A: With "idle", priorities are not used in scheduling decisions. Range 0 (high) to 7 (low). Default 4.
      };
    })
  ];

  imports = [
    # Host unique files
    ../${hostname}/hardware-configuration.nix
    ../${hostname}/host-packages.nix

    # Common stuff
    ./host-packages.nix
    ../../users/default.nix
  ]
  ++ lib.flatten (
    lib.mapAttrsToList (
      username: userVars:
      import ../../users/modules-for-user.nix (
        attrs
        // {
          # Merge attrs and the variables that need to be explicitly imported
          inherit
            commonHostVars
            hostVars
            userVars
            usersVars
            ;
        }
      ) # Pass to the module
    ) usersVars
  ) # For each user, import the module that imports all their programs with their specific vars into a list for the user, and flatten into one big list for all users
  ++ hostVars.enabledImports;
}
