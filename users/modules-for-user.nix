{
  lib,
  userVars,
  ...
}@attrs:

let
  programs = userVars.programs;

  regular = lib.concatMap (
    category:
    lib.optional (
      category != "other" && programs.${category} != "" # Don't get programs specified in the "other" variable, those are handled below
    ) ./programs/${category}/${programs.${category}}.nix
  ) (builtins.attrNames programs); # Get all programs specified in the usual way

  others = map (program: ./programs/${program}.nix) (programs.other or [ ]); # Get all programs specified in the "other" variable

  all = [
    ./${userVars.username}/user-packages.nix
  ]
  ++ lib.optional (userVars.git.enabled) ./programs/git.nix
  ++ regular
  ++ others;

  # Wrap each module so it receives expected args (userVars, pkgs, etc.)
  wrap = path: import path attrs; # attrs captured the entire argument set, including not explicitly listed keys
in
map wrap all # Combine all programs into one big list
