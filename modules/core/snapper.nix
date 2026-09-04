{ hostVars, ... }: {
  services.snapper = {
    persistentTimer = true;

    snapshotInterval = "hourly";
    cleanupInterval = "1d";

    configs = hostVars.snapper.configs;
  };

  # Create the required snapshot directories with correct permissions if they do not already exist
  # https://discourse.nixos.org/t/snapper-should-snapshots-subvolumes-be-created-automatically/22329/3
  systemd.tmpfiles.rules = [
    "d /.snapshots 0750 root root -"
    "d /home/.snapshots 0750 root root -"
  ];
}
