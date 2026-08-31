{
  commonHostVars,
  pkgs,
  username,
  ...
}: let
  programs = {
    compositor = "niri";
    desktop-shell = "wayle";
    display-server = "wayland";
    killer = "earlyoom";
    login-manager = "greetd";

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
    remote-desktop = "freerdp";
    screen-recorder = "gpu-screen-recorder";
    system-monitor = "missioncenter";
    terminal = "ghostty";
    terminal-shell = "zsh";
    visual = "zeditor";
    vpn = "tailscale";

    other = [
      "anki"
      "atuin"
      "aw"
      "kde-connect"
      "nix-direnv"
      "nix-index-database"
      "nix-your-shell"
      "styles"
      "typst"
      "waynav"
      "wl-clip-persist"
      "wshowkeys"
      "ydotool"
    ];
  };
in {
  inherit programs;

  wallpaper = "Berries.JPG";

  # NFS-backed shared state: todo.json, task-scheduler, etc.
  # Both hosts see the same list since it's shared across users too.
  sharedStateDir = "/mnt/Remote-Storage/custom-scripts";

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
      {
        mountPoint = "/mnt/Remote-Storage";
        server = "pifi";
        remotePath = "/media/ami/Remote Storage";
      }
    ];
  };

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

  stylixTargetsWhitelist = with programs; [
    terminal
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

  sessionVariables = {};

  systemdServices = {
    todo-checker = {
      Unit = {
        Description = "Check for due todo reminders";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
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
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
        X-SwitchMethod = "keep-old";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "/home/${username}/.local/bin/todo.sh --startup";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
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
        X-SwitchMethod = "keep-old";
      };
      Timer = {
        OnBootSec = "1m";
        OnUnitActiveSec = "1m";
      };
      Install.WantedBy = ["timers.target"];
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

    "schedule" = builtins.readFile ./scripts/schedule.sh;
    "smart-rebuild" = builtins.readFile ./scripts/smart-rebuild.sh;

    "is-workspace-focused" = "niri msg focused-output | grep -q \"$1\" && niri msg workspaces | grep -A 10 \"$1\" | grep \"^\\s*\\*\" | grep -q \" $2 \"";
  };
}
