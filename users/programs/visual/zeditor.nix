{userVars, ...}: {
  home-manager.users.${userVars.username} = {
    programs.zed-editor = {
      enable = true;

      defaultEditor = false; # Whether to set zeditor -w as the default editor using the EDITOR and VISUAL environment variables.

      extensions = [
        "codebook"
        "git-firefly"
        "markdownlint"
        "nix"
      ];

      mutableUserSettings = true; # Whether user settings (settings.json) can be updated by zed.

      userSettings = {
        disable_ai = true;

        telemetry = {
          metrics = false;
        };

        autosave = "on_focus_change";
        format_on_save = "on";
        relative_line_numbers = "disabled";
        helix_mode = false; # Also enables vim mode
        vim_mode = false;

        project_panel = {
          dock = "left";
        };

        git_panel = {
          dock = "right";
        };

        languages = {
          Nix = {
            language_servers = [
              "nixd"
              "!nil"
            ];

            formatter = {
              external = {
                command = "alejandra";
              };
            };
          };
        };
      };
    };
  };
}
