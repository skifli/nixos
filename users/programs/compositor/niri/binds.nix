{
  config,
  userVars,
  ...
}:

with config.home-manager.users.${userVars.username}.lib.niri.actions;
{
  "Mod+D" = {
    action = spawn [
      userVars.programs.launcher
      (if userVars.programs.launcher == "vicinae" then "toggle" else "")
    ];
    hotkey-overlay.title = "Application launcher";
  };

  # HELP & OVERVIEW
  "Mod+Slash" = {
    action = show-hotkey-overlay;
    hotkey-overlay.title = "Show keybindings";
  };
  "Mod+Tab" = {
    action = toggle-overview;
    hotkey-overlay.title = "Toggle overview";
  };

  # APPLICATIONS
  "Mod+Return" = {
    action = spawn [
      "app2unit"
      "-T"
    ];
    hotkey-overlay.title = "Terminal";
  };
  "Mod+F" = {
    action = spawn [
      "app2unit"
      userVars.programs.explorer-gui
    ];
    hotkey-overlay.title = "File manager";
  };
  "Mod+V" = {
    action = spawn [
      "app2unit"
      userVars.programs.visual
    ];
    hotkey-overlay.title = "Visual editor";
  };
  "Ctrl+Shift+Escape" = {
    action = spawn [
      "app2unit"
      userVars.programs.system-monitor
    ];
    hotkey-overlay.title = "System monitor";
  };

  # WINDOW MANAGEMENT
  "Mod+Q" = {
    action = close-window;
    hotkey-overlay.title = "Close window";
  };
  "Mod+F11" = {
    action = fullscreen-window;
    hotkey-overlay.title = "Toggle fullscreen";
  };
  "Mod+O" = {
    action = toggle-window-floating;
    hotkey-overlay.title = "Toggle floating";
  };

  # COLUMN MANAGEMENT
  "Mod+Equal" = {
    action = set-column-width "+10%";
    hotkey-overlay.title = "Increase column width";
  };
  "Mod+Minus" = {
    action = set-column-width "-10%";
    hotkey-overlay.title = "Decrease column width";
  };
  "Mod+C" = {
    action = center-column;
    hotkey-overlay.title = "Center column";
  };
  "Mod+M" = {
    action = maximize-column;
    hotkey-overlay.title = "Maximize column";
  };
  "Mod+T" = {
    action = toggle-column-tabbed-display;
    hotkey-overlay.title = "Toggle tabbed view";
  };

  # WINDOW MOVEMENT
  "Mod+Shift+Home" = {
    action = move-column-to-first;
    hotkey-overlay.title = "Move column to first";
  };
  "Mod+Shift+End" = {
    action = move-column-to-last;
    hotkey-overlay.title = "Move column to last";
  };

  "Mod+Shift+H" = {
    action = move-column-left;
    hotkey-overlay.title = "Move column left";
  };
  "Mod+Shift+L" = {
    action = move-column-right;
    hotkey-overlay.title = "Move column right";
  };
  "Mod+Shift+J" = {
    action = move-window-down;
    hotkey-overlay.title = "Move window down";
  };
  "Mod+Shift+K" = {
    action = move-window-up;
    hotkey-overlay.title = "Move window up";
  };

  # FOCUS MOVEMENT (Vim style)
  "Mod+H" = {
    action = focus-column-left;
    hotkey-overlay.title = "Focus left";
  };
  "Mod+J" = {
    action = focus-window-down;
    hotkey-overlay.title = "Focus down";
  };
  "Mod+K" = {
    action = focus-window-up;
    hotkey-overlay.title = "Focus up";
  };
  "Mod+L" = {
    action = focus-column-right;
    hotkey-overlay.title = "Focus right";
  };

  # WORKSPACES
  "Mod+1" = {
    action = focus-workspace "1";
  };
  "Mod+2" = {
    action = focus-workspace "2";
  };
  "Mod+3" = {
    action = focus-workspace "3";
  };
  "Mod+4" = {
    action = focus-workspace "4";
  };
  "Mod+5" = {
    action = focus-workspace "5";
  };
  "Mod+6" = {
    action = focus-workspace "6";
  };
  "Mod+7" = {
    action = focus-workspace "7";
  };
  "Mod+8" = {
    action = focus-workspace "8";
  };

  # LAYOUT
  "Mod+Space" = {
    action = switch-layout "next";
    hotkey-overlay.title = "Next layout";
  };
  "Mod+Shift+Space" = {
    action = switch-layout "prev";
    hotkey-overlay.title = "Previous layout";
  };
  /*
    TODO: Uncomment when flake gets update
    "Alt+Tab".action = next-window;
    "Alt+Shift+Tab".action = previous-window;
    "Alt+grave".action = next-window;
    "Alt+Shift+grave".action = next-window;
  */

  # SYSTEM
  "Mod+Shift+E" = {
    action = quit;
    hotkey-overlay.title = "Exit Niri";
  };

  # SCREENSHOTS
  "Print" = {
    action.screenshot = [ ];
    hotkey-overlay.title = "Screenshot";
  };
  "Shift+Print" = {
    action.screenshot-window = [ ];
    hotkey-overlay.title = "Screenshot window";
  };

  # MEDIA KEYS
  "XF86AudioRaiseVolume" = {
    action = spawn [
      "swayosd-client"
      "--output-volume"
      "2"
    ];
  };
  "XF86AudioLowerVolume" = {
    action = spawn [
      "swayosd-client"
      "--output-volume"
      "-2"
    ];
  };
  "XF86AudioMute" = {
    action = spawn [
      "swayosd-client"
      "--output-volume"
      "mute-toggle"
    ];
  };
  "XF86AudioPlay" = {
    action = spawn [
      "swayosd-client"
      "--playerctl"
      "play-pause"
    ];
  };
  "XF86AudioNext" = {
    action = spawn [
      "swayosd-client"
      "--playerctl"
      "next"
    ];
  };
  "XF86AudioPrev" = {
    action = spawn [
      "swayosd-client"
      "--playerctl"
      "previous"
    ];
  };
  "XF86MonBrightnessUp" = {
    action = spawn [
      "swayosd-client"
      "--brightness"
      "+2"
    ];
  };
  "XF86MonBrightnessDown" = {
    action = spawn [
      "swayosd-client"
      "--brightness"
      "-2"
    ];
  };
}
