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
    _props.allow-inhibiting = false;
    spawn =
      [userVars.programs.launcher]
      ++ pkgs.lib.optional (userVars.programs.launcher == "vicinae") "toggle";
  };

  # HELP & OVERVIEW
  "Mod+Slash" = {
    _props.allow-inhibiting = false;
    show-hotkey-overlay = [];
  };
  "Mod+Tab" = {
    _props.allow-inhibiting = false;
    spawn = ["/home/${userVars.username}/.local/bin/smart-overview.sh"];
  };
  "Mod+Shift+Tab" = {
    _props.allow-inhibiting = false;
    toggle-overview = [];
  };

  # APPLICATIONS
  "Mod+Return" = {
    _props.allow-inhibiting = false;
    spawn =
      if userVars.programs.terminal == "ghostty"
      then ["ghostty" "+new-window"]
      else [userVars.programs.terminal];
  };
  "Mod+Shift+Return" = {
    _props.allow-inhibiting = false;
    spawn = [
      "/home/${userVars.username}/.local/bin/floating-term.sh"
      userVars.programs.terminal
    ];
  };
  "Mod+F" = {
    _props.allow-inhibiting = false;
    spawn = [userVars.programs.explorer-gui];
  };
  "Mod+Shift+F" = {
    _props.allow-inhibiting = false;
    spawn = [
      userVars.programs.terminal
      "-e"
      userVars.programs.explorer-tui
    ];
  };
  "Mod+V" = {
    _props.allow-inhibiting = false;
    spawn = [userVars.programs.visual];
  };
  "Mod+E" = {
    _props.allow-inhibiting = false;
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
  /*
     Clashes with another Mod+Ctrl+M
  "Mod+Ctrl+M" = {
    _props.allow-inhibiting = false;
    maximize-window-to-edges = [];
  };
  */
  "Mod+W" = {
    _props = {
      hotkey-overlay-title = "Toggle tabbed column view";
      allow-inhibiting = false;
    };
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

  # FLOATING WINDOW MOVEMENT (Vim H/J/K/L)
  "Mod+Alt+Shift+H" = {
    _props.allow-inhibiting = false;
    spawn = ["niri" "msg" "action" "move-floating-window" "-x" "-10%"];
  };
  "Mod+Alt+Shift+L" = {
    _props.allow-inhibiting = false;
    spawn = ["niri" "msg" "action" "move-floating-window" "-x" "+10%"];
  };
  "Mod+Alt+Shift+K" = {
    _props.allow-inhibiting = false;
    spawn = ["niri" "msg" "action" "move-floating-window" "-y" "-10%"];
  };
  "Mod+Alt+Shift+J" = {
    _props.allow-inhibiting = false;
    spawn = ["niri" "msg" "action" "move-floating-window" "-y" "+10%"];
  };

  # FLOATING WINDOW MOVEMENT (Arrow Keys)
  "Mod+Alt+Shift+Left" = {
    _props.allow-inhibiting = false;
    spawn = ["niri" "msg" "action" "move-floating-window" "-x" "-10%"];
  };
  "Mod+Alt+Shift+Right" = {
    _props.allow-inhibiting = false;
    spawn = ["niri" "msg" "action" "move-floating-window" "-x" "+10%"];
  };
  "Mod+Alt+Shift+Up" = {
    _props.allow-inhibiting = false;
    spawn = ["niri" "msg" "action" "move-floating-window" "-y" "-10%"];
  };
  "Mod+Alt+Shift+Down" = {
    _props.allow-inhibiting = false;
    spawn = ["niri" "msg" "action" "move-floating-window" "-y" "+10%"];
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
      "mkdir -p ~/.local/state/nirius-floating; PRE_WIN=$(niri msg -j focused-window 2>/dev/null); PRE_ID=$(echo \"$PRE_WIN\" | jq -r '.id // empty'); PRE_FLOAT=$(echo \"$PRE_WIN\" | jq -r '.is_floating // empty'); [ -n \"$PRE_ID\" ] && echo \"$PRE_FLOAT\" > ~/.local/state/nirius-floating/\"$PRE_ID\"; nirius scratchpad-toggle; sleep 0.05; POST_WIN=$(niri msg -j focused-window 2>/dev/null); POST_ID=$(echo \"$POST_WIN\" | jq -r '.id // empty'); POST_FLOAT=$(echo \"$POST_WIN\" | jq -r '.is_floating // empty'); if [ -n \"$POST_ID\" ] && [ -f ~/.local/state/nirius-floating/\"$POST_ID\" ]; then WAS_FLOAT=$(cat ~/.local/state/nirius-floating/\"$POST_ID\"); [ \"$WAS_FLOAT\" = \"false\" ] && [ \"$POST_FLOAT\" = \"true\" ] && niri msg action focus-window --id \"$POST_ID\" && niri msg action toggle-window-floating; rm -f ~/.local/state/nirius-floating/\"$POST_ID\"; fi; list=$(nirius list-scratchpad | awk -F', ' '/app-id:/{delete m; for(i=1;i<=NF;i++){split($i,a,\": \"); gsub(/Some\\(\"|\"\\)|Some\\(|\\)|None/,\"\",a[2]); m[a[1]]=a[2]} print m[\"on workspace\"] \"\\t• \" m[\"app-id\"] \" — \" m[\"title\"] \" (WS \" m[\"on workspace\"] \")\"}' | sort -n | cut -f2-) && if [ -z \"$list\" ]; then list='No scratchpad windows'; fi && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 3500 'Scratchpad Windows' \"$list\""
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
      "nirius scratchpad-show; sleep 0.05; POST_WIN=$(niri msg -j focused-window 2>/dev/null); POST_ID=$(echo \"$POST_WIN\" | jq -r '.id // empty'); POST_FLOAT=$(echo \"$POST_WIN\" | jq -r '.is_floating // empty'); if [ -n \"$POST_ID\" ] && [ -f ~/.local/state/nirius-floating/\"$POST_ID\" ]; then WAS_FLOAT=$(cat ~/.local/state/nirius-floating/\"$POST_ID\"); [ \"$WAS_FLOAT\" = \"false\" ] && [ \"$POST_FLOAT\" = \"true\" ] && niri msg action focus-window --id \"$POST_ID\" && niri msg action toggle-window-floating; rm -f ~/.local/state/nirius-floating/\"$POST_ID\"; fi; list=$(nirius list-scratchpad | awk -F', ' '/app-id:/{delete m; for(i=1;i<=NF;i++){split($i,a,\": \"); gsub(/Some\\(\"|\"\\)|Some\\(|\\)|None/,\"\",a[2]); m[a[1]]=a[2]} print m[\"on workspace\"] \"\\t• \" m[\"app-id\"] \" — \" m[\"title\"] \" (WS \" m[\"on workspace\"] \")\"}' | sort -n | cut -f2-) && if [ -z \"$list\" ]; then list='No scratchpad windows'; fi && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 3500 'Scratchpad Windows' \"$list\""
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
      "nirius scratchpad-show-all; sleep 0.05; for f in ~/.local/state/nirius-floating/*; do [ -f \"$f\" ] || continue; id=$(basename \"$f\"); was_float=$(cat \"$f\"); if [ \"$was_float\" = \"false\" ]; then niri msg action focus-window --id \"$id\" 2>/dev/null && niri msg action toggle-window-floating; fi; rm -f \"$f\"; done; list=$(nirius list-scratchpad | awk -F', ' '/app-id:/{delete m; for(i=1;i<=NF;i++){split($i,a,\": \"); gsub(/Some\\(\"|\"\\)|Some\\(|\\)|None/,\"\",a[2]); m[a[1]]=a[2]} print m[\"on workspace\"] \"\\t• \" m[\"app-id\"] \" — \" m[\"title\"] \" (WS \" m[\"on workspace\"] \")\"}' | sort -n | cut -f2-) && if [ -z \"$list\" ]; then list='No scratchpad windows'; fi && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 3500 'Scratchpad Windows' \"$list\""
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
      "list=$(nirius list-scratchpad | awk -F', ' '/app-id:/{delete m; for(i=1;i<=NF;i++){split($i,a,\": \"); gsub(/Some\\(\"|\"\\)|Some\\(|\\)|None/,\"\",a[2]); m[a[1]]=a[2]} print m[\"on workspace\"] \"\\t• \" m[\"app-id\"] \" — \" m[\"title\"] \" (WS \" m[\"on workspace\"] \")\"}' | sort -n | cut -f2-) && if [ -z \"$list\" ]; then list='No scratchpad windows'; fi && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 3500 'Scratchpad Windows' \"$list\""
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
      "nirius toggle-follow-mode && info=$(niri msg -j focused-window | jq -r '\"• \" + (.app_id // \"Unknown app\") + \" — \" + (.title // \"Untitled\") + \"\\nWindow ID: \" + (.id|tostring)') && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 3500 'Follow mode' \"$info\""
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
      "nirius toggle-mark && list=$(nirius list-marked | awk -F', ' '/app-id:/{delete m; for(i=1;i<=NF;i++){split($i,a,\": \"); gsub(/Some\\(\"|\"\\)|Some\\(|\\)|None/,\"\",a[2]); m[a[1]]=a[2]} print m[\"on workspace\"] \"\\t• \" m[\"app-id\"] \" — \" m[\"title\"] \" (WS \" m[\"on workspace\"] \")\"}' | sort -n | cut -f2-) && if [ -z \"$list\" ]; then list='No windows marked'; fi && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 3500 'Marked Windows' \"$list\""
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
      "list=$(nirius list-marked --all | awk -F', ' '/app-id:/{delete m; for(i=1;i<=NF;i++){split($i,a,\": \"); gsub(/Some\\(\"|\"\\)|Some\\(|\\)|None/,\"\",a[2]); m[a[1]]=a[2]} print m[\"on workspace\"] \"\\t• \" m[\"app-id\"] \" — \" m[\"title\"] \" (WS \" m[\"on workspace\"] \")\"}' | sort -n | cut -f2-) && if [ -z \"$list\" ]; then list='No windows marked'; fi && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 3500 'All Marked Windows' \"$list\""
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
      "nirius focus-marked && list=$(nirius list-marked | awk -F', ' '/app-id:/{delete m; for(i=1;i<=NF;i++){split($i,a,\": \"); gsub(/Some\\(\"|\"\\)|Some\\(|\\)|None/,\"\",a[2]); m[a[1]]=a[2]} print m[\"on workspace\"] \"\\t• \" m[\"app-id\"] \" — \" m[\"title\"] \" (WS \" m[\"on workspace\"] \")\"}' | sort -n | cut -f2-) && if [ -z \"$list\" ]; then list='No windows marked'; fi && notify-send -e -a nirius -i /home/${userVars.username}/.local/share/misc/niri-icon.svg -u low -t 3500 'Focused Marked Window' \"$list\""
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
    spawn = ["/home/${userVars.username}/.local/bin/colour-picker.sh"];
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
  "Mod+Alt+S" = {
    _props = {
      hotkey-overlay-title = "Manual theme switch";
      allow-inhibiting = false;
    };
    spawn = ["/home/${userVars.username}/.local/bin/theme-switcher.sh"];
  };
  "Mod+Alt+R" = {
    _props = {
      hotkey-overlay-title = "RDP menu";
      allow-inhibiting = false;
      repeat = false;
    };
    spawn = [
      "sh"
      "-c"
      ''
        focus-second-monitor
        niri msg action focus-workspace 3
        /home/${userVars.username}/.local/bin/rdp.sh
      ''
    ];
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
  "Mod+Shift+G" = {
    _props = {
      repeat = false;
      allow-inhibiting = false;
    };
    spawn = "qrcreate";
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
