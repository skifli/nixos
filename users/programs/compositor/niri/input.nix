{
  hostVars,
  lib,
  ...
}:
{
  keyboard = {
    repeat-delay = 300;
    repeat-rate = 20;
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
    tap = [];
    dwt = [];
    natural-scroll = [];
  };

  disable-power-key-handling = []; # By default niri takes over the power button and makes it sleep not power off
  warp-mouse-to-focus._props = {
    mode = "center-xy"; # Warps by both X and Y together, so won't warp if it was already somewhere inside the newly focused window
  }; # Enables mouse warping to center of newly focused window
  focus-follows-mouse._props = {
    max-scroll-amount = "5%"; # Won't focus a window if it will result in the view scrolling more than the set amount. The value is a percentage of the working area width.
  }; # Focuses windows and outputs automatically when moving the mouse over them.
  workspace-auto-back-and-forth = []; # With this, switching to the same workspace by index twice will switch back to the previous workspace.
}
// (hostVars.niri.input or {})
