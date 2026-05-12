{ inputs, lib, usersVars, ... }:

let
  # Location for encrypted secrets tracked in git.
  # Create these with `agenix -e`.
  secretsDir = ../../secrets;

  # Helper for defining a per-user secret if the encrypted file exists.
  mkUserSecret =
    username: name: extra:
    let
      file = secretsDir + "/${username}/${name}.age";
    in
    lib.mkIf (builtins.pathExists file) {
      "${username}-${name}" = {
        inherit file;
        owner = username;
        group = "users";
        mode = "0400";
      } // extra;
    };

  mkUserSecrets = username: _userVars:
    lib.mkMerge [
      (mkUserSecret username "hashedPasswordFile" { })

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
    ];

  mkTmpfilesForUser = username: _userVars: [
    "d /home/${username}/.config 0700 ${username} users -"
    "d /home/${username}/.config/gh 0700 ${username} users -"
  ];
in
{
  imports = [ inputs.agenix.nixosModules.default ];

  age.secrets = lib.mkMerge (lib.mapAttrsToList mkUserSecrets usersVars);

  systemd.tmpfiles.rules = lib.flatten (lib.mapAttrsToList mkTmpfilesForUser usersVars);
}
