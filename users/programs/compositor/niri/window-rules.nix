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
        softness = 45;
        spread = 6;

        offset._props = {
          x = 0;
          y = 6;
        };
        color = "rgba(0, 0, 0, 0.18)";
      };
      border = {
        on = [];
        width = 1;
        active-color = "rgba(255, 255, 255, 0.08)";
        inactive-color = "rgba(255, 255, 255, 0.03)";
      };

      # Rounded
      clip-to-geometry = true;
      geometry-corner-radius = 10;
    }
    # Swayimg - open centered and floating
    {
      match._props.app-id._raw = ''r#"(?i)swayimg"#'';
      open-floating = true;
      # By default, new floating windows open at the center of the screen, and windows from the tiling layout open close to their visual screen position.
    }
    # Gets the usually centered status window away and not focus it
    {
      match._props.title._raw = ''r#"(?i)(Copying — Dolphin|Progress Dialogue — Dolphin)"#'';
      open-focused = false;
      default-floating-position._props = {
        x = 10;
        y = 10;
        relative-to = "bottom-right";
      };
    }
    # Gets the actually useful requiring-interaction window focused
    {
      match._props.title._raw = ''r#"(?i)Already Exists — Dolphin"#'';
      open-focused = true;
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
