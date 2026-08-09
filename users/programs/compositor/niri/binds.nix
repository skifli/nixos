{
  pkgs,
  userVars,
  ...
}: {
  # APPLICATION LAUNCHER
  "Mod+D" = {
    hotkey-overlay-title = "Application launcher";
    spawn =
      [userVars.programs.launcher]
      ++ pkgs.lib.optional (userVars.programs.launcher == "vicinae") "toggle";
  };

  # HELP & OVERVIEW
  "Mod+Slash" = {
    hotkey-overlay-title = "Show keybindings";
    show-hotkey-overlay = {};
  };
  "Mod+Tab" = {
    hotkey-overlay-title = "Toggle overview";
    toggle-overview = {};
  };

  # APPLICATIONS
  "Mod+Return" = {
    hotkey-overlay-title = "Terminal";
    spawn =
      if userVars.programs.terminal == "ghostty"
      then ["ghostty" "+new-window"]
      else [userVars.programs.terminal];
  };
  "Mod+F" = {
    hotkey-overlay-title = "File manager";
    spawn = [userVars.programs.explorer-gui];
  };
  "Mod+V" = {
    hotkey-overlay-title = "Visual editor";
    spawn = [userVars.programs.visual];
  };
  "Mod+E" = {
    hotkey-overlay-title = "Text editor";
    spawn = [userVars.programs.editor];
  };
  "Ctrl+Shift+Escape" = {
    hotkey-overlay-title = "System monitor";
    spawn = [userVars.programs.system-monitor];
  };
  "Shift+Escape" = {
    hotkey-overlay-title = "System monitor (terminal)";
    spawn = [
      userVars.programs.terminal
      "-e"
      "btop"
    ];
  };

  # WINDOW MANAGEMENT
  "Mod+Q" = {
    hotkey-overlay-title = "Close window";
    close-window = {};
  };
  "Mod+F11" = {
    hotkey-overlay-title = "Toggle fullscreen";
    fullscreen-window = {};
  };
  "Mod+O" = {
    hotkey-overlay-title = "Toggle floating";
    toggle-window-floating = {};
  };

  # COLUMN MANAGEMENT
  "Mod+Equal" = {
    hotkey-overlay-title = "Increase column width";
    set-column-width = "+10%";
  };
  "Mod+Minus" = {
    hotkey-overlay-title = "Decrease column width";
    set-column-width = "-10%";
  };
  "Mod+C" = {
    hotkey-overlay-title = "Center column";
    center-column = {};
  };
  "Mod+M" = {
    hotkey-overlay-title = "Maximize column";
    maximize-column = {};
  };
  "Mod+W" = {
    hotkey-overlay-title = "Toggle tabbed view";
    toggle-column-tabbed-display = {};
  };
  "Mod+R" = {
    hotkey-overlay-title = "Cycle column width preset";
    switch-preset-column-width = {};
  };

  # NEW FEATURES (v25.11+)
  "Mod+Ctrl+M" = {
    hotkey-overlay-title = "True maximize (fill screen edges)";
    maximize-window-to-edges = {};
  };

  # WINDOW MOVEMENT
  "Mod+Shift+Home" = {
    hotkey-overlay-title = "Move column to first";
    move-column-to-first = {};
  };
  "Mod+Shift+End" = {
    hotkey-overlay-title = "Move column to last";
    move-column-to-last = {};
  };

  "Mod+Shift+H" = {
    hotkey-overlay-title = "Move column left";
    move-column-left = {};
  };
  "Mod+Shift+L" = {
    hotkey-overlay-title = "Move column right";
    move-column-right = {};
  };
  "Mod+Shift+J" = {
    hotkey-overlay-title = "Move window down";
    move-window-down = {};
  };
  "Mod+Shift+K" = {
    hotkey-overlay-title = "Move window up";
    move-window-up = {};
  };
  "Mod+Comma" = {
    hotkey-overlay-title = "Consume window into column";
    consume-window-into-column = {};
  };
  "Mod+Period" = {
    hotkey-overlay-title = "Expel window from column";
    expel-window-from-column = {};
  };

  # FOCUS MOVEMENT (Vim style)
  "Mod+H" = {
    hotkey-overlay-title = "Focus left";
    focus-column-left = {};
  };
  "Mod+J" = {
    hotkey-overlay-title = "Focus down";
    focus-window-down = {};
  };
  "Mod+K" = {
    hotkey-overlay-title = "Focus up";
    focus-window-up = {};
  };
  "Mod+L" = {
    hotkey-overlay-title = "Focus right";
    focus-column-right = {};
  };
  "Mod+Shift+WheelScrollDown" = {
    cooldown-ms = userVars.scroll-cooldown-ms;
    focus-column-right = {};
  };
  "Mod+Shift+WheelScrollUp" = {
    cooldown-ms = userVars.scroll-cooldown-ms;
    focus-column-left = {};
  };

  # WORKSPACES
  "Mod+1" = {
    focus-monitor-left = {};
  };
  "Mod+2" = {
    focus-monitor-right = {};
  };
  "Mod+WheelScrollDown" = {
    cooldown-ms = userVars.scroll-cooldown-ms;
    focus-workspace-down = {};
  };
  "Mod+WheelScrollUp" = {
    cooldown-ms = userVars.scroll-cooldown-ms;
    focus-workspace-up = {};
  };

  "Mod+Ctrl+WheelScrollDown" = {
    cooldown-ms = userVars.scroll-cooldown-ms;
    move-column-to-workspace-down = {};
  };
  "Mod+Ctrl+WheelScrollUp" = {
    cooldown-ms = userVars.scroll-cooldown-ms;
    move-column-to-workspace-up = {};
  };

  "Mod+Shift+1" = {
    focus-workspace = "1";
  };
  "Mod+Shift+2" = {
    focus-workspace = "2";
  };
  "Mod+Shift+3" = {
    focus-workspace = "3";
  };
  "Mod+Shift+4" = {
    focus-workspace = "4";
  };
  "Mod+Shift+5" = {
    focus-workspace = "5";
  };
  "Mod+Shift+6" = {
    focus-workspace = "6";
  };
  "Mod+Shift+7" = {
    focus-workspace = "7";
  };
  "Mod+Shift+8" = {
    focus-workspace = "8";
  };

  # LAYOUT
  "Mod+Space" = {
    hotkey-overlay-title = "Next layout";
    switch-layout = "next";
  };
  "Mod+Shift+Space" = {
    hotkey-overlay-title = "Previous layout";
    switch-layout = "prev";
  };

  # SYSTEM
  "Mod+Shift+E" = {
    hotkey-overlay-title = "Exit Niri";
    quit = {};
  };

  # SCREENSHOTS
  "Print" = {
    hotkey-overlay-title = "Screenshot";
    screenshot = {};
  };
  "Shift+Print" = {
    hotkey-overlay-title = "Screenshot window";
    screenshot-window = {};
  };
  "Ctrl+Print" = {
    hotkey-overlay-title = "OCR screenshot";
    spawn = ["normcap"];
  };

  # MEDIA KEYS
  "XF86AudioRaiseVolume" = {
    spawn = [
      "wayle"
      "audio"
      "output-volume"
      "+2"
    ];
  };
  "XF86AudioLowerVolume" = {
    spawn = [
      "wayle"
      "audio"
      "output-volume"
      "-2"
    ];
  };
  "XF86AudioMute" = {
    spawn = [
      "wayle"
      "audio"
      "output-mute"
    ];
  };
  "XF86AudioMicMute" = {
    spawn = [
      "wayle"
      "audio"
      "input-mute"
    ];
  };

  "XF86AudioPlay" = {
    spawn = [
      "wayle"
      "media"
      "play-pause"
    ];
  };
  "XF86AudioNext" = {
    spawn = [
      "wayle"
      "media"
      "next"
    ];
  };
  "XF86AudioPrev" = {
    spawn = [
      "wayle"
      "media"
      "previous"
    ];
  };

  # NIRIUS - SCRATCHPAD
  "Mod+P" = {
    hotkey-overlay-title = "Park/unpark window (scratchpad toggle)";
    spawn = [
      "sh"
      "-c"
      "nirius scratchpad-toggle && list=\$(nirius list-scratchpad | awk -F', ' '/app-id:/{delete m; for(i=1;i<=NF;i++){split(\$i,a,\": \"); gsub(/Some\\(\"|\"\\)|Some\\(|\\)|None/,\"\",a[2]); m[a[1]]=a[2]} print m[\"on workspace\"] \"\\t• \" m[\"app-id\"] \" — \" m[\"title\"] \" (WS \" m[\"on workspace\"] \")\"}' | sort -n | cut -f2-) && if [ -z \"\$list\" ]; then list='No scratchpad windows'; fi && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 2500 'Scratchpad Windows' \"\$list\""
    ];
  };
  "Mod+Shift+P" = {
    hotkey-overlay-title = "Show/cycle scratchpad window";
    spawn = ["nirius" "scratchpad-show"];
  };
  "Mod+Ctrl+P" = {
    hotkey-overlay-title = "Show/hide all scratchpad windows";
    spawn = ["nirius" "scratchpad-show-all"];
  };
  "Mod+Alt+P" = {
    hotkey-overlay-title = "List scratchpad windows";
    spawn = [
      "sh"
      "-c"
      "list=\$(nirius list-scratchpad | awk -F', ' '/app-id:/{delete m; for(i=1;i<=NF;i++){split(\$i,a,\": \"); gsub(/Some\\(\"|\"\\)|Some\\(|\\)|None/,\"\",a[2]); m[a[1]]=a[2]} print m[\"on workspace\"] \"\\t• \" m[\"app-id\"] \" — \" m[\"title\"] \" (WS \" m[\"on workspace\"] \")\"}' | sort -n | cut -f2-) && if [ -z \"\$list\" ]; then list='No scratchpad windows'; fi && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 2500 'Scratchpad Windows' \"\$list\""
    ];
  };

  # NIRIUS - FOLLOW MODE
  "Mod+Ctrl+F" = {
    hotkey-overlay-title = "Toggle follow-mode";
    spawn = ["nirius" "toggle-follow-mode"];
  };

  # NIRIUS - MARKS
  "Mod+T" = {
    hotkey-overlay-title = "Tag/untag window";
    spawn = [
      "sh"
      "-c"
      "nirius toggle-mark && list=\$(nirius list-marked | awk -F', ' '/app-id:/{delete m; for(i=1;i<=NF;i++){split(\$i,a,\": \"); gsub(/Some\\(\"|\"\\)|Some\\(|\\)|None/,\"\",a[2]); m[a[1]]=a[2]} print m[\"on workspace\"] \"\\t• \" m[\"app-id\"] \" — \" m[\"title\"] \" (WS \" m[\"on workspace\"] \")\"}' | sort -n | cut -f2-) && if [ -z \"\$list\" ]; then list='No windows marked'; fi && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 2500 'Marked Windows' \"\$list\""
    ];
  };
  "Mod+Alt+T" = {
    hotkey-overlay-title = "List tagged windows";
    spawn = [
      "sh"
      "-c"
      "list=\$(nirius list-marked --all | awk -F', ' '/app-id:/{delete m; for(i=1;i<=NF;i++){split(\$i,a,\": \"); gsub(/Some\\(\"|\"\\)|Some\\(|\\)|None/,\"\",a[2]); m[a[1]]=a[2]} print m[\"on workspace\"] \"\\t• \" m[\"app-id\"] \" — \" m[\"title\"] \" (WS \" m[\"on workspace\"] \")\"}' | sort -n | cut -f2-) && if [ -z \"\$list\" ]; then list='No windows marked'; fi && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 2500 'All Marked Windows' \"\$list\""
    ];
  };
  "Mod+Shift+T" = {
    hotkey-overlay-title = "Focus tagged window";
    spawn = ["nirius" "focus-marked"];
  };

  # Misc
  "Mod+B" = {
    spawn = [
      "wayle"
      "panel"
      "toggle"
    ];
  };
  "Mod+S" = {
    spawn = [
      "sunsetr"
    ];
  };
  "Mod+Shift+S" = {
    spawn = [
      "sunsetr"
      "stop"
    ];
  };
  "Mod+Z" = {
    spawn = [
      "sh"
      "-c"
      "${userVars.programs.terminal} -e ${userVars.programs.terminal-shell} -c \"/home/${userVars.username}/.local/bin/zen-keyboard-shortcuts.sh; ${userVars.programs.terminal-shell}\""
    ];
  };

  "Mod+Ctrl+1" = {
    hotkey-overlay-title = "Run script 1";
    spawn = ["/home/${userVars.username}/.local/bin/1-niri.sh"];
  };
  "Mod+Ctrl+2" = {
    hotkey-overlay-title = "Run script 2";
    spawn = ["/home/${userVars.username}/.local/bin/2-niri.sh"];
  };
  "Mod+Ctrl+3" = {
    hotkey-overlay-title = "Run script 3";
    spawn = ["/home/${userVars.username}/.local/bin/3-niri.sh"];
  };
}