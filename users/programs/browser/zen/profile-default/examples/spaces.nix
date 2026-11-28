# Zen Spaces with custom gradient themes
# Spaces are workspaces for organizing tabs across different contexts.
# ⚠ Only if using spaces or spacesForce: close Zen before home-manager switch
# (activation script decompresses zen-sessions.jsonlz4, modifies with jq, recompresses)
#
# Note: Changing a space's id re-creates it as new, losing opened tabs.
# If spacesForce = true, the old space is deleted.
let
  containers = import ./containers.nix;
in
{
  Personal = {
    id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee";
    icon = "🏠";
    position = 1;
    container = containers.Personal.id;
  };

  Work = {
    id = "bbbbbbbb-cccc-dddd-eeee-ffffffffffff";
    icon = "💼";
    position = 2;
    container = containers.Work.id;
  };

  Research = {
    id = "cccccccc-dddd-eeee-ffff-000000000000";
    icon = "🔬";
    position = 3;
    container = containers.Research.id;
  };
}
