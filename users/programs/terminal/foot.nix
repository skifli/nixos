{
  pkgs,
  userVars,
  ...
}:
{
  home-manager.users.${userVars.username} = {
    programs.foot = {
      enable = true;

      # Enables the foot daemon for quick startup
      server.enable = true;

      settings = {
        main = { };

        cursor = {
          style = "beam";
          blink = "yes";
        };

        mouse = {
          hide-when-typing = "yes";
        };

        # Ghostty-style keybindings
        key-bindings = {
          clipboard-copy = "Control+Shift+c XF86Copy";
          clipboard-paste = "Control+Shift+v XF86Paste";
          search-start = "Control+Shift+f";
          font-increase = "Control+plus Control+equal";
          font-decrease = "Control+minus";
          font-reset = "Control+0";
        };

        url = {
          launch = "${pkgs.xdg-utils}/bin/xdg-open \${url}";
        };
      };
    };

    # Dolphin's terminal launcher should connect to the already-running Foot
    # server, and the packaged desktop entry references an icon that is not
    # shipped by Foot. Override it locally so KDE can resolve a standard icon
    # for the context-menu action.
    home.file.".local/share/applications/footclient.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Foot Client
      GenericName=Terminal
      Comment=A Wayland terminal client
      Exec=footclient
      Icon=utilities-terminal
      Terminal=false
      Categories=System;TerminalEmulator;
      Keywords=shell;prompt;command;commandline;
    '';
  };
}
