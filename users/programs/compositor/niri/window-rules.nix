{userVars, ...}: [
  {
    match._props.app-id._raw = ''r#"(?i)${userVars.programs.terminal}"#'';
    background-effect = {
      blur = [];
    };
  }
  {
    match._props.app-id._raw = ''r#"(?i)${userVars.programs.terminal}"#'';
    open-maximized = true;
  }
  {
    match._props.app-id._raw = ''r#"(?i)${userVars.programs.launcher}"#'';
    background-effect = {
      blur = [];
    };
  }
]
++ (userVars.niri.window-rules or [])

