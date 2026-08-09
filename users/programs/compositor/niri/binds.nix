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
      hotkey-overlay-title = "Show keybindings";
      allow-inhibiting = false;
    };
    show-hotkey-overlay = [];
  };
  "Mod+Tab" = {
    _props = {
      hotkey-overlay-title = "Toggle overview";
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
      hotkey-overlay-title = "File manager";
      allow-inhibiting = false;
    };
    spawn = [userVars.programs.explorer-gui];
  };
  "Mod+Shift+F" = {
    _props = {
      hotkey-overlay-title = "File manager (terminal)";
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
    _props.hotkey-overlay-title = "System monitor";
    spawn = [userVars.programs.system-monitor];
  };
  "Shift+Escape" = {
    _props = {
      hotkey-overlay-title = "System monitor (terminal)";
      allow-inhibiting = false;
    };
    spawn = [
      userVars.programs.terminal
      "-e"
      "btop"
    ];
  };

  # WINDOW MANAGEMENT
  "Mod+Q" = {
    _props = {
      hotkey-overlay-title = "Close window";
      repeat = false;
      allow-inhibiting = false;
    };
    close-window = [];
  };
  "Mod+Ctrl+Q" = {
    _props = {
      hotkey-overlay-title = "Kill click window";
      repeat = false;
      allow-inhibiting = false;
    };
    spawn = "killclick";
  };
  "Mod+Shift+Q" = {
    _props = {
      hotkey-overlay-title = "Kill current window";
      repeat = false;
      allow-inhibiting = false;
    };
    spawn = "killcurrent";
  };
  "Mod+F11" = {
    _props.hotkey-overlay-title = "Toggle fullscreen";
    allow-inhibiting = false;
    fullscreen-window = [];
  };
  "Mod+O" = {
    _props.hotkey-overlay-title = "Toggle floating";
    allow-inhibiting = false;
    toggle-window-floating = [];
  };

  # COLUMN MANAGEMENT
  "Mod+Equal" = {
    _props.hotkey-overlay-title = "Increase column width";
    set-column-width = "+10%";
  };
  "Mod+Minus" = {
    _props.hotkey-overlay-title = "Decrease column width";
    set-column-width = "-10%";
  };
  "Mod+C" = {
    _props.hotkey-overlay-title = "Center column";
    center-column = [];
  };
  "Mod+M" = {
    _props.hotkey-overlay-title = "Maximize column";
    maximize-column = [];
  };
  "Mod+W" = {
    _props.hotkey-overlay-title = "Toggle tabbed view";
    toggle-column-tabbed-display = [];
  };
  "Mod+R" = {
    _props.hotkey-overlay-title = "Cycle column width preset";
    switch-preset-column-width = [];
  };

  # NEW FEATURES (v25.11+)
  "Mod+Ctrl+M" = {
    _props.hotkey-overlay-title = "True maximize (fill screen edges)";
    maximize-window-to-edges = [];
  };

  # WINDOW MOVEMENT
  "Mod+Shift+Home" = {
    _props.hotkey-overlay-title = "Move column to first";
    move-column-to-first = [];
  };
  "Mod+Shift+End" = {
    _props.hotkey-overlay-title = "Move column to last";
    move-column-to-last = [];
  };

  "Mod+Shift+H" = {
    _props.hotkey-overlay-title = "Move column left";
    move-column-left = [];
  };
  "Mod+Shift+L" = {
    _props.hotkey-overlay-title = "Move column right";
    move-column-right = [];
  };
  "Mod+Shift+J" = {
    _props.hotkey-overlay-title = "Move window down";
    move-window-down = [];
  };
  "Mod+Shift+K" = {
    _props.hotkey-overlay-title = "Move window up";
    move-window-up = [];
  };
  "Mod+Comma" = {
    _props.hotkey-overlay-title = "Consume window into column";
    consume-window-into-column = [];
  };
  "Mod+Period" = {
    _props.hotkey-overlay-title = "Expel window from column";
    expel-window-from-column = [];
  };

  # FOCUS MOVEMENT (Vim style)
  "Mod+H" = {
    _props = {
      hotkey-overlay-title = "Focus left";
      allow-inhibiting = false;
    };
    focus-column-left = [];
  };
  "Mod+J" = {
    _props = {
      hotkey-overlay-title = "Focus down";
      allow-inhibiting = false;
    };
    focus-window-down = [];
  };
  "Mod+K" = {
    _props = {
      hotkey-overlay-title = "Focus up";
      allow-inhibiting = false;
    };
    focus-window-up = [];
  };
  "Mod+L" = {
    _props = {
      hotkey-overlay-title = "Focus right";
      allow-inhibiting = false;
    };
    focus-column-right = [];
  };
  "Mod+Shift+WheelScrollDown" = {
    _props = {
      hotkey-overlay-title = "Focus column down";
      cooldown-ms = userVars.scroll-cooldown-ms;
      allow-inhibiting = false;
    };
    focus-column-right = [];
  };
  "Mod+Shift+WheelScrollUp" = {
    _props = {
      hotkey-overlay-title = "Focus column up";
      cooldown-ms = userVars.scroll-cooldown-ms;
      allow-inhibiting = false;
    };
    focus-column-left = [];
  };

  # WORKSPACES
  "Mod+1" = {
    _props = {
      hotkey-overlay-title = "Focus monitor left";
      allow-inhibiting = false;
    };
    focus-monitor-left = [];
  };
  "Mod+2" = {
    _props = {
      hotkey-overlay-title = "Focus monitor right";
      allow-inhibiting = false;
    };
    focus-monitor-right = [];
  };
  "Mod+WheelScrollDown" = {
    _props = {
      hotkey-overlay-title = "Focus workspace down";
      cooldown-ms = userVars.scroll-cooldown-ms;
      allow-inhibiting = false;
    };
    focus-workspace-down = [];
  };
  "Mod+WheelScrollUp" = {
    _props = {
      hotkey-overlay-title = "Focus workspace up";
      cooldown-ms = userVars.scroll-cooldown-ms;
      allow-inhibiting = false;
    };
    focus-workspace-up = [];
  };

  "Mod+Ctrl+WheelScrollDown" = {
    _props = {
      hotkey-overlay-title = "Move column to workspace down";
      cooldown-ms = userVars.scroll-cooldown-ms;
      allow-inhibiting = false;
    };
    move-column-to-workspace-down = [];
  };
  "Mod+Ctrl+WheelScrollUp" = {
    _props = {
      hotkey-overlay-title = "Move column to workspace up";
      cooldown-ms = userVars.scroll-cooldown-ms;
      allow-inhibiting = false;
    };
    move-column-to-workspace-up = [];
  };

  "Mod+Shift+1" = {
    _props = {
      hotkey-overlay-title = "Focus workspace 1";
      allow-inhibiting = false;
    };
    focus-workspace = "1";
  };
  "Mod+Shift+2" = {
    _props = {
      hotkey-overlay-title = "Focus workspace 2";
      allow-inhibiting = false;
    };
    focus-workspace = "2";
  };
  "Mod+Shift+3" = {
    _props = {
      hotkey-overlay-title = "Focus workspace 3";
      allow-inhibiting = false;
    };
    focus-workspace = "3";
  };
  "Mod+Shift+4" = {
    _props = {
      hotkey-overlay-title = "Focus workspace 4";
      allow-inhibiting = false;
    };
    focus-workspace = "4";
  };
  "Mod+Shift+5" = {
    _props = {
      hotkey-overlay-title = "Focus workspace 5";
      allow-inhibiting = false;
    };
    focus-workspace = "5";
  };
  "Mod+Shift+6" = {
    _props = {
      hotkey-overlay-title = "Focus workspace 6";
      allow-inhibiting = false;
    };
    focus-workspace = "6";
  };
  "Mod+Shift+7" = {
    _props = {
      hotkey-overlay-title = "Focus workspace 7";
      allow-inhibiting = false;
    };
    focus-workspace = "7";
  };
  "Mod+Shift+8" = {
    _props = {
      hotkey-overlay-title = "Focus workspace 8";
      allow-inhibiting = false;
    };
    focus-workspace = "8";
  };

  # LAYOUT
  "Mod+Space" = {
    _props.hotkey-overlay-title = "Next layout";
    switch-layout = "next";
  };
  "Mod+Shift+Space" = {
    _props.hotkey-overlay-title = "Previous layout";
    switch-layout = "prev";
  };

  # SYSTEM
  "Mod+Shift+E" = {
    _props.hotkey-overlay-title = "Exit Niri";
    quit = [];
  };

  # SCREENSHOTS
  "Print" = {
    _props = {
      hotkey-overlay-title = "Screenshot";
      allow-inhibiting = false;
    };
    screenshot = [];
  };
  "Shift+Print" = {
    _props = {
      hotkey-overlay-title = "Screenshot (window)";
      allow-inhibiting = false;
    };
    screenshot-window = [];
  };
  "Ctrl+Print" = {
    _props = {
      hotkey-overlay-title = "OCR screenshot";
      allow-inhibiting = false;
    };
    spawn = ["normcap"];
  };

  # MEDIA KEYS
  "XF86AudioRaiseVolume" = {
    _props.allow-inhibiting = false;
    spawn = [
      "wayle"
      "audio"
      "output-volume"
      "+2"
    ];
  };
  "XF86AudioLowerVolume" = {
    _props.allow-inhibiting = false;
    spawn = [
      "wayle"
      "audio"
      "output-volume"
      "-2"
    ];
  };
  "XF86AudioMute" = {
    _props.allow-inhibiting = false;
    spawn = [
      "wayle"
      "audio"
      "output-mute"
    ];
  };
  "XF86AudioMicMute" = {
    _props.allow-inhibiting = false;
    spawn = [
      "wayle"
      "audio"
      "input-mute"
    ];
  };

  "XF86AudioPlay" = {
    _props.allow-inhibiting = false;
    spawn = [
      "wayle"
      "media"
      "play-pause"
    ];
  };
  "XF86AudioNext" = {
    _props.allow-inhibiting = false;
    spawn = [
      "wayle"
      "media"
      "next"
    ];
  };
  "XF86AudioPrev" = {
    _props.allow-inhibiting = false;
    spawn = [
      "wayle"
      "media"
      "previous"
    ];
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
    spawn = ["nirius" "scratchpad-show"];
  };
  "Mod+Ctrl+P" = {
    _props = {
      hotkey-overlay-title = "Show/hide all scratchpad windows";
      allow-inhibiting = false;
    };
    spawn = ["nirius" "scratchpad-show-all"];
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
    spawn = ["nirius" "toggle-follow-mode"];
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
    spawn = ["nirius" "focus-marked"];
  };

  # Misc
  "Mod+B" = {
    _props = {
      hotkey-overlay-title = "Toggle bar";
      allow-inhibiting = false;
    };
    spawn = [
      "wayle"
      "panel"
      "toggle"
    ];
  };
  "Mod+S" = {
    _props = {
      hotkey-overlay-title = "Start sunsetr";
      allow-inhibiting = false;
    };
    spawn = [
      "sunsetr"
    ];
  };
  "Mod+Shift+S" = {
    _props = {
      hotkey-overlay-title = "Stop sunsetr";
      allow-inhibiting = false;
    };
    spawn = [
      "sunsetr"
      "stop"
    ];
  };
  "Mod+Z" = {
    _props = {
      hotkey-overlay-title = "Open Zen Keyboard Shortcuts";
      allow-inhibiting = false;
    };
    spawn = [
      "sh"
      "-c"
      "${userVars.programs.terminal} -e ${userVars.programs.terminal-shell} -c \"/home/${userVars.username}/.local/bin/zen-keyboard-shortcuts.sh; ${userVars.programs.terminal-shell}\""
    ];
  };
  "Mod+Shift+Z" = {
    _props = {
      hotkey-overlay-title = "Scan QR with Zbar";
      repeat = false;
      allow-inhibiting = false;
    };
    spawn = "qrscan";
  };

  "Mod+Ctrl+1" = {
    _props = {
      hotkey-overlay-title = "Run script 1";
      allow-inhibiting = false;
    };
    spawn = ["/home/${userVars.username}/.local/bin/1-niri.sh"];
  };
  "Mod+Ctrl+2" = {
    _props = {
      hotkey-overlay-title = "Run script 2";
      allow-inhibiting = false;
    };
    spawn = ["/home/${userVars.username}/.local/bin/2-niri.sh"];
  };
  "Mod+Ctrl+3" = {
    _props = {
      hotkey-overlay-title = "Run script 3";
      allow-inhibiting = false;
    };
    spawn = ["/home/${userVars.username}/.local/bin/3-niri.sh"];
  };
}
