let
  /*
    Public keys (recipients) that can decrypt secrets.

    How to get a key:
    - For a NixOS host identity (recommended for this repo):
      `sudo cat /etc/ssh/ssh_host_ed25519_key.pub`

      Then paste the `ssh-ed25519 ...` line below.

    Notes:
    - This file contains only public keys; it is safe to commit.
    - Add more recipients if you want multiple machines/users to decrypt.
  */
  # Raspberry Pi / pifi
  # pifi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhF6vPHavSoFf/TiQI8fc4rHsplwe7ucGFhX5g/oaMY root@raspberrypi";
  # Desktop / lyra
  lyra = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILLoR4r2C+luZVCcMqfbhKx23YS3MAnZTxgMZzUXoRkl root@lyra";
  fydetabduo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMU8pSmOB4dBX3JwGcgMCmmxVc/iwewNXH9JofEUA+8G root@fydetabduo";

  # Personal key
  ami = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM00chXNLX0Mdss+qEVuYmoIDVgJNY2AqyGIEgn0Z48I ami@lyra";
  fynix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPLjuhLizbbD7biJR6CBnal8duh68uFkC5u78uxEa02Z fynix@fydetabduo";

  /*
    all = [
      pifi
      lyra
      ami
    ];
  */

  # The lyra host must be able to decrypt these during activation.
  # ami is included so the personal key can edit/re-encrypt them.
  amiOnLyra = [
    lyra
    ami
  ];

  # The fydetabduo host must be able to decrypt these during activation.
  # fynix is included so the personal key can edit/re-encrypt them.
  fynixOnFydetabduo = [
    fydetabduo
    fynix
  ];

  # Rescue password is only needed on lyra and fydetab, and ami and fynix for administration.
  rescueRecipients = [
    lyra
    fydetabduo

    ami
    fynix
  ];
  /*
    HOW TO USE:
    1. Run `export RULES="$PWD/secrets/secrets.nix"` in the ROOT of this repository (`nixos`)
    2. Add secret entries to `secrets/secrets.nix` FIRST (ahoy).
    3. Register secrets in `modules/core/agenix.nix` SECOND.
    4. THEN create and edit the encrypted files - e.g., `agenix -e secrets/ami/rdp-pifi-linux.age`
  */
in
{
  # Per host secrets (filenames match secrets/<host>/<name>.age)
  "secrets/lyra/wifi.env.age".publicKeys = amiOnLyra;
  "secrets/fydetabduo/wifi.env.age".publicKeys = fynixOnFydetabduo;
  "secrets/fydetabduo/warp-prefixes.env.age".publicKeys = fynixOnFydetabduo;

  # Per-user secrets (filenames match secrets/<user>/<name>.age)
  "secrets/ami/hashedPasswordFile.age".publicKeys = amiOnLyra;
  "secrets/ami/github-credentials.age".publicKeys = amiOnLyra;
  "secrets/ami/github-pat.age".publicKeys = amiOnLyra;
  "secrets/ami/gh-hosts.yml.age".publicKeys = amiOnLyra;
  "secrets/ami/anki-keyFile.age".publicKeys = amiOnLyra;
  "secrets/ami/anki-usernameFile.age".publicKeys = amiOnLyra;
  "secrets/ami/cachix.dhall.age".publicKeys = amiOnLyra;
  "secrets/ami/rdp-pifi-linux.age".publicKeys = amiOnLyra;
  "secrets/ami/rdp-pifi-win.age".publicKeys = amiOnLyra;
  "secrets/ami/vnc-oracle.age".publicKeys = amiOnLyra;
  "secrets/ami/oracle-vnc-key.age".publicKeys = amiOnLyra;

  "secrets/fynix/hashedPasswordFile.age".publicKeys = fynixOnFydetabduo;
  "secrets/fynix/github-credentials.age".publicKeys = fynixOnFydetabduo;
  "secrets/fynix/github-pat.age".publicKeys = fynixOnFydetabduo;
  "secrets/fynix/gh-hosts.yml.age".publicKeys = fynixOnFydetabduo;
  "secrets/fynix/anki-keyFile.age".publicKeys = fynixOnFydetabduo;
  "secrets/fynix/anki-usernameFile.age".publicKeys = fynixOnFydetabduo;
  "secrets/fynix/cachix.dhall.age".publicKeys = fynixOnFydetabduo;
  "secrets/fynix/rdp-pifi-linux.age".publicKeys = fynixOnFydetabduo;
  "secrets/fynix/rdp-pifi-win.age".publicKeys = fynixOnFydetabduo;
  "secrets/fynix/vnc-oracle.age".publicKeys = fynixOnFydetabduo;
  "secrets/fynix/oracle-vnc-key.age".publicKeys = fynixOnFydetabduo;

  # Misc secrets
  "secrets/rescue/hashedPasswordFile.age".publicKeys = rescueRecipients;
}
