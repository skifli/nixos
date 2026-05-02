{
  pkgs,
  userVars,
  ...
}:

{
  home-manager.users.${userVars.username} = {
    services.swayosd = {
      enable = true;
    };

    systemd.user.services.swayosd-libinput-backend = {
      Unit = {
        Description = "SwayOSD LibInput backend for listening to certain keys like CapsLock, ScrollLock, VolumeUp, etc.";
        Documentation = [ "https://github.com/ErikReider/SwayOSD" ];
        PartOf = [ "graphical.target" ];
        After = [ "graphical.target" ];
      };

      Service = {
        Type = "dbus";
        BusName = "org.erikreider.swayosd";
        ExecStart = "${pkgs.swayosd}/bin/swayosd-libinput-backend";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical.target" ];
    };
  };
}

