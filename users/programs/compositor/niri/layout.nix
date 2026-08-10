{...}: {
  gaps = 0;
  center-focused-column = "on-overflow";
  # always-center-single-column = [];
  empty-workspace-above-first = false;
  default-column-display = "normal";
  background-color = "transparent"; # CRITICAL as the wallpaper daemon is placed within the backdrop as well so the background colour for workspaces must be transparent to also show the wallpaper

  preset-column-widths._children = [
    {proportion = 0.25;}
    {proportion = 1.0 / 3.0;}
    {proportion = 0.5;}
    {proportion = 2.0 / 3.0;}
    {proportion = 0.75;}
  ];

  # This is a bit unclearly defined in the Wayland protocol, so some clients may misinterpret it. Either way, default-column-width {} is most useful for specific windows, in form of a window rule with the same syntax.
  default-column-width = {};

  preset-window-heights._children = [
    {proportion = 0.25;}
    {proportion = 1.0 / 3.0;}
    {proportion = 0.5;}
    {proportion = 2.0 / 3.0;}
    {proportion = 0.75;}
  ];

  # Disables focus ring
  focus-ring.off = [];

  # Disables window border
  border.off = [];

  # Disables window shadow (manually enabled for floating windows in window-rules.nix)
  shadow.off = [];

  # Enables the tab indicator
  tab-indicator = {
    on = [];
    position = "left";
    hide-when-single-tab = [];
    place-within-column = []; # Otherwise with my config it doesn't show (I think due to struts or smth idk gaps)
    length._props.total-proportion = 1.0; # I do prefer

    urgent-color = "#BF616A";
		active-color = "#F5F5DC";
		inactive-color = "#A3BE8C";
  };

  # Enables the insert hint
  insert-hint.on = [];

  # Screen edge struts
  struts = {
    top = 0;
    left = 0;
    right = 0;
    bottom = 0;
  };
}
