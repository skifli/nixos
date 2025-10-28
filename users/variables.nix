{ enabledUsers, lib, ... }:

let
  allUsers = [ "ami" ];

  # Filter the usernames to keep only allowed ones for this host
  filteredUsers = lib.filter (name: builtins.elem name enabledUsers) allUsers;
in
{
  # Import variables for each user
  usersVars = lib.genAttrs filteredUsers (
    username: (import ./${username}/variables.nix) // { inherit username; } # // Merges username with the other config, to more seamlessly combine
  );
}
