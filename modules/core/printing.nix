{
  hostVars,
  lib,
  pkgs,
  ...
}: {
  services = {
    # Whether to enable ipp-usb, a daemon to turn an USB printer/scanner supporting IPP everywhere (aka AirPrint, WSD, AirScan) into a locally accessible network printer/scanner.
    ipp-usb.enable = true;

    printing = {
      enable = true;
      drivers = with pkgs;
        [
          splix
          gutenprint
          cups-filters
        ]
        ++ (hostVars.printerDrivers or []);
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  # Enable SANE scanner support + driverless AirScan/WSD backend
  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.sane-airscan];
  };

  hardware.printers = lib.mkIf ((hostVars.printers or []) != []) {
    ensurePrinters = hostVars.printers;
    ensureDefaultPrinter = (builtins.head hostVars.printers).name; # Default printer defaults to first printer
  };

  environment.systemPackages = with pkgs; [
    system-config-printer
    cups-filters

    # Scanner utilities and GUI
    sane-backends # Provides scanimage, sane-find-scanner CLI tools
    sane-airscan # CLI discovery tool (airscan-discover)
    kdePackages.skanpage # KDE
  ];

  users.users = lib.genAttrs hostVars.enabledUsers (_username: {
    extraGroups = ["lp" "scanner"];
  });
}
