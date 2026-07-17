{
  config,
  lib,
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      bat
      fd
      pay-respects

      # Packages for zsh plugins
      chroma
      eza
      fzf
      ripgrep # "completion is already included when installed via package managers"
      # rigrep-all
      zoxide
    ];

    xdg.terminal-exec.settings.default = ["ghostty.desktop"];

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

        options = [
          "--cmd cd"
        ];
      };

      zsh = {
        enable = true;
        dotDir = "/home/${userVars.username}"; # Lock in legacy behavior for stateVersion 25.05

        autosuggestion.enable = true;
        enableCompletion = true;
        completionInit = ''
          autoload -Uz compinit

          if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
            compinit
          else
            compinit -C
          fi
        ''; # Source: https://gist.github.com/ctechols/ca1035271ad134841284

        initContent = ''
          eval "$(pay-respects zsh)"
          # Or use eval "$(pay-respects zsh --inline)" for inline mode
        '';

        syntaxHighlighting = {
          enable = true;
        };

        shellAliases = {
          cat = "bat";
          f = "pay-respects";
        };

        history.size = 100000;

        oh-my-zsh = {
          enable = true;
          plugins =
            [
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
