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

          if [[ -n ''${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
            compinit
          else
            compinit -C
          fi
        ''; # Source: https://gist.github.com/ctechols/ca1035271ad134841284

        initContent = ''
          eval "$(pay-respects zsh)"

          # Source for the three below - https://github.com/Axlefublr/dotfiles

          # Axlefublr da goat: Copy file path as Wayland URI list
          copyl() {
            if [ -n "$1" ]; then
              local abs_path
              abs_path=$(realpath "$1")
              echo -n "file://$abs_path" | ${pkgs.wl-clipboard}/bin/wl-copy -t text/uri-list
              notify-send -e -a "nixos" -i "/home/${userVars.username}/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 2500 "Clipboard" "Copied URI to clipboard: file://$abs_path"
            else
              echo "Usage: copyl <file>"
            fi
          }

          # Axlefublr da goat: Read file selection buffer
          blammo() {
            if [ -f /tmp/blammo ]; then
              cat /tmp/blammo
            elif [ -f "$HOME/.cache/mine/blammo" ]; then
              cat "$HOME/.cache/mine/blammo"
            else
              echo "No blammo selection found"
            fi
          }

          # Zsh prompt hook: Populate $in with Yazi selection
          precmd() {
            if [ -f /tmp/blammo ]; then
              in=$(cat /tmp/blammo 2>/dev/null)
            elif [ -f "$HOME/.cache/mine/blammo" ]; then
              in=$(cat "$HOME/.cache/mine/blammo" 2>/dev/null)
            fi
          }
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
