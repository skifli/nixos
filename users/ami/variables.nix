{
  hostVars,
  lib,
  ...
}: let
  allOutputs = builtins.attrNames hostVars.outputs;

  focusedOutputs =
    builtins.filter (
      name:
        hostVars.outputs.${name}.focus-at-startup or false
    )
    allOutputs;

  focusedMonitor =
    if focusedOutputs == []
    then builtins.head allOutputs
    else builtins.head focusedOutputs;

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
      open-maximized = true;
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

  startupPrograms = [
    "dbus-update-activation-environment --systemd --all"
    "anki"
    "anytype"
    "ferdium"
    "kdeconnect-indicator" # Idk even though it has its own service that never seems to work... future me problem todo a fix!
    "remmina"
    "sleep 10 && safeeyes"
    "zen-beta"
    "sleep 0.5 && niri msg action focus-monitor \"${focusedMonitor}\" && niri msg action focus-workspace 1"
  ];

  scroll-cooldown-ms = 75; # Cooldown for scroll events (for workspace switching and column focus switching)

  niri = let
    browserAppIdMatches =
      builtins.concatMap (
        browser:
          [
            {
              app-id = "(?i)${browser}";
            }
          ]
          # BrowserOS is special (often shows up as chromium-browser)
          ++ (
            if browser == "browseros"
            then [{app-id = "(?i)chromium-browser";}]
            else []
          )
      )
      programs.browsers;
  in {
    spawn-at-startup = map (program: {command = [program];}) startupPrograms;

    window-rules =
      [
        {
          matches = browserAppIdMatches;

          open-on-workspace = "1";
          open-maximized = true;
          clip-to-geometry = true;
        }
        {
          matches = [
            {
              # TODO: Fix me for Kwallet!
              app-id = "(?i)gcr-prompter";
            }
          ];

          open-focused = true;
          open-on-workspace = "1";
        }
        {
          matches = [
            {
              app-id = "(?i)anki";
            }
          ];

          open-on-workspace = "2";
          open-focused = false;
          open-maximized = true;
        }
        {
          matches = [
            {
              title = "(?i)Anytype";
            }
          ];

          open-on-workspace = "3";
          open-focused = false;
          open-maximized = true;
        }
        {
          matches = [
            {
              app-id = "(?i)ferdium";
            }
          ];

          open-on-workspace = "5";
          open-focused = false;
          open-maximized = true;
        }
        {
          matches = [
            {
              app-id = "(?i)org.remmina.Remmina";
            }
          ];

          open-on-workspace = "6";
          open-focused = false;
          open-maximized = true;
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
              app-id = "(?i)org.gnome.Evince";
            }
            {
              app-id = "(?i)com.wayle.settings";
            }
            {
              app-id = "(?i)(?i)io.missioncenter.MissionCenter";
            }
            {
              app-id = "(?i)io.github.slgobinath.SafeEyes";
              title = "(?i)Safe Eyes";
            }
          ];

<<<<<<< HEAD
          open-maximized = true;
        }
      ]
      + safeEyesRules;
=======
        open-maximized = true;
      }
    ] ++ safeEyesRules;
>>>>>>> 3515fc1 (fix(niri): meant ++ not + for concatenation)
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
    nightlight = "wlsunset";
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
