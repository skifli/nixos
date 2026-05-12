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
  Home = {
    id = "1f8a6f7c-3b59-4d65-9c1f-0a3e9a6f1b01";
    icon = "🏠";
    position = 1000;
    container = containers.Home.id;
  };

  Work = {
    id = "2a7b8c9d-4e6f-5a1b-8c2d-1f9e0a7b2c34";
    icon = "💼";
    position = 2000;
    container = containers.Home.id;
  };
}
