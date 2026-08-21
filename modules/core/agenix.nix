{
  hostVars,
  inputs,
  lib,
  usersVars,
  ...
}: let
  # Location for encrypted secrets tracked in git.
  # Create these with `agenix -e`.
  secretsDir = ../../secrets;

  # Helper for defining a per-host system secret if the encrypted file exists.
  mkHostSecret = hostname: name: extra: let
    file = secretsDir + "/${hostname}/${name}.age";
  in
    lib.mkIf (builtins.pathExists file) {
      "${hostname}-${name}" =
        {
          inherit file;
          owner = "root";
          group = "root";
          mode = "0400";
        }
        // extra;
    };

  # Helper for defining a per-user secret if the encrypted file exists.
  mkUserSecret = username: name: extra: let
    file = secretsDir + "/${username}/${name}.age";
  in
    lib.mkIf (builtins.pathExists file) {
      "${username}-${name}" =
        {
          inherit file;
          owner = username;
          group = "users";
          mode = "0400";
        }
        // extra;
    };

  mkHostSecrets = hostname:
    lib.mkMerge [
      (mkHostSecret hostname "wifi.env" {})
    ];

  mkUserSecrets = username: _userVars:
    lib.mkMerge [
      (mkUserSecret username "hashedPasswordFile" {})

      # Decrypt directly where apps expect them.
      (mkUserSecret username "github-credentials" {
        path = "/home/${username}/.git-credentials";
      })
      (mkUserSecret username "github-pat" {
        path = "/home/${username}/.github-pat";
      })
      (mkUserSecret username "gh-hosts.yml" {
        path = "/home/${username}/.config/gh/hosts.yml";
      })
      (mkUserSecret username "anki-keyFile" {
        path = "/home/${username}/.config/anki-keyFile";
      })
      (mkUserSecret username "anki-usernameFile" {
        path = "/home/${username}/.config/anki-usernameFile";
      })

      # --- Remote Desktop / VNC Secrets ---
      (mkUserSecret username "rdp-pifi-linux" {})
      (mkUserSecret username "rdp-pifi-win" {})
      (mkUserSecret username "vnc-oracle" {})
      (mkUserSecret username "oracle-vnc-key" {})

      # --- Misc ---
      (mkUserSecret username "cachix.dhall" {
        path = "/home/${username}/.config/cachix/cachix.dhall";
        mode = "0600";
      })
    ];

  rescuePasswordSecret =
    lib.mkIf
    (builtins.pathExists (secretsDir + "/rescue/hashedPasswordFile.age"))
    {
      "rescue-hashedPasswordFile" = {
        file = secretsDir + "/rescue/hashedPasswordFile.age";
        owner = "rescue";
        group = "users";
        mode = "0400";
      };
    };

  mkTmpfilesForUser = username: _userVars: [
    "d /home/${username}/.config 0700 ${username} users -"
    "d /home/${username}/.config/gh 0700 ${username} users -"
    "d /home/${username}/.config/cachix 0700 ${username} users -"
  ];
in {
  imports = [inputs.agenix.nixosModules.default];

  age.secrets = lib.mkMerge (
    (lib.mapAttrsToList mkUserSecrets usersVars)
    ++ [(mkHostSecrets hostVars.hostname)]
    ++ [
      (mkHostSecrets hostVars.hostname)
      rescuePasswordSecret
    ]
  );

  systemd.tmpfiles.rules = lib.flatten (lib.mapAttrsToList mkTmpfilesForUser usersVars);
}
