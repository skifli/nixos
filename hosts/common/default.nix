{
  hostname,
  lib,
  pkgs,
  ...
}@attrs: # Combine everything passed into here into one variable, attrs (includes not explicitly used variables)

let
  commonHostVars = import ./variables.nix { inherit pkgs; };
  hostVars = import ../${hostname}/variables.nix // {
    inherit hostname;
  }; # Merges hostname with the other config, to more seamlessly combine

  usersVars =
    (import ../../users/variables.nix {
      inherit (hostVars) enabledUsers;
      inherit lib;
    }).usersVars; # Get variables for all users enabled for this host
in
{
  _module.args = { inherit commonHostVars hostVars usersVars; }; # Pass these to future imported modules automagically

  imports = [
    # Host unique files
    ../${hostname}/hardware-configuration.nix
    ../${hostname}/host-packages.nix

    # Common stuff
    ../../users/default.nix
  ]
  ++ lib.flatten (
    lib.mapAttrsToList (
      username: userVars:
      import ../../users/modules-for-user.nix (
        attrs
        // {
          # Merge attrs and the variables that need to be explicitly imported
          inherit
            commonHostVars
            hostVars
            userVars
            usersVars
            ;
        }
      ) # Pass to the module
    ) usersVars
  ) # For each user, import the module that imports all their programs with their specific vars into a list for the user, and flatten into one big list for all users
  ++ hostVars.enabledImports;
}
