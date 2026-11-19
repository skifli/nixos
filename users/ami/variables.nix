{
  commonHostVars,
  hostVars,
  lib,
  pkgs,
  username,
  ...
}:
let
  protectedCloseApps =
    if hostVars.hostname == "lyra" then
      [
        {
          appId = "io.github.slgobinath.SafeEyes";
          name = "SafeEyes";
          icon = "safeeyes-icon.png";
          message = "Use its own break controls so the break is recorded correctly.";
          mainWindowTitle = "Safe Eyes";
          breakWindowTitlePrefix = "SafeEyes-";
        }
      ]
    else
      [ ];

  common = import ../common/variables.nix {
    inherit
      commonHostVars
      hostVars
      lib
      pkgs
      protectedCloseApps
      username
      ;
  };

  # Place each break on its own output. The event-driven focus guard moves it
  # to that output's active workspace and refocuses it if another window gets
  # focus, including another window on the same workspace.
  protectedBreakRules = lib.concatMap (
    app:
    lib.imap0 (idx: outputName: {
      match._props = {
        app-id._raw = ''r#"(?i)${lib.replaceStrings [ "." ] [ "\\." ] app.appId}"#'';
        title._raw = ''r#"(?i)${lib.escapeRegex "${app.breakWindowTitlePrefix}${toString idx}"}"#'';
      };
      open-on-output = outputName;
      open-focused = true;
      open-fullscreen = true;
    }) hostVars.orderedOutputs
  ) (lib.filter (app: app ? breakWindowTitlePrefix) protectedCloseApps);
in
common
// rec {
  extraGroups = [
    "input" # Needed for Activity Watch / ActivityWatch / AW / aw (just so if I ever search it comes up in any form lol)
  ];

  niri = common.niri // {
    spawn-sh-at-startup = "$HOME/.local/bin/startup.sh \"${builtins.elemAt hostVars.orderedOutputs 0}\" \"${builtins.elemAt hostVars.orderedOutputs 1}\"";

    binds = common.niri.binds // {
      "Mod+1" = {
        _props = {
          hotkey-overlay-title = "Focus monitor left (also with left arrow and Mod+Alt+H)";
          allow-inhibiting = false;
        };
        focus-monitor-left = [ ];
      };
      "Mod+2" = {
        _props = {
          hotkey-overlay-title = null;
          allow-inhibiting = false;
        };
        focus-monitor-right = [ ];
      };
      "Mod+Alt+H" = {
        _props = {
          hotkey-overlay-title = null;
          allow-inhibiting = false;
        };
        focus-monitor-left = [ ];
      };
      "Mod+Alt+Left" = {
        _props = {
          hotkey-overlay-title = null;
          allow-inhibiting = false;
        };
        focus-monitor-left = [ ];
      };
      "Mod+Alt+L" = {
        _props = {
          hotkey-overlay-title = null;
          allow-inhibiting = false;
        };
        focus-monitor-right = [ ];
      };
      "Mod+Alt+Right" = {
        _props = {
          hotkey-overlay-title = null;
          allow-inhibiting = false;
        };
        focus-monitor-right = [ ];
      };
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

      "Mod+Ctrl+1" = {
        _props = {
          hotkey-overlay-title = null;
          allow-inhibiting = false;
        };
        spawn = [ "/home/${username}/.local/bin/1-niri.sh" ];
      };
      "Mod+Ctrl+2" = {
        _props = {
          hotkey-overlay-title = null;
          allow-inhibiting = false;
        };
        spawn = [ "/home/${username}/.local/bin/2-niri.sh" ];
      };
      "Mod+Ctrl+3" = {
        _props = {
          hotkey-overlay-title = null;
          allow-inhibiting = false;
        };
        spawn = [ "/home/${username}/.local/bin/3-niri.sh" ];
      };
      "Mod+Ctrl+4" = {
        _props = {
          hotkey-overlay-title = null;
          allow-inhibiting = false;
        };
        spawn = [ "/home/${username}/.local/bin/4-niri.sh" ];
      };
    };

    window-rules =
      (common.niri.window-rules or [ ])
      ++ [
        # at-startup rules: place apps on correct monitor/workspace during niri's
        # first 60s. These only apply at startup so later launches aren't affected.
        {
          match._props = {
            app-id._raw = ''r#"(?i)zen-beta"#'';
            at-startup = true;
          };
          open-on-output = "HDMI-A-2";
          open-on-workspace = "1";
          open-focused = false;
        }
        {
          match._props = {
            app-id._raw = ''r#"(?i)anki"#'';
            at-startup = true;
          };
          open-on-output = "HDMI-A-2";
          open-on-workspace = "2";
          open-focused = false;
          open-maximized = true;
        }
        {
          match._props = {
            app-id._raw = ''r#"(?i)anytype"#'';
            at-startup = true;
          };
          open-on-output = "DP-1";
          open-on-workspace = "5";
          open-focused = false;
          open-maximized = true;
        }
        {
          match._props = {
            app-id._raw = ''r#"(?i)ferdium"#'';
            at-startup = true;
          };
          open-on-output = "DP-1";
          open-on-workspace = "6";
          open-focused = false;
          open-maximized = true;
        }

        # Other
        {
          # Cus sometimes it doesn't open in 60 seconds or summat idk don't do at-startup
          match._props.app-id._raw = ''r#"(?i)gcr-prompter"#'';
          block-out-from = "screen-capture";
          open-focused = true;
          # open-on-workspace = "1"; # Was annoying because sometimes it opens later on
        }
        {
          # https://www.reddit.com/r/niri/comments/1skrhet/steam_notifications_appear_in_the_center_of_the/
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
      ]
      ++ map (app: {
        match._props = {
          app-id._raw = ''r#"(?i)${lib.replaceStrings [ "." ] [ "\\." ] app.appId}"#'';
          title._raw = ''r#"(?i)${lib.escapeRegex app.mainWindowTitle}"#'';
        };
        open-maximized = true;
      }) (lib.filter (app: app ? mainWindowTitle) protectedCloseApps)
      ++ protectedBreakRules;
  };

  kanata.keyboards = {
    calliope-uk = {
      devices = [ "/dev/input/by-id/usb-LiteOn_Lenovo_Calliope_USB_Keyboard-event-kbd" ];
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
    output = builtins.elemAt hostVars.orderedOutputs 0;
  };

  programs = common.programs // {
    ergonomics = "safeeyes";
    login-manager = "greetd";
    terminal = "ghostty";
    other = common.programs.other ++ [
      "affinity"
      "mute-builtin-speakers"
      "opentabletdriver"
      "steam"
    ];
  };

  stylixTargetsWhitelist = common.stylixTargetsWhitelist ++ [ programs.terminal ];

  shellScripts = common.shellScripts // {
    "focus-focused-monitor" =
      "niri msg action focus-monitor \"${builtins.elemAt hostVars.orderedOutputs 0}\"";
    "focus-second-monitor" =
      "niri msg action focus-monitor \"${builtins.elemAt hostVars.orderedOutputs 1}\"";
    "is-focused-monitor-focused" =
      "niri msg focused-output | grep -q \"${builtins.elemAt hostVars.orderedOutputs 0}\"";
    "is-second-monitor-focused" =
      "niri msg focused-output | grep -q \"${builtins.elemAt hostVars.orderedOutputs 1}\"";
  };
}
