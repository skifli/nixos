{
  hostVars,
  lib,
  ...
}:
{
  keyboard = {
    repeat-delay = 300;
    repeat-rate = 50;
    xkb =
      {
        layout = hostVars.keyboardLayout;
      }
      // (lib.optionalAttrs ((hostVars.kbdVariant or "") != "") {
        variant = hostVars.kbdVariant;
      });
  };

  mouse = {
    accel-profile = "adaptive";
  };

  touchpad = {
    tap = {};
    dwt = {};
    natural-scroll = true;
  };

  # Enables mouse warping to center of newly focused window
  warp-mouse-to-focus = {};

  # Focus follows mouse with max scroll threshold
  focus-follows-mouse = {
    max-scroll-amount = "5%";
  };
}
// (hostVars.niri.input or {})
