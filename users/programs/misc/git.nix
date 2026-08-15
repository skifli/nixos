{
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    programs = {
      delta = {
        enable = true;

        enableGitIntegration = true;
      };

      git = {
        enable = true;
        settings = {
          user = {
            inherit (userVars.git) email name;
          };

          core.editor = userVars.programs.editor;
          init.defaultBranch = "main";

          # Use a credentials file to avoid interactive prompts.
          # The file should contain lines like:
          # https://<TOKEN>@github.com
          credential = {
            helper = "store --file ~/.git-credentials";
            useHttpPath = true;
          };
        };
      };

      gh = {
        enable = true;

        extensions = with pkgs; [
          gh-dash
          gh-markdown-preview
          gh-notify
        ];

        settings = {
          git_protocol = "https";
          prompt = "enabled";

          aliases = {
            co = "pr checkout";
            pv = "pr view";
          };
        };
      };

      lazygit = {
        enable = true;
      };
    };
  };
}
