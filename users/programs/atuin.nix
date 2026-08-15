{
  inputs,
  pkgs,
  userVars,
  ...
}: {
  home-manager = {
    users.${userVars.username} = {
      # First run run atuin import auto
      programs.atuin = {
        enable = true;
        enableZshIntegration = userVars.programs.terminal-shell == "zsh";

        daemon.enable = true;

        # When enabled, force overwriting of the Atuin configuration file ($XDG_CONFIG_HOME/atuin/config.toml). Any existing Atuin configuration will be lost.
        # Enabling this is useful when adding settings for the first time because Atuin writes its default config file after every single shell command, which can make it difficult to manually remove.
        forceOverwriteSettings = true;

        # Keep Up-Arrow for Zsh historySubstringSearch, use Ctrl+R for Atuin
        flags = [ "--disable-up-arrow" ];

        settings = {
          auto_sync = false;            # No cloud sync
          search_mode = "daemon-fuzzy"; # This search mode uses an in-memory index, stored in the daemon, to perform fast and customizable searches.
          style = "auto";
          inline_height = 15;           # How many lines the history popup occupies
          show_preview = true;          # Shows command details in a side preview pane
        };
      };
    };
  };
}
