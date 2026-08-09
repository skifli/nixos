{
  hostVars,
  lib,
  ...
}: let
  allOutputs = builtins.attrNames hostVars.outputs;

  focusedOutputs =
    builtins.filter (
      name: hostVars.outputs.${name}.focus-at-startup or false
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

  # Arguments:
  #   cmd:        To run - e.g., ("anki", "anytype").
  #   key:        Target window property JSON filter ("app_id" or "title").
  #   val:        Value string used inside regex match tracking.
  #   target_mon: Specific target monitor string ID (e.g., "DP-1").
  #   target_ws:  Target workspace string indicator.
  startAndManage = cmd: key: val: target_mon: target_ws:
    "(${cmd} & while ! niri msg --json windows | grep -qi '\"${key}\": *\"[^\"]*${val}'; do sleep 0.5; done; "
    + "WIN_ID=$(niri msg --json windows | tr -d '\\n' | sed 's/}/\\n/g' | sed -n '/\"${key}\": *\"[^\"]*${val}/I{s/.*\"id\": *\\([0-9]*\\).*/\\1/p;q}'); "
    + "if [ -n \"$WIN_ID\" ]; then "
    + "niri msg action move-window-to-monitor --id \"$WIN_ID\" \"${target_mon}\"; "
    + "niri msg action move-window-to-workspace \"${target_ws}\" --window-id $WIN_ID; "
    + "fi) &";

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
  extraGroups = [];
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

  # Combine all startup commands into a single script block.
  # Due to the way I've done it it's blocking, except actual app startups use & so the only blocking stuff is the waiting for windows to appear to move them. So do NOT place anything after that wait, unless you want it to be a tad delayed!!!
  startupScript = ''
    dbus-update-activation-environment --systemd --all

    # As all keyring dependent applications are not open yet, the gcr prompt will not show / automatically hide. So, this prompts it with dummy values to cause it to prompt the user via the GUI first. Done this early just to give it as much time to spawn the GUI.
    secret-tool lookup dummy-key dummy-value

    # Sys-tray apps
    kdeconnect-indicator & disown
    ktailctl & disown
    niriusd & disown
    safeeyes & disown
    sunsetr & disown

    # Apps that don't need keyring unlock
    ${startAndManage "zen-beta" "app_id" "zen-beta" focusedMonitor "1"}
    ${startAndManage "User 1 - Anki" "title" "anki" focusedMonitor "2"} # Otherwise it would sometimes just move the syncing window not the actual window which was annoying... tad of a workaround... but it works!
    ${startAndManage "ferdium" "app_id" "ferdium" secondMonitor "2"}

    niri msg action focus-monitor "${focusedMonitor}"
    niri msg action focus-workspace 1
    nirius focus --app-id gcr-prompter # Thanks to nirius - before it was this behemoth - niri msg action focus-window --id $(niri msg --json windows | jq -r '.[] | select(.app_id == "gcr-prompter") | .id' | head -n 1)

    # Bg process: wait for keyring to be unlocked, then launch apps that depend on the keyring
    (
      echo "Waiting for keyring to unlock..."
      while [ "$(busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/aliases/default org.freedesktop.Secret.Collection Locked 2>/dev/null | awk '{print $2}')" != "false" ]; do
        sleep 0.5
      done
      echo "Keyring unlocked - launching keyring-dependent apps..."

      ${startAndManage "anytype" "title" "anytype" secondMonitor "1"}
      ${startAndManage "remmina" "app_id" "org.remmina.Remmina" secondMonitor "3"}
    ) &

    # Now wait for all background startAndManage jobs to finish
    wait

    niri msg action focus-monitor "${focusedMonitor}"
    niri msg action focus-workspace 1
  '';

  scroll-cooldown-ms = 75; # Cooldown for scroll events (for workspace switching and column focus switching)

  niri = {
    # Note the format!
    spawn-sh-at-startup = startupScript;

    window-rules =
      [
        {
          # Cus sometimes it doesn't open in 60 seconds or summat idk don't do at-startup
          match._props.app-id._raw = ''r#"(?i)gcr-prompter"#'';
          open-focused = true;
          open-on-workspace = "1";
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

        # Remmina (remote desktop) - maximize
        {
          match._props.app-id._raw = ''r#"(?i)org\.remmina\.Remmina"#'';
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

        # Mission Center (system monitor) - maximize
        {
          match._props.app-id._raw = ''r#"(?i)io\.missioncenter\.MissionCenter"#'';
          open-maximized = true;
        }

        # Zed editor - maximize
        {
          match._props.app-id._raw = ''r#"(?i)dev\.zed\.Zed"#'';
          open-maximized = true;
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
    launcher = "vicinae";
    network-mounts = "nfs";
    nightlight = "sunsetr";
    partition-manager = "kde";
    prompt = "starship";
    remote-desktop = "remmina";
    screen-recorder = "gpu-screen-recorder";
    system-monitor = "missioncenter"; # Future me - look into http://github.com/Kyza/gpuitop
    terminal = "ghostty";
    terminal-shell = "zsh";
    visual = "zeditor";
    vpn = "tailscale";

    other = [
      "affinity"
      "anki"
      "aw"
      # "discord"
      "kde-connect"
      "lan-mouse"
      "nix-direnv"
      "nix-index-database"
      "opentabletdriver"
      "steam"
      "styles"
      "typst"
    ];
  };
}
