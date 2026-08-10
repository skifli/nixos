{
  pkgs,
  userVars,
  ...
}: {
  "Mod+Escape" = {
    _props.hotkey-overlay-title = "Toggle keyboard shortcuts inhibit";
    toggle-keyboard-shortcuts-inhibit = [];
  };

  # APPLICATION LAUNCHER
  "Mod+D" = {
    _props = {
      hotkey-overlay-title = "Application launcher";
      allow-inhibiting = false;
    };
    spawn =
      [userVars.programs.launcher]
      ++ pkgs.lib.optional (userVars.programs.launcher == "vicinae") "toggle";
  };

  # HELP & OVERVIEW
  "Mod+Slash" = {
    _props = {
      hotkey-overlay-title = "Show keybindings overlay";
      allow-inhibiting = false;
    };
    show-hotkey-overlay = [];
  };
  "Mod+Tab" = {
    _props = {
      hotkey-overlay-title = "Toggle smart overview";
      allow-inhibiting = false;
    };
    spawn = ["/home/${userVars.username}/.local/bin/smart-overview.sh"];
  };
  "Mod+Shift+Tab" = {
    _props = {
      allow-inhibiting = false;
    };
    toggle-overview = [];
  };

  # APPLICATIONS
  "Mod+Return" = {
    _props = {
      hotkey-overlay-title = "Terminal";
      allow-inhibiting = false;
    };
    spawn =
      if userVars.programs.terminal == "ghostty"
      then ["ghostty" "+new-window"]
      else [userVars.programs.terminal];
  };
  "Mod+F" = {
    _props = {
      hotkey-overlay-title = "File manager (GUI)";
      allow-inhibiting = false;
    };
    spawn = [userVars.programs.explorer-gui];
  };
  "Mod+Shift+F" = {
    _props = {
      hotkey-overlay-title = "File manager (TUI)";
      allow-inhibiting = false;
    };
    spawn = [
      userVars.programs.terminal
      "-e"
      userVars.programs.explorer-tui
    ];
  };
  "Mod+V" = {
    _props = {
      hotkey-overlay-title = "Visual editor";
      allow-inhibiting = false;
    };
    spawn = [userVars.programs.visual];
  };
  "Mod+E" = {
    _props = {
      hotkey-overlay-title = "Text editor";
      allow-inhibiting = false;
    };
    spawn = [userVars.programs.editor];
  };
  "Ctrl+Shift+Escape" = {
    _props.allow-inhibiting = false;
    spawn = [userVars.programs.system-monitor];
  };
  "Shift+Escape" = {
    _props.allow-inhibiting = false;
    spawn = [
      userVars.programs.terminal
      "-e"
      "btop"
    ];
  };

  # WINDOW MANAGEMENT
  "Mod+Q" = {
    _props = {
      hotkey-overlay-title = "Close current window";
      repeat = false;
      allow-inhibiting = false;
    };
    close-window = [];
  };
  "Mod+Ctrl+Q" = {
    _props = {
      repeat = false;
      allow-inhibiting = false;
    };
    spawn = "killclick";
  };
  "Mod+Shift+Q" = {
    _props = {
      repeat = false;
      allow-inhibiting = false;
    };
    spawn = "killcurrent";
  };
  "Mod+F11" = {
    _props = {
      hotkey-overlay-title = "Toggle fullscreen";
      allow-inhibiting = false;
    };
    fullscreen-window = [];
  };
  "Mod+Shift+F11" = {
    _props = {
      hotkey-overlay-title = "Toggle windowed fullscreen";
      allow-inhibiting = false;
    };
    toggle-windowed-fullscreen = [];
  };
  "Mod+O" = {
    _props = {
      hotkey-overlay-title = "Toggle floating window";
      allow-inhibiting = false;
    };
    toggle-window-floating = [];
  };

  # COLUMN MANAGEMENT
  "Mod+Equal" = {
    _props.allow-inhibiting = false;
    set-column-width = "+10%";
  };
  "Mod+Minus" = {
    _props.allow-inhibiting = false;
    set-column-width = "-10%";
  };
  "Mod+C" = {
    _props.allow-inhibiting = false;
    center-column = [];
  };
  "Mod+M" = {
    _props.allow-inhibiting = false;
    maximize-column = [];
  };
  "Mod+Ctrl+M" = {
    _props.allow-inhibiting = false;
    maximize-window-to-edges = [];
  };
  "Mod+W" = {
    _props.hotkey-overlay-title = "Toggle tabbed column view";
    allow-inhibiting = false;
    toggle-column-tabbed-display = [];
  };
  "Mod+R" = {
    _props.allow-inhibiting = false;
    switch-preset-column-width = [];
  };
  "Mod+Shift+R" = {
    _props.allow-inhibiting = false;
    switch-preset-column-width-back = [];
  };
  "Mod+Ctrl+R" = {
    _props.allow-inhibiting = false;
    switch-preset-window-height = [];
  };
  "Mod+Ctrl+Shift+R" = {
    _props.allow-inhibiting = false;
    switch-preset-window-height-back = [];
  };

  # WINDOW MOVEMENT (Vim H/J/K/L & Arrows)
  "Mod+Shift+Home" = {
    _props.allow-inhibiting = false;
    move-column-to-first = [];
  };
  "Mod+Shift+End" = {
    _props.allow-inhibiting = false;
    move-column-to-last = [];
  };

  "Mod+Shift+H" = {
    _props.allow-inhibiting = false;
    move-column-left = [];
  };
  "Mod+Shift+Left" = {
    _props.allow-inhibiting = false;
    move-column-left = [];
  };
  "Mod+Shift+L" = {
    _props.allow-inhibiting = false;
    move-column-right = [];
  };
  "Mod+Shift+Right" = {
    _props.allow-inhibiting = false;
    move-column-right = [];
  };
  "Mod+Shift+J" = {
    _props.allow-inhibiting = false;
    move-window-down = [];
  };
  "Mod+Shift+Down" = {
    _props.allow-inhibiting = false;
    move-window-down = [];
  };
  "Mod+Shift+K" = {
    _props.allow-inhibiting = false;
    move-window-up = [];
  };
  "Mod+Shift+Up" = {
    _props.allow-inhibiting = false;
    move-window-up = [];
  };
  "Mod+Comma" = {
    _props.allow-inhibiting = false;
    consume-window-into-column = [];
  };
  "Mod+Period" = {
    _props.allow-inhibiting = false;
    expel-window-from-column = [];
  };

  # FOCUS MOVEMENT (Columns & Stacked Windows)
  "Mod+H" = {
    _props.allow-inhibiting = false;
    focus-column-left = [];
  };
  "Mod+Left" = {
    _props.allow-inhibiting = false;
    focus-column-left = [];
  };
  "Mod+L" = {
    _props.allow-inhibiting = false;
    focus-column-right = [];
  };
  "Mod+Right" = {
    _props.allow-inhibiting = false;
    focus-column-right = [];
  };
  "Mod+J" = {
    _props.allow-inhibiting = false;
    focus-window-down = [];
  };
  "Mod+Down" = {
    _props.allow-inhibiting = false;
    focus-window-down = [];
  };
  "Mod+K" = {
    _props.allow-inhibiting = false;
    focus-window-up = [];
  };
  "Mod+Up" = {
    _props.allow-inhibiting = false;
    focus-window-up = [];
  };
  "Mod+Shift+WheelScrollDown" = {
    _props = {
      cooldown-ms = userVars.scroll-cooldown-ms;
      allow-inhibiting = false;
    };
    focus-column-right = [];
  };
  "Mod+Shift+WheelScrollUp" = {
    _props = {
      cooldown-ms = userVars.scroll-cooldown-ms;
      allow-inhibiting = false;
    };
    focus-column-left = [];
  };

  # WORKSPACE NAVIGATION (Keyboard + Scroll + Arrows)
  "Mod+Ctrl+J" = {
    _props.allow-inhibiting = false;
    focus-workspace-down = [];
  };
  "Mod+Ctrl+Down" = {
    _props.allow-inhibiting = false;
    focus-workspace-down = [];
  };
  "Mod+Ctrl+K" = {
    _props.allow-inhibiting = false;
    focus-workspace-up = [];
  };
  "Mod+Ctrl+Up" = {
    _props.allow-inhibiting = false;
    focus-workspace-up = [];
  };
  "Mod+WheelScrollDown" = {
    _props = {
      cooldown-ms = userVars.scroll-cooldown-ms;
      allow-inhibiting = false;
    };
    focus-workspace-down = [];
  };
  "Mod+WheelScrollUp" = {
    _props = {
      cooldown-ms = userVars.scroll-cooldown-ms;
      allow-inhibiting = false;
    };
    focus-workspace-up = [];
  };

  "Mod+Ctrl+Shift+J" = {
    _props.allow-inhibiting = false;
    move-column-to-workspace-down = [];
  };
  "Mod+Ctrl+Shift+Down" = {
    _props.allow-inhibiting = false;
    move-column-to-workspace-down = [];
  };
  "Mod+Ctrl+Shift+K" = {
    _props.allow-inhibiting = false;
    move-column-to-workspace-up = [];
  };
  "Mod+Ctrl+Shift+Up" = {
    _props.allow-inhibiting = false;
    move-column-to-workspace-up = [];
  };
  "Mod+Ctrl+WheelScrollDown" = {
    _props = {
      cooldown-ms = userVars.scroll-cooldown-ms;
      allow-inhibiting = false;
    };
    move-column-to-workspace-down = [];
  };
  "Mod+Ctrl+WheelScrollUp" = {
    _props = {
      cooldown-ms = userVars.scroll-cooldown-ms;
      allow-inhibiting = false;
    };
    move-column-to-workspace-up = [];
  };

  # Monitor Navigation
  "Mod+1" = {
    _props = {
      allow-inhibiting = false;
    };
    focus-monitor-left = [];
  };
  "Mod+2" = {
    _props = {
      allow-inhibiting = false;
    };
    focus-monitor-right = [];
  };
  "Mod+Alt+H" = {
    _props.allow-inhibiting = false;
    focus-monitor-left = [];
  };
  "Mod+Alt+Left" = {
    _props.allow-inhibiting = false;
    focus-monitor-left = [];
  };
  "Mod+Alt+L" = {
    _props.allow-inhibiting = false;
    focus-monitor-right = [];
  };
  "Mod+Alt+Right" = {
    _props.allow-inhibiting = false;
    focus-monitor-right = [];
  };

  # DIRECT WORKSPACE JUMPING 1..8
  "Mod+Shift+1" = {
    _props = {
      hotkey-overlay-title = "Focus workspace 1(-8)";
      allow-inhibiting = false;
    };
    focus-workspace = "1";
  };
  "Mod+Shift+2" = {
    _props.allow-inhibiting = false;
    focus-workspace = "2";
  };
  "Mod+Shift+3" = {
    _props.allow-inhibiting = false;
    focus-workspace = "3";
  };
  "Mod+Shift+4" = {
    _props.allow-inhibiting = false;
    focus-workspace = "4";
  };
  "Mod+Shift+5" = {
    _props.allow-inhibiting = false;
    focus-workspace = "5";
  };
  "Mod+Shift+6" = {
    _props.allow-inhibiting = false;
    focus-workspace = "6";
  };
  "Mod+Shift+7" = {
    _props.allow-inhibiting = false;
    focus-workspace = "7";
  };
  "Mod+Shift+8" = {
    _props.allow-inhibiting = false;
    focus-workspace = "8";
  };

  # LAYOUT
  "Mod+Space" = {
    _props.allow-inhibiting = false;
    switch-layout = "next";
  };
  "Mod+Shift+Space" = {
    _props.allow-inhibiting = false;
    switch-layout = "prev";
  };

  # SYSTEM
  "Mod+Shift+E" = {
    _props.hotkey-overlay-title = "Exit Niri compositor";
    quit = [];
  };

  # SCREENSHOTS
  "Print" = {
    _props = {
      hotkey-overlay-title = "Take screenshot";
      allow-inhibiting = false;
    };
    screenshot = [];
  };
  "Shift+Print" = {
    _props.allow-inhibiting = false;
    screenshot-window = [];
  };
  "Ctrl+Print" = {
    _props.allow-inhibiting = false;
    spawn = ["normcap"];
  };

  # MEDIA KEYS
  "XF86AudioRaiseVolume" = {
    _props.allow-inhibiting = false;
    spawn = ["wayle" "audio" "output-volume" "+2"];
  };
  "XF86AudioLowerVolume" = {
    _props.allow-inhibiting = false;
    spawn = ["wayle" "audio" "output-volume" "-2"];
  };
  "XF86AudioMute" = {
    _props.allow-inhibiting = false;
    spawn = ["wayle" "audio" "output-mute"];
  };
  "XF86AudioMicMute" = {
    _props.allow-inhibiting = false;
    spawn = ["wayle" "audio" "input-mute"];
  };

  "XF86AudioPlay" = {
    _props.allow-inhibiting = false;
    spawn = ["wayle" "media" "play-pause"];
  };
  "XF86AudioNext" = {
    _props.allow-inhibiting = false;
    spawn = ["wayle" "media" "next"];
  };
  "XF86AudioPrev" = {
    _props.allow-inhibiting = false;
    spawn = ["wayle" "media" "previous"];
  };

  # NIRIUS - SCRATCHPAD
  "Mod+P" = {
    _props = {
      hotkey-overlay-title = "Park/unpark window (scratchpad toggle)";
      allow-inhibiting = false;
    };
    spawn = [
      "sh"
      "-c"
      "nirius scratchpad-toggle && list=\$(nirius list-scratchpad | awk -F', ' '/app-id:/{delete m; for(i=1;i<=NF;i++){split(\$i,a,\": \"); gsub(/Some\\(\"|\"\\)|Some\\(|\\)|None/,\"\",a[2]); m[a[1]]=a[2]} print m[\"on workspace\"] \"\\t• \" m[\"app-id\"] \" — \" m[\"title\"] \" (WS \" m[\"on workspace\"] \")\"}' | sort -n | cut -f2-) && if [ -z \"\$list\" ]; then list='No scratchpad windows'; fi && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 2500 'Scratchpad Windows' \"\$list\""
    ];
  };
  "Mod+Shift+P" = {
    _props = {
      hotkey-overlay-title = "Show/cycle scratchpad window";
      allow-inhibiting = false;
    };
    spawn = [
      "sh"
      "-c"
      "nirius scratchpad-show && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 2500 'Scratchpad' 'Cycled active scratchpad window'"
    ];
  };
  "Mod+Ctrl+P" = {
    _props = {
      hotkey-overlay-title = "Show/hide all scratchpad windows";
      allow-inhibiting = false;
    };
    spawn = [
      "sh"
      "-c"
      "nirius scratchpad-show-all && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 2500 'Scratchpad' 'Toggled all hidden scratchpad windows'"
    ];
  };
  "Mod+Alt+P" = {
    _props = {
      hotkey-overlay-title = "List scratchpad windows";
      allow-inhibiting = false;
    };
    spawn = [
      "sh"
      "-c"
      "list=\$(nirius list-scratchpad | awk -F', ' '/app-id:/{delete m; for(i=1;i<=NF;i++){split(\$i,a,\": \"); gsub(/Some\\(\"|\"\\)|Some\\(|\\)|None/,\"\",a[2]); m[a[1]]=a[2]} print m[\"on workspace\"] \"\\t• \" m[\"app-id\"] \" — \" m[\"title\"] \" (WS \" m[\"on workspace\"] \")\"}' | sort -n | cut -f2-) && if [ -z \"\$list\" ]; then list='No scratchpad windows'; fi && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 2500 'Scratchpad Windows' \"\$list\""
    ];
  };

  # NIRIUS - FOLLOW MODE
  "Mod+Ctrl+F" = {
    _props = {
      hotkey-overlay-title = "Toggle follow-mode";
      allow-inhibiting = false;
    };
    spawn = [
      "sh"
      "-c"
      "nirius toggle-follow-mode && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 2500 'Follow mode' 'Toggled follow mode state'"
    ];
  };

  # NIRIUS - MARKS
  "Mod+T" = {
    _props = {
      hotkey-overlay-title = "Tag/untag window";
      allow-inhibiting = false;
    };
    spawn = [
      "sh"
      "-c"
      "nirius toggle-mark && list=\$(nirius list-marked | awk -F', ' '/app-id:/{delete m; for(i=1;i<=NF;i++){split(\$i,a,\": \"); gsub(/Some\\(\"|\"\\)|Some\\(|\\)|None/,\"\",a[2]); m[a[1]]=a[2]} print m[\"on workspace\"] \"\\t• \" m[\"app-id\"] \" — \" m[\"title\"] \" (WS \" m[\"on workspace\"] \")\"}' | sort -n | cut -f2-) && if [ -z \"\$list\" ]; then list='No windows marked'; fi && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 2500 'Marked Windows' \"\$list\""
    ];
  };
  "Mod+Alt+T" = {
    _props = {
      hotkey-overlay-title = "List tagged windows";
      allow-inhibiting = false;
    };
    spawn = [
      "sh"
      "-c"
      "list=\$(nirius list-marked --all | awk -F', ' '/app-id:/{delete m; for(i=1;i<=NF;i++){split(\$i,a,\": \"); gsub(/Some\\(\"|\"\\)|Some\\(|\\)|None/,\"\",a[2]); m[a[1]]=a[2]} print m[\"on workspace\"] \"\\t• \" m[\"app-id\"] \" — \" m[\"title\"] \" (WS \" m[\"on workspace\"] \")\"}' | sort -n | cut -f2-) && if [ -z \"\$list\" ]; then list='No windows marked'; fi && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 2500 'All Marked Windows' \"\$list\""
    ];
  };
  "Mod+Shift+T" = {
    _props = {
      hotkey-overlay-title = "Focus tagged window";
      allow-inhibiting = false;
    };
    spawn = [
      "sh"
      "-c"
      "nirius focus-marked && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 2500 'Marked windows' 'Focused marked window(s)'"
    ];
  };

  # Dynamic screencasting
  "Mod+Ctrl+S" = {
    _props = {
      hotkey-overlay-title = "Set dynamic cast target (window)";
      allow-inhibiting = false;
    };
    spawn = ["/home/${userVars.username}/.local/bin/cast-picker.sh" "window"];
  };
  "Mod+Ctrl+M" = {
    _props = {
      hotkey-overlay-title = "Set dynamic cast target (monitor)";
      allow-inhibiting = false;
    };
    spawn = ["/home/${userVars.username}/.local/bin/cast-picker.sh" "monitor"];
  };
  "Mod+Ctrl+Shift+S" = {
    _props = {
      hotkey-overlay-title = "Clear dynamic cast target";
      allow-inhibiting = false;
    };
    spawn = ["/home/${userVars.username}/.local/bin/cast-picker.sh" "clear"];
  };

  # Mod + Alt Meta Utilities
  "Mod+Alt+C" = {
    _props = {
      hotkey-overlay-title = "Pick color from screen";
      allow-inhibiting = false;
    };
    spawn = ["/home/${userVars.username}/.local/bin/color-picker.sh"];
  };
  "Mod+Alt+I" = {
    _props = {
      hotkey-overlay-title = "Copy focused window info";
      allow-inhibiting = false;
    };
    spawn = ["/home/${userVars.username}/.local/bin/focused-window-info.sh"];
  };
  "Mod+Alt+O" = {
    _props = {
      hotkey-overlay-title = "Copy focused output info";
      allow-inhibiting = false;
    };
    spawn = ["/home/${userVars.username}/.local/bin/focused-output-info.sh"];
  };
  "Mod+Alt+N" = {
    _props = {
      hotkey-overlay-title = "Manual theme switch";
      allow-inhibiting = false;
    };
    spawn = ["/home/${userVars.username}/.local/bin/theme-switcher.sh"];
  };

  # MISC & SCRIPTS
  "Mod+B" = {
    _props.allow-inhibiting = false;
    spawn = ["wayle" "panel" "toggle"];
  };
  "Mod+S" = {
    _props.allow-inhibiting = false;
    spawn = ["sunsetr"];
  };
  "Mod+Shift+S" = {
    _props.allow-inhibiting = false;
    spawn = ["sunsetr" "stop"];
  };
  "Mod+Z" = {
    _props.allow-inhibiting = false;
    spawn = [
      "sh"
      "-c"
      "${userVars.programs.terminal} -e ${userVars.programs.terminal-shell} -c \"/home/${userVars.username}/.local/bin/zen-keyboard-shortcuts.sh; ${userVars.programs.terminal-shell}\""
    ];
  };
  "Mod+I" = {
    _props = {
      hotkey-overlay-title = "Copy picked window info";
      allow-inhibiting = false;
    };
    spawn = [
      "sh"
      "-c"
      ''out=$(niri msg pick-window | grep -v '^[[:space:]]*~' | sed -E 's/^[[:space:]]+//') && [ ! -z "$out" ] && echo "$out" | wl-copy && notify-send -e -a niri -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 3500 "Window Captured" "$(echo "$out" | grep -E '^(Window ID|Title|App ID|PID|Window size)')"''
    ];
  };
  "Mod+Shift+Z" = {
    _props = {
      repeat = false;
      allow-inhibiting = false;
    };
    spawn = "qrscan";
  };

  # Preset layout scripts
  "Mod+Ctrl+1" = {
    _props = {
      hotkey-overlay-title = "Run layout preset scripts 1(-4)";
      allow-inhibiting = false;
    };
    spawn = ["/home/${userVars.username}/.local/bin/1-niri.sh"];
  };
  "Mod+Ctrl+2" = {
    _props.allow-inhibiting = false;
    spawn = ["/home/${userVars.username}/.local/bin/2-niri.sh"];
  };
  "Mod+Ctrl+3" = {
    _props.allow-inhibiting = false;
    spawn = ["/home/${userVars.username}/.local/bin/3-niri.sh"];
  };
  "Mod+Ctrl+4" = {
    _props.allow-inhibiting = false;
    spawn = ["/home/${userVars.username}/.local/bin/4-niri.sh"];
  };
}
