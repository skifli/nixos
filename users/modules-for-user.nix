{
  lib,
  userVars,
  ...
} @ attrs: let
  inherit (userVars) programs;

  requireModulePath = kind: path:
    if builtins.pathExists path
    then path
    else throw "Missing ${kind} module for user '${userVars.username}': ${toString path}";

  categoryDirFor = category:
    if builtins.pathExists (./programs/${category})
    then category
    else if lib.hasSuffix "s" category && builtins.pathExists (./programs/${lib.removeSuffix "s" category})
    then lib.removeSuffix "s" category
    else category;

  mkProgramModulePath = category: name:
    requireModulePath "program" ./programs/${categoryDirFor category}/${name}.nix;

  regular = lib.concatMap (
    category: let
      value = programs.${category};
    in
      if category == "other"
      then []
      else if builtins.isList value
      then map (name: mkProgramModulePath category name) value
      else if value != ""
      then [(mkProgramModulePath category value)]
      else []
  ) (builtins.attrNames programs); # Get all programs specified in the usual way

  others = map (program: requireModulePath "other" ./programs/${program}.nix) (programs.other or []); # Get all programs specified in the "other" variable

  all =
    [
      (requireModulePath "user-packages" ./${userVars.username}/user-packages.nix)
    ]
    ++ lib.optional userVars.git.enabled ./programs/git.nix
    ++ regular
    ++ others;

  # Wrap each module so it receives expected args (userVars, pkgs, etc.)
  wrap = path: import path attrs; # attrs captured the entire argument set, including not explicitly listed keys
in
  map wrap all
# Combine all programs into one big list

