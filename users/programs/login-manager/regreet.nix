{
  pkgs,
  userVars,
  ...
}: {
  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.regreet}/bin/regreet";
          user = "greeter";
        };
      };
    };

    displayManager.autoLogin.enable = false;
  };

  environment.etc."greetd/regreet.toml".text = ''
    [background]
    path = "/home/${userVars.username}/.local/share/wallpaper"
    fit = "Cover"

    [GTK]
    application_prefer_dark_theme = true
    cursor_theme_name = "Bibata-Modern-Ice"
    icon_theme_name = "Papirus"
    theme_name = "Adwaita-dark"

    [commands]
    session = "${pkgs.uwsm}/bin/uwsm start ${pkgs.niri}/bin/niri-session"
    user = "${userVars.username}"
  '';

  environment.etc."greetd/regreet.css".text = ''
    window {
      background-size: cover;
      background-position: center;
    }

    frame.background {
      background-color: rgba(0, 0, 0, 0.5);
      border: 1px solid rgba(255, 255, 255, 0.12);
      border-radius: 24px;
      padding: 16px;
    }

    label {
      color: rgba(255, 255, 255, 0.9);
    }

    entry, combobox {
      background-color: rgba(255, 255, 255, 0.1);
      border: 1px solid rgba(255, 255, 255, 0.25);
      border-radius: 10px;
      padding: 6px 10px;
      color: #ffffff;
      caret-color: #ffffff;
    }

    entry:focus, combobox:focus {
      border-color: rgba(255, 255, 255, 0.5);
      background-color: rgba(255, 255, 255, 0.14);
    }

    entry placeholder {
      color: rgba(255, 255, 255, 0.4);
    }

    button.suggested-action {
      background-color: rgba(99, 179, 237, 0.9);
      background-image: none;
      color: #ffffff;
      font-weight: bold;
      border: none;
      border-radius: 10px;
      padding: 8px 24px;
    }

    button.suggested-action:hover {
      background-color: rgba(99, 179, 237, 1.0);
    }

    button:not(.suggested-action):not(.destructive-action) {
      background-color: rgba(255, 255, 255, 0.1);
      color: rgba(255, 255, 255, 0.85);
      border: 1px solid rgba(255, 255, 255, 0.2);
      border-radius: 10px;
      padding: 8px 18px;
    }

    button:not(.suggested-action):not(.destructive-action):hover {
      background-color: rgba(255, 255, 255, 0.18);
    }
  '';

  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.swaylock = {};

  users.users.greeter.home = pkgs.lib.mkDefault "/var/lib/regreet";

  systemd.tmpfiles.rules = [
    "d /var/lib/regreet  0755 greeter greeter -"
    "d /var/log/regreet  0755 greeter greeter -"
  ];

  environment.systemPackages = [
    pkgs.bibata-cursors
  ];
}
