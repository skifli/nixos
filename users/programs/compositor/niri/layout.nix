{...}: {
  gaps = 0;
  background-color = "transparent";
  center-focused-column = "on-overflow";
  always-center-single-column = {};
  empty-workspace-above-first = false;

  default-column-width = {};

  preset-column-widths._children = [
    {proportion = 0.25;}
    {proportion = 1.0 / 3.0;}
    {proportion = 0.5;}
    {proportion = 2.0 / 3.0;}
    {proportion = 0.75;}
  ];

  # Disables window border
  border = {
    off = {};
  };

  # Disables focus ring
  focus-ring = {
    off = {};
  };

  # Enables window shadow
  shadow = {
    draw-behind-window = true;
    softness = 20;
    spread = 5;
    offset = {
      x = 5;
      y = 5;
    };
    color = "#000000aa";
  };

  # Screen edge struts
  struts = {
    top = 0;
    left = 0;
    right = 0;
    bottom = 0;
  };

  tab-indicator = {
    position = "top";
  };
}
