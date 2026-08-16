{
  hostVars,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    smartmontools # provides `smartctl`
    gsmartcontrol # provides the GTK GUI inspector
  ];

  services.smartd = {
    enable = true;
    autodetect = false; # Explicitly defined below

    devices = hostVars.devices;

    notifications = {
      wall.enable = false; # Disable terminal-wide broadcasting
      systembus-notify.enable = true; # Enable graphical desktop notification
    };
  };
}
