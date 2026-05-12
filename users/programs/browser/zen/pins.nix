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
    };

    pinnedSubFolder = {
      id = "00000000-0000-4000-8000-000000000002";
      parent = "pinnedFolder";
      position = 3001;
    };

    plainFolder = {
      id = "00000000-0000-4000-8000-000000000003";
      position = 3100;
    };

    plainSubFolder = {
      id = "00000000-0000-4000-8000-000000000004";
      parent = "plainFolder";
      position = 3101;
    };
  };

  folderIds = builtins.mapAttrs (_: spec: spec.id) folderSpecs;

  mkFolder = spec:
    {
      inherit (spec) id position;
      workspace = spaces.Home.id;
      isGroup = true;
      isFolderCollapsed = false;
      editedTitle = true;
    }
    // (
      if spec ? parent
      then {folderParentId = folderIds.${spec.parent};}
      else {}
    );

  folders = builtins.mapAttrs (_: spec: mkFolder spec) folderSpecs;

  pinSpecs = {
    # Container tabs
    homeContainerTab = {
      id = "a1111111-1111-4111-8111-111111111111";
      url = "https://www.google.com/search?q=1";
      container = containers.Home.id;
      position = 2000;
    };

    homeContainerEssentialTab = {
      id = "a2222222-2222-4222-8222-222222222222";
      url = "https://www.google.com/search?q=2";
      container = containers.Home.id;
      isEssential = true;
      position = 2001;
    };

    workContainerTab = {
      id = "a3333333-3333-4333-8333-333333333333";
      url = "https://www.google.com/search?q=3";
      container = containers.Work.id;
      position = 2002;
    };

    workContainerEssentialTab = {
      id = "a4444444-4444-4444-8444-444444444444";
      url = "https://www.google.com/search?q=4";
      container = containers.Work.id;
      isEssential = true;
      position = 2003;
    };

    # Workspace tabs
    homeWorkspaceTab = {
      id = "b1111111-1111-4111-8111-111111111111";
      url = "https://www.google.com/search?q=5";
      position = 2100;
    };

    homeWorkspaceEssentialTab = {
      id = "b2222222-2222-4222-8222-222222222222";
      url = "https://www.google.com/search?q=6";
      isEssential = true;
      position = 2101;
    };

    # Tabs in folders
    pinnedFolderTab = {
      id = "c1111111-1111-4111-8111-111111111111";
      url = "https://www.google.com/search?q=7";
      folder = "pinnedFolder";
      position = 2200;
    };

    pinnedSubFolderTab = {
      id = "c2222222-2222-4222-8222-222222222222";
      url = "https://www.google.com/search?q=8";
      folder = "pinnedSubFolder";
      position = 2201;
    };

    plainFolderTab = {
      id = "d1111111-1111-4111-8111-111111111111";
      url = "https://www.google.com/search?q=9";
      folder = "plainFolder";
      position = 2300;
    };

    plainSubFolderTab = {
      id = "d2222222-2222-4222-8222-222222222222";
      url = "https://www.google.com/search?q=10";
      folder = "plainSubFolder";
      position = 2301;
    };

    # Root tabs for joined-tabs example
    joinedExampleTab1 = {
      id = "e1111111-1111-4111-8111-111111111111";
      url = "https://www.google.com/search?q=joined1";
      position = 2400;
    };

    joinedExampleTab2 = {
      id = "e2222222-2222-4222-8222-222222222222";
      url = "https://www.google.com/search?q=joined2";
      position = 2401;
    };

    joinedExampleTab3 = {
      id = "e3333333-3333-4333-8333-333333333333";
      url = "https://www.google.com/search?q=joined3";
      position = 2402;
    };

    joinedExampleTab4 = {
      id = "e4444444-4444-4444-8444-444444444444";
      url = "https://www.google.com/search?q=joined4";
      position = 2403;
    };
  };

  mkPin = spec:
    {
      inherit (spec) id position url;
    }
    // (
      if spec ? container
      then {container = spec.container;}
      else {workspace = spaces.Home.id;}
    )
    // (
      if spec ? folder
      then {
        workspace = spaces.Home.id;
        folderParentId = folderIds.${spec.folder};
      }
      else {}
    )
    // (
      if spec ? isEssential
      then {isEssential = true;}
      else {}
    );

  pins = builtins.mapAttrs (_: spec: mkPin spec) pinSpecs;
in {
  # Folders
  "Pinned Folder" = folders.pinnedFolder;
  "Pinned Sub Folder" = folders.pinnedSubFolder;
  "Non-Pinned Folder" = folders.plainFolder;
  "Non-Pinned Sub Folder" = folders.plainSubFolder;

  # Pins
  "Home container tab" = pins.homeContainerTab;
  "Home container essential tab" = pins.homeContainerEssentialTab;
  "Work container tab" = pins.workContainerTab;
  "Work container essential tab" = pins.workContainerEssentialTab;
  "Home workspace tab" = pins.homeWorkspaceTab;
  "Home workspace essential tab" = pins.homeWorkspaceEssentialTab;
  "Pinned Folder Tab" = pins.pinnedFolderTab;
  "Pinned Sub Folder Tab" = pins.pinnedSubFolderTab;
  "Non-Pinned Folder Tab" = pins.plainFolderTab;
  "Non-Pinned Sub Folder Tab" = pins.plainSubFolderTab;

  # Joined-tabs example tabs
  "Joined Example Tab 1" = pins.joinedExampleTab1;
  "Joined Example Tab 2" = pins.joinedExampleTab2;
  "Joined Example Tab 3" = pins.joinedExampleTab3;
  "Joined Example Tab 4" = pins.joinedExampleTab4;
}
