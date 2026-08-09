{
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
      inherit (hostVars.outputs.${name}) mode;
      position._props = hostVars.outputs.${name}.position;
    }
    // (pkgs.lib.optionalAttrs (hostVars.outputs.${name}.focus-at-startup or false) {
      focus-at-startup = [];
    })) (builtins.attrNames hostVars.outputs);

  workspaces = map (name: {
    _args = [name];
    inherit (hostVars.workspaces.${name}) open-on-output;
  }) (builtins.attrNames hostVars.workspaces);
in {
  # Top-level stuff
  inherit binds input layout;
  layer-rule = layerRules;
  output = outputs;
  window-rule = windowRules;
  workspace = workspaces;

  spawn-sh-at-startup = userVars.niri.spawn-sh-at-startup;

  prefer-no-csd = [];
  hotkey-overlay.skip-at-startup = [];

  xwayland-satellite = [];

  gestures.hot-corners.off = [];
  clipboard.disable-primary = [];

  # Animation settings (empty list [] = parameterless KDL flag/node)
  animations = {
    config-notification-open-close = [];
    exit-confirmation-open-close = [];
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
    debounce-delay-ms = 100;
    preview-size._props.natural = 256;
    gap._props.natural = 16;
  };

  # Overview configuration
  overview = {
    zoom = 0.5;
    prefer-centered-preview = [];
  };
}
