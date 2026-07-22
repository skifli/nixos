/*
   {
  lib,
  libx,
  ...
}:
*/
_: {
  force = true; # Rewrite bookmarks on each rebuild (overwrite browser changes)
  settings = [
    {
      name = "Bookmarks";
      toolbar = false;
      /*
      bookmarks = let
        mkEntryWithKeywords = {
          name,
          url,
          keywords,
          tags ? [],
        }:
          lib.imap0 (i: kw: {
            name = "${name}-${toString i}";
            keyword = kw;
            url = "${url}#${kw}";
            inherit tags;
          })
          keywords;
      in
      [
        {
          name = "Example Bookmark";
          url = "https://www.example.com";
          keyword = "ex";
          tags = ["example"];
        }
      ]
      ++ (mkEntryWithKeywords {
        name = "docs";
        url = "https://docs.example.com";
        keywords = ["ref" "docs"];
        tags = ["documentation"];
      });
      */
    }
  ];
}
