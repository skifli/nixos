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
            email = userVars.git.name;
            name = userVars.git.email;
          };

          core.editor = userVars.programs.editor;
          init.defaultBranch = "main";
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
