# Joined tabs create Zen split-view groups.
# Use the stable tab IDs from declared pins.
let
  pins = import ./pins.nix;

  mkJoinedTabs = builtins.mapAttrs (
    _: spec: {
      inherit (spec) id gridType;
      tabs = map (pinName: pins.${pinName}.id) spec.tabs;
    }
  );
in
  mkJoinedTabs {
    "Example joined tabs vertical" = {
      id = "example-joined-tabs";
      folderParentId = pins.folderSpecs."Some folder".id;
      gridType = "vsep";
      tabs = [
        "Joined Example Tab 1"
        "Joined Example Tab 2"
      ];
    };

    "Example joined tabs horizontal" = {
      id = "example-joined-tabs-hesp";
      folderParentId = pins.folderSpecs."Some folder".id;
      gridType = "hsep";
      tabs = [
        "Joined Example Tab 3"
        "Joined Example Tab 4"
      ];
    };
  }
