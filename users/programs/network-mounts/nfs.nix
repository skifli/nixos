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
      # A dead NFS server must not D-state the whole desktop:
      # - automount only mounts on first access and makes idle-timeout work
      # - timeo=20 is 2s per retransmission, so soft failures surface in ~6s
      # - keep a finite mount timeout instead of letting mount jobs run forever
      options = [
        "_netdev"
        "nofail"
        "auto"
        "soft"
        "timeo=20"
        "retrans=2"
        "x-systemd.after=tailscale-online.target"
        "x-systemd.wants=tailscale-online.target"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "x-systemd.mount-timeout=30s"
        "x-systemd.device-timeout=30s"
      ]
      ++ (share.options or [ ]);
    };
in
{
  # Dolphin's KIO NFS worker uses mount.nfs for user-initiated nfs:// mounts.
  # Nix store files cannot carry setuid bits, so provide the standard runtime
  # wrapper required by mount.nfs for these user mounts.
  security.wrappers."mount.nfs" = {
    source = "${pkgs.nfs-utils}/bin/mount.nfs";
    setuid = true;
  };

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

  systemd.services.nfs-shutdown-umount = {
    description = "Force unmount NFS filesystems before network shutdown";
    wantedBy = [ "umount.target" ];
    before = [ "umount.target" ];
    unitConfig = {
      DefaultDependencies = false;
    };
    serviceConfig = {
      Type = "oneshot";
      # -l is a lazy unmount, -a unmounts all, -t nfs limits to NFS types
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.util-linux}/bin/umount -l -a -t nfs,nfs4 || true'";
      TimeoutStartSec = "10s";
    };
  };
}
