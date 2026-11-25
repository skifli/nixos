#!/usr/bin/env bash
set -euo pipefail

mountpoint=/mnt/pifi-private
icon="$HOME/.local/share/misc/niri-icon.svg"

notify() {
  local urgency="$1" title="$2" body="$3"
  notify-send -e -t 8000 -a "Private Vault" -i "$icon" -u "$urgency" "$title" "$body" \
    >/dev/null 2>&1 || true
}

if ! sudo -v; then
  notify critical "Vault not closed" "Could not authenticate to unmount the local share."
  exit 1
fi

if mountpoint -q "$mountpoint"; then
  source="$(findmnt -n -o SOURCE --target "$mountpoint" || true)"
  fstype="$(findmnt -n -o FSTYPE --target "$mountpoint" || true)"
  if [[ "$fstype" != nfs* || "$source" != pifi:/private* ]]; then
    echo "Refusing to unmount unrelated filesystem at $mountpoint ($source, $fstype)." >&2
    notify critical "Vault not closed" "Refused to unmount an unrelated filesystem at $mountpoint."
    exit 1
  fi
  if ! sudo umount "$mountpoint"; then
    notify critical "Vault still in use" "Close files and file-manager windows inside the vault, then try again."
    exit 1
  fi
fi

notify low "Closing private vault" "We are unmounted; asking Pifi to lock the encrypted image."

# The local NFS unmount can complete before Pifi's NFS server releases its
# final references. Retry the server close briefly; it preserves the lease if
# the remote filesystem is still busy.
last_output=""
for attempt in 1 2 3; do
  if last_output="$(ssh -o BatchMode=yes -o ConnectTimeout=8 root@pifi pifi-private-close-server 2>&1)"; then
    printf '%s\n' "$last_output"
    case "$last_output" in
      *"Private vault closed."*)
        notify low "Private vault closed" "The image is unmounted and locked on Pifi."
        ;;
      *"vault remains open for "*)
        notify low "This device disconnected" "$last_output"
        ;;
      *"already closed."*)
        notify low "Private vault closed" "Pifi confirms the image is already locked."
        ;;
      *)
        notify low "Vault close complete" "$last_output"
        ;;
    esac
    exit 0
  fi

  printf '%s\n' "$last_output" >&2
  if [[ "$attempt" -lt 3 ]]; then
    sleep 1
  fi
done

notify critical "Pifi may still have the vault open" \
  "We unmounted, but Pifi did not confirm the image was locked. Retry Close private vault and check its notification."
echo "Pifi did not confirm that the private vault was closed after three attempts." >&2
exit 1
