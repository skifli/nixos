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
      matches = [
        {
          app-id = "(?i)io.github.slgobinath.SafeEyes";
          title = "SafeEyes-${builtins.toString idx}";
        }
      ];
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

    # Sys-tray apps
    kdeconnect-indicator & disown
    ktailctl & disown
    niriusd & disown
    safeeyes & disown
    sunsetr & disown

    # Apps that don't need keyring unlock
    ${startAndManage "zen-beta" "app_id" "zen-beta" focusedMonitor "1"}
    ${startAndManage "anki" "app_id" "anki" focusedMonitor "2"}
    ${startAndManage "ferdium" "app_id" "ferdium" secondMonitor "2"}

    niri msg action focus-monitor "${focusedMonitor}"
    niri msg action focus-workspace 1
    niri msg action focus-window --id $(niri msg --json windows | jq -r '.[] | select(.app_id == "gcr-prompter") | .id' | head -n 1)

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
    spawn-at-startup = [
      {sh = startupScript;}
    ];

    window-rules =
      [
        {
          matches = [
            {
              # TODO: Fix me for Kwallet!
              app-id = "(?i)gcr-prompter";
              at-startup = false; # Cus sometimes it doesn't open in 60 seconds or summat idk
            }
          ];

          open-focused = true;
          open-on-workspace = "1";
        }
        ## https://www.reddit.com/r/niri/comments/1skrhet/steam_notifications_appear_in_the_center_of_the/
        {
          # Do above
          matches = [
            {
              app-id = "(?i)steam";
              title = "(?i)notificationtoasts_\\d+_desktop";
            }
          ];

          open-maximized = false;
          open-focused = false;
          default-floating-position = {
            x = 0;
            y = 0;
            relative-to = "bottom-right";
          };
        }
        {
          matches = [
            {
              app-id = "(?i)anki";
            }
            {
              title = "(?i)Anytype";
            }
            {
              app-id = "(?i)ferdium";
            }
            {
              app-id = "(?i)org.remmina.Remmina";
            }
            {
              app-id = "(?i)ferdium";
            }
            {
              app-id = "(?i)org.gnome.Evince";
            }
            {
              app-id = "(?i)com.wayle.settings";
            }
            {
              app-id = "(?i)io.missioncenter.MissionCenter";
            }
            {
              app-id = "(?i)dev.zed.Zed";
            }
            {
              app-id = "(?i)io.github.slgobinath.SafeEyes";
              title = "(?i)Safe Eyes";
            }
          ];

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
    system-monitor = "missioncenter";
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
