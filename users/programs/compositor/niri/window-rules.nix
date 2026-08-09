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
  # Block gcr-prompter from screen recordings
  {
    match._props.app-id._raw = ''r#"(?i)gcr-prompter"#'';
    block-out-from = "screen-capture";
  }
  # Blur first browser
  {
    match._props.app-id._raw = ''r#"(?i)${builtins.elemAt userVars.programs.browsers 0}"#'';
    background-effect.blur = true;
    opacity = 0.90;
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
  # Give specifically screencasted windows a custom look
  {
    match._props.is-window-cast-target = true;

    # Stolen from https://github.com/niri-wm/niri/wiki/Configuration:-Window-Rules#is-window-cast-target!
    focus-ring = {
      active-color = "#f38ba8";
      inactive-color = "#7d0d2d";
    };
    border = {
      inactive-color = "#7d0d2d";
    };
    shadow = {
      color = "#7d0d2d70";
    };
    tab-indicator = {
      active-color = "#f38ba8";
      inactive-color = "#7d0d2d";
    };
  }
  # Open urgent windows focused
  {
    match._props.is-urgent = true;
    open-focused = true;
  }
]
++ (userVars.niri.window-rules or [])
