# Generate monotonically increasing positions from pin-order.nix.
# Add or reorder an entry in its workspace list instead of hand-editing numbers.
let
  ordered = import ./pin-order.nix;
  positionsByWorkspace = builtins.mapAttrs (
    _workspace: keys:
    builtins.listToAttrs (
      builtins.genList (index: {
        name = builtins.elemAt keys index;
        value = index + 1;
      }) (builtins.length keys)
    )
  ) ordered;
in
builtins.foldl' (all: current: all // current) { } (builtins.attrValues positionsByWorkspace)
