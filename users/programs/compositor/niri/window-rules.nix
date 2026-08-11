{userVars, ...}: let
  # Map over all browsers to generate for each blur and layout rules
  browserRules =
    builtins.map (browser: {
      match._props.app-id._raw = ''r#"(?i)${browser}"#'';
      background-effect = {
        blur = true;
        noise = 0.01;
        saturation = 1.1;
      };
      open-maximized = true;
    })
    userVars.programs.browsers;
in
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
    # Open urgent windows focused and give them a prominent glow
    {
      match._props.is-urgent = true;
      open-focused = true;
      focus-ring = {
        active-color = "#f38ba8";
        inactive-color = "#f38ba8";
      };
      border = {
        active-color = "#f38ba8";
        inactive-color = "#f38ba8";
      };
      tab-indicator = {
        active-color = "#f38ba8";
        inactive-color = "#f38ba8";
        urgent-color = "#f38ba8";
      };
    }
  ]
  ++ browserRules
  ++ (userVars.niri.window-rules or [])
