{
  config,
  lib,
  pkgs,
  userVars,
  ...
}:
let
  hasGitCredential = builtins.hasAttr "${userVars.username}-github-credentials" config.age.secrets;

  readOnlyCredentialHelper = pkgs.writeShellScriptBin "git-credential-agenix" ''
    case "''${1:-}" in
      get)
        exec ${pkgs.git}/bin/git credential-store \
          --file=/home/${userVars.username}/.git-credentials get
        ;;
      store | erase)
        # This credential file is deployed by agenix and is intentionally
        # read-only. Rotate it by updating the encrypted secret instead.
        exit 0
        ;;
      *)
        exit 0
        ;;
    esac
  '';
in
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
            inherit (userVars.git) email name;
          };

          gpg = {
            format = "ssh";
          };

          commit = {
            gpgsign = true;
          };

          tag = {
            gpgsign = true;
          };

          core.editor = userVars.programs.editor;
          init.defaultBranch = "main";

          # Read credentials from the agenix-managed file without prompting
          # the desktop keyring. Writes are handled by rotating the age secret.
          credential.helper = lib.mkIf hasGitCredential "!${readOnlyCredentialHelper}/bin/git-credential-agenix";
        };

        signing = {
          format = "ssh";
          key = "/home/${userVars.username}/.ssh/id_ed25519_signing.pub";
          signByDefault = true;
        };
      };

      gh = {
        enable = true;

        hosts = {
          "github.com" = {
            user = userVars.git.name;
          };
        };

        gitCredentialHelper = {
          enable = !hasGitCredential;
          hosts = [
            "https://github.com"
            "https://gist.github.com"
          ];
        };

        extensions = with pkgs; [
          gh-dash
          gh-markdown-preview
          gh-notify
        ];

        settings = {
          git_protocol = "ssh";
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
