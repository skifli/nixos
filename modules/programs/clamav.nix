{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    clamav
    clamtk
  ];

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
    scanner.enable = true;
  };
}
