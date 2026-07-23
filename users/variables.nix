{
  hostVars,
  lib,
  ...
}: let
  allUsers = ["ami"];

  # Filter the usernames to keep only allowed ones for this host
  filteredUsers = lib.filter (name: builtins.elem name hostVars.enabledUsers) allUsers;
in {
  usersVars = lib.genAttrs filteredUsers (
    username: 
      (import ./${username}/variables.nix { inherit hostVars lib; }) 
      // { inherit username; }
  );
}