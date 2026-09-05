{
  commonHostVars,
  hostVars,
  lib,
  pkgs,
  username,
  ...
}:
let
  common = import ../common/variables.nix {
    inherit
      commonHostVars
      hostVars
      lib
      pkgs
      username
      ;
  };
in
common
// rec {
  extraGroups = [
    "input"
  ];

  niri = {
    # Startup apps are launched by the `apps-startup` systemd user service
    # (see user-packages.nix) instead of niri's spawn-sh-at-startup. The niri
    # config read races a slow first-login home-manager activation, so niri
    # perchance starts with a stale config and never spawns the apps. Set to a
    # nothing burger so this field stays a valid string (null breaks config stuff).
    spawn-sh-at-startup = "true";

    binds = {
      "Mod+1" = {
        _props = {
          hotkey-overlay-title = "Focus workspace 1";
          allow-inhibiting = false;
        };
        focus-workspace = [ "1" ];
      };
      "Mod+2" = {
        _props = {
          hotkey-overlay-title = "Focus workspace 2";
          allow-inhibiting = false;
        };
        focus-workspace = [ "2" ];
      };
      "Mod+3" = {
        _props = {
          hotkey-overlay-title = "Focus workspace 3";
          allow-inhibiting = false;
        };
        focus-workspace = [ "3" ];
      };
      "Mod+4" = {
        _props = {
          hotkey-overlay-title = "Focus workspace 4";
          allow-inhibiting = false;
        };
        focus-workspace = [ "4" ];
      };
      "Mod+5" = {
        _props = {
          hotkey-overlay-title = "Focus workspace 5";
          allow-inhibiting = false;
        };
        focus-workspace = [ "5" ];
      };
      "Mod+6" = {
        _props = {
          hotkey-overlay-title = "Focus workspace 6";
          allow-inhibiting = false;
        };
        focus-workspace = [ "6" ];
      };
      "Mod+7" = {
        _props = {
          hotkey-overlay-title = "Focus workspace 7";
          allow-inhibiting = false;
        };
        focus-workspace = [ "7" ];
      };
      "Mod+8" = {
        _props = {
          hotkey-overlay-title = "Focus workspace 8";
          allow-inhibiting = false;
        };
        focus-workspace = [ "8" ];
      };
      "Mod+Alt+H" = {
        _props = {
          hotkey-overlay-title = null;
          allow-inhibiting = false;
        };
        focus-workspace-down = [ ];
      };
      "Mod+Alt+Left" = {
        _props = {
          hotkey-overlay-title = null;
          allow-inhibiting = false;
        };
        focus-workspace-down = [ ];
      };
      "Mod+Alt+L" = {
        _props = {
          hotkey-overlay-title = null;
          allow-inhibiting = false;
        };
        focus-workspace-up = [ ];
      };
      "Mod+Alt+Right" = {
        _props = {
          hotkey-overlay-title = null;
          allow-inhibiting = false;
        };
        focus-workspace-up = [ ];
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
    };

    window-rules = [
      {
        match._props.app-id._raw = ''r#"(?i)gcr-prompter"#'';
        block-out-from = "screen-capture";
        open-focused = true;
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

      {
        match._props.title._raw = ''r#"(?i)anytype"#'';
        open-maximized = true;
      }

      {
        match._props.app-id._raw = ''r#"(?i)ferdium"#'';
        open-maximized = true;
      }

      {
        match._props.app-id._raw = ''r#"(?i)org\.gnome\.Evince"#'';
        open-maximized = true;
      }

      {
        match._props.app-id._raw = ''r#"(?i)com\.wayle\.settings"#'';
        open-maximized = true;
      }

      {
        match._props.app-id._raw = ''r#"(?i)dev\.zed\.Zed"#'';
        open-maximized = true;
      }
    ];
  };

  kanata.keyboards = {
    fydetabduo = {
      devices = [
        "/dev/input/by-path/platform-fc880000.usb-usbv2-0:1.1:1.0-event-kbd"
      ];
      extraDefCfg = "process-unmapped-keys yes";

      # Use https://jtroo.github.io/ to verify
      config = ''
        ;; Fydetab Duo keyboard
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
          _    lmet (mwheel-left 20 60) (movemouse-accel-up 5 400 1 6) (mwheel-right 20 60) lalt _    @zmin (mwheel-down 30 60) (mwheel-up 30 60) @zmout _    _
          _    lsft (movemouse-accel-left 5 400 1 6) (movemouse-accel-down 5 400 1 6) (movemouse-accel-right 5 400 1 6) lctl _    mlft mrgt (layer-toggle mouse-slow) _    _    _
          _    _    _    _    _    _    _    @ntog mmid pgup pgdn _    _
          _    _    _              _              _    _    _
        )

        (deflayer mouse-lock
          _    _    _    _    _    _    _    _    _    _    _    _    _    _
          _    lmet (mwheel-left 20 60) (movemouse-accel-up 5 400 1 6) (mwheel-right 20 60) lalt _    @zmin (mwheel-down 30 60) (mwheel-up 30 60) @zmout _    _
          _    lsft (movemouse-accel-left 5 400 1 6) (movemouse-accel-down 5 400 1 6) (movemouse-accel-right 5 400 1 6) lctl _    mlft mrgt (layer-toggle mouse-slow) _    _    _
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
    output = "DSI-1";
  };

  programs = common.programs // {
    login-manager = "tuigreet";
    terminal = "foot";
    other = common.programs.other ++ [ "qwarp" ];
  };

  stylixTargetsWhitelist = common.stylixTargetsWhitelist ++ [ programs.terminal ];

  shellScripts = common.shellScripts // {
    "focus-focused-monitor" = "niri msg action focus-monitor \"DSI-1\"";
    "is-focused-monitor-focused" = "niri msg focused-output | grep -q \"DSI-1\"";
  };
}
