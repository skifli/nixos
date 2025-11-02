{ userVars, ... }:

{
  home-manager.users.${userVars.username} = {
    xdg.mimeApps.defaultApplications = {
      "text/plain" = ""; # Unformatted text
      "application/x-shellscript" = ""; # Shell script file
      "text/x-chdr" = ""; # C header file
      "text/x-csrc" = ""; # C file
      "text/x-c++src" = ""; # C++ file
      "text/x-python" = ""; # Python file
      "text/x-markdown" = ""; # Markdown file
      "application/json" = ""; # JSON file
    };

    programs.helix = {
      enable = true;
      settings = {
        editor = {
          line-number = "absolute";
        };
      };
    };
  };
}
