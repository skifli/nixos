{
  pkgs,
  userVars,
  ...
}: let
  nfsShares = userVars.networkMounts.nfsShares or [];

  mkNfsMount = share: {
    device = "${share.server}:${share.remotePath}";
    fsType = "nfs";
    options =
      [
        "_netdev"
        "nofail"
        "auto"
        "x-systemd.automount"
        "x-systemd.after=network-online.target"
        "x-systemd.requires=network-online.target"
        "x-systemd.idle-timeout=600"
        "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=5s"
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

  environment.systemPackages = with pkgs; [
    nfs-utils
  ];

  # Force lazy unmounting of all NFS mounts early during shutdown
  systemd.services.nfs-shutdown-umount = {
    description = "Force unmount NFS filesystems before network shutdown";
    wantedBy = [ "multi-user.target" ];
    # Ensure it runs before network and remote-fs targets are torn down
    before = [ "network.target" "network-online.target" "shutdown.target" ];
    conflicts = [ "shutdown.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # -l is a lazy unmount, -a unmounts all, -t nfs limits to NFS types
      ExecStop = "${pkgs.umount}/bin/umount -l -a -t nfs,nfs4";
      TimeoutStopSec = "10s";
    };
  };
}
