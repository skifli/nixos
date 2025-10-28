{
  # User configuration
  extraGroups = [ ];
  wallpaper = "1-0Q3A5252";

  git = {
    enabled = true;
    name = "skifli";
    email = "121291719+skifli@users.noreply.github.com";
  };

  programs = {
    # Muy core apps
    bar = "waybar";
    compositor = "niri";
    display-server = "wayland";
    idler = "swayidle";
    login-manager = "greetd";
    notifications = "swaync";

    # Kinda core apps
    browser = "zen";
    editor = "hx";
    explorer = "yazi";
    launcher = "vicinae";
    prompt = "starship";
    shell = "zsh";
    terminal = "ghostty";

    other = [
      "anki"
      "stylix"
      "swaybg"
      "wlsunset"
    ];
  };
}
