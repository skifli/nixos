{
  commonHostVars,
  hostVars,
  lib,
  pkgs,
  username,
  ...
}: let
  common = import ../common/variables.nix {inherit commonHostVars hostVars lib pkgs username;};

  # Dynamic SafeEyes window rules based on ze outputs
  safeEyesRules =
    lib.imap0 (idx: outputName: {
      match._props = {
        app-id._raw = ''r#"(?i)io\.github\.slgobinath\.SafeEyes"#'';
        title._raw = ''r#"(?i)SafeEyes-${toString idx}"#'';
      };
      open-on-output = outputName;
      open-focused = true;
      open-fullscreen = true;
    })
    hostVars.orderedOutputs;
in
  common
  // rec {
    extraGroups = [
      "input" # Needed for Activity Watch / ActivityWatch / AW / aw (just so if I ever search it comes up in any form lol)
    ];

    niri = {
      spawn-sh-at-startup = "$HOME/.local/bin/startup.sh \"${builtins.elemAt hostVars.orderedOutputs 0}\" \"${builtins.elemAt hostVars.orderedOutputs 1}\"";

      binds = {
        "Mod+Shift+A" = {
          _props = {
            hotkey-overlay-title = null;
            allow-inhibiting = false;
          };
          spawn = [
            "/home/${username}/.local/bin/find-or-make.sh"
            "app_id"
            "anytype"
            "anytype"
          ];
        };
        "Mod+Shift+N" = {
          _props = {
            hotkey-overlay-title = null;
            allow-inhibiting = false;
          };
          spawn = [
            "/home/${username}/.local/bin/find-or-make.sh"
            "app_id"
            "anki"
            "anki"
          ];
        };
        "Mod+Shift+C" = {
          _props = {
            hotkey-overlay-title = null;
            allow-inhibiting = false;
          };
          spawn = [
            "/home/${username}/.local/bin/find-or-make.sh"
            "app_id"
            "ferdium"
            "ferdium"
          ];
        };
        "Mod+Shift+Z" = {
          _props = {
            hotkey-overlay-title = null;
            allow-inhibiting = false;
          };
          spawn = [
            "/home/${username}/.local/bin/find-or-make.sh"
            "app_id"
            "zen-beta"
            "zen-beta"
          ];
        };
        "Mod+Shift+D" = {
          _props = {
            hotkey-overlay-title = null;
            allow-inhibiting = false;
          };
          spawn = [
            "/home/${username}/.local/bin/find-or-make.sh"
            "title"
            "TigerVNC"
            "TigerVNC"
          ];
        };
        "Mod+Shift+Y" = {
          _props = {
            hotkey-overlay-title = null;
            allow-inhibiting = false;
          };
          spawn = [
            "/home/${username}/.local/bin/find-or-make.sh"
            "app_id"
            "affinity.exe"
            "affinity-v3"
          ];
        };
      };

      window-rules =
        [
          {
            # Cus sometimes it doesn't open in 60 seconds or summat idk don't do at-startup
            match._props.app-id._raw = ''r#"(?i)gcr-prompter"#'';
            block-out-from = "screen-capture";
            open-focused = true;
            # open-on-workspace = "1"; # Was annoying because sometimes it opens later on
          }

          {
            match._props = {
              title._raw = ''r#"(?i)Anki Pomodoro"#'';
            };
            open-floating = true;
            open-on-workspace = "5";
            default-floating-position._props = {
              x = 20;
              y = 20;
              relative-to = "top-left";
            };
            default-column-width = {
              proportion = 0.50;
            };
            default-window-height = {
              proportion = 0.30;
            };
          }

          ## https://www.reddit.com/r/niri/comments/1skrhet/steam_notifications_appear_in_the_center_of_the/
          {
            match._props = {
              app-id._raw = ''r#"(?i)steam"#'';
              title._raw = ''r#"(?i)notificationtoasts_\d+_desktop"#'';
            };
            open-maximized = false;
            open-focused = false;
            default-floating-position._props = {
              x = 0;
              y = 0;
              relative-to = "bottom-right";
            };
          }

          # Anki - maximize
          {
            match._props.app-id._raw = ''r#"(?i)anki"#'';
            open-maximized = true;
          }

          {
            match._props.app-id._raw = ''r#"(?i)anki"#'';
            match._props.title._raw = ''r#"(?i)Study Deck"#'';
            open-floating = true;
            default-column-width = {
              proportion = 0.75;
            };
            default-window-height = {
              proportion = 0.75;
            };
          }

          # Anytype - maximize
          {
            match._props.title._raw = ''r#"(?i)anytype"#'';
            open-maximized = true;
          }

          # Ferdium - maximize
          {
            match._props.app-id._raw = ''r#"(?i)ferdium"#'';
            open-maximized = true;
          }

          # Evince (PDF viewer) - maximize
          {
            match._props.app-id._raw = ''r#"(?i)org\.gnome\.Evince"#'';
            open-maximized = true;
          }

          # Wayle settings - maximize
          {
            match._props.app-id._raw = ''r#"(?i)com\.wayle\.settings"#'';
            open-maximized = true;
          }

          # Zed editor - maximize (in here and not users/programs/compositor/niri/window-rules.nix due to it being zeditor in the file path but that not matching the app-id)
          {
            match._props.app-id._raw = ''r#"(?i)dev\.zed\.Zed"#'';
            open-maximized = true;
          }

          # FreeRDP - maximize
          {
            match._props.title._raw = ''r#"(?i)TigerVNC"#'';
            open-maximized = true;
            open-focused = true;

            # Properties that apply once upon window opening.
            default-column-width = {
              proportion = 1.0;
            };
            default-window-height = {
              proportion = 1.0;
            };
          }

          # SafeEyes - maximize
          {
            match._props = {
              app-id._raw = ''r#"(?i)io\.github\.slgobinath\.SafeEyes"#'';
              title._raw = ''r#"(?i)Safe Eyes"#'';
            };
            open-maximized = true;
          }
        ]
        ++ safeEyesRules;
    };

    kanata.keyboards = {
      calliope-uk = {
        devices = []; # Grabs all connected desktop keyboards
        extraDefCfg = "process-unmapped-keys yes";

        # Use https://jtroo.github.io/ to verify
        config = ''
          ;; Physical - Lenovo USB Calliope UK ISO Map
          (defsrc
            grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]
            caps a    s    d    f    g    h    j    k    l    ;    bksl ret
            lsft 102d z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc            ralt rmet rctl
          )

          (defalias
            spc (tap-hold 150 250 spc (layer-toggle mouse))

            zmin (multi lctl eql)
            zmout (multi lctl min)

            ntog (layer-switch mouse-lock)
            nunlock (layer-switch default)
          )

          (deflayer default
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _              @spc           _    _    _
          )

          (deflayer mouse
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    lmet (mwheel-left 20 60) (movemouse-accel-up 5 450 1 8) (mwheel-right 20 60) lalt _    @zmin (mwheel-down 30 60) (mwheel-up 30 60) @zmout _    _
            _    lsft (movemouse-accel-left 5 450 1 8) (movemouse-accel-down 5 450 1 8) (movemouse-accel-right 5 450 1 8) lctl _    mlft mrgt (layer-toggle mouse-slow) _    _    _
            _    _    _    _    _    _    _    @ntog mmid pgup pgdn _    _
            _    _    _              _              _    _    _
          )

          (deflayer mouse-lock
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    lmet (mwheel-left 20 60) (movemouse-accel-up 5 450 1 8) (mwheel-right 20 60) lalt _    @zmin (mwheel-down 30 60) (mwheel-up 30 60) @zmout _    _
            _    lsft (movemouse-accel-left 5 450 1 8) (movemouse-accel-down 5 450 1 8) (movemouse-accel-right 5 450 1 8) lctl _    mlft mrgt (layer-toggle mouse-slow) _    _    _
            _    _    _    _    _    _    _    @nunlock mmid pgup pgdn _    _
            _    _    _              _              _    _    _
          )

          (deflayer mouse-slow
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _    (movemouse-up 20 1) _    _    _    _    _    _    _    _    _
            _    _    (movemouse-left 20 1) (movemouse-down 20 1) (movemouse-right 20 1) _    _    _    _    _    _    _    _
            _    _    _    _    _    _    _    XX   _    _    _    _    _
            _    _    _              _              _    _    _
          )
        '';
      };
    };

    bar = {
      output = builtins.elemAt hostVars.orderedOutputs 1;
    };

    programs =
      common.programs
      // {
        ergonomics = "safeeyes";
        login-manager = "greetd";
        terminal = "ghostty";
        other =
          common.programs.other
          ++ [
            "affinity"
            "opentabletdriver"
            "steam"
          ];
      };

    stylixTargetsWhitelist = common.stylixTargetsWhitelist ++ [programs.terminal];

    shellScripts =
      common.shellScripts
      // {
        "focus-focused-monitor" = "niri msg action focus-monitor \"${builtins.elemAt hostVars.orderedOutputs 0}\"";
        "focus-second-monitor" = "niri msg action focus-monitor \"${builtins.elemAt hostVars.orderedOutputs 1}\"";
        "is-focused-monitor-focused" = "niri msg focused-output | grep -q \"${builtins.elemAt hostVars.orderedOutputs 0}\"";
        "is-second-monitor-focused" = "niri msg focused-output | grep -q \"${builtins.elemAt hostVars.orderedOutputs 1}\"";
      };
  }
