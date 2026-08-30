{
  pkgs,
  userVars,
  ...
}: let
  nfsShares = userVars.networkMounts.nfsShares or [];

  mkNfsMount = share: {
    # The actual device path remains the same
    device = "${share.server}:${share.remotePath}";
    fsType = "nfs";
    options =
      [
        "_netdev"
        "nofail"
        "auto"
        # Swapped network-online.target for tailscale target
        "x-systemd.after=tailscale-online.target"
        "x-systemd.requires=tailscale-online.target"
        "x-systemd.idle-timeout=600"
        "x-systemd.mount-timeout=10s"
        "x-systemd.device-timeout=10s"
        "vers=4.2"
      ]
      ++ (share.options or []);
  };
in {
  fileSystems = builtins.listToAttrs (
    map (share: {
      name = share.mountPoint;
      value = mkNfsMount share;
    })
    nfsShares
  );

  boot.supportedFilesystems = [
    # NFS
    "nfs"
  ];

  services.rpcbind.enable = true; # Needed for NFS
  environment.systemPackages = with pkgs; [nfs-utils];

  # Force lazy unmounting of all NFS mounts early during shutdown
  systemd.services.nfs-shutdown-umount = {
    description = "Force unmount NFS filesystems before network shutdown";
    wantedBy = ["multi-user.target"];
    before = ["network.target" "network-online.target" "shutdown.target" "tailscale-online.target"];
    conflicts = ["shutdown.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # -l is a lazy unmount, -a unmounts all, -t nfs limits to NFS types
      ExecStop = "${pkgs.util-linux}/bin/umount -l -a -t nfs,nfs4";
      TimeoutStopSec = "10s";
    };
  };
}
