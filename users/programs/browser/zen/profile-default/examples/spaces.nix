# Zen Spaces with custom gradient themes
# Spaces are workspaces for organizing tabs across different contexts.
# ⚠ Only if using spaces or spacesForce: close Zen before home-manager switch
# (activation script decompresses zen-sessions.jsonlz4, modifies with jq, recompresses)
#
# Note: Changing a space's id re-creates it as new, losing opened tabs.
# If spacesForce = true, the old space is deleted.
let
  containers = import ./containers.nix;
in {
  Example = {
    id = "5e76f9c8-00c0-4443-a6ae-d239879bb1d5"; 
    icon = "📚";
    position = 1;
    container = containers.Example.id;
  };
}
