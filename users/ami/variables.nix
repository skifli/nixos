{
  # User configuration
  extraGroups = [ ];
  wallpaper = "1-0Q3A5252";

  git = {
    enabled = true;
    name = "skifli";
    email = "121291719+skifli@users.noreply.github.com";
  };

  niri = {
    spawn-at-startup = [
      { command = [ "anki" ]; }
      { command = [ "anytype" ]; }
      { command = [ "evince" ]; }
      { command = [ "ferdium" ]; }
      { command = [ "kdeconnect-indicator" ]; }
      { command = [ "lan-mouse" ]; }
      { command = [ "remmina" ]; }
      { command = [ "safeeyes" ]; }
      { command = [ "weylus" ]; }
      { command = [ "zen" ]; }
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
        matches = [
          {
            app-id = "(?i)zen";
          }
        ];

        open-on-workspace = "2";
        open-maximized = true;
      }
      {
        matches = [
          {
            app-id = "(?i)anki";
            title = "(?i)Browse";
          }
        ];

        open-on-workspace = "2";
        open-maximized = false;
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
            app-id = "(?i)anytype";
          }
        ];

        open-on-workspace = "4";
        open-maximized = true;
      }
      {
        matches = [
          {
            app-id = "(?i)org.remmina.Remmina";
          }
        ];

        open-on-workspace = "5";
        open-maximized = true;
      }
      {
        matches = [
          {
            app-id = "(?i)weylus";
          }
        ];

        open-on-workspace = "6";
        open-maximized = true;
      }
      {
        matches = [
          {
            title = "(?i)Lan Mouse";
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

    # Kinda core apps
    browser = "zen";
    editor = "hx";
    explorer-tui = "yazi";
    explorer-gui = "dolphin";
    launcher = "vicinae";
    partition-manager = "kde";
    prompt = "starship";
    shell = "zsh";
    system-monitor = "missioncenter";
    terminal = "ghostty";
    visual = "zeditor";

    other = [
      "anki"
      "earlyoom"
      "kde-connect"
      "lan-mouse"
      "nix-direnv"
      "safeeyes"
      "stylix"
      "swaybg"
      "typst"
      "weylus"
      "winapps"
      "wlsunset"
    ];
  };
}
