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
  Personal = {
    id = "1f8a6f7c-3b59-4d65-9c1f-0a3e9a6f1b01";
    icon = "🫆";
    position = 1;
    container = containers.Personal.id;
  };

  School = {
    id = "2a7b8c9d-4e6f-5a1b-8c2d-1f9e0a7b2c34";
    icon = "🏫";
    position = 2;
    container = containers.School.id;
  };

  "Stem Racing" = {
    id = "3c9d0e1f-5a2b-6c3d-9e4f-2a1b0c3d4e56";
    icon = "🏎️";
    position = 3;
    container = containers."Stem Racing".id;
  };

  Computing = {
    id = "4e1f2a3b-6c4d-7e5f-0a1b-3c2d4e5f6a78";
    icon = "💻";
    position = 4;
    container = containers.Personal.id;
  };

  /*
     Not needed (for NOW <3!!!)
  Engineering = {
    id = "5f2a3b4c-7d5e-8f6a-1b2c-4d3e5f6a7b89";
    icon = "🛠️";
    position = 5;
    container = containers.Personal.id;
  };
  */
}
