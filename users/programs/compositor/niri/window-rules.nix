{userVars, ...}:
[
  # Give floating windows a shadow
  {
    match._props.is-floating = true;
    shadow = {
      on = [];
      softness = 20;
      spread = 4;

      offset._props = {
        x = 0;
        y = 4;
      };
      color = "rgba(0, 0, 0, 0.5)";
    };
  }
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
  # Browser open 1st maximized
  {
    match._props.app-id._raw = ''r#"(?i)${builtins.elemAt userVars.programs.browsers 0}"#'';
    open-maximized = true;
  }
  # Explorer GUI open maximized
  {
    match._props.app-id._raw = ''r#"(?i)${userVars.programs.explorer-gui}"#'';
    open-maximized = true;
  }
  # Remote desktop open maximized
  {
    match._props.app-id._raw = ''r#"(?i)${userVars.programs.remote-desktop}"#'';
    open-maximized = true;
  }
  # System monitor open maximized
  {
    match._props.app-id._raw = ''r#"(?i)${userVars.programs.system-monitor}"#'';
    open-maximized = true;
  }
]
++ (userVars.niri.window-rules or [])
