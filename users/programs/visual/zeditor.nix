{userVars, ...}: {
  home-manager.users.${userVars.username} = {
    programs.zed-editor = {
      enable = true;

      defaultEditor = false; # Whether to set zeditor -w as the default editor using the EDITOR and VISUAL environment variables.
      installRemoteServer = false; # Whether to symlink the Zed’s remote server binary to the expected location. This allows remotely connecting to this system from a distant Zed client.

      extensions = [
        "codebook"
        "git-firefly"
        "markdownlint"
        "nix"
      ];

      # Declare and inject extra system packages directly into the environment where the Zed editor runs
      extraPackages = [];

      enableMcpIntegration = false; # Whether to integrate the MCP server config from programs.mcp.servers into programs.zed-editor.userSettings.context_servers. Note: Settings defined in programs.zed-editor.userSettings.context_servers will take precedence over the generated MCP configuration.

      mutableUserKeymaps = true;
      mutableUserTasks = true;
      mutableUserDebug = true;
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

            format_on_save = "on";

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
