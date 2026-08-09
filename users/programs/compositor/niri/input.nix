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

  mouse.accel-profile = "adaptive";

  # Enables mouse warping to focused window/column
  warp-mouse-to-focus = [];

  # Focus follows mouse with max scroll threshold
  focus-follows-mouse._props = {
    max-scroll-amount = "5%";
  };
}
// (hostVars.niri.input or {})
