rec {
  # User configuration
  extraGroups = [];
  wallpaper = "Berries.JPG";

  networkMounts = {
    nfsShares = [
      {
        mountPoint = "/mnt/pifi";
        server = "192.168.1.184";
        remotePath = "/home/ami";
      }
      {
        mountPoint = "/mnt/Main";
        server = "192.168.1.184";
        remotePath = "/media/ami/Main";
      }
    ];
  };

  git = {
    enabled = true;
    name = "skifli";
    email = "121291719+skifli@users.noreply.github.com";
  };

  niri = let
    browserStartup = map (browser: {command = [browser];}) programs.browsers;

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
    spawn-at-startup =
      browserStartup
      ++ [
        {command = ["anki"];}
        {command = ["anytype"];}
        # { command = [ "cherry-studio" ]; }
        {command = ["evince"];}
        {command = ["ferdium"];}
        {command = ["kdeconnect-indicator"];}
        {command = ["ktailctl"];}
        {command = ["lan-mouse"];}
        {command = ["remmina"];}
        {
          command = [
            "sh"
            "-c"
            "sleep 10 && safeeyes"
          ];
        }
        # { command = [ "weylus" ]; }
      ];

    window-rules = [
      {
        matches = [
          {
            app-id = "(?i)ferdium";
          }
        ];

        open-on-workspace = "1";
        open-maximized = true;
      }
      {
        matches = browserAppIdMatches;

        open-on-workspace = "2";
        open-maximized = true;
        clip-to-geometry = true;
      }
      {
        matches = [
          {
            app-id = "(?i)anki";
          }
        ];

        open-on-workspace = "3";
        open-maximized = true;
      }
      {
        matches = [
          {
            app-id = "(?i)evince";
          }
        ];

        open-on-workspace = "3";
        open-maximized = true;
      }
      {
        matches = [
          {
            title = "(?i)Anytype";
          }
        ];

        open-on-workspace = "4";
        open-maximized = true;
      }
      {
        matches = [
          {
            app-id = "(?i)anki";
            title = "(?i)Preview";
          }
        ];

        open-on-workspace = "5";
        open-maximized = true;
      }
      {
        matches = [
          {
            app-id = "(?i)org.remmina.Remmina";
          }
          {
            app-id = "(?i)steam";
          }
        ];

        open-on-workspace = "5";
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

        open-on-workspace = "5";
        open-maximized = false;
        open-focused = false;
        default-floating-position = {
          x = 0;
          y = 0;
          relative-to = "bottom-right";
        };
      }
      /*
      {
        matches = [
          {
            app-id = "(?i)weylus";
          }
        ];

        open-on-workspace = "6";
        open-maximized = true;
      }
      */
      {
        matches = [
          {
            title = "(?i)Lan Mouse";
          }
          {
            app-id = "(?i)org.fkoehler.KTailctl";
          }
        ];

        open-on-workspace = "6";
        open-maximized = true;
      }
      {
        matches = [
          {
            title = "(?i)Safe Eyes";
          }
        ];

        open-on-workspace = "6";
        open-maximized = true;
      }
    ];
  };

  waybar = {
    output = "DP-1";
  };

  programs = {
    # Muy core apps
    bar = "waybar";
    compositor = "niri";
    display-server = "wayland";
    idler = "swayidle";
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
    explorer-tui = "yazi";
    explorer-gui = "dolphin";
    launcher = "vicinae";
    network-mounts = "nfs";
    partition-manager = "kde";
    prompt = "starship";
    shell = "zsh";
    system-monitor = "missioncenter";
    terminal = "ghostty";
    visual = "zeditor";
    vpn = "tailscale";

    other = [
      "anki"
      "aw"
      "earlyoom"
      "kde-connect"
      "lan-mouse"
      "nix-direnv"
      "opentabletdriver"
      "safeeyes"
      "steam"
      "styles"
      "typst"
      "wlsunset"
      # "weylus"
      # "winapps"
    ];
  };
}
