{
  commonHostVars,
  hostVars,
  lib,
  pkgs,
  username,
  ...
}: let
  allOutputs = builtins.attrNames hostVars.outputs;

  focusedOutputs =
    builtins.filter (
      name: (hostVars.outputs.${name}.focus-at-startup or false) == true
    )
    allOutputs;

  focusedMonitor =
    if focusedOutputs == []
    then builtins.head allOutputs
    else builtins.head focusedOutputs;

  otherOutputs = builtins.filter (name: name != focusedMonitor) allOutputs;

  secondMonitor =
    if otherOutputs == []
    then focusedMonitor
    else builtins.head otherOutputs;

  # Dynamic SafeEyes window rules based on ze outputs
  safeEyesRules =
    lib.imap0 (idx: outputName: {
      match._props = {
        app-id._raw = ''r#"(?i)io\.github\.slgobinath\.SafeEyes"#'';
        title._raw = ''r#"(?i)SafeEyes-${builtins.toString idx}"#'';
      };
      open-on-output = outputName;
      open-focused = true;
      open-fullscreen = true;
    })
    allOutputs;
in rec {
  # User configuration
  extraGroups = [
    "input" # Needed for Activity Watch / ActivityWatch / AW / aw (just so if I ever search it comes up in any form lol)
  ];
  wallpaper = "Berries.JPG";

  networkMounts = {
    nfsShares = [
      {
        mountPoint = "/mnt/pifi";
        server = "pifi";
        remotePath = "/home/ami";
      }
      {
        mountPoint = "/mnt/Main";
        server = "pifi";
        remotePath = "/media/ami/Main";
      }
    ];
  };

  git = {
    enabled = true;
    name = "skifli";
    email = "121291719+skifli@users.noreply.github.com";
  };

  scroll-cooldown-ms = 80; # Cooldown for scroll events (for workspace switching and column focus switching)

  niri = {
    spawn-sh-at-startup = "$HOME/.local/bin/startup.sh \"${focusedMonitor}\" \"${secondMonitor}\"";

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

        ;; (defvirtualkeys
        ;; )

        (defalias
          ;; 150ms tap timeout, 250ms hold timeout.
          ;; Mouse layer ONLY activates if Space is held longer than 250ms.
          spc (tap-hold 150 250 spc (layer-toggle mouse))

          zmin (multi lctl eql)
          zmout (multi lctl min)

          ;; Toggles virtual key mouse-mode on/off
          ntog (layer-switch mouse-lock)
          nunlock (layer-switch default)
        )

        ;; Default typing layer
        (deflayer default
          _    _    _    _    _    _    _    _    _    _    _    _    _    _
          _    _    _    _    _    _    _    _    _    _    _    _    _
          _    _    _    _    _    _    _    _    _    _    _    _    _
          _    _    _    _    _    _    _    _    _    _    _    _    _
          _    _    _              @spc           _    _    _
        )

        ;; Mouse mode layer (hold space)
        (deflayer mouse
          _    _    _    _    _    _    _    _    _    _    _    _    _    _
          _    lmet (mwheel-left 20 60) (movemouse-accel-up 5 210 1 9) (mwheel-right 20 60) lalt _    @zmin (mwheel-down 30 60) (mwheel-up 30 60) @zmout _    _
          _    lsft (movemouse-accel-left 5 210 1 9) (movemouse-accel-down 5 210 1 9) (movemouse-accel-right 5 210 1 9) lctl _    mlft mrgt (layer-toggle mouse-slow) _    _    _
          _    _    _    _    _    _    _    @ntog mmid pgup pgdn _    _
          _    _    _              _              _    _    _
        )

        (deflayer mouse-lock
          _    _    _    _    _    _    _    _    _    _    _    _    _    _
          _    lmet (mwheel-left 20 60) (movemouse-accel-up 5 210 1 9) (mwheel-right 20 60) lalt _    @zmin (mwheel-down 30 60) (mwheel-up 30 60) @zmout _    _
          _    lsft (movemouse-accel-left 5 210 1 9) (movemouse-accel-down 5 210 1 9) (movemouse-accel-right 5 210 1 9) lctl _    mlft mrgt (layer-toggle mouse-slow) _    _    _
          _    _    _    _    _    _    _    @nunlock mmid pgup pgdn _    _
          _    _    _              _              _    _    _
        )

        ;; Slow precision mode layer (hold l in mouse mode)
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

  zsh = {
    shellGlobalAliases = {
      G = "| grep";
      UUID = "$(uuidgen | tr -d \\n)";
    };
  };

  bar = {
    output = "DP-1";
  };

  programs = {
    # Muy core apps
    # bar = "waybar"; # - Not used anymore in favour of wayle
    compositor = "niri";
    desktop-shell = "wayle";
    display-server = "wayland";
    idler = "swayidle";
    killer = "earlyoom";
    login-manager = "greetd";
    # notifications = "swaync"; # - Not used anymore in favour of wayle
    # osd = "swayosd"; # - Not used anymore in favour of wayle
    # wallpaper = "swaybg"; # - Not used anymore in favour of wayle

    # Kinda core apps
    browsers = [
      "zen-beta"
      "browseros"
    ];
    editor = "hx";
    ergonomics = "safeeyes";
    explorer-tui = "yazi";
    explorer-gui = "dolphin";
    keyboard = "kanata";
    launcher = "vicinae";
    network-mounts = "nfs";
    nightlight = "sunsetr";
    pager = "ov";
    partition-manager = "kde";
    prompt = "starship";
    remote-desktop = "freerdp";
    screen-recorder = "gpu-screen-recorder";
    system-monitor = "missioncenter"; # Future me - look into http://github.com/Kyza/gpuitop
    terminal = "ghostty";
    terminal-shell = "zsh";
    visual = "zeditor";
    vpn = "tailscale";

    other = [
      "affinity"
      "anki"
      "atuin"
      "aw"
      # "discord"
      "kde-connect"
      # "lan-mouse"
      "nix-direnv"
      "nix-index-database"
      "nix-your-shell"
      "opentabletdriver"
      "steam"
      "styles"
      "typst"
      "ydotool"
    ];
  };

  systemdServices = {
    todo-checker = {
      Unit = {
        Description = "Check for due todo reminders";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "/home/${username}/.local/bin/todo.sh --check";
      };
    };

    todo-startup = {
      Unit = {
        Description = "Check and show startup todo reminders";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "/home/${username}/.local/bin/todo.sh --startup";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 10"; # Give enough time for notification daemon to start
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    niri-streamer = {
      Unit = {
        Description = "Niri event streamer";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = "/home/${username}/.local/bin/niri-streamer.sh";
        Restart = "always";
        RestartSec = "2s";
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    task-receiver = {
      Unit = {
        Description = "Task scheduler receiver daemon";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = "/home/${username}/.local/bin/task-receiver.sh";
        Restart = "always";
        RestartSec = "2s";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };

  systemdTimers = {
    todo-checker = {
      Unit = {
        Description = "Timer for todo reminder checker";
      };
      Timer = {
        OnBootSec = "1m";
        OnUnitActiveSec = "1m";
      };
      Install.WantedBy = ["timers.target"];
    };
  };

  inherit focusedMonitor secondMonitor;

  shellScripts = {
    # These 3 proudly stolen from https://github.com/MangoCubes/nix/blob/e7fdb3fe51a8dce3c6ce6bc2a9fe8423f276f187/desktop/packages/home/niri.nix#L11 ;p (on a serious note if you ever see this MangoCubes these are really smart 'n useful binds! Thanks sm <3.)
    "killclick" = "kill -9 $(niri msg pick-window | grep PID | tail -n 1 | awk '{print $NF}')";
    "killcurrent" = "kill -9 $(niri msg focused-window | grep PID | tail -n 1 | awk '{print $NF}')";
    "qrscan" = ''
      selected_area=$(${pkgs.slurp}/bin/slurp)

      if [ -n "$selected_area" ]; then
        if ${pkgs.grim}/bin/grim -g "$selected_area" - | ${pkgs.zbar}/bin/zbarimg --raw - > /tmp/qr_result.txt 2>/dev/null; then
          ${pkgs.wl-clipboard}/bin/wl-copy < /tmp/qr_result.txt
          ${pkgs.libnotify}/bin/notify-send -e -a ZBar -i "$HOME/.local/share/misc/zbar.200.png" -u low -t 2500 -e "QR Code Captured" "$(cat /tmp/qr_result.txt)"
        else
          ${pkgs.libnotify}/bin/notify-send -e -a ZBar  -i "$HOME/.local/share/misc/zbar.200.png" -u normal -t 2500 -e "QR Code Failed" "No valid QR code found in selection."
        fi

        rm -f /tmp/qr_result.txt
      fi
    ''; # Customised a lot from MangoCubes' though!
    # My own but inspired by them lol
    "qrcreate" = ''
      input=$(${pkgs.fuzzel}/bin/fuzzel --dmenu --lines=0 --width=40 \
        --font="${commonHostVars.fonts.sansSerif.name}:size=14" \
        --prompt="QR Code Data: " \
        --background-color=1e1e2eff \
        --text-color=cdd6f4ff \
        --input-color=cdd6f4ff \
        --horizontal-pad=12 \
        --border-radius=10)

      [ -n "$input" ] && ${pkgs.qrencode}/bin/qrencode -o - "$input" | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png && ${pkgs.libnotify}/bin/notify-send -a "QR Gen" -u low -t 2000 "QR Code Generated" "Image copied to clipboard"
    ''; # commonHostVars.fonts.sizes.applications is too small - 14 is best probably

    # Inspired by axlefublr
    "schedule" = builtins.readFile ./scripts/schedule.sh;
    "smart-rebuild" = builtins.readFile ./scripts/smart-rebuild.sh;

    # My own random ones
    "focus-focused-monitor" = "niri msg action focus-monitor \"${focusedMonitor}\"";
    "focus-second-monitor" = "niri msg action focus-monitor \"${secondMonitor}\"";
    "is-focused-monitor-focused" = "niri msg focused-output | grep -q \"${focusedMonitor}\"";
    "is-second-monitor-focused" = "niri msg focused-output | grep -q \"${secondMonitor}\"";
    "is-workspace-focused" = "niri msg focused-output | grep -q \"$1\" && niri msg workspaces | grep -A 10 \"$1\" | grep \"^\\s*\\*\" | grep -q \" $2 \""; # Checks both 1. Is the requested monitor the one that currently has focus, AND 2. Is the requested workspace the active one on that monitor. Because `niri msg workspaces` shows which workspace is active per monitor, but doesn't care which monitor is active, so before it had said race condition.
  };
}
