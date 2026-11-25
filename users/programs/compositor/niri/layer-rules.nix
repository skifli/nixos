{ userVars, ... }: [
  # Place overview (blurred) background within backdrop
  {
    match._props.namespace = "^awww-daemonoverview$";
    place-within-backdrop = true;
  }
  # Block notifications from screen recordings, but keep them in screenshots.
  # "screen-capture" would make LumineCapture/grim render them as black
  # rectangles; "screencast" only blocks xdg-desktop-portal recordings (OBS).
  {
    match._props.namespace = "notification";
    # E.g., wayle-notification-popup
    block-out-from = "screencast";
    opacity = 0.9; # Makes it a bit nice
  }
  /*
    Overlay layer:
      Surface:
        Namespace: "launcher"
        Keyboard interactivity: exclusive

    This is for FUZZEL
  */
  {
    match._props = {
      # just match only "launcher" like the string nothing else
      namespace = "^launcher$";
      layer = "overlay";
    };
    opacity = 0.9;
  }

  # Keep launcher blur when it uses the overlay layer above fullscreen apps.
  {
    match._props.namespace = "^${userVars.programs.launcher}$";
    background-effect.blur = true;
  }
  # Blur behind the desktop shell while it remains on the top layer.
  {
    match._props = {
      namespace = "^${userVars.programs.desktop-shell}.*$";
      # Needs .* because e.g., wayle-bar-DP-1
      layer = "top";
    };
    background-effect.blur = true;
  }
]
