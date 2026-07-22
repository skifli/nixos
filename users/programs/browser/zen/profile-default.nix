{
  hostVars,
  inputs,
  pkgs,
  ...
}: let
  settings = import ./profile-default/settings.nix {inherit hostVars;};
  bookmarks = import ./profile-default/bookmarks.nix;
  search = import ./profile-default/search.nix {inherit pkgs;};
  containers = import ./profile-default/hidden/containers.nix;
  pins = import ./profile-default/hidden/pins.nix;
  liveFolders = import ./profile-default/hidden/live-folders.nix;
  joinedTabs = import ./profile-default/joined-tabs.nix;
  presets = import ./profile-default/presets.nix;
  spaces = import ./profile-default/hidden/spaces.nix;
  spaceRouting = import ./profile-default/hidden/space-routing.nix;
  mods = import ./profile-default/mods.nix;

  keyboardShortcutsSpec = import ./profile-default/keyboard-shortcuts.nix;
  extraConfig = import ./profile-default/extra-config.nix {inherit inputs;};

  profileId = 0;
  profileName = "default";
in {
  id = profileId;
  name = profileName;
  isDefault = true;

  containersForce = true; # Delete containers not declared in ./hidden/containers.nix

  pinsForce = true;
  pinsForceAction = "demote"; # Keep undeclared pins as normal tabs

  spacesForce = true; # Delete spaces not declared in ./hidden/spaces.nix

  inherit
    settings
    bookmarks
    search
    containers
    pins
    joinedTabs
    presets
    spaces
    spaceRouting
    liveFolders
    mods
    ;

  inherit (keyboardShortcutsSpec) keyboardShortcuts keyboardShortcutsVersion;

  sine = {
    # Disabled due to buggy and not (yet) documented:
    # https://github.com/0xc000022070/zen-browser-flake/issues/237
    enable = false;
  };

  inherit extraConfig;
}
