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
  };
}
