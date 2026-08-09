{userVars, ...}: [
  # Block notifications from screen recordings
  {
    match._props = {
      namespace = "^notifications$";
    };
    block-out-from = "screen-capture";
  }
  # Block GCR prompt from screen recordings
  {
    match._props = {
      namespace = "^(gcr-prompter)$";
    };
    block-out-from = "screen-capture";
  }
  # Blur behind top/overlay layers (launchers, desktop shell)
  {
    match._props = {
      namespace = "^(${userVars.programs.launcher}|${userVars.programs.desktop-shell}.*)$";
      layer = "top";
    };
    background-effect = {
      blur = {};
    };
  }
]
