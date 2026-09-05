{
  pkgs,
  userVars,
  ...
}:
let
  nfsShares = userVars.networkMounts.nfsShares or [ ];

  mkNfsMount =
    share:
    let
      sanitizedServer = builtins.replaceStrings [ " " ] [ "" ] share.server;

      # Escape spaces in the remote path for compatibility (\040)
      escapedPath = builtins.replaceStrings [ " " ] [ "\\040" ] share.remotePath;
    in
    {
      device = "${sanitizedServer}:${escapedPath}";
      fsType = "nfs";
      options = [
        "_netdev"
        "nofail"
        "auto"
        "x-systemd.after=tailscale-online.target"
        "x-systemd.wants=tailscale-online.target"
        "x-systemd.idle-timeout=600"
        "x-systemd.mount-timeout=30s"
        "x-systemd.device-timeout=30s"
      ]
      ++ (share.options or [ ]);
    };
in
{
  fileSystems = builtins.listToAttrs (
    map (share: {
      name = share.mountPoint;
      value = mkNfsMount share;
    }) nfsShares
  );

  boot.supportedFilesystems = [
    # NFS
    "nfs"
  ];

  services.rpcbind.enable = true; # Needed for NFS
  environment.systemPackages = with pkgs; [ nfs-utils ];

  # Force lazy unmounting of all NFS mounts early during shutdown
  systemd.services.nfs-shutdown-umount = {
    description = "Force unmount NFS filesystems before network shutdown";
    wantedBy = [ "multi-user.target" ];
    # Start after the network/filesystems are available, so on shutdown this
    # service is stopped before those dependencies get kaboomed.
    after = [
      "network.target"
      "remote-fs.target"
      "tailscale-online.target"
    ];
    before = [
      "shutdown.target"
      "umount.target"
    ];
    conflicts = [
      "shutdown.target"
      "umount.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # -l is a lazy unmount, -a unmounts all, -t nfs limits to NFS types
      ExecStop = "${pkgs.bash}/bin/bash -c '${pkgs.util-linux}/bin/umount -l -a -t nfs,nfs4 || true'";
      TimeoutStopSec = "10s";
    };
  };
}
