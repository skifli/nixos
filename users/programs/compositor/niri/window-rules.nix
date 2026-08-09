{userVars, ...}:
[
  # Terminal background blur
  {
    match._props.app-id = "(?i)${userVars.programs.terminal}";
    background-effect = {
      blur = {};
    };
  }
  # Terminal open maximized
  {
    match._props.app-id = "(?i)${userVars.programs.terminal}";
    open-maximized = true;
  }
  # Launcher background blur
  {
    match._props.app-id = "(?i)${userVars.programs.launcher}";
    background-effect = {
      blur = {};
    };
  }
]
++ (userVars.niri.window-rules or [])
