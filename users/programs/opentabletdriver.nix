{
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      opentabletdriver
    ];
  };

  # Enable OpenTabletDriver
  hardware.opentabletdriver.enable = true;

  systemd.user.services.opentabletdriver = {
    Unit = {
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
  }; # Till https://github.com/OpenTabletDriver/OpenTabletDriver/issues/4885 is resolved

  # Required by OpenTabletDriver
  hardware.uinput.enable = true;
  boot.kernelModules = ["uinput"];
}
