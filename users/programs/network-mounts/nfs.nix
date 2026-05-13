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
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "vers=4.2"
      ]
      ++ (share.options or []);
  };
in {
  services.nfs.client.enable = true;

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
