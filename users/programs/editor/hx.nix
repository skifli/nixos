{userVars, ...}: {
  home-manager.users.${userVars.username} = {
    xdg.mimeApps.defaultApplications = {
      "text/plain" = "Helix.desktop"; # Unformatted text
      "application/x-shellscript" = "Helix.desktop"; # Shell script file
      "text/x-chdr" = "Helix.desktop"; # C header file
      "text/x-csrc" = "Helix.desktop"; # C file
      "text/x-c++src" = "Helix.desktop"; # C++ file
      "text/x-python" = "Helix.desktop"; # Python file
      "text/x-markdown" = "Helix.desktop"; # Markdown file
      "application/json" = "Helix.desktop"; # JSON file
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
