# Live folders: Zen fills the folder with fetched items (RSS feed or GitHub
# queries). Member tabs are browser-owned — only the container and provider
# config are declared. State lands in two files that must share the folder id:
# zen-sessions.jsonlz4 (the sidebar folder row) and zen-live-folders.jsonlz4
# (provider config). The module writes both; runtime state the browser tracks
# (lastFetched, dismissed items, discovered repos) survives re-activation.
#
# GitHub kinds reuse the browser's logged-in github.com session — no token.
# Keep "zen.window-sync.enabled" = true (the default) or Zen may drop the
# entries on restore.
let
  spaces = import ./spaces.nix;
in {
  "Pull requests" = {
    id = "3c682973-4ce0-413c-a836-764fb6bd2aa4";
    kind = "github:pull-requests";
    position = 401;
    workspace = spaces.Example.id;
    github = {
      assignedMe = true; # default
      reviewRequested = true;
      # authorMe = true;
      # repoExcludes = ["owner/noisy-repo"];
    };
  };

  "My issues" = {
    id = "10492fb2-7922-4efd-b0af-ce44a2beebff";
    kind = "github:issues";
    position = 402;
    workspace = spaces.Example.id;
    github.authorMe = true;
  };
}
