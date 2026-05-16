{userVars, ...}: {
  home-manager.users.${userVars.username} = {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = userVars.programs.shell == "zsh";
      settings = {
        desktop-notifications = true;
        notify-on-command-finish = "unfocused";
        notify-on-command-finish-action = "bell,notify";
        bell-features = "system";
        link-url = true;
        link-previews = true;
        gtk-single-instance = true;
      };
      systemd.enable = true; # Nyoom startup times
    };
  };
}
