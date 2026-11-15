#!/usr/bin/env bash
set -euo pipefail

mountpoint=/mnt/pifi-private

if mountpoint -q "$mountpoint"; then
  sudo umount "$mountpoint"
fi

# Pifi refuses to close while the NFS client still has the vault mounted or
# files are busy. This keeps the decrypted filesystem intact if unmount fails.
ssh -t root@pifi pifi-private-close-server

echo "Private files are closed."
