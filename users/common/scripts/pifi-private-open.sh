#!/usr/bin/env bash
set -euo pipefail

mountpoint=/mnt/pifi-private

# Authenticate before waiting on the remote vault passphrase. Otherwise a
# slow unlock can let sudo's timestamp expire and trigger a second prompt.
sudo -v

sudo install -d -m 0755 "$mountpoint"

if mountpoint -q "$mountpoint"; then
  source="$(findmnt -n -o SOURCE --target "$mountpoint" || true)"
  fstype="$(findmnt -n -o FSTYPE --target "$mountpoint" || true)"
  if [[ "$fstype" != nfs* || "$source" != pifi:/private* ]]; then
    echo "$mountpoint is already occupied by an unrelated mount ($source, $fstype)." >&2
    exit 1
  fi
fi

if [[ ! -t 0 ]]; then
  echo "Run pifi-private-open from a terminal so SSH can prompt for the vault passphrase." >&2
  exit 1
fi

# The passphrase prompt comes from cryptsetup on Pifi and is carried by this
# interactive SSH session. It is not stored locally or passed in a command.
ssh -t root@pifi pifi-private-open-server

if ! mountpoint -q "$mountpoint"; then
  if ! sudo mount -t nfs -o rw,soft,timeo=20,retrans=2 pifi:/private "$mountpoint"; then
    echo "Local mount failed; releasing this client's Pifi lease." >&2
    ssh -t root@pifi pifi-private-close-server || true
    exit 1
  fi
fi

if ! timeout 8 ls -A "$mountpoint" >/dev/null; then
  echo "The NFS mount exists but Pifi is not responding to reads. Close this client lease and retry." >&2
  exit 1
fi

echo "Private files are available at $mountpoint."
xdg-open "$mountpoint" >/dev/null 2>&1 &
