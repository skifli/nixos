{
  hostVars,
  inputs,
  pkgs,
  ...
}: let
  settings = import ./settings.nix {inherit hostVars;};
  bookmarks = import ./bookmarks.nix;
  search = import ./search.nix {inherit pkgs;};
  containers = import ./containers.nix;
  pins = import ./pins.nix;
  joinedTabs = import ./joined-tabs.nix;
  spaces = import ./spaces.nix;
  mods = import ./mods.nix;

  keyboardShortcutsSpec = import ./keyboard-shortcuts.nix;
  extraConfig = import ./extra-config.nix {inherit inputs;};

  profileId = 0;
  profileName = "default";
in {
  id = profileId;
  name = profileName;
  isDefault = true;

  containersForce = true; # Delete containers not declared in ./containers.nix

  pinsForce = true;
  pinsForceAction = "demote"; # Keep undeclared pins as normal tabs

  spacesForce = true; # Delete spaces not declared in ./spaces.nix

  inherit
    settings
    bookmarks
    search
    containers
    pins
    joinedTabs
    spaces
    mods
    ;

  keyboardShortcuts = keyboardShortcutsSpec.keyboardShortcuts;
  keyboardShortcutsVersion = keyboardShortcutsSpec.keyboardShortcutsVersion;

  sine = {
    # Disabled due to buggy and not (yet) documented:
    # https://github.com/0xc000022070/zen-browser-flake/issues/237
    enable = false;
  };

  inherit extraConfig;
}
