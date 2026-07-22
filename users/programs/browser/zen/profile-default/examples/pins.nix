# Pinned tabs with groups, folders, and container assignment
# Pins can be organized in folders and assigned to specific containers/spaces.
#
# ⚠ Only if using pins or pinsForce: close Zen before home-manager switch
# (activation script needs exclusive access to modify zen-sessions.jsonlz4)
let
  containers = import ./containers.nix;
  spaces = import ./spaces.nix;

  folderSpecs = {
    pinnedFolder = {
      id = "00000000-0000-4000-8000-000000000001";
      position = 3000;
      workspace = spaces.Personal.id;
      container = containers.Personal.id;
    };

    pinnedSubFolder = {
      id = "00000000-0000-4000-8000-000000000002";
      parent = "pinnedFolder";
      position = 3001;
      workspace = spaces.Work.id;
      container = containers.Work.id;
    };
  };

  folderIds = builtins.mapAttrs (_: spec: spec.id) folderSpecs;

  mkFolder = spec:
    {
      inherit (spec) id position workspace container;
      isGroup = true;
      isFolderCollapsed = true;
      editedTitle = true;
    }
    // (
      if spec ? parent
      then {folderParentId = folderIds.${spec.parent};}
      else {}
    );

  folders = builtins.mapAttrs (_: mkFolder) folderSpecs;

  pinSpecs = {
    # Container tabs
    homeContainerTab = {
      id = "a1111111-1111-4111-8111-111111111111";
      url = "https://www.google.com/search?q=1";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      position = 2000;
    };

    homeContainerEssentialTab = {
      id = "a2222222-2222-4222-8222-222222222222";
      url = "https://www.google.com/search?q=2";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      isEssential = true;
      position = 2001;
    };

    workContainerTab = {
      id = "a3333333-3333-4333-8333-333333333333";
      url = "https://www.google.com/search?q=3";
      container = containers.Work.id;
      workspace = spaces.Work.id;
      position = 2002;
    };

    workContainerEssentialTab = {
      id = "a4444444-4444-4444-8444-444444444444";
      url = "https://www.google.com/search?q=4";
      container = containers.Work.id;
      workspace = spaces.Work.id;
      isEssential = true;
      position = 2003;
    };

    # Workspace tabs
    homeWorkspaceTab = {
      id = "b1111111-1111-4111-8111-111111111111";
      url = "https://www.google.com/search?q=5";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      position = 2100;
    };

    homeWorkspaceEssentialTab = {
      id = "b2222222-2222-4222-8222-222222222222";
      url = "https://www.google.com/search?q=6";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      isEssential = true;
      position = 2101;
    };

    # Tabs in folders
    pinnedFolderTab = {
      id = "c1111111-1111-4111-8111-111111111111";
      url = "https://www.google.com/search?q=7";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "pinnedFolder";
      position = 2200;
    };

    pinnedSubFolderTab = {
      id = "c2222222-2222-4222-8222-222222222222";
      url = "https://www.google.com/search?q=8";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "pinnedSubFolder";
      position = 2201;
    };

    # Root tabs for joined-tabs example
    joinedExampleTab1 = {
      id = "e1111111-1111-4111-8111-111111111111";
      url = "https://www.google.com/search?q=joined1";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "pinnedFolder";
      position = 2400;
    };

    joinedExampleTab2 = {
      id = "e2222222-2222-4222-8222-222222222222";
      url = "https://www.google.com/search?q=joined2";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      folder = "pinnedFolder";
      position = 2401;
    };

    joinedExampleTab3 = {
      id = "e3333333-3333-4333-8333-333333333333";
      url = "https://www.google.com/search?q=joined3";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      position = 2402;
    };

    joinedExampleTab4 = {
      id = "e4444444-4444-4444-8444-444444444444";
      url = "https://www.google.com/search?q=joined4";
      container = containers.Personal.id;
      workspace = spaces.Personal.id;
      position = 2403;
    };
  };

  mkPin = spec:
    {
      inherit (spec) id position url container workspace;
    }
    // (
      if spec ? folder
      then {
        folderParentId = folderIds.${spec.folder};
      }
      else {}
    )
    // (
      if spec ? isEssential
      then {inherit (spec) isEssential;}
      else {}
    );

  pins = builtins.mapAttrs (_: mkPin) pinSpecs;
in {
  # Folders
  "Pinned Folder" = folders.pinnedFolder;
  "Pinned Sub Folder" = folders.pinnedSubFolder;

  # Pins
  "Home container tab" = pins.homeContainerTab;
  "Home container essential tab" = pins.homeContainerEssentialTab;
  "Work container tab" = pins.workContainerTab;
  "Work container essential tab" = pins.workContainerEssentialTab;
  "Home workspace tab" = pins.homeWorkspaceTab;
  "Home workspace essential tab" = pins.homeWorkspaceEssentialTab;
  "Pinned Folder Tab" = pins.pinnedFolderTab;
  "Pinned Sub Folder Tab" = pins.pinnedSubFolderTab;

  # Joined-tabs example tabs
  "Joined Example Tab 1" = pins.joinedExampleTab1;
  "Joined Example Tab 2" = pins.joinedExampleTab2;
  "Joined Example Tab 3" = pins.joinedExampleTab3;
  "Joined Example Tab 4" = pins.joinedExampleTab4;
}