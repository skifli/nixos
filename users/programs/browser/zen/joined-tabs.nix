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
  mkJoinedTabs {}
