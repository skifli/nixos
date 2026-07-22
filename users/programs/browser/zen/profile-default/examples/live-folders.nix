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
  "My Pull Requests" = {
    id = "zen-live-folder-github-pull-requests";
    kind = "github:pull-requests";
    position = 1;
    workspace = spaces.Example.id;
    github = {
      assignedMe = true; # default
      reviewRequested = true;
      authorMe = true;
      # repoExcludes = ["owner/noisy-repo"];
    };
    # timeRange = 86400000;   # only items from the last 24 h; 0 (default) keeps all
    # fetchInterval = 900000; # 15 min; omit to let the browser manage it
  };

  "My Issues" = {
    id = "zen-live-folder-github-issues";
    kind = "github:issues";
    position = 2;
    workspace = spaces.Example.id;
    github.authorMe = true;
  };
}
