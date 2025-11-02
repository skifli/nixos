{
  lib,
  pkgs,
  userVars,
  ...
}:

{
  xdg.terminal-exec.settings.default = [ "ghostty.desktop" ];

  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      # Packages for zsh plugins
      chroma
      eza
      fzf
      ripgrep # "completion is already included when installed via package managers"
      # rigrep-all
      zoxide
    ];

    programs = {
      eza = {
        enable = true;
        enableZshIntegration = true;

        colors = "auto";
        git = true;
        icons = "auto";
      };

      fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      /*
        vivid = {
          enable = true;
          enableZshIntegration = true;
        };
      */

      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };

      zsh = {
        enable = true;

        autosuggestion.enable = true;
        enableCompletion = true;
        syntaxHighlighting = {
          enable = true;
        };

        history.size = 100000;

        oh-my-zsh = {
          enable = true;
          plugins = [
            "colored-man-pages"
            "colorize"
            "copyfile"
            "copypath"
            "dirhistory"
            "dotenv"
            "extract"
            "eza"
            "git"
            "history-substring-search"
            "safe-paste"
            "sudo"
            "zoxide"
          ]
          ++ lib.optional (userVars.programs.prompt == "starship") "starship";
        };
      };
    };
  };

  users.users.${userVars.username}.shell = pkgs.zsh;
}
