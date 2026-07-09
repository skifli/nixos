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

  # Required by OpenTabletDriver
  hardware.uinput.enable = true;
  boot.kernelModules = [ "uinput" ];
}
