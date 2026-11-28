# Pin specs define individual pin specifications (url, container, workspace, folder, isEssential)
# Each spec gets its position from positions.nix (which reads from pin-order.nix)
let
  containers = import ./containers.nix;
  spaces = import ./spaces.nix;
  positions = import ./positions.nix;
  specs = {
    # Personal Space
    personal_home = {
      id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeee1";
      url = "https://example.com";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      isEssential = true;
    };
    personal_docs = {
      id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeee2";
      url = "https://docs.example.com";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      isEssential = true;
    };

    # Work Space
    work_dashboard = {
      id = "bbbbbbbb-cccc-dddd-eeee-fffffffffff1";
      url = "https://dashboard.example.com";
      container = containers.Work.id;
      workspace = spaces.Work.id;
      isEssential = true;
    };
    work_github = {
      id = "bbbbbbbb-cccc-dddd-eeee-fffffffffff2";
      url = "https://github.com";
      container = containers.Work.id;
      workspace = spaces.Work.id;
    };
    work_folder_github = {
      id = "bbbbbbbb-cccc-dddd-eeee-fffffffffff3";
      url = "https://github.com/example";
      container = containers.Work.id;
      workspace = spaces.Work.id;
      folder = "work_folder";
    };
    work_subfolder_prs = {
      id = "bbbbbbbb-cccc-dddd-eeee-fffffffffff4";
      url = "https://github.com/example/pulls";
      container = containers.Work.id;
      workspace = spaces.Work.id;
      folder = "work_subfolder";
    };

    # Research Space
    research_papers = {
      id = "cccccccc-dddd-eeee-ffff-000000000001";
      url = "https://scholar.google.com";
      container = containers.Research.id;
      workspace = spaces.Research.id;
    };
    research_folder_arxiv = {
      id = "cccccccc-dddd-eeee-ffff-000000000002";
      url = "https://arxiv.org";
      container = containers.Research.id;
      workspace = spaces.Research.id;
      folder = "research_folder";
    };
  };
in
builtins.mapAttrs (name: spec: spec // { position = positions.${name}; }) specs
