{
  commonHostVars,
  config,
  hostVars,
  pkgs,
  userVars,
  ...
} @ attrs: let
  binds = import ./binds.nix attrs;
  input = import ./input.nix attrs;
  layerRules = import ./layer-rules.nix attrs;
  layout = import ./layout.nix attrs;
  windowRules = import ./window-rules.nix attrs;

  outputs = map (name:
    {
      _args = [name];
      inherit (hostVars.outputs.${name}) mode scale;
      position._props = hostVars.outputs.${name}.position;
      # TODO - Did this cause the weird white lines on my second monitor in the overview :eyes:?
      # variable-refresh-rate._props = {on-demand = true;};
    }
    // (pkgs.lib.optionalAttrs (hostVars.outputs.${name}.focus-at-startup or false) {
      focus-at-startup = [];
    }))
  hostVars.orderedOutputs;

  workspaces = map (name: {
    _args = [name];
    inherit (hostVars.workspaces.${name}) open-on-output;
  }) (builtins.attrNames hostVars.workspaces);
in {
  # Top-level stuff
  inherit input layout;
  binds = binds // userVars.niri.binds;
  layer-rule = layerRules;
  output = outputs;
  window-rule = windowRules;
  workspace = workspaces;

  spawn-sh-at-startup = userVars.niri.spawn-sh-at-startup;

  prefer-no-csd = [];

  cursor = {
    xcursor-theme = config.home-manager.users.${userVars.username}.stylix.cursor.name;
    xcursor-size = commonHostVars.cursor.size;
  };

  # Overview configuration
  overview = {
    zoom = 0.25;

    # Workspace shadows are configured for a workspace size normalized to 1080 pixels tall, then zoomed out together with the workspace. Practically, this means that you'll want bigger spread, offset, and softness compared to window shadows.
    workspace-shadow = {
      on = [];
      softness = 40;
      spread = 10;
      offset._props = {
        x = 0;
        y = 10;
      };
      color = "#00000050";
    };
  };

  xwayland-satellite = [];

  clipboard.disable-primary = [];

  hotkey-overlay = {
    skip-at-startup = [];
    hide-not-bound = [];
  };

  blur = {
    on = [];
    passes = 5;
    offset = 1;
    noise = 0.02;
    saturation = 1.0;
  };

  gestures.hot-corners.off = [];

  # Animation settings (empty list [] = parameterless KDL flag/node)
  animations = {
    config-notification-open-close = [];
    exit-confirmation-open-close = [];
    screenshot-ui-open = [];
    recent-windows-close = [];
    horizontal-view-movement = [];
    overview-open-close = [];
    window-close = [];
    window-movement = [];
    window-open = [];
    window-resize = [];
    workspace-switch.off = [];
  };

  # Alt-Tab recent-windows configuration
  recent-windows = {
    open-delay-ms = 0;
    debounce-ms = 750;

    previews = {
      max-scale = 0.5;
    };

    binds = {
      "Alt+Tab" = {next-window = [];};
      "Alt+Shift+Tab" = {previous-window = [];};
      # Can also do e.g., filter="app-id";, or for scope "all" or "workspace"
      "Alt+grave" = {
        next-window._props = {scope = "output";};
      };
      "Alt+Shift+grave" = {
        previous-window._props = {scope = "output";};
      };
    };
  };
}
