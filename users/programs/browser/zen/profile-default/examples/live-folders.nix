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
#
# Example shows RSS and GitHub live folders in the Research space.
let
  spaces = import ./spaces.nix;
  # UUIDs are stable identifiers; generate with `uuidgen` or similar.
  # RSS feeds require a valid RSS/Atom URL.
  # GitHub kinds use the browser's logged-in session.
in
{
  "RSS - Tech News" = {
    id = "zen-live-folder-rss-tech-news";
    kind = "rss";
    position = 1;
    workspace = spaces.Research.id;
    rss = {
      url = "https://feeds.arstechnica.com/arstechnica/technology-lab";
      # maxItems = 50;          # default: 50
      # fetchInterval = 900000; # 15 min; omit to let browser manage
    };
  };

  "RSS - Research Papers" = {
    id = "zen-live-folder-rss-research";
    kind = "rss";
    position = 2;
    workspace = spaces.Research.id;
    rss = {
      url = "https://export.arxiv.org/rss/cs.AI";
    };
  };

  "GitHub Pull Requests" = {
    id = "zen-live-folder-github-prs";
    kind = "github:pull-requests";
    position = 3;
    workspace = spaces.Work.id;
    github = {
      assignedMe = true;
      reviewRequested = true;
      authorMe = true;
    };
  };

  "GitHub Issues" = {
    id = "zen-live-folder-github-issues";
    kind = "github:issues";
    position = 4;
    workspace = spaces.Work.id;
    github.authorMe = true;
  };
}
