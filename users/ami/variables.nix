{
  hostVars,
  lib,
  pkgs,
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
    # Niri has its own option for this but keep just in case
    # Or tbh just remove...
    dbus-update-activation-environment --systemd --all

    notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Locked" "Polling for keyring unlock..."

    # As all keyring dependent applications are not open yet, the gcr prompt will not show / automatically hide. So, this prompts it with dummy values to cause it to prompt the user via the GUI first. Done this early just to give it as much time to spawn the GUI.
    # Do as early as possible though to give time for the GUI to exist
    # And redirect stdin to /dev/null to avoid it blocking the script if it prompts for input (which is probably why something still hung all my startup stuff...)
    ( secret-tool lookup xdg:schema org.freedesktop.Secret.Generic </dev/null >/dev/null 2>&1 & )

    # Sys-tray apps that don't need keyring unlock
    kdeconnect-indicator & disown
    ktailctl & disown
    niriusd & disown
    safeeyes & disown
    sunsetr & disown

    notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Pre-keyring sys-tray" "Apps spawned"

    # Apps that don't need keyring unlock
    ${startAndManage "zen-beta" "app_id" "zen-beta" focusedMonitor "1"}
    ${startAndManage "anki" "title" "User 1 - Anki" focusedMonitor "2"} # Otherwise it would sometimes just move the syncing window not the actual window which was annoying... tad of a workaround... but it works!
    ${startAndManage "ferdium" "app_id" "ferdium" secondMonitor "2"}

    notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Pre-keyring apps" "Apps spawned"

    # - START AWWW STUFF -

    # Start ze primary background daemon (Default namespace: awww-daemon)
    awww-daemon & disown

    # Start ze special overview background daemon (Custom namespace: awww-daemonoverview)
    awww-daemon --namespace overview & disown

    # Wait till sock is populated
    while [ ! -S "$XDG_RUNTIME_DIR/''${WAYLAND_DISPLAY:-wayland-1}-awww-daemon.sock" ] || [ ! -S "$XDG_RUNTIME_DIR/''${WAYLAND_DISPLAY:-wayland-1}-awww-daemon.overview.sock" ]; do
      sleep 0.01 # Loop efficiently until the sockets are created
    done

    notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "AWWW daemons" "Daemons spawned"

    # Load ze sharp wallpaper into the default daemon surface
    awww img ~/.local/share/wallpaper

    # Load ze pre-blurred wallpaper into the overview daemon surface
    awww img --namespace overview ~/.local/share/wallpaper-blurred

    notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "AWWW wallpaper" "Wallpapers loaded"

    # - END AWWW STUFF -

    niri msg action focus-monitor "${focusedMonitor}"
    niri msg action focus-workspace 1
    nirius focus --app-id gcr-prompter # Thanks to nirius - before it was this behemoth - niri msg action focus-window --id $(niri msg --json windows | jq -r '.[] | select(.app_id == "gcr-prompter") | .id' | head -n 1)

    # Bg process: wait for keyring to be unlocked, then launch apps that depend on the keyring
    (
      notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Locked" "Waiting for keyring to be unlocked..."

      while [ "$(busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/aliases/default org.freedesktop.Secret.Collection Locked 2>/dev/null | awk '{print $2}')" != "false" ]; do
        sleep 0.5
      done

      sleep 1 # Just a tad of a delay to ensure the keyring is fully ready for use

      notify-send -e -a "gcr-prompter" -i "$HOME/.local/share/misc/Seahorse_icon_hicolor.svg" -u low -t 2500 "Keyring Unlocked" "Launching keyring-dependent apps..."

      ${startAndManage "anytype" "app_id" "anytype" secondMonitor "1"}
      ${startAndManage "remmina" "app_id" "org.remmina.Remmina" secondMonitor "3"}
    ) &

    notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 2500 "Post-keyring apps" "Apps spawned"

    # Now wait for all background startAndManage jobs to finish
    wait

    niri msg action focus-monitor "${focusedMonitor}"
    niri msg action focus-workspace 1

    notify-send -e -a "niri" -i "$HOME/.local/share/misc/niri-icon.svg" -u low -t 5000 "Startup complete" "All startup tasks completed"
  '';

  scroll-cooldown-ms = 80; # Cooldown for scroll events (for workspace switching and column focus switching)

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
          caps a    s    d    f    g    h    j    k    l    ;    '    bksl ret
          lsft 102d z    x    c    v    b    n    m    ,    .    /    rsft
          lctl lmet lalt           spc            ralt rmet rctl
        )

        (defalias
          ;; 1 - tap timeout (unit: ms)
          ;; 2 - hold timeout (unit: ms)
          ;; Tap Timeout: 200ms (Double-tap to repeat spaces)
          ;; Hold Timeout: 300ms (Hold to trigger mouse layer)
          spc (tap-hold 200 300 spc (layer-toggle mouse))
          zmin (multi lctl eql)
          zmout (multi lctl min)
        )

        ;; Required virtual keys for modifier stacking and auto release
        (defvirtualkeys
          shift lsft
          ctrl  lctl
          alt   lalt
          meta  lmet
          modifier (multi (on-press release-vkey shift) (on-press release-vkey ctrl) (on-press release-vkey alt) (on-press release-vkey meta))
        )

        ;; Default typing layer
        (deflayer default
          _    _    _    _    _    _    _    _    _    _    _    _    _    _
          _    _    _    _    _    _    _    _    _    _    _    _    _
          _    _    _    _    _    _    _    _    _    _    _    _    _    _
          _    _    _    _    _    _    _    _    _    _    _    _    _
          _    _    _           @spc           _    _    _
        )

        ;; Mouse mode layer (hold space)
        (deflayer mouse
          _    _    _    _    _    _    _    _    _    _    _    _    _    _
          _    (on-press press-vkey meta) (mwheel-left 20 60) (movemouse-accel-up 5 210 1 9) (mwheel-right 20 60) (on-press press-vkey alt) _ @zmin (mwheel-down 30 60) (mwheel-up 30 60) @zmout _ _
          _    (on-press press-vkey shift) (movemouse-accel-left 5 210 1 9) (movemouse-accel-down 5 210 1 9) (movemouse-accel-right 5 210 1 9) (on-press press-vkey ctrl) _ (multi mlft (on-release tap-vkey modifier)) (multi mrgt (on-release tap-vkey modifier)) (layer-toggle mouse-slow) _ _ _ _
          _    _    _    _    _    _    _    (multi mmid (on-release tap-vkey modifier)) pgup pgdn _    _    _
          _    _    _              _              _    _    _
        )

        ;; Slow precision mode layer (hold l in mouse mode)
        (deflayer mouse-slow
          _    _    _    _    _    _    _    _    _    _    _    _    _    _
          _    _    _    (movemouse-up 20 1) _ _ _ _ _ _ _ _ _
          _    _    (movemouse-left 20 1) (movemouse-down 20 1) (movemouse-right 20 1) _ _ _ _ _ _ _ _ _
          _    _    _    _    _    _    _    _    _    _    _    _    _
          _    _    _              _              _    _    _
        )
      '';
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

  shellScripts = {
    # These 3 proudly stolen from https://github.com/MangoCubes/nix/blob/e7fdb3fe51a8dce3c6ce6bc2a9fe8423f276f187/desktop/packages/home/niri.nix#L11 ;p (on a serious note if you ever see this MangoCubes these are really smart 'n useful binds! Thanks sm <3.)
    "killclick" = "kill -9 $(niri msg pick-window | grep PID | tail -n 1 | awk '{print $NF}')";
    "killcurrent" = "kill -9 $(niri msg focused-window | grep PID | tail -n 1 | awk '{print $NF}')";
    "qrscan" = ''selected_area=$(${pkgs.slurp}/bin/slurp) && ${pkgs.grim}/bin/grim -g "$selected_area" - | ${pkgs.zbar}/bin/zbarimg --raw - | wl-copy && ${pkgs.libnotify}/bin/notify-send -e -a ZBar -i "$HOME/.local/share/misc/zbar.200.png" -u low -t 2500 -e "QR Code Captured" "$(wl-paste)"'';
  };
}
