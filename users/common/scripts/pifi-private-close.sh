#!/usr/bin/env bash
set -euo pipefail

mountpoint=/mnt/pifi-private

sudo -v

if mountpoint -q "$mountpoint"; then
  source="$(findmnt -n -o SOURCE --target "$mountpoint" || true)"
  fstype="$(findmnt -n -o FSTYPE --target "$mountpoint" || true)"
  if [[ "$fstype" != nfs* || "$source" != pifi:/private* ]]; then
    echo "Refusing to unmount unrelated filesystem at $mountpoint ($source, $fstype)." >&2
    exit 1
  fi
  sudo umount "$mountpoint"
fi

# Pifi refuses to close while the NFS client still has the vault mounted or
# files are busy. This keeps the decrypted filesystem intact if unmount fails.
ssh -t root@pifi pifi-private-close-server

echo "Private files are closed."
