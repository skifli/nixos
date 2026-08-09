{userVars, ...}:
[
  # Terminal background blur
  {
    match.app-id = "(?i)${userVars.programs.terminal}";
    background-effect = {
      blur = {};
    };
  }
  # Terminal open maximized
  {
    match.app-id = "(?i)${userVars.programs.terminal}";
    open-maximized = true;
  }
  # Launcher background blur
  {
    match.app-id = "(?i)${userVars.programs.launcher}";
    background-effect = {
      blur = {};
    };
  }
]
++ (userVars.niri.window-rules or [])