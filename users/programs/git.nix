{ pkgs, userVars, ... }:

{
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
            email = userVars.git.email;
            name = userVars.git.name;
          };

          core.editor = userVars.programs.editor;
          init.defaultBranch = "main";

          # TODO: FIXME - Still doesn't work!?
          # Use a credentials file (contains the PAT in the form
          # https://<PAT>@github.com) to avoid interactive prompts.
          credential.helper = "store --file ~/.git-credentials";
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

    # Provide two secret files from the repo's secrets directory.
    # Copy them directly into the user's home so they exist during
    # activation (avoids timing/order issues with activation hooks).
    home.file.".git-credentials" = {
      source = ../${userVars.username}/secrets/github-credentials;
    };

    home.file.".github-pat" = {
      source = ../${userVars.username}/secrets/github-pat;
    };
  };
}
