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
    ];
  };

  programs = {
    # Muy core apps
    bar = "waybar";
    compositor = "niri";
    display-server = "wayland";
    idler = "swayidle";
    login-manager = "greetd";
    logout-menu = "wleave";
    notifications = "swaync";
    osd = "swayosd";

    # Kinda core apps
    browser = "zen";
    editor = "hx";
    explorer-tui = "yazi";
    explorer-gui = "nemo";
    launcher = "vicinae";
    prompt = "starship";
    shell = "zsh";
    terminal = "ghostty";
    visual = "zeditor";

    other = [
      "anki"
      "stylix"
      "swaybg"
      "wlsunset"
    ];
  };
}
