{
  commonHostVars,
  config,
  inputs,
  lib,
  pkgs,
  userVars,
  ...
}:
{
  imports = [
    inputs.vicinae.nixosModules.default
  ];

  programs.vicinae.input-server.enable = true; # Needed for snippets

  home-manager = {
    sharedModules = [ inputs.vicinae.homeManagerModules.default ];

    users.${userVars.username} = {
      home.packages = with pkgs; [
        sqlite-interactive # Needed for Zed recent projects extension
        didyoumean
      ];

      xdg.dataFile."vicinae/snippets/snippets.json".text = ''
        [
          {
            "id": "snp-49bdf73ecdee",
            "name": "TM symbol",
            "data": { "text": "™" },
            "createdAt": 1783760727,
            "updatedAt": 1783760763,
            "expansion": { "keyword": "!tm", "apps": [], "word": false }
          },
          {
            "id": "snp-c33eee8cfd85",
            "name": "UUID",
            "data": { "text": "{uuid}" },
            "createdAt": 1783760855,
            "expansion": { "keyword": "!uuid", "apps": [], "word": false }
          },
          {
            "id": "snp-bd5eaa6ccf2c",
            "name": "Date",
            "data": { "text": "{shell code=\"date\"}" },
            "createdAt": 1783760978,
            "updatedAt": 1783761064,
            "expansion": { "keyword": "!dt", "apps": [], "word": false }
          },
          {
            "id": "snp-2ea1410e2c05",
            "name": "Copyright",
            "data": { "text": "©" },
            "createdAt": 1783761258,
            "expansion": { "keyword": "!c", "apps": [], "word": false }
          },
          {
            "id": "snp-c26a967d3516",
            "name": "Registered trademark",
            "data": { "text": "®" },
            "createdAt": 1783761270,
            "expansion": { "keyword": "!r", "apps": [], "word": false }
          },
          {
            "id": "snp-e5d409811d4d",
            "name": "Degree symbol",
            "data": { "text": "°" },
            "createdAt": 1783761287,
            "updatedAt": 1783761296,
            "expansion": { "keyword": "!deg", "apps": [], "word": false }
          },
          {
            "id": "snp-e4ff4d2be4f7",
            "name": "Right arrow",
            "data": { "text": "→" },
            "createdAt": 1783761339,
            "expansion": { "keyword": "!rar", "apps": [], "word": false }
          },
          {
            "id": "snp-f5fd1d78e7ae",
            "name": "Left arrow",
            "data": { "text": "←" },
            "createdAt": 1783761347,
            "expansion": { "keyword": "!lar", "apps": [], "word": false }
          },
          {
            "id": "snp-cb300880b451",
            "name": "Plus minus",
            "data": { "text": "±" },
            "createdAt": 1783761356,
            "expansion": { "keyword": "!pm", "apps": [], "word": false }
          },
          {
            "id": "snp-7ec49c47e7a6",
            "name": "Minus plus",
            "data": { "text": "∓" },
            "createdAt": 1783761379,
            "updatedAt": 1783761389,
            "expansion": { "keyword": "!mp", "apps": [], "word": false }
          },
          {
            "id": "snp-384a11d556aa",
            "name": "Not equal to",
            "data": { "text": "≠" },
            "createdAt": 1783761403,
            "expansion": { "keyword": "!neq", "apps": [], "word": false }
          },
          {
            "id": "snp-7e0f1c8d3a2b",
            "name": "GitHub PAT",
            "data": { "text": "{shell code=\"cat ${
              config.age.secrets."${userVars.username}-github-pat".path
            }\"}" },
            "createdAt": 1783761415,
            "expansion": { "keyword": "!pat", "apps": [], "word": false }
          },
          {
            "id": "snp-a81d4f29e10c",
            "name": "Git: amend and force push",
            "data": { "text": "git add -A && git commit --amend --no-edit && git push --force-with-lease" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!gamend", "apps": [], "word": false }
          },
          {
            "id": "snp-b72e503af21d",
            "name": "Git: undo last commit (keep staged)",
            "data": { "text": "git reset --soft HEAD~1" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!gundo", "apps": [], "word": false }
          },
          {
            "id": "snp-c63f614b032e",
            "name": "Git: hard reset to origin main",
            "data": { "text": "git fetch origin main && git checkout main && git reset --hard origin/main" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!greset", "apps": [], "word": false }
          },
          {
            "id": "snp-d54a725c143f",
            "name": "Git: discard all local changes",
            "data": { "text": "git reset --hard HEAD && git clean -fd" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!gnuke", "apps": [], "word": false }
          },
          {
            "id": "snp-e45b836d254a",
            "name": "Git: quick WIP commit + push",
            "data": { "text": "git add -A && git commit -m \"wip: save progress\" && git push" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!gwip", "apps": [], "word": false }
          },
          {
            "id": "snp-f36c947e365b",
            "name": "Git: prune merged local branches",
            "data": { "text": "git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -D" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!gprune", "apps": [], "word": false }
          },
          {
            "id": "snp-027d058f476c",
            "name": "Git: current short SHA",
            "data": { "text": "git rev-parse --short HEAD" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!gsha", "apps": [], "word": false }
          },
          {
            "id": "snp-138e169a587d",
            "name": "Git: current branch name",
            "data": { "text": "git rev-parse --abbrev-ref HEAD" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!gbranch", "apps": [], "word": false }
          },
          {
            "id": "snp-46b1492d8ba0",
            "name": "Git: safe pull w/ rebase + autostash",
            "data": { "text": "git pull --rebase --autostash" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!gpullr", "apps": [], "word": false }
          },
          {
            "id": "snp-57c25a3e9cb1",
            "name": "Git: push new branch + set upstream",
            "data": { "text": "git push -u origin HEAD" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!gpushu", "apps": [], "word": false }
          },
          {
            "id": "snp-68d36b4fac12",
            "name": "Git: show unpushed commits",
            "data": { "text": "git log @{u}..HEAD --oneline" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!gunpushed", "apps": [], "word": false }
          },
          {
            "id": "snp-79e47c50bd23",
            "name": "Git: full recursive submodule sync and update",
            "data": { "text": "git submodule sync --recursive && git submodule update --init --recursive" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!gsub", "apps": [], "word": false }
          },
          {
            "id": "snp-8af58d61ce34",
            "name": "Git: stash all (including untracked files)",
            "data": { "text": "git stash -u" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!gstash", "apps": [], "word": false }
          },
          {
            "id": "snp-9b069e72df45",
            "name": "Git: nuclear clean (untracked + gitignore caches)",
            "data": { "text": "git clean -xdf" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!gcleanall", "apps": [], "word": false }
          },
          {
            "id": "snp-0c17af83e056",
            "name": "Git: diff only staged changes",
            "data": { "text": "git diff --staged" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!gdiffs", "apps": [], "word": false }
          },
          {
            "id": "snp-1d28b094f167",
            "name": "Git: pretty compact commit graph",
            "data": { "text": "git log --graph --oneline --decorate --all" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!glog", "apps": [], "word": false }
          },
          {
            "id": "snp-2e39c1a50278",
            "name": "Git: stash, pull, pop",
            "data": { "text": "git stash -u && git pull && git stash pop" },
            "createdAt": 1788694231,
            "expansion": { "keyword": "!gsp", "apps": [], "word": false }
          }
        ]
      '';

      programs.vicinae = {
        enable = true;

        systemd = {
          autoStart = true;
          enable = true;
        };

        extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
          clean-keyboard
          # dbus # Packaging is disabled - https://github.com/vicinaehq/extensions/pull/61
          firefox
          it-tools
          niri
          nix
          port-killer
          process-manager
          protondb-search
          # systemd # Same as above...
          zed-recents
        ]; # Extension names can be found here https://github.com/vicinaehq/extensions/tree/main/extensions

        settings = {
          favorites = [
            "system:run"
            "files:search"
            "clipboard:history"
            "power:power-off"
          ];

          close_on_focus_loss = true;
          pop_to_root_on_close = true;
          pop_on_backspace = true;
          escape_key_behavior = "";
          search_files_in_root = true;
          # encrypt_sensitive_data = true; - Causing issues right now https://github.com/vicinaehq/vicinae/issues/1632
          encrypt_sensitive_data = false;

          font = {
            rendering = "native";

            normal = {
              family = commonHostVars.fonts.sansSerif.name;
              size = 10;
            };
          };

          theme = {
            dark = {
              name = "stylix";
              icon_theme = commonHostVars.icons.dark;
            };

            light = {
              name = "stylix";
              icon_theme = commonHostVars.icons.light;
            };
          };

          launcher_window = {
            opacity = lib.mkForce 0.9;
            material = "blur"; # Otherwise breaks blur

            compact_mode = {
              enabled = false;
            };
          };

          providers = {
            "@LuggaPugga/store.vicinae.port-killer" = {
              entrypoints = {
                port-killer = {
                  alias = "kp";
                };
              };
            };

            "@fbosch/store.vicinae.protondb-search" = {
              entrypoints = {
                protondb-search = {
                  alias = "pdb";
                };
              };
            };

            "@knoopx/store.vicinae.firefox" = {
              preferences = {
                profile_dir =
                  if builtins.elem "zen-beta" userVars.programs.browsers then ".config/zen" else ".mozilla/firefox";
              };

              entrypoints = {
                bookmarks = {
                  alias = "fb";
                  enabled = false;
                };
                history = {
                  alias = "fh";
                };
              };
            };

            "@knoopx/store.vicinae.niri" = {
              entrypoints = {
                layers = {
                  alias = "nla";
                };
                outputs = {
                  alias = "nou";
                };
                pick-color = {
                  alias = "cp";
                };
                windows = {
                  alias = "nwi";
                };
                workspaces = {
                  alias = "nwo";
                };
              };
            };

            "@knoopx/store.vicinae.nix" = {
              entrypoints = {
                flake-packages = {
                  alias = "nfp";
                };
                home-manager-options = {
                  alias = "hm";
                };
                options = {
                  alias = "no";
                };
                packages = {
                  alias = "np";
                };
                pull-requests = {
                  enabled = false;
                };
              };
            };

            "@knoopx/store.vicinae.systemd" = {
              entrypoints = {
                services = {
                  alias = "se";
                };
              };
            };

            "@leonkohli/store.vicinae.process-manager" = {
              preferences = {
                clear-search-after-kill = false;
                close-window-after-kill = false;
                process-limit = 100;
                refresh-interval = 1000;
                search-in-paths = true;
                search-in-pid = true;
                show-path = false;
                show-pid = true;
                show-system-processes = true;
                sort-by-memory = false;
              };
            };

            "@xevrion/store.vicinae.clean-keyboard" = {
              entrypoints = {
                clean-keyboard = {
                  alias = "ck";
                };
              };
            };

            browser-extension = {
              enabled = false;

              entrypoints = {
                shortcut-active-tab = {
                  enabled = false;
                };
              };
            };

            clipboard = {
              preferences = {
                encryption = true;
                eraseOnStartup = false;
                ignorePasswords = true;
                monitoring = true;
              };

              entrypoints = {
                history = {
                  alias = "ch";
                };
              };
            };

            core = {
              entrypoints = {
                search-emojis = {
                  alias = "em";
                };
                sponsor = {
                  enabled = false;
                };
              };
            };

            developer = {
              enabled = false;
            };

            files = {
              entrypoints = {
                search = {
                  alias = "fs";
                };
              };
              preferences = {
                autoIndexing = true;
                excludedIndexingPaths = [ ];
                indexingPaths = map (share: share.mountPoint) userVars.networkMounts.nfsShares ++ [
                  "/home/${userVars.username}/Downloads"
                  "/home/${userVars.username}/Documents"
                  "/home/${userVars.username}/Pictures"
                  "/home/${userVars.username}/Videos"
                  "/home/${userVars.username}/nixos"
                ];
              };
            };

            font = {
              entrypoints = {
                browse = {
                  alias = "sf";
                };
              };
            };

            manage-shortcuts = {
              enabled = false;
            };

            power = {
              entrypoints = {
                hibernate = {
                  alias = "hb";
                };
                lock = {
                  alias = "lc";
                };
                logout = {
                  alias = "lo";
                };
                power-off = {
                  alias = "sd";
                };
                reboot = {
                  alias = "rb";
                };
                soft-reboot = {
                  alias = "sr";
                };
                suspend = {
                  alias = "ss";
                };
              };
            };

            snippets = {
              preferences = {
                enabled = true;
                keyDelay = 0.1;
                layout = "";
                prePasteDelay = 0;
                undo = true;
              };
              entrypoints = {
                create = {
                  alias = "sc";
                };
                manage = {
                  alias = "sm";
                };
              };
            };

            system = {
              entrypoints = {
                run = {
                  alias = "cmd";
                };
                toggle-mute = {
                  enabled = false;
                };
                volume-0 = {
                  enabled = false;
                };
                volume-100 = {
                  enabled = false;
                };
                volume-25 = {
                  enabled = false;
                };
                volume-50 = {
                  enabled = false;
                };
                volume-75 = {
                  enabled = false;
                };
                volume-down = {
                  enabled = false;
                };
                volume-up = {
                  enabled = false;
                };
              };
            };

            theme = {
              enabled = false;
            };

            wm = {
              enabled = false;
            };
          };
        };
      };
    };
  };
}
