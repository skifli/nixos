# Pinned tabs with groups, folders, and container assignment
# Pins can be organized in folders and assigned to specific containers/spaces.
#
# ⚠ Only if using pins or pinsForce: close Zen before home-manager switch
# (activation script needs exclusive access to modify zen-sessions.jsonlz4)
let
  pinSpecs = import ./pin-specs.nix;
  folderSpecs = import ./folder-specs.nix;

  folderIds = builtins.mapAttrs (_: spec: spec.id) folderSpecs;

  mkFolder =
    spec:
    {
      inherit (spec)
        id
        position
        workspace
        container
        ;
      isGroup = true;
      isFolderCollapsed = true;
      editedTitle = true;
    }
    // (if spec ? parent then { folderParentId = folderIds.${spec.parent}; } else { });

  folders = builtins.mapAttrs (_: mkFolder) folderSpecs;

  mkPin =
    spec:
    {
      inherit (spec)
        id
        position
        url
        container
        workspace
        ;
    }
    // (
      if spec ? folder then
        {
          folderParentId = folderIds.${spec.folder};
        }
      else
        { }
    )
    // (if spec ? isEssential then { inherit (spec) isEssential; } else { });

  pins = builtins.mapAttrs (_: mkPin) pinSpecs;
in
{
  # Folders
  "Work Folder" = folders.work_folder;
  "Work Subfolder" = folders.work_subfolder;
  "Research Folder" = folders.research_folder;

  # Pins
  "Personal Home" = pins.personal_home;
  "Personal Docs" = pins.personal_docs;
  "Work Dashboard" = pins.work_dashboard;
  "Work GitHub" = pins.work_github;
  "Work Folder GitHub" = pins.work_folder_github;
  "Work Subfolder PRs" = pins.work_subfolder_prs;
  "Research Papers" = pins.research_papers;
  "Research Folder arXiv" = pins.research_folder_arxiv;
}
