{
  commonHostVars,
  hostVars,
  lib,
  pkgs,
  ...
}:
let
  allUsers = [
    "ami"
    "fynix"
  ];

  # Filter the usernames to keep only allowed ones for this host
  filteredUsers = lib.filter (name: builtins.elem name hostVars.enabledUsers) allUsers;
in
{
  usersVars = lib.genAttrs filteredUsers (
    username:
    (import ./${username}/variables.nix {
      inherit
        commonHostVars
        hostVars
        lib
        pkgs
        username
        ;
    })
    // {
      inherit username;
    }
  );
}
