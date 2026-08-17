{
  lib,
  userVars,
  ...
} @ attrs: let
  inherit (userVars) programs;

  # Map plural categories to singular directory names
  categoryDir = cat:
  # Support ones where multiple packages can be installed from a single category, e.g. "browsers" to "browser"
    if cat == "browsers"
    then "browser"
    else cat;

  regular = lib.concatMap (
    category: let
      value = programs.${category};
      dir = categoryDir category;
    in
      if category == "other"
      then []
      else if builtins.isList value
      then map (name: ./programs/${dir}/${name}.nix) value
      else if value != ""
      then [./programs/${dir}/${value}.nix]
      else []
  ) (builtins.attrNames programs); # Get all programs specified in the usual way

  others = map (program: ./programs/misc/${program}.nix) (programs.other or []); # Get all programs specified in the "other" variable

  all = [ ./${userVars.username}/user-packages.nix ]
    ++ lib.optional userVars.git.enabled ./programs/misc/git.nix
    ++ regular
    ++ others;
in
  all
# attrs captured the entire argument set, including not explicitly listed keys
# Combine all programs into one big list

