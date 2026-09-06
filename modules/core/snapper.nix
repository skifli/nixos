{ hostVars, ... }: {
  services.snapper = {
    persistentTimer = true;

    snapshotInterval = "hourly";
    cleanupInterval = "1d";

    configs = hostVars.snapper.configs;
  };

  # Create the required snapshot directories with correct permissions if they do not already exist
  # https://discourse.nixos.org/t/snapper-should-snapshots-subvolumes-be-created-automatically/22329/3
  # 'v' tells systemd-tmpfiles to create a Btrfs subvolume if it does not exist
  systemd.tmpfiles.rules = [
    "v /.snapshots 0750 root root -"
    "v /home/.snapshots 0750 root root -"
  ];
}
