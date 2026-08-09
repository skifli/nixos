{userVars, ...}: [
  # Place background within backdrop
  {
    match._props.namespace = "^awww-daemon$";
    background-effect.blur = true;
    place-within-backdrop = true;
  }
  # Block notifications from screen recordings
  {
    match._props.namespace = "^notifications$";
    block-out-from = "screen-capture";
  }
  # Block GCR prompt from screen recordings
  {
    match._props.namespace = "^(gcr-prompter)$";
    block-out-from = "screen-capture";
  }
  # Blur behind top/overlay layers (launchers, desktop shell)
  {
    match._props = {
      namespace = "^(${userVars.programs.launcher}|${userVars.programs.desktop-shell}.*)$";
      # Needs .* because e.g., wayle-bar-DP-1
      layer = "top";
    };
    background-effect.blur = true;
  }
  # Blur first browser
  {
    match._props = {
      namespace = "^(${builtins.elemAt userVars.programs.browsers 0})$";
    };
    background-effect.blur = true;
    opacity = 0.90;
  }
]
