# Generic Zen pin structure
let
  containers = import ./containers.nix;
  spaces = import ./spaces.nix;
in
{
  # Folder examples
  # Add more folders by copying one of these blocks and changing the names/ids.

  "Example Home Folder" = {
    id = "00000000-0000-4000-8000-000000000001";
    workspace = spaces.Home.id;
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1000;
  };

  "Example Child Folder" = {
    id = "00000000-0000-4000-8000-000000000002";
    workspace = spaces.Home.id;
    folderParentId = "00000000-0000-4000-8000-000000000001";
    isGroup = true;
    isFolderCollapsed = true;
    editedTitle = true;
    position = 1001;
  };

  # Pin examples
  # Use either workspace or container depending on how you want Zen to file the page.

  "Example Workspace Pin" = {
    id = "00000000-0000-4000-8000-000000000010";
    url = "https://example.com/";
    workspace = spaces.Home.id;
    position = 2000;
  };

  "Example Folder Pin" = {
    id = "00000000-0000-4000-8000-000000000011";
    url = "https://example.com/docs";
    workspace = spaces.Home.id;
    folderParentId = "00000000-0000-4000-8000-000000000001";
    position = 2001;
  };

  "Example Container Pin" = {
    id = "00000000-0000-4000-8000-000000000012";
    url = "https://example.com/work";
    container = containers.Home.id;
    position = 2002;
  };
}
