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
}
