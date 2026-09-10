{ hostVars, lib, ... }: {
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
    # Exclude specifically large dirs from /home snapshots by making them
    # nested subvolumes. btrfs snapshots do NOT recurse into nested subvols,
    # so these paths are treated as empty in every /home snapshot.
  ]
  ++ lib.flatten (
    map (username: [
      "v /home/${username}/.cache 0700 ${username} users -"
      "v /home/${username}/.local/share/Trash 0700 ${username} users -"
      "v /home/${username}/.local/share/Steam 0700 ${username} users -"
      # Electron app profile dirs (huge, high-churn caches). NOTE: anytype's
      # actual note data lives under here too, so it won't be in snapshots.
      "v /home/${username}/.config/Ferdium 0700 ${username} users -"
      "v /home/${username}/.config/anytype 0700 ${username} users -"
    ]) (hostVars.enabledUsers or [ ])
  );
}
