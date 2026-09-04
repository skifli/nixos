{
  config,
  lib,
  pkgs,
  userVars,
  ...
}:
let
  blockers = userVars.historyBlockers or { };

  # Exact matches: "ls", "cd .."
  exactPatterns = blockers.exact or [ ];

  # Prefix matches: "copyl", "copyl *"
  prefixPatterns = lib.concatMap (p: [
    p
    "${p} *"
  ]) (blockers.prefixes or [ ]);

  # Sensitive exports: "export *TOKEN*"
  sensitivePatterns = map (s: "export *${s}*") (blockers.sensitiveKeywords or [ ]);

  generatedIgnorePatterns = exactPatterns ++ prefixPatterns ++ sensitivePatterns;
in
{
  home-manager.users.${userVars.username} = {
    home = {
      packages = with pkgs; [
        bat
        fd

        # Packages for zsh plugins
        chroma
        eza
        fzf
        ripgrep # "completion is already included when installed via package managers"
        repgrep
        # rigrep-all
        zoxide
      ];
    };

    xdg.terminal-exec.settings.default = [ "${userVars.programs.terminal}.desktop" ];

    programs = {
      pay-respects = {
        enable = true;
        enableZshIntegration = true; # Auto sets up `eval "$(pay-respects zsh)"`

        options = [
          "--alias"
          "f"
        ]; # Auto sets up `f = "pay-respects"` alias;
      };

      carapace = {
        enable = true;
        enableZshIntegration = true;

        ignoreCase = true;
      };

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

      vivid = {
        enable = true;
        enableZshIntegration = true;
      };

      zoxide = {
        enable = true;
        enableZshIntegration = true;

        options = [
          "--cmd cd" # Bind cd to z
        ];
      };

      zsh = {
        enable = true;

        shellGlobalAliases = userVars.zsh.shellGlobalAliases;

        # Below I opt-in to the modern XDG directory layout (~/.config/zsh).
        # This is the same default behavior of modern Home Manager (26.05+),
        # without needing to bump stateVersion, which for me is before said
        # needed version and should not be bumped in general.
        dotDir = "${config.home-manager.users.${userVars.username}.home.homeDirectory}/.config/zsh"; # Directory where the zsh configuration and more should be located, relative to the users home directory. The default is the home directory.

        autosuggestion.enable = true;
        enableCompletion = true; # Enable zsh completion. Don\u2019t forget to add environment.pathsToLink = [ "/share/zsh" ]; to your system configuration to get completion for system packages (e.g. systemd).
        completionInit = builtins.readFile ./zsh/completionInit.sh;

        # Force the functions to the bottom of .zshrc
        initContent = lib.mkOrder 1500 ''
          export WL_COPY_BIN="${pkgs.wl-clipboard}/bin/wl-copy"

          ${builtins.readFile ./zsh/initContent.sh}
        '';

        syntaxHighlighting = {
          enable = true;
        };

        shellAliases = {
          rgr = "repgrep";
        };

        history = {
          size = 100000;
          save = 100000;
          saveNoDups = true;
          ignoreDups = true; # Do not enter duplicate commands
          ignoreSpace = true; # Ignore commands starting with a space (e.g., secrets)
          expireDuplicatesFirst = true; # When history fills up, purge duplicates first
          share = true; # Share command history across open zsh sessions (better than append imo)
          extended = true; # Save timestamps alongside commands

          ignorePatterns = generatedIgnorePatterns;
        };

        historySubstringSearch = {
          enable = true;
        };

        autocd = true; # Change to a directory by typing its name (no need for `cd`)

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
            "git"
            "safe-paste"
            "sudo"
          ]
          ++ lib.optional (userVars.programs.prompt == "starship") "starship";
        };
      };
    };
  };

  environment.pathsToLink = [ "/share/zsh" ];

  users.users.${userVars.username}.shell = pkgs.zsh;
}
