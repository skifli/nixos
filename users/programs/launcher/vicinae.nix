{
  hostVars,
  inputs,
  lib,
  pkgs,
  userVars,
  ...
}: {
  home-manager = {
    sharedModules = [inputs.vicinae.homeManagerModules.default];

    users.${userVars.username} = {
      home.packages = with pkgs; [
        sqlite-interactive # Needed for Zed recent projects extension
      ];

      xdg.dataFile."vicinae/snippets/snippets.json".text = ''
        [
          {
            "id": "snp-49bdf73ecdee",
            "name": "TM symbol",
            "data": { "text": "™" },
            "createdAt": 1783760727,
            "updatedAt": 1783760763,
            "expansion": { "keyword": "!tm", "apps": [], "word": true }
          },
          {
            "id": "snp-c33eee8cfd85",
            "name": "UUID",
            "data": { "text": "{uuid}" },
            "createdAt": 1783760855,
            "expansion": { "keyword": "!uuid", "apps": [], "word": true }
          },
          {
            "id": "snp-bd5eaa6ccf2c",
            "name": "Date",
            "data": { "text": "{shell code=\"date\"}" },
            "createdAt": 1783760978,
            "updatedAt": 1783761064,
            "expansion": { "keyword": "!dt", "apps": [], "word": true }
          },
          {
            "id": "snp-2ea1410e2c05",
            "name": "Copyright",
            "data": { "text": "©" },
            "createdAt": 1783761258,
            "expansion": { "keyword": "!c", "apps": [], "word": true }
          },
          {
            "id": "snp-c26a967d3516",
            "name": "Registered trademark",
            "data": { "text": "®" },
            "createdAt": 1783761270,
            "expansion": { "keyword": "!r", "apps": [], "word": true }
          },
          {
            "id": "snp-e5d409811d4d",
            "name": "Degree symbol",
            "data": { "text": "°" },
            "createdAt": 1783761287,
            "updatedAt": 1783761296,
            "expansion": { "keyword": "!deg", "apps": [], "word": true }
          },
          {
            "id": "snp-e4ff4d2be4f7",
            "name": "Right arrow",
            "data": { "text": "→" },
            "createdAt": 1783761339,
            "expansion": { "keyword": "!rar", "apps": [], "word": true }
          },
          {
            "id": "snp-f5fd1d78e7ae",
            "name": "Left arrow",
            "data": { "text": "←" },
            "createdAt": 1783761347,
            "expansion": { "keyword": "!lar", "apps": [], "word": true }
          },
          {
            "id": "snp-cb300880b451",
            "name": "Plus minus",
            "data": { "text": "±" },
            "createdAt": 1783761356,
            "expansion": { "keyword": "!pm", "apps": [], "word": true }
          },
          {
            "id": "snp-7ec49c47e7a6",
            "name": "Minus plus",
            "data": { "text": "∓" },
            "createdAt": 1783761379,
            "updatedAt": 1783761389,
            "expansion": { "keyword": "!mp", "apps": [], "word": true }
          },
          {
            "id": "snp-384a11d556aa",
            "name": "Not equal to",
            "data": { "text": "≠" },
            "createdAt": 1783761403,
            "expansion": { "keyword": "!neq", "apps": [], "word": true }
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
          wifi-commander
          zed-recents
        ]; # Extension names can be found here https://github.com/vicinaehq/extensions/tree/main/extensions

        settings = {
          favorites = [
            "system:run"
            "clipboard:history"
            "power:power-off"
          ];

          close_on_focus_loss = true;
          pop_to_root_on_close = true;
          pop_on_backspace = true;
          escape_key_behavior = "";
          search_files_in_root = true;

          font = {
            rendering = "native";

            normal = {
              family = hostVars.fonts.sansSerif.name;
              size = 10;
            };
          };

          theme = {
            dark = {
              name = "stylix";
              icon_theme = hostVars.icons.dark;
            };

            light = {
              name = "stylix";
              icon_theme = hostVars.icons.light;
            };
          };

          launcher_window = {
            opacity = 0.95;

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

            "@dagimg-dot/store.vicinae.wifi-commander" = {
              preferences = {
                network-cli-tool = "nmcli";
              };

              entrypoints = {
                manage-saved-networks = {alias = "wn";};
                restart-wifi = {alias = "wre";};
                scan-wifi = {alias = "ws";};
                toggle-wifi-off = {alias = "won";};
                toggle-wifi-on = {alias = "wof";};
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
                  if builtins.elem "zen-beta" userVars.programs.browsers
                  then ".config/zen"
                  else ".mozilla/firefox";
              };

              entrypoints = {
                bookmarks = {
                  alias = "fb";
                  enabled = false;
                };
                history = {alias = "fh";};
              };
            };

            "@knoopx/store.vicinae.niri" = {
              entrypoints = {
                layers = {alias = "nla";};
                outputs = {alias = "nou";};
                pick-color = {alias = "cp";};
                windows = {alias = "nwi";};
                workspaces = {alias = "nwo";};
              };
            };

            "@knoopx/store.vicinae.nix" = {
              entrypoints = {
                flake-packages = {alias = "nfp";};
                home-manager-options = {alias = "hm";};
                options = {alias = "no";};
                packages = {alias = "np";};
                pull-requests = {enabled = false;};
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
                sponsor = {enabled = false;};
              };
            };

            developer = {
              enabled = false;
            };

            files = {
              preferences = {
                autoIndexing = true;
                excludedIndexingPaths = [];
                indexingPaths = map (share: share.mountPoint) userVars.networkMounts.nfsShares;
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
                hibernate = {alias = "hb";};
                lock = {alias = "lc";};
                logout = {alias = "lo";};
                power-off = {alias = "sd";};
                reboot = {alias = "rb";};
                soft-reboot = {alias = "sr";};
                suspend = {alias = "ss";};
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
                create = {alias = "sc";};
                manage = {alias = "sm";};
              };
            };

            system = {
              entrypoints = {
                run = {alias = "cmd";};
                toggle-mute = {enabled = false;};
                volume-0 = {enabled = false;};
                volume-100 = {enabled = false;};
                volume-25 = {enabled = false;};
                volume-50 = {enabled = false;};
                volume-75 = {enabled = false;};
                volume-down = {enabled = false;};
                volume-up = {enabled = false;};
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
