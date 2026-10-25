# This file contains hardware-specific filesystem and boot layout for the FydeTab Duo.
# It was generated specifically for this eMMC install by fydetab-install-to-emmc.
# YOU GENERALLY DO NOT NEED TO EDIT THIS FILE - IF YOU ARE BE CAREFUL.
#
# Uses PARTUUIDs to avoid ambiguity when multiple devices share the same
# filesystem labels (e.g., microSD + eMMC both flashed with the same image).
{ lib, ... }: {
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  fileSystems."/" = {
    device = "/dev/disk/by-partuuid/02b0351d-8715-40ac-91d3-91990351eb68";
    fsType = "btrfs";
    options = [ "x-systemd.growfs" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partuuid/20757645-b9ed-4735-9331-e828a3ddfefa";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/snapshots" = {
    device = "/dev/disk/by-partuuid/02b0351d-8715-40ac-91d3-91990351eb68";
    fsType = "btrfs";
    options = [ "subvolid=5" ];
  };

  boot.growPartition = true;
}
