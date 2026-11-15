#!/usr/bin/env bash
set -euo pipefail

mountpoint=/mnt/pifi-private

if [[ ! -t 0 ]]; then
  echo "Run pifi-private-open from a terminal so SSH can prompt for the vault passphrase." >&2
  exit 1
fi

# The passphrase prompt comes from cryptsetup on Pifi and is carried by this
# interactive SSH session. It is not stored locally or passed in a command.
ssh -t root@pifi pifi-private-open-server

sudo install -d -m 0755 "$mountpoint"
if ! sudo mount -t nfs -o rw,soft,timeo=20,retrans=2 pifi:/private "$mountpoint"; then
  echo "Local mount failed; closing the temporary Pifi export." >&2
  ssh -t root@pifi pifi-private-close-server || true
  exit 1
fi

echo "Private files are available at $mountpoint."
