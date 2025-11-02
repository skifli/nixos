{ userVars, ... }:

{
  home-manager.users.${userVars.username} = {
    programs.zed-editor = {
      enable = true;

      extensions = [
        "git-firefly"
        "markdownlint"
        "nix"
      ];

      userSettings = {
        disable_ai = true;

        telemetry = {
          metrics = false;
        };

        autosave = "on_focus_change";
        format_on_save = "on";
        relative_line_numbers = false;
        helix_mode = true; # Also enables vim mode
        show_close_button = "hidden";

        languages = {
          Nix = {
            language_servers = [
              "nixd"
              "!nil"
            ];

            formatter = {
              external = {
                command = "nixfmt";
              };
            };
          };
        };
      };
    };
  };
}
