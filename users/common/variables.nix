{
  commonHostVars,
  lib,
  pkgs,
  protectedCloseApps ? [ ],
  username,
  ...
}:
let
  programs = {
    compositor = "niri";
    desktop-shell = "wayle";
    display-server = "wayland";
    killer = "earlyoom";
    login-manager = "";

    browsers = [
      "zen-beta"
    ];
    editor = "hx";
    explorer-tui = "yazi";
    explorer-gui = "dolphin";
    idler = "swayidle";
    keyboard = "kanata";
    launcher = "vicinae";
    network-mounts = "nfs";
    nightlight = "sunsetr";
    pager = "ov";
    partition-manager = "kde";
    prompt = "starship";
    remote-desktop = "vnc";
    screen-recorder = "gpu-screen-recorder";
    system-monitor = "missioncenter";
    terminal = "";
    terminal-shell = "zsh";
    visual = "zeditor";
    vpn = "tailscale";

    other = [
      "anki"
      "atuin"
      "aw"
      "default-bluetooth-sink"
      "fuzzel"
      "kde-connect"
      "lumine-capture"
      "nix-direnv"
      "nix-index-database"
      "nix-your-shell"
      "ntfy-notifications"
      "opencode"
      "styles"
      "typst"
      "waynav"
      "wayscriber"
      "wl-clip-persist"
      "wshowkeys"
      "ydotool"
    ];
  };

  protectedCloseGuard = lib.concatMapStringsSep "\n" (app: ''
    if [ "$app_id" = ${lib.escapeShellArg app.appId} ]; then
      ${pkgs.libnotify}/bin/notify-send -a ${lib.escapeShellArg app.name} -i "$HOME/.local/share/misc/${app.icon}" -u low ${lib.escapeShellArg "${app.name} is still active"} ${lib.escapeShellArg app.message}
      exit 0
    fi
  '') protectedCloseApps;
  protectedCloseCheck = lib.optionalString (protectedCloseApps != [ ]) ''
    app_id=$(printf '%s' "$focused" | ${pkgs.jq}/bin/jq -r '.app_id // empty')
    ${protectedCloseGuard}
  '';

in
{
  inherit programs protectedCloseApps;

  wallpaper = "Berries.JPG";

  # NFS-backed shared state: todo.json, task-scheduler, etc.
  # Both hosts see the same list since it's shared across users too.
  sharedStateDir = "/mnt/pifi-data/remote-storage/custom-scripts";

  networkMounts = {
    nfsShares = [
      {
        mountPoint = "/mnt/pifi";
        server = "pifi";
        remotePath = "/home/pili";
      }
      {
        mountPoint = "/mnt/pifi-data";
        server = "pifi";
        remotePath = "/data";
      }
      {
        mountPoint = "/mnt/pifi-media";
        server = "pifi";
        remotePath = "/media";
      }
      {
        mountPoint = "/mnt/pistor";
        server = "pistor";
        remotePath = "/home/castor";
      }
      {
        mountPoint = "/mnt/pistor-archive";
        server = "pistor";
        remotePath = "/archive";
      }
    ];
  };

  niri.window-rules = [
    # Open maximised train
    {
      match._props.app-id._raw = ''r#"(?i)anki"#'';
      open-maximized = true;
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
      # Maximise (in here and not users/programs/compositor/niri/window-rules.nix due to it being zeditor in the file path but that not matching the app-id)
      match._props.app-id._raw = ''r#"(?i)dev\.zed\.Zed"#'';
      open-maximized = true;
    }
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

    # Other
    {
      match._props.app-id._raw = ''r#"(?i)anki"#'';
      match._props.title._raw = ''r#"(?i)Study Deck"#'';
      open-floating = true;
      default-column-width = {
        proportion = 0.65;
      };
      default-window-height = {
        proportion = 0.65;
      };
    }
  ];

  git = {
    enabled = true;
    name = "skifli";
    email = "121291719+skifli@users.noreply.github.com";
  };

  scroll-cooldown-ms = 80;

  zsh = {
    shellGlobalAliases = {
      G = "| grep";
      UUID = "$(uuidgen | tr -d \\n)";
    };
  };

  kdeConnectExcluded = [
    "lenovo-a2016a40"
  ];

  stylixTargetsWhitelist = with programs; [
    "helix"
    "zed"
    explorer-tui
    launcher
    prompt

    "lazygit"
    "btop"
    "mpv"
    "fzf"
    "bat"
    "vivid"
    "swaylock"
    "nixos-icons"
  ];

  sessionVariables = { };

  systemdServices = {
    todo-checker = {
      Unit = {
        Description = "Check for due todo reminders";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        X-SwitchMethod = "keep-old";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "/home/${username}/.local/bin/todo.sh --check";
      };
    };

    todo-startup = {
      Unit = {
        Description = "Check and show startup todo reminders";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        X-SwitchMethod = "keep-old";
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        Environment = "STORAGE_GRACE_SECONDS=30";
        ExecStart = "/home/${username}/.local/bin/todo.sh --startup";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    niri-streamer = {
      Unit = {
        Description = "Niri event streamer";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "/home/${username}/.local/bin/niri-streamer.sh";
        Restart = "always";
        RestartSec = "2s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    task-receiver = {
      Unit = {
        Description = "Task scheduler receiver daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "/home/${username}/.local/bin/task-receiver.sh";
        Restart = "always";
        RestartSec = "2s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Systemd services managing the main and overview wallpaper daemons
    awww-main = {
      Unit = {
        Description = "awww wallpaper daemon (default namespace)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.awww}/bin/awww-daemon";
        ExecStartPost = "${pkgs.bash}/bin/bash -c 'for i in {1..50}; do ${pkgs.awww}/bin/awww img %h/.local/share/wallpaper 2>/dev/null && exit 0 || sleep 0.1; done'";
        Restart = "on-failure";
        RestartSec = "2s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    awww-overview = {
      Unit = {
        Description = "awww wallpaper daemon (overview blurred namespace)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.awww}/bin/awww-daemon --namespace overview";
        ExecStartPost = "${pkgs.bash}/bin/bash -c 'for i in {1..50}; do ${pkgs.awww}/bin/awww img --namespace overview %h/.local/share/wallpaper-blurred 2>/dev/null && exit 0 || sleep 0.1; done'";
        Restart = "on-failure";
        RestartSec = "2s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Minimal GNOME settings daemon plugins for GTK3 live theme reload.
    # gsd-color watches the portal/dconf for color-scheme changes and
    # broadcasts them; gsd-xsettings exports XSETTINGS (Net/ThemeName, etc.)
    # so GTK3 apps pick up the new theme without restart.
    gsd-color = {
      Unit = {
        Description = "GNOME Settings Daemon - Color plugin";
        After = [ "xdg-desktop-portal.service" ];
        Wants = [ "xdg-desktop-portal.service" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.gnome-settings-daemon}/libexec/gsd-color";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # gsd-xsettings disabled: crashes on Wayland (SEGV + "only one xsettings manager").
    # KDE already runs its own xsettings manager. gsd-color is sufficient for
    # GTK3 theme propagation on Wayland via the portal/dconf.
    # gsd-xsettings = {
    #   Unit = {
    #     Description = "GNOME Settings Daemon - XSettings plugin";
    #     After = [ "xdg-desktop-portal.service" ];
    #     Wants = [ "xdg-desktop-portal.service" ];
    #   };
    #   Service = {
    #     Type = "simple";
    #     ExecStart = "${pkgs.gnome-settings-daemon}/libexec/gsd-xsettings";
    #     Restart = "on-failure";
    #   };
    #   Install.WantedBy = [ "graphical-session.target" ];
    # };
  };

  systemdTimers = {
    todo-checker = {
      Unit = {
        Description = "Timer for todo reminder checker";
        X-SwitchMethod = "keep-old";
      };
      Timer = {
        OnBootSec = "1m";
        OnUnitActiveSec = "1m";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };

  historyBlockers = {
    exact = [
      "cd"
      "cd .."
      "cd -"
      "cd ~"
      ".."
      "..."
      "pwd"
      "popd"
      "dirs"
      "z"
      "zi"

      "ls"
      "l"
      "ll"
      "la"
      "eza"
      "tree"

      "c"
      "clear"
      "cls"
      "reset"
      "exit"
      "logout"
      "q"
      "fg"
      "bg"
      "jobs"

      "top"
      "htop"
      "btop"
      "iotop"
      "fastfetch"
      "neofetch"
      "uptime"
      "date"
      "cal"
      "whoami"
      "hostname"
      "uname -a"

      "git status"
      "git s"
      "gs"
      "git diff"
      "git d"
      "gd"
      "git branch"
      "git branch -a"
      "git log --oneline"
      "git log"
      "gl"
      "git stash list"

      "y"
      "f"
      "rgr"
      "blammo"
      "zngp"
      "zngs"
      "zngu"
      "nhdry"
      "nhtest"
      "nhdiff"
      "ov"
    ];

    prefixes = [
      "copyl"
      "secret-tool"
      "agenix"
      "gh auth"
      "bw"
      "pass"
      "ssh-add"
      "which"
      "where"
      "type"
      "man"
      "tldr"
      "less"
      "more"
      "pushd"
      "ov"
      "eza"
    ];

    sensitiveKeywords = [
      "TOKEN"
      "KEY"
      "SECRET"
      "PAT"
      "PASSWORD"
      "AUTH"
    ];
  };

  shellScripts = {
    "close-window-safely" = ''
      focused=$(niri msg -j focused-window 2>/dev/null || true)
      ${protectedCloseCheck}
      niri msg action close-window
    '';
    "killclick" = ''
      picked=$(niri msg pick-window 2>/dev/null || true)
      pid=$(printf '%s\n' "$picked" | ${pkgs.gnused}/bin/sed -n 's/.*PID: *\([0-9][0-9]*\).*/\1/p' | ${pkgs.coreutils}/bin/tail -n 1)
      [ -n "$pid" ] || exit 0
      case "$pid" in *[!0-9]*) exit 0 ;; esac
      ${lib.optionalString (protectedCloseApps != [ ]) ''
        focused=$(niri msg -j windows | ${pkgs.jq}/bin/jq -c --argjson pid "$pid" '[.[] | select(.pid == $pid)][0] // {}')
        ${protectedCloseCheck}
      ''}
      kill -9 "$pid"
    '';
    "killcurrent" = ''
      focused=$(niri msg -j focused-window 2>/dev/null || true)
      pid=$(printf '%s' "$focused" | ${pkgs.jq}/bin/jq -r '.pid // empty')
      ${protectedCloseCheck}
      [ -n "$pid" ] || exit 0
      case "$pid" in *[!0-9]*) exit 0 ;; esac
      kill -9 "$pid"
    '';
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
    '';
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
    '';

    "copyl" = builtins.readFile ./scripts/copyl.sh;
    "pifi-private-open" = builtins.readFile ./scripts/pifi-private-open.sh;
    "pifi-private-close" = builtins.readFile ./scripts/pifi-private-close.sh;
    "pifi-private-menu" = builtins.readFile ./scripts/pifi-private-menu.sh;
    "schedule" = builtins.readFile ./scripts/schedule.sh;
    "smart-rebuild" = builtins.readFile ./scripts/smart-rebuild.sh;
    "toggle-dnd" = builtins.readFile ./scripts/toggle-dnd.sh;

    "is-workspace-focused" =
      "niri msg focused-output | grep -q \"$1\" && niri msg workspaces | grep -A 10 \"$1\" | grep \"^\\s*\\*\" | grep -q \" $2 \"";
  };
}
