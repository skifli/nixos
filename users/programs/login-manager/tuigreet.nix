{pkgs, ...}: {
  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd '${pkgs.uwsm}/bin/uwsm start ${pkgs.niri}/bin/niri-session' --remember --remember-session";
          user = "greeter";
        };
      };
    };

    displayManager.autoLogin.enable = false;
  };

  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.swaylock = {};

  users.users.greeter = {
    home = pkgs.lib.mkDefault "/var/lib/greetd";
    extraGroups = ["video"];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/greetd 0755 greeter greeter -"
  ];

  environment.systemPackages = [
    pkgs.bibata-cursors
  ];
}
