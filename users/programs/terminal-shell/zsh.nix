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

        # Below I opt-in to the modern XDG directory layout (~/.config/zsh).
        # This is the same default behavior of modern Home Manager (26.05+),
        # without needing to bump stateVersion, which for me is before said
        # needed version and should not be bumped in general.
        dotDir = ".config/zsh"; # Directory where the zsh configuration and more should be located, relative to the users home directory. The default is the home directory.

        autosuggestion.enable = true;
        enableCompletion = true;
        completionInit = builtins.readFile ./zsh/completionInit.sh;

        # Force the functions to the bottom of .zshrc
        initContent = lib.mkOrder 1500 builtins.readFile ./zsh/initContent.sh;

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
