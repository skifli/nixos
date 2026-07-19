rec {
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
    "breaktimer"
    "ferdium"
    "kdeconnect-indicator" # Idk even though it has its own service that never seems to work... future me problem todo a fix!
    "remmina"
    "zen-beta"
  ];

  scroll-cooldown-ms = 50; # Cooldown for scroll events (for workspace switching and column focus switching)

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
    spawn-at-startup = builtins.map (program: {command = [program];}) startupPrograms;

    window-rules = [
      {
        matches = browserAppIdMatches;

        open-on-workspace = "1";
        open-maximized = true;
        clip-to-geometry = true;
      }
      {
        matches = [
          {
            app-id = "(?i)anki";
          }
        ];

        open-on-workspace = "2";
        open-maximized = true;
      }
      {
        matches = [
          {
            title = "(?i)Anytype";
          }
        ];

        open-on-workspace = "3";
        open-maximized = true;
      }
      {
        matches = [
          {
            app-id = "(?i)ferdium";
          }
        ];

        open-on-workspace = "5";
        open-maximized = true;
      }
      {
        matches = [
          {
            # TODO: Fix me for Kwallet!
            app-id = "(?i)gcr-prompter";
          }
        ];

        open-on-workspace = "5";
      }
      {
        matches = [
          {
            app-id = "(?i)org.remmina.Remmina";
          }
        ];

        open-on-workspace = "6";
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
    ];
  };

  bar = {
    output = "DP-1";
  };

  programs = {
    # Muy core apps
    bar = "waybar";
    compositor = "niri";
    display-server = "wayland";
    idler = "swayidle";
    killer = "earlyoom";
    login-manager = "greetd";
    notifications = "swaync";
    osd = "swayosd";
    wallpaper = "swaybg";

    # Kinda core apps
    browsers = [
      "zen-beta"
      "browseros"
    ];
    editor = "hx";
    ergonomics = "breaktimer";
    explorer-tui = "yazi";
    explorer-gui = "dolphin";
    launcher = "vicinae";
    network-mounts = "nfs";
    nightlight = "wlsunset";
    partition-manager = "kde";
    prompt = "starship";
    screen-recorder = "gpu-screen-recorder";
    shell = "zsh";
    system-monitor = "missioncenter";
    terminal = "ghostty";
    visual = "zeditor";
    vpn = "tailscale";

    other = [
      "affinity"
      "anki"
      "aw"
      "kde-connect"
      "lan-mouse"
      "nix-direnv"
      "opentabletdriver"
      "steam"
      "styles"
      "typst"
    ];
  };
}
