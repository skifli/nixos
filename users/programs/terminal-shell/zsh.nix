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

        # Force the functions to the bottom of .zshrc
        initContent = lib.mkOrder 1500 ''
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
              blammo_in=$(cat /tmp/blammo 2>/dev/null)
            elif [ -f "$HOME/.cache/mine/blammo" ]; then
              blammo_in=$(cat "$HOME/.cache/mine/blammo" 2>/dev/null)
            fi
          }

          # -t 0 prevents disappearing until manual closing

          safe_reboot() {
            local target_action=$1
            shift

            if [ -f /tmp/gpu-screen-recorder.pid ] && kill -0 $(cat /tmp/gpu-screen-recorder.pid) 2>/dev/null; then
              notify-send -e -a nixOS -t 0 -u critical -i "/home/${userVars.username}/.local/share/misc/nix-snowflake-rainbow.svg" "Shutdown refused" "Screen recording is currently in progress!"
              return 1
            fi

            if pgrep -f "nixos-rebuild|nh os switch" >/dev/null; then
              notify-send -e -a nixOS -t 0 -u critical -i "/home/${userVars.username}/.local/share/misc/nix-snowflake-rainbow.svg" "Shutdown refused" "nixOS system rebuild is currently active!"
              return 1
            fi

            urgent_wins=$(niri msg --json windows 2>/dev/null | jq -r '.[] | select(.is_urgent == true) | .id')
            if [ -n "$urgent_wins" ]; then
              notify-send -e -a nixOS -t 0 -u critical -i "/home/${userVars.username}/.local/share/misc/nix-snowflake-rainbow.svg" "Shutdown refused" "There are urgent windows requiring attention!"
              return 1
            fi

            systemctl "$target_action" "$@"
          }

          alias reboot="safe_reboot reboot"
          alias shutdown="safe_reboot shutdown"
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
