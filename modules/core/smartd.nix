{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    smartmontools # provides `smartctl`
    gsmartcontrol # provides the GTK GUI inspector
  ];

  services.smartd = {
    enable = true;
    autodetect = true; # Automatically monitors NVMe, SSDs, and HDDs

    # Custom smartd rules applied to all detected drives:
    # -a: Monitor all SMART attributes
    # -o on: Enable automatic SMART background testing
    # -S on: Enable automatic saving of SMART attributes
    # -n standby,q: Do NOT wake if sleeping/spun-down
    # -s (S/../.././02|L/../../6/03): Short test daily at 2:00 AM, Long test every Saturday at 3:00 AM
    # -W 4,70,80: Temperature alerts: Report 4°C delta, warn at 70°C, critical at 80°C (for NVMe)
    defaults.autodetected = "-a -o on -S on -n standby,q -s (S/../.././02|L/../../6/03) -W 4,70,80";

    notifications = {
      wall.enable = false; # Disable terminal-wide broadcasting
      systembus-notify.enable = true; # Enable graphical desktop notification
    };
  };
}
