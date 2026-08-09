{userVars, ...}:
[
  # Terminal background blur & open maximized
  {
    match._props.app-id._raw = ''r#"(?i)${userVars.programs.terminal}"#'';
    background-effect.blur = [];
    open-maximized = true;
  }
  # Launcher background blur
  {
    match._props.app-id._raw = ''r#"(?i)${userVars.programs.launcher}"#'';
    background-effect.blur = [];
  }
]
++ (userVars.niri.window-rules or [])
