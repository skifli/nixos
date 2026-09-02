{
  commonHostVars,
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    programs.foot = {
      enable = true;

      # Enables the foot daemon for quick startup
      server.enable = true;

      settings = {
        main = {
          # High-DPI handling
          dpi-aware = "yes";
          font = "${commonHostVars.fonts.monospace.name}:size=${toString commonHostVars.fonts.sizes.terminal},monospace:size=${toString commonHostVars.fonts.sizes.terminal}";

          # Ghostty-style window padding (X x Y in pixels)
          pad = "14x14";

          # URL detection (open on click / hover)
          underline-url = "yes";
        };

        cursor = {
          style = "beam";
          blink = "yes";
        };

        mouse = {
          hide-when-typing = "yes";
        };

        # Ghostty standard dark palette
        colors = {
          alpha = 0.95; # Subtle background transparency (change to 1.0 for solid)
          background = "16161e";
          foreground = "c0caf5";

          # Normal colors
          regular0 = "15161e"; # black
          regular1 = "f7768e"; # red
          regular2 = "9ece6a"; # green
          regular3 = "e0af68"; # yellow
          regular4 = "7aa2f7"; # blue
          regular5 = "bb9af7"; # magenta
          regular6 = "7dcfff"; # cyan
          regular7 = "a9b1d6"; # white

          # Bright colors
          bright0 = "414868"; # bright black
          bright1 = "f7768e"; # bright red
          bright2 = "9ece6a"; # bright green
          bright3 = "e0af68"; # bright yellow
          bright4 = "7aa2f7"; # bright blue
          bright5 = "bb9af7"; # bright magenta
          bright6 = "7dcfff"; # bright cyan
          bright7 = "c0caf5"; # bright white
        };

        # Ghostty-style keybindings
        key-bindings = {
          clipboard-copy = "Control+Shift+c XF86Copy";
          clipboard-paste = "Control+Shift+v XF86Paste";
          search-start = "Control+Shift+f";
          font-increase = "Control+plus Control+equal";
          font-decrease = "Control+minus";
          font-reset = "Control+0";
          spawn-terminal = "Control+Shift+n";
          new-window = "Control+Shift+Return";
        };

        url = {
          launch = "${pkgs.xdg-utils}/bin/xdg-open \${url}";
        };
      };
    };
  };
}
