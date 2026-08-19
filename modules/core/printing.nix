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

  hardware.printers = lib.mkIf ((hostVars.printers or []) != []) {
    ensurePrinters = hostVars.printers;
    ensureDefaultPrinter = (builtins.head hostVars.printers).name; # Default printer defaults to first printer
  };

  environment.systemPackages = with pkgs; [
    system-config-printer
    cups-filters
  ];
}
