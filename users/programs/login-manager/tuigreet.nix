{ pkgs, ... }: {
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

  # THANKS SM https://github.com/sjcobb2022/nixos-config/blob/main/hosts/common/optional/greetd.nix
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.swaylock = { };

  users.users.greeter = {
    home = pkgs.lib.mkDefault "/var/lib/greetd";
    extraGroups = [ "video" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/greetd 0755 greeter greeter -"
  ];

  environment.systemPackages = [
    pkgs.bibata-cursors
  ];
}
