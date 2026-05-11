# Joined tabs create Zen split-view groups.
# Use the stable tab IDs from declared pins.
let
  pins = import ./pins.nix;

  mkJoinedTabs = builtins.mapAttrs (_: spec: {
    id = spec.id;
    gridType = spec.gridType;
    tabs = map (pinName: pins.${pinName}.id) spec.tabs;
  });
in
mkJoinedTabs {
  "Example joined tabs vertical" = {
    id = "example-joined-tabs";
    gridType = "vesp";
    tabs = [
      "Joined Example Tab 1"
      "Joined Example Tab 2"
    ];
  };

  "Example joined tabs horizontal" = {
    id = "example-joined-tabs-hesp";
    gridType = "hesp";
    tabs = [
      "Joined Example Tab 3"
      "Joined Example Tab 4"
    ];
  };
}