# --------------------------------------------------------------------------
# Folder specs use stable IDs and hierarchy; positions come from pin-order.nix.
# --------------------------------------------------------------------------
let
  containers = import ./containers.nix;
  spaces = import ./spaces.nix;
  positions = import ./positions.nix;
  specs = {
    work_folder = {
      id = "11111111-2222-3333-4444-555555555555";
      workspace = spaces.Work.id;
      container = containers.Work.id;
    };
    work_subfolder = {
      id = "22222222-3333-4444-5555-666666666666";
      parent = "work_folder";
      workspace = spaces.Work.id;
      container = containers.Work.id;
    };
    research_folder = {
      id = "33333333-4444-5555-6666-777777777777";
      workspace = spaces.Research.id;
      container = containers.Research.id;
    };
  };
in
builtins.mapAttrs (name: spec: spec // { position = positions.${name}; }) specs
