{
  hostVars,
  lib,
  ...
}: {
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
  warp-mouse-to-focus.enable = true;

  focus-follows-mouse = {
    enable = true;
    max-scroll-amount = "5%";
  };
}
// (hostVars.niri.input or {})

