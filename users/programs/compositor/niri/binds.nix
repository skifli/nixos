{
  config,
  pkgs,
  userVars,
  ...
}:

with config.home-manager.users.${userVars.username}.lib.niri.actions;
let
  brightnessctl = spawn "${pkgs.brightnessctl}/bin/brightnessctl";
  pamixer = spawn "${pkgs.pamixer}/bin/pamixer";
  playerctl = spawn "${pkgs.playerctl}/bin/playerctl";
in
{
  # Applications
  "Mod+B" = {
    action = spawn ''sh -c "$BROWSER"'';
  };
  "Mod+E" = {
    action = spawn ''sh -c "$EDITOR"'';
  };
  "Mod+F" = {
    action = spawn ''sh -c "$EXPLORER"'';
  };
  "Mod+T" = {
    action = spawn ''sh -c "$TERMINAL"'';
  };

  # Window management
  "Mod+Q" = {
    action = close-window;
  };
  "Mod+W" = {
    action = toggle-window-floating;
  };
  "Alt+Return" = {
    action = fullscreen-window;
  };

  # Workspace navigation
  "Mod+1" = {
    action = focus-workspace 1;
  };
  "Mod+2" = {
    action = focus-workspace 2;
  };
  "Mod+3" = {
    action = focus-workspace 3;
  };
  "Mod+4" = {
    action = focus-workspace 4;
  };
  "Mod+5" = {
    action = focus-workspace 5;
  };
  "Mod+6" = {
    action = focus-workspace 6;
  };
  "Mod+7" = {
    action = focus-workspace 7;
  };
  "Mod+8" = {
    action = focus-workspace 8;
  };
  "Mod+9" = {
    action = focus-workspace 9;
  };
  "Mod+0" = {
    action = focus-workspace 10;
  };

  # Move windows to workspaces
  "Mod+Shift+1" = {
    action = move-column-to-index 1;
  };
  "Mod+Shift+2" = {
    action = move-column-to-index 2;
  };
  "Mod+Shift+3" = {
    action = move-column-to-index 3;
  };
  "Mod+Shift+4" = {
    action = move-column-to-index 4;
  };
  "Mod+Shift+5" = {
    action = move-column-to-index 5;
  };
  "Mod+Shift+6" = {
    action = move-column-to-index 6;
  };
  "Mod+Shift+7" = {
    action = move-column-to-index 7;
  };
  "Mod+Shift+8" = {
    action = move-column-to-index 8;
  };
  "Mod+Shift+9" = {
    action = move-column-to-index 9;
  };
  "Mod+Shift+0" = {
    action = move-column-to-index 10;
  };

  # Focus movement
  "Mod+Left" = {
    action = focus-column-left;
  };
  "Mod+Right" = {
    action = focus-column-right;
  };
  "Mod+Up" = {
    action = focus-window-up;
  };
  "Mod+Down" = {
    action = focus-window-down;
  };

  # Media keys
  "XF86AudioRaiseVolume" = {
    action = pamixer "-i" "2";
  };
  "XF86AudioLowerVolume" = {
    action = pamixer "-d" "2";
  };
  "XF86AudioMute" = {
    action = pamixer "-t";
  };
  "XF86AudioPlay" = {
    action = playerctl "play-pause";
  };
  "XF86AudioNext" = {
    action = playerctl "next";
  };
  "XF86AudioPrev" = {
    action = playerctl "previous";
  };

  # Brightness
  "XF86MonBrightnessUp" = {
    action = brightnessctl "set" "+2%";
  };
  "XF86MonBrightnessDown" = {
    action = brightnessctl "set" "2%-";
  };
}
