{ hostVars, ... }:

{
  networking = {
    hostName = hostVars.hostname;
    networkmanager.enable = true;

    /*
      firewall = {
        enable = true;
        allowedTCPPorts = [
          22 # SSH (Secure Shell) - remote access
          80 # HTTP - web traffic
          443 # HTTPS - encrypted web traffic
          0 # Custom application port
        ];
        allowedUDPPorts = [
          0 # Custom application port
        ];
      };
    */
  };
}
