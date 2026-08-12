{userVars, ...}: [
  # Place overview (blurred) background within backdrop
  {
    match._props.namespace = "^awww-daemonoverview$";
    place-within-backdrop = true;
  }
  # Block notifications from screen recordings
  {
    match._props.namespace = "notification";
    # E.g., wayle-notification-popup
    block-out-from = "screen-capture";
    opacity = 0.9; # Makes it a bit nice
  }

  # Blur behind top/overlay layers (launchers, desktop shell)
  {
    match._props = {
      namespace = "^(${userVars.programs.launcher}|${userVars.programs.desktop-shell}.*)$";
      # Needs .* because e.g., wayle-bar-DP-1
      # E.g., vicinae
      layer = "top";
    };
    background-effect.blur = true;
  }
]
