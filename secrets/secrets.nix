let
  # Public keys (recipients) that can decrypt secrets.
  #
  # How to get a key:
  # - For a NixOS host identity (recommended for this repo):
  #   `sudo cat /etc/ssh/ssh_host_ed25519_key.pub`
  #
  # Then paste the `ssh-ed25519 ...` line below.
  #
  # Notes:
  # - This file contains only public keys; it is safe to commit.
  # - Add more recipients if you want multiple machines/users to decrypt.
  # Raspberry Pi / pifi
  pifi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhF6vPHavSoFf/TiQI8fc4rHsplwe7ucGFhX5g/oaMY root@raspberrypi";

  # Desktop / lyra
  lyra = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILLoR4r2C+luZVCcMqfbhKx23YS3MAnZTxgMZzUXoRkl root@lyra";

  # Personal key
  ami = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM00chXNLX0Mdss+qEVuYmoIDVgJNY2AqyGIEgn0Z48I ami@lyra";

  all = [
    pifi
    lyra
    ami
  ];
  /*
  HOW TO USE:
  1. Add secret entries to `secrets/secrets.nix` FIRST (ahoy).
  2. Register secrets in `modules/core/agenix.nix` SECOND.
  3. THEN create and edit the encrypted files - e.g., `agenix -e secrets/ami/rdp-pifi-linux.age`
  */
in {
  # Per-user secrets (filenames match secrets/<user>/<name>.age)
  "secrets/ami/hashedPasswordFile.age".publicKeys = all;
  "secrets/ami/github-credentials.age".publicKeys = all;
  "secrets/ami/github-pat.age".publicKeys = all;
  "secrets/ami/gh-hosts.yml.age".publicKeys = all;
  "secrets/ami/anki-keyFile.age".publicKeys = all;
  "secrets/ami/anki-usernameFile.age".publicKeys = all;

  # --- Remote Desktop / VNC Secrets ---
  "secrets/ami/rdp-pifi-linux.age".publicKeys = all;
  "secrets/ami/rdp-pifi-win.age".publicKeys = all;
  "secrets/ami/vnc-oracle.age".publicKeys = all;
  "secrets/ami/oracle-vnc-key.age".publicKeys = all;
}
