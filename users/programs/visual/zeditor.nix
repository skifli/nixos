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
        # Core & Features
        disable_ai = true;
        autosave = "on_focus_change";
        format_on_save = "on";
        relative_line_numbers = "disabled";
        helix_mode = false;
        vim_mode = false;
        show_signature_help_after_edits = false;
        auto_signature_help = true;
        autoscroll_on_clicks = false;
        mouse_wheel_zoom = true;
        scroll_beyond_last_line = "off";
        double_click_in_multibuffer = "select";
        when_closing_with_no_tabs = "keep_window_open";
        proxy = "";
        colorize_brackets = true;
        soft_wrap = "editor_width";
        auto_update = false;
        lsp_document_colors = "inlay";
        code_lens = "on";

        # Telemetry
        telemetry = {
          metrics = false;
        };

        # Git
        git = {
          inline_blame = {
            show_commit_summary = false;
          };
        };

        # Terminal
        terminal = {
          toolbar = {
            breadcrumbs = false;
          };
          font_size = 12.0;
          show_count_badge = true;
        };

        # UI & Windows
        window_decorations = "client";
        use_system_window_tabs = false;
        preview_tabs = {
          enable_preview_from_file_finder = true;
        };
        tab_bar = {
          show_pinned_tabs_in_separate_row = false;
        };
        title_bar = {
          button_layout = "";
          show_menus = false;
          show_branch_status_icon = true;
        };
        status_bar = {
          show_active_file = true;
          line_endings_button = true;
        };
        diagnostics = {
          inline = {
            enabled = true;
          };
        };
        inlay_hints = {
          show_background = true;
          enabled = true;
        };
        toolbar = {
          code_actions = true;
        };
        which_key = {
          enabled = true;
        };
        sticky_scroll = {
          enabled = true;
        };

        # Minimap
        minimap = {
          current_line_highlight = "all";
          thumb_border = "left_open";
          thumb = "always";
          show = "auto";
        };

        # Typography & Themes
        text_rendering_mode = "platform_default";
        ui_font_weight = 400.0;
        buffer_line_height = "standard";
        buffer_font_size = 12.0;

        # Panels & Layouts
        tabs = {
          file_icons = true;
          git_status = true;
        };
        project_panel = {
          diagnostic_badges = true;
          git_status_indicator = true;
          bold_folder_labels = false;
          entry_spacing = "standard";
          default_width = 240.0;
          button = true;
          dock = "left";
        };
        outline_panel = {
          dock = "left";
        };
        collaboration_panel = {
          dock = "left";
        };
        git_panel = {
          show_count_badge = true;
          file_icons = false;
          tree_view = true;
          dock = "right";
        };
        agent = {
          dock = "right";
          favorite_models = [];
          model_parameters = [];
        };

        # Language Specific Configurations
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
