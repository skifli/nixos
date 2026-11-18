{
  hostVars,
  lib,
  ...
}:
{
  keyboard = {
    repeat-delay = 300; # Delay is in milliseconds before the keyboard repeat starts.
    repeat-rate = 20; # Rate is in characters per second.
    xkb = {
      layout = hostVars.keyboardLayout;
    }
    // (lib.optionalAttrs ((hostVars.kbdVariant or "") != "") {
      variant = hostVars.kbdVariant;
    });
  };

  mouse = {
    accel-profile = "adaptive";
  };

  disable-power-key-handling = [ ]; # By default niri takes over the power button and makes it sleep not power off
  # Keep the pointer where the user put it when the SafeEyes guard restores
  # focus. Warping it on every attempted focus change makes the break controls
  # difficult to click. Niri leaves this unset to disable focus warping.
  focus-follows-mouse._props = {
    max-scroll-amount = "10%"; # Won't focus a window if it will result in the view scrolling more than the set amount. The value is a percentage of the working area width.
  }; # Focuses windows and outputs automatically when moving the mouse over them.
  workspace-auto-back-and-forth = [ ]; # With this, switching to the same workspace by index twice will switch back to the previous workspace.
}
// (hostVars.niri.input or { })
