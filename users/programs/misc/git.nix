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
        };

        signing = {
          format = "ssh";
          key = "/home/${userVars.username}/.ssh/id_ed25519_signing.pub";
          signByDefault = true;
        };
      };

      gh = {
        enable = true;

        # Let GitHub CLI act as Git's credential helper
        gitCredentialHelper = {
          enable = true;
          hosts = ["https://github.com" "https://gist.github.com"];
        };

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
