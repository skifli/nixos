# Space routing: rules that send a URL to a specific space when a tab opens,
# plus a global default for links opened from outside the browser. State lands
# in zen-space-routing.jsonlz4, independent of the session file. Undeclared
# routes Zen created are preserved unless `force = true`; runtime edits to a
# declared route are overwritten on re-activation.
#
# `openIn` / `defaultExternalRoute` take a space id or the literal
# "most-recent-space". A space id is brace-wrapped internally to match Zen's
# workspace uuid — declare it here without braces, exactly like `pins.workspace`.
#
# matchType options: "contains" (default), "regex", "startsWith", "endsWith", "equals"
let
  spaces = import ./spaces.nix;
in
{
  # Link previews / external opens with no matching rule land here.
  defaultExternalRoute = "most-recent-space";

  routes = {
    "github" = {
      reference = "github.com";
      matchType = "contains";
      openIn = spaces.Work.id;
    };

    "github-prs" = {
      reference = "https?://github\\.com/.*/pull/\\d+";
      matchType = "regex";
      openIn = spaces.Work.id;
    };

    "arxiv" = {
      reference = "arxiv.org";
      matchType = "contains";
      openIn = spaces.Research.id;
    };

    "docs" = {
      reference = "docs.";
      matchType = "startsWith";
      openIn = spaces.Personal.id;
    };
  };
}
# Space-scoped form: same options as spaceRouting.routes.* except openIn,
# which is set to the owning space's id automatically. Only `reference` is
# required; `matchType` defaults to "contains" and `id` defaults to the
# attribute name (namespaced per space, so equal names don't collide).
/*
  spaces = {
    "Personal" = {
      id = personalID;

      routes."Personal Docs" = {
        reference = "docs."; # matchType = "startsWith"
      };
    };
    "Work" = {
      id = workID;

      routes."GitHub" = {
        reference = "github.com"; # matchType = "contains"
      };
    };
    "Research" = {
      id = researchID;

      routes."arXiv" = {
        reference = "arxiv.org"; # matchType = "contains"
      };
    };
  };
*/
