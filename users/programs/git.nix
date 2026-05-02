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

          # Use a credentials file (contains the PAT in the form
          # https://<PAT>@github.com) to avoid interactive prompts.
          "credential.helper" = "store --file ~/.git-credentials";
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
    # Copy them into a managed secrets directory under the user's
    # home and then create symlinks at the well-known locations.
    # This mirrors how other secret files are projected while keeping
    # the canonical copy in ~/.local/share/secrets.
    home.file.".local/share/secrets/github-credentials" = {
      source = ../../ami/secrets/github-credentials;
    };

    home.file.".local/share/secrets/github-pat" = {
      source = ../../ami/secrets/github-pat;
    };

    home.activation.copyGithubSecrets = {
      text = ''
        mkdir -p "$HOME/.local/share/secrets"
        chmod 700 "$HOME/.local/share/secrets"
        ln -sf "$HOME/.local/share/secrets/github-credentials" "$HOME/.git-credentials"
        ln -sf "$HOME/.local/share/secrets/github-pat" "$HOME/.github-pat"
        chmod 600 "$HOME/.local/share/secrets/github-credentials" "$HOME/.local/share/secrets/github-pat"
      '';
      deps = [ "home-manager" ];
    };
  };
}
