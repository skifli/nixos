{userVars, ...}:
[
  # Terminal background blur & open maximized
  {
    match._props.app-id._raw = ''r#"(?i)${userVars.programs.terminal}"#'';
    background-effect.blur = true;
    open-maximized = true;
  }
  # Launcher background blur
  {
    match._props.app-id._raw = ''r#"(?i)${userVars.programs.launcher}"#'';
    background-effect.blur = true;
  }
  # Browser background blur
  {
    match._props.app-id._raw = ''r#"(?i)${builtins.elemAt userVars.programs.browsers 0}"#'';
    background-effect.blur = true;
  }
]
++ (userVars.niri.window-rules or [])
